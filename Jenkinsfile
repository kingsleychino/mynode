pipeline {
    agent any

    environment {
        DOCKER_TAG = "${BUILD_NUMBER}"
        ECR_REPO = "503499294473.dkr.ecr.us-east-1.amazonaws.com/mynode"
        AWS_REGION = "us-east-1"
        ECR_REGISTRY = "503499294473.dkr.ecr.us-east-1.amazonaws.com"
    }

    stages {

        stage('Docker Build') {
            steps {
                sh '''
                docker build -t $ECR_REPO:$DOCKER_TAG .
                docker tag $ECR_REPO:$DOCKER_TAG $ECR_REPO:latest
                '''
            }
        }

        stage('Login & Push to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'
                ]]) {
                    sh '''
                    # Login
                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin $ECR_REGISTRY

                    # Push both tags
                    docker push $ECR_REPO:$DOCKER_TAG
                    docker push $ECR_REPO:latest
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "✅ Image pushed: $ECR_REPO:$DOCKER_TAG and latest"
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}