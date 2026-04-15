pipeline {
    agent any

    environment {
        AWS_CREDS = credentials('aws-jenkins-creds')
    }

    stages {
        stage('Test AWS') {
            steps {
                sh '''
                aws sts get-caller-identity \
                  --access-key $AWS_CREDS_USR \
                  --secret-key $AWS_CREDS_PSW
                '''
                echo 'Logged in Successfully'
            }
        }
    }
}
