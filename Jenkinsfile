pipeline {
    agent any

    environment {
        AWS_CREDS = credentials('aws-jenkins-creds')
    }

    stages {
        stage('Test AWS') {
            steps {
                sh '''
                export AWS_ACCESS_KEY_ID=$AWS_CREDS_USR
                export AWS_SECRET_ACCESS_KEY=$AWS_CREDS_PSW

                aws sts get-caller-identity
                '''
                echo 'Logged in Successfully'
            }
        }
    }
}