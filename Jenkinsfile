pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'aws-jenkins-credentials'
        ENVIRONMENT = 'test'  // Set the environment to 'test'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/rajivsharma92/terraform-caps-project.git'
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
                    sh '''
                        # Commented out the S3 backend initialization as per the request
                        # terraform init -backend-config=bucket=mr-ci-cd -backend-config=region=us-east-1 -input=false
                        terraform init -input=false
                    '''
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
                            terraform plan -input=false \
                                -var="cidr_block=10.0.0.0/16" \
                                -var="public_subnets=[10.0.1.0/24,10.0.2.0/24]" \
                                -var="private_subnets=[10.0.3.0/24,10.0.4.0/24]" \
                                -var="azs=[us-east-1a,us-east-1b]" \
                                -var="environment=${env.ENVIRONMENT}" \  // Environment is now 'test'
                                -var="cluster_name=eks-cluster"
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
                        sh """
                            terraform apply -input=false -auto-approve \
                                -var="cidr_block=10.0.0.0/16" \
                                -var="public_subnets=[10.0.1.0/24,10.0.2.0/24]" \
                                -var="private_subnets=[10.0.3.0/24,10.0.4.0/24]" \
                                -var="azs=[us-east-1a,us-east-1b]" \
                                -var="environment=${env.ENVIRONMENT}" \  // Environment is now 'test'
                                -var="cluster_name=eks-cluster"
                        """
                    }
                }
            }
        }

        stage('Terraform Output') {
            steps {
                dir('terraform-caps-project/terraform-eks-project') {
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
