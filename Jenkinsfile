pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'  // Change this to your AWS region
        S3_BUCKET = 'mr-ci-cd'
    }

    options {
        skipDefaultCheckout(true)
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/rajivsharma92/terraform-caps-project.git', branch: 'main'
            }
        }

        stage('Set Up AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    sh 'aws sts get-caller-identity'
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                dir('terraform-eks-project') {
                    sh """
                        terraform init \
                          -backend-config="bucket=${S3_BUCKET}" \
                          -backend-config="region=${AWS_REGION}" \
                          -input=false
                    """
                }
            }
        }

        stage('Terraform Format and Validate') {
            steps {
                dir('terraform-eks-project') {
                    sh 'terraform fmt -check'
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform-eks-project') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform-eks-project') {
                    input message: "Do you want to apply the plan?", ok: "Apply"
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Please check logs.'
        }
        cleanup {
            cleanWs()
        }
    }
}
