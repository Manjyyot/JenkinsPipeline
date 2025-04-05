pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        AWS_CREDENTIALS_ID = "aws-jenkins-credentials"
    }

    options {
        cleanWs()  // Ensure a clean workspace before starting
    }

    stages {
        stage('Checkout') {
            steps {
                deleteDir()  // Fresh start by deleting the workspace
                git url: 'https://github.com/rajivsharma92/terraform-caps-project.git', branch: 'main'
            }
        }

        stage('Set Up AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: AWS_CREDENTIALS_ID
                ]]) {
                    sh '''
                        echo "Verifying AWS credentials..."
                        aws sts get-caller-identity
                    '''
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: AWS_CREDENTIALS_ID
                ]]) {
                    dir('terraform-eks-project') {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                            terraform init \
                              -backend-config="bucket=mr-ci-cd" \
                              -backend-config="region=$AWS_DEFAULT_REGION" \
                              -input=false

                            if [ $? -ne 0 ]; then
                                echo "Terraform initialization failed."
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: AWS_CREDENTIALS_ID
                ]]) {
                    dir('terraform-eks-project') {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                            terraform plan -input=false
                            if [ $? -ne 0 ]; then
                                echo "Terraform plan failed."
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: AWS_CREDENTIALS_ID
                ]]) {
                    dir('terraform-eks-project') {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                            terraform apply -auto-approve -input=false
                            if [ $? -ne 0 ]; then
                                echo "Terraform apply failed."
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }

        stage('Terraform Output') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: AWS_CREDENTIALS_ID
                ]]) {
                    dir('terraform-eks-project') {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                            terraform output
                            if [ $? -ne 0 ]; then
                                echo "Terraform output failed."
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
        always {
            cleanWs()  // Clean workspace after every run
        }
    }
}
