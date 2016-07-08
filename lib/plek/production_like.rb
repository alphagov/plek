class Plek
  ##
  # Affordance methods for telling what type of environment we're in.
  # Allows us to do things like test pre-production code in integration
  # or tell what kind of environment we're in when we're not in a Rails app
  module ProductionLike
    def environment
      @environment ||= begin
        match = parent_domain.match('^(?<env_name>.+?)\.')

        case match[:env_name]
        when 'dev', nil
          :development
        else
          match[:env_name].to_sym
        end
      end
    end

    def production_like?
      [:integration, :staging, :production].include?(environment)
    end

    %w(development integration staging production).each do |env|
      define_method "#{env}?".to_sym do
        self.environment == env.to_sym
      end
    end
  end
end
