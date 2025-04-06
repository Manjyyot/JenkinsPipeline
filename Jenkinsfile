pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'aws-jenkins-credentials'
        ENVIRONMENT = 'test'
        TF_VARS_FILE = 'terraform-eks-project/terraform.tfvars'  // Updated path
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/rajivsharma92/terraform-caps-project.git'
            }
        }

        stage('Check Workspace') {
            steps {
                sh 'ls -R'  // List all files in the workspace to ensure correct paths
            }
        }

        stage('Set Up AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID
                ]]) {
                    sh 'aws sts get-caller-identity'
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                dir('terraform-caps-project/terraform-eks-project') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID
                ]]) {
                    dir('terraform-caps-project/terraform-eks-project') {
                        sh """
                            terraform plan -input=false -var-file=${env.TF_VARS_FILE}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
