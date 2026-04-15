pipeline {
    agent any

    stages {
        stage('Test AWS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'
                ]]) {
                    sh '''
                    aws sts get-caller-identity
                    '''
                }
                echo 'Logged in Successfully'
            }
        }
    }
}