pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repo with Terraform configurations
                git 'https://github.com/rajivsharma92/terraform-caps-project.git'
            }
        }

        stage('Verify Directory Structure') {
            steps {
                // Verify the structure after cloning
                sh 'ls -al'  // Check the top-level files in the repo
                sh 'ls -al terraform-caps-project'  // Navigate inside the folder
                sh 'ls -al terraform-caps-project/terraform-eks-project'  // Ensure we are inside the correct folder
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Check if terraform-eks-project directory exists
                    if (!fileExists('terraform-caps-project/terraform-eks-project/main.tf')) {
                        error("No Terraform configuration found in terraform-caps-project/terraform-eks-project. Please check your repo structure.")
                    }
                }

                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-jenkins-credentials' 
                ]]) {
                    dir('terraform-caps-project/terraform-eks-project') {
                        sh '''
                            echo "Running terraform init..."
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
                    dir('terraform-caps-project/terraform-eks-project') {
                        sh '''
                            echo "Running terraform plan..."
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform plan -var-file=terraform.tfvars -out=tfplan
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
                    dir('terraform-caps-project/terraform-eks-project') {
                        sh '''
                            echo "Fetching Terraform outputs..."
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform output
                        '''
                    }
                }
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed. Please check the logs."
        }
        success {
            echo "Terraform plan completed successfully!"
        }
    }
}
