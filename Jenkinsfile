pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TERRAFORM_DIR = 'terraform-caps-project/terraform-eks-project'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/rajivsharma92/terraform-caps-project.git'
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
                input message: "Approve to apply?"
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
