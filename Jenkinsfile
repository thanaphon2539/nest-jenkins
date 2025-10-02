pipeline {
    agent any

    tools {
        nodejs "NodeJS-20"
    }

    environment {
        PNPM_HOME = "$HOME/.local/share/pnpm"
        PATH = "$PNPM_HOME:$PATH"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/thanaphon2539/nest-jenkins.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'corepack enable'
                sh 'pnpm install'
            }
        }

        stage('Build') {
            steps {
                sh 'pnpm build'
            }
        }

        stage('Test Docker Connection') {
            steps {
                sh '''
                echo "🔍 Testing Docker-in-Docker connection..."
                docker version
                docker info
                docker ps -a
                '''
            }
        }

        stage('Deploy Local Container') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh '''
                    echo "🚀 Clean up old container if exists..."
                    docker rm -f nestapp || true

                    echo "🚀 Force rebuild & redeploy nestapp..."
                    docker compose down --remove-orphans || true
                    docker compose up -d --build nestapp
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD pipeline finished successfully!'
        }
        failure {
            echo '❌ Build/Deploy pipeline failed!'
        }
    }
}
