pipeline {
  agent any

  tools {
    terraform 'terraform'
  }

  environment {
    AWS_ACCESS_KEY_ID     = credentials('aws-secret-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }
 parameters{
        choice(
            choices:['apply','destroy'],
            name:'Actions',
            description: 'Describes the Actions')
    }
  stages {
    stage('Init Provider') {
      steps {
        sh 'terraform init'
      }
    }
    stage('Apply Resources') {
      steps {
        sh "terraform ${params.Actions} -auto-approve"
      }
    }
  }
}
