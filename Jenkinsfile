pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TERRAFORM_DIR = 'terraform-caps-project/terraform-eks-project'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/rajivsharma92/terraform-caps-project.git'
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    if (!fileExists("${TERRAFORM_DIR}/main.tf")) {
                        error("No Terraform configuration found in ${TERRAFORM_DIR}. Please check your repo structure.")
                    }
                }

                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-jenkins-credentials' 
                ]]) {
                    dir("${TERRAFORM_DIR}") {
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
                    dir("${TERRAFORM_DIR}") {
                        sh '''
                            echo "Running terraform plan..."
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform plan -var-file=terraform.tfvars -out=tfplan
                        '''
                    }
                }
            }
        }

        // stage('Terraform Apply') {
        //     steps {
        //         input message: "Approve apply step?"
        //         withCredentials([[ 
        //             $class: 'AmazonWebServicesCredentialsBinding', 
        //             credentialsId: 'aws-jenkins-credentials' 
        //         ]]) {
        //             dir("${TERRAFORM_DIR}") {
        //                 sh '''
        //                     echo "Applying Terraform plan..."
        //                     export AWS_DEFAULT_REGION=$AWS_REGION
        //                     terraform apply -auto-approve tfplan
        //                 '''
        //             }
        //         }
        //     }
        // }

        stage('Terraform Output') {
            steps {
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-jenkins-credentials' 
                ]]) {
                    dir("${TERRAFORM_DIR}") {
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
