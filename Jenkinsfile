pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/rajivsharma92/terraform-caps-project.git'
            }
        }

        stage('Locate Terraform Directory') {
            steps {
                script {
                    terraformDir = sh(
                        script: 'find . -type f -name "*.tf" | head -n 1 | xargs dirname',
                        returnStdout: true
                    ).trim()
                    echo "Terraform files located in: ${terraformDir}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    dir(terraformDir) {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh '''
                                terraform init \
                                -backend-config="bucket=mr-ci-cd" \
                                -backend-config="region=${AWS_REGION}" \
                                -input=false
                            '''
                        }
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
                    dir(terraformDir) {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh '''
                                terraform plan \
                                -var-file=terraform.tfvars \
                                -out=tfplan
                            '''
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input "Approve Apply?"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-credentials'
                ]]) {
                    dir(terraformDir) {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh 'terraform apply -auto-approve tfplan'
                        }
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
                    dir(terraformDir) {
                        withEnv(["AWS_DEFAULT_REGION=${AWS_REGION}"]) {
                            sh 'terraform output'
                        }
                    }
                }
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
        cleanup {
            cleanWs()
        }
    }
}
