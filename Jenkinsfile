pipeline {
    agent any

    environment {
        DOCKER_TAG = "${BUILD_NUMBER}"
        ECR_REPO = "503499294473.dkr.ecr.us-east-1.amazonaws.com/mynode"
        AWS_REGION = "us-east-1"
    }

    stages {
        stage('Login to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin 503499294473.dkr.ecr.us-east-1.amazonaws.com
                    '''
                }
                echo 'Logged in Successfully'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker build -t $ECR_REPO:$DOCKER_TAG .
                '''
            }
        }

        stage('Docker Push') {
            steps {
                sh '''
                docker push $ECR_REPO:$DOCKER_TAG
                '''
            }
        }
    }
}