pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        AWS_CREDENTIALS_ID = "aws-jenkins-credentials"
    }

    stages {
        stage('Checkout') {
            steps {
                deleteDir()  // Clean workspace before checkout
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
        always {
            cleanWs()  // Clean workspace after every run
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}
