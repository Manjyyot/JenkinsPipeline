pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/rajivsharma92/terraform-caps-project.git', branch: 'main'
            }
        }

        stage('Locate Terraform Directory') {
            steps {
                script {
                    def tfDir = sh(script: "find . -type f -name '*.tf' | head -n 1 | xargs dirname", returnStdout: true).trim()
                    if (!tfDir) {
                        error("No Terraform files found in repository.")
                    }
                    env.TERRAFORM_DIR = tfDir
                    echo "Terraform files located in directory: ${env.TERRAFORM_DIR}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir("${env.TERRAFORM_DIR}") {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh 'terraform init -backend-config="bucket=mr-ci-cd" -backend-config="region=us-east-1" -input=false'
                        }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir("${env.TERRAFORM_DIR}") {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir("${env.TERRAFORM_DIR}") {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Output') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir("${env.TERRAFORM_DIR}") {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh 'terraform output'
                        }
                    }
                }
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}
