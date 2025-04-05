pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    dir('terraform-eks-project') {
                        sh '''
                            echo "🔧 Running terraform init..."
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform init -backend-config="bucket=mr-ci-cd" -backend-config="region=us-east-1" -input=false
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
                    dir('terraform-eks-project') {
                        sh '''
                            echo "📦 Running terraform plan..."
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "🟢 Apply the Terraform plan?"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    dir('terraform-eks-project') {
                        sh '''
                            echo "🚀 Applying terraform plan..."
                            export AWS_DEFAULT_REGION=$AWS_REGION
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed. Please check the logs."
        }
        success {
            echo "✅ Terraform deployed successfully!"
        }
    }
}
