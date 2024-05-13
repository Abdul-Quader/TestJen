pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="992382522294"
        AWS_DEFAULT_REGION= "ap-south-1"
        IMAGE_REPO_NAME="ecr_docker_images"
        IMAGE_TAG="IMAGE_TAG"
        REPOSITORY_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }

    stages {
        stage('Loggin into AWS ECR'){
            steps{
                script{
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                }
            }
        }
        stage('Checkout Code') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Abdul-Quader/TestJen.git']])
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-web-app:${BUILD_NUMBER} .' // Build with build number tag
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    // Retrieve build version from environment variable
                    def buildVersion = "${BUILD_NUMBER}"
                    // Configure AWS credentials and ECR details here
                    sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin <ECR_REPOSITORY_URI>'
                    // Tag image with build version and ECR repository URI
                    sh "docker tag my-web-app:${buildVersion} <REPOSITORY_URI>:${buildVersion}"
                    // Push image to ECR with build version tag
                    sh "docker push <REPOSITORY_URI>:${buildVersion}"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    // Configure AWS credentials (replace with placeholders or use IAM roles)
                    def accessKey = 'YOUR_ACCESS_KEY_ID'
                    def secretKey = 'YOUR_SECRET_ACCESS_KEY'
                    // Retrieve build version from environment variable
                    def buildVersion = "${BUILD_NUMBER}"

                    // Use AWS CLI commands within sh steps
                    sh "aws configure set aws_access_key_id ${accessKey}"
                    sh "aws configure set aws_secret_access_key ${secretKey}"
                    sh "aws configure set region ${AWS_DEFAULT_REGION}"

                    // Login to ECR using AWS CLI
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}"

                    // Pull the latest image from ECR
                    sh "docker pull ${REPOSITORY_URI}:${buildVersion}"

                    // Access EC2 instance using SSH (replace with your details)
                    sh "ssh -i <your_pem_key_file> ubuntu@<EC2_INSTANCE_PUBLIC_IP> docker stop my-web-app || true" // Stop existing container (optional)
                    sh "ssh -i <your_pem_key_file> ubuntu@<EC2_INSTANCE_PUBLIC_IP> docker rm my-web-app || true"   // Remove existing container (optional)
                    sh "ssh -i <your_pem_key_file> ubuntu@<EC2_INSTANCE_PUBLIC_IP> docker run -d -p 80:80 --name my-web-app ${REPOSITORY_URI}:${buildVersion}" // Run the pulled image

                    // Update security group to allow access (temporary for demo)
                    sh "aws ec2 authorize-security-group-ingress --group-id <YOUR_SECURITY_GROUP_ID> --protocol tcp --port 80 --cidr 0.0.0.0/0 || true" // Allow all traffic for demo
                }
            }
        }

        stage('Post-Build Actions') {
            steps {
                // Success message and optional reporting
                script {
                    if (currentBuild.result == 'SUCCESS') {
                        echo 'Pipeline execution successful!'
                    } else {
                        echo 'Pipeline execution failed!'
                    }
                }
            }
        }

        post {
             always {
            emailext body: '''Job Name: ${currentBuild.fullDisplayName} Status: ${currentBuild.result} Build URL: ${env.BUILD_URL}''',
            subject: 'CI/CD Pipeline - Build Status Notification',
            to: 'qureshiabdulquader@gmail.com'
            }
        }
    }
}
