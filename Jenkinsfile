pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TERRAFORM_DIR = 'terraform-eks-project'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    dir("${TERRAFORM_DIR}") {
                        sh '''
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform init -backend-config="bucket=mr-ci-cd" -backend-config="region=$AWS_REGION" -input=false
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    dir("${TERRAFORM_DIR}") {
                        sh '''
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Approve apply"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    dir("${TERRAFORM_DIR}") {
                        sh '''
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Terraform Output') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    dir("${TERRAFORM_DIR}") {
                        sh '''
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform output
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
        always {
            cleanWs()
        }
    }
}
