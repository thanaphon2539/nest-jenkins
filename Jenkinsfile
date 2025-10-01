pipeline {
    agent any

    environment {
        // ให้ Jenkins ใช้ Docker API ผ่าน TCP แทน socket
        DOCKER_HOST = "tcp://host.docker.internal:2375"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build nestapp image') {
            steps {
                sh '''
                  echo "🐳 Building Docker image for NestJS app..."
                  docker build -t nestapp:latest .
                '''
            }
        }

        stage('Run container') {
            steps {
                sh '''
                  echo "🚀 Starting container..."
                  docker rm -f nestapp || true
                  docker run -d --name nestapp -p 3005:3005 nestapp:latest
                '''
            }
        }

        stage('Verify container') {
            steps {
                sh '''
                  echo "🔍 Checking container health..."
                  sleep 5
                  curl -f http://localhost:3005 || exit 1
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}
