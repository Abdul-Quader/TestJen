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


    }
}