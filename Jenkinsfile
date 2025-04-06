pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'aws-jenkins-credentials'
        TF_VARS_FILE = 'terraform-eks-project/terraform.tfvars'  // Path to .tfvars file
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository which contains the 'terraform-eks-project' folder
                git 'https://github.com/rajivsharma92/terraform-caps-project.git'
            }
        }

        stage('Check Workspace') {
            steps {
                // List all files recursively to confirm the folder structure
                sh 'ls -R'
            }
        }

        stage('Set Up AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID
                ]]) {
                    // Test the AWS credentials
                    sh 'aws sts get-caller-identity'
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                // Change directory to where the Terraform configuration files are located
                dir('terraform-caps-project/terraform-eks-project') {
                    // Run terraform init
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
                        // Ensure that the terraform.tfvars file exists
                        sh 'ls -l terraform.tfvars'
                        
                        // Run terraform plan with the correct tfvars file
                        sh """
                            terraform plan -input=false -var-file=${env.TF_VARS_FILE}
                        """
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID
                ]]) {
                    dir('terraform-caps-project/terraform-eks-project') {
                        // Run terraform apply with auto-approve
                        sh """
                            terraform apply -input=false -auto-approve -var-file=${env.TF_VARS_FILE}
                        """
                    }
                }
            }
        }

        stage('Terraform Output') {
            steps {
                dir('terraform-caps-project/terraform-eks-project') {
                    // Run terraform output to show outputs
                    sh 'terraform output'
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
