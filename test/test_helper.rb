require "simplecov"
SimpleCov.start

require "minitest/autorun"
require "climate_control"

$LOAD_PATH.unshift("../lib")
require "plek"
require "uri"
