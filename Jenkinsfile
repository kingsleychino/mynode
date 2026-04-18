pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
        string(name: 'WORKSPACE', defaultValue: 'default', description: 'Terraform workspace')
    }

    environment {
        TF_DIR   = 'terraform'
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

        stage('Initialize') {
            steps {
                dir("${TF_DIR}") {
                    sh """
                        terraform init
                        terraform workspace select ${params.WORKSPACE} || terraform workspace new ${params.WORKSPACE}
                    """
                }
            }
        }

        stage('Plan') {
            steps {
                dir("${TF_DIR}") {
                    sh "terraform plan -var-file=${TF_VARS} -out=tfplan -detailed-exitcode || true"
                    sh "terraform show -no-color tfplan > tfplan.txt"
                    archiveArtifacts 'tfplan.txt'
                }
            }
        }

        stage('Approval') {
            when { expression { params.ACTION != 'plan' } }
            steps {
                script {
                    def planPreview = readFile("${TF_DIR}/tfplan.txt")
                    input message: "Approve ${params.ACTION}?", ok: "Proceed",
                          parameters: [text(name: 'Preview', defaultValue: planPreview)]
                }
            }
        }

        stage('Execute') {
            when { expression { params.ACTION != 'plan' } }
            steps {
                dir("${TF_DIR}") {
                    script {
                        if (params.ACTION == 'apply') {
                            sh "terraform apply -auto-approve tfplan"
                        } else if (params.ACTION == 'destroy') {
                            sh "terraform destroy -var-file=${TF_VARS} -auto-approve"
                        }
                    }
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