pipeline {
    agent any

    environment {
        TF_VAR_region = "us-east-1"
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
                    credentialsId: 'aws-jenkins-credentials' // using your provided ID
                ]]) {
                    sh '''
                        echo "✅ Verifying AWS credentials..."
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        aws sts get-caller-identity
                    '''
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    dir('terraform-eks-project') {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            export AWS_DEFAULT_REGION=us-east-1

                            terraform init \
                              -backend-config="bucket=mr-ci-cd" \
                              -backend-config="region=us-east-1" \
                              -input=false
                        '''
                    }
                }
            }
        }

        stage('Terraform Format and Validate') {
            steps {
                dir('terraform-eks-project') {
                    sh 'terraform fmt -check && terraform validate'
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
    }

    post {
        failure {
            echo 'Pipeline failed. Please check logs.'
        }
        always {
            cleanWs()
        }
    }
}
