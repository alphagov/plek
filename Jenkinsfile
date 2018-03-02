#!/usr/bin/env groovy

library("govuk")

REPOSITORY = 'plek'

node {

  try {
    stage('Checkout') {
      checkout scm
    }

    stage('Clean') {
      govuk.cleanupGit()
      govuk.mergeMasterBranch()
    }

    stage("Build") {
      sh "${WORKSPACE}/jenkins.sh"
    }

    if (env.BRANCH_NAME == 'master') {
      stage("Publish gem") {
        govuk.publishGem(REPOSITORY, env.BRANCH_NAME)
      }
    }
  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
