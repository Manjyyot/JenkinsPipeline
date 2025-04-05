pipeline {
    agent any

    environment {
        TF_VAR_region = "us-east-1"
        AWS_CREDENTIALS_ID = "aws-jenkins-credentials"
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
                    credentialsId: AWS_CREDENTIALS_ID
                ]]) {
                    sh '''
                        echo "✅ Verifying AWS credentials..."
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
                              -backend-config="region=us-east-1" \
                              -input=false
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform-eks-project') {
                    sh 'terraform plan -input=false'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform-eks-project') {
                    sh 'terraform apply -auto-approve -input=false'
                }
            }
        }

        stage('Terraform Output') {
            steps {
                dir('terraform-eks-project') {
                    sh 'terraform output'
                }
            }
        }
    }

    post {
        failure {
            echo '❌ Pipeline failed. Please check logs.'
        }
        always {
            cleanWs()
        }
    }
}
