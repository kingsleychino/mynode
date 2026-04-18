pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
        string(name: 'WORKSPACE', defaultValue: 'default', description: 'Terraform workspace')
    }

    environment {
        ECR_REPO   = "503499294473.dkr.ecr.us-east-1.amazonaws.com/mynode"
        AWS_REGION = "us-east-1"
        DOCKER_TAG = "${BUILD_NUMBER}"
        TF_DIR     = "terraform"
        TF_COMMON  = "-var-file=${TF_VARS}"
    }

    stages {
        stage('Build & Push') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'
                ]]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION \
                            | docker login --username AWS --password-stdin $ECR_REPO
                        docker build -t $ECR_REPO:$DOCKER_TAG -t $ECR_REPO:latest .
                        docker push $ECR_REPO:$DOCKER_TAG $ECR_REPO:latest
                    '''
                }
            }
        }

        stage('Terraform') {
            steps {
                dir(TF_DIR) {
                    sh """
                        terraform init -input=false
                        terraform workspace select ${params.WORKSPACE} 2>/dev/null \
                            || terraform workspace new ${params.WORKSPACE}
                        terraform plan ${TF_COMMON} -out=tfplan -detailed-exitcode | tee tfplan.txt || true
                    """
                    archiveArtifacts 'tfplan.txt'

                    script {
                        if (params.ACTION != 'plan') {
                            input message: "Approve ${params.ACTION}?", ok: "Proceed",
                                  parameters: [text(name: 'Preview', defaultValue: readFile('tfplan.txt'))]

                            sh params.ACTION == 'apply'
                                ? "terraform apply -auto-approve tfplan"
                                : "terraform destroy ${TF_COMMON} -auto-approve"
                        }
                    }
                }
            }
        }
    }

    post {
        always  { cleanWs() }
        success { echo "✅ Pushed $ECR_REPO:$DOCKER_TAG" }
        failure { echo "❌ Pipeline failed!" }
    }
}