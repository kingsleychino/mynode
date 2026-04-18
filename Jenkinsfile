pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
        string(name: 'WORKSPACE', defaultValue: 'default', description: 'Terraform workspace')
    }

    environment {
        TF_DIR       = 'terraform'
        ECR_REPO     = "503499294473.dkr.ecr.us-east-1.amazonaws.com/mynode"
        AWS_REGION   = "us-east-1"
        DOCKER_TAG   = "${BUILD_NUMBER}"
    }

    stages {
        stage('Docker Build & Push') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'
                ]]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

                        docker build -t $ECR_REPO:$DOCKER_TAG -t $ECR_REPO:latest .
                        docker push $ECR_REPO:$DOCKER_TAG
                        docker push $ECR_REPO:latest
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir(TF_DIR) {
                    sh """
                        terraform init -input=false
                        terraform workspace select ${params.WORKSPACE} || terraform workspace new ${params.WORKSPACE}
                    """
                }
            }
        }

        stage('Plan') {
            steps {
                dir(TF_DIR) {
                    sh "terraform plan -var-file=${TF_VARS} -out=tfplan -detailed-exitcode || true"
                    sh "terraform show -no-color tfplan > tfplan.txt"
                    archiveArtifacts 'tfplan.txt'
                }
            }
        }

        stage('Approval & Execute') {
            when { expression { params.ACTION != 'plan' } }
            steps {
                input message: "Approve ${params.ACTION}?", ok: "Proceed",
                      parameters: [text(name: 'Preview', defaultValue: readFile("${TF_DIR}/tfplan.txt"))]

                dir(TF_DIR) {
                    sh params.ACTION == 'apply'
                        ? "terraform apply -auto-approve tfplan"
                        : "terraform destroy -var-file=${TF_VARS} -auto-approve"
                }
            }
        }
    }

    post {
        always  { cleanWs() }
        success { echo "✅ Pushed: $ECR_REPO:$DOCKER_TAG & latest" }
        failure { echo "❌ Build failed!" }
    }
}