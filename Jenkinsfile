pipeline {
    agent any

    triggers {
        // ✅ Poll SCM ทุก 2 นาที (หรือเปลี่ยนเป็น webhook จะดีกว่า)
        pollSCM('H/2 * * * *')
    }

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

        stage('Lint') {
            steps {
                sh 'pnpm lint'
            }
        }

        stage('Build') {
            steps {
                sh 'pnpm build'
            }
        }

        stage('Test') {
            steps {
                sh 'pnpm test'
            }
        }
        
        stage('Debug Docker Access') {
            steps {
                sh '''
                echo "WHOAMI/ID in pipeline:"
                whoami || true
                id || true
                echo "socket:"
                ls -ln /var/run/docker.sock || true
                docker --version || true
                docker ps || true
                '''
            }
        }

        stage('Deploy Local Container') {
            steps {
                // เปลี่ยนโฟลเดอร์เป็น workspace (ที่มี docker-compose.yml)
                dir("${env.WORKSPACE}") {
                sh '''
                    set -e
                    echo "🚀 Deploying with Docker Compose..."
                    # show where we are and files
                    pwd
                    ls -la

                    # bring down previous
                    docker compose down --remove-orphans || true

                    # build image with logs visible
                    docker compose build --no-cache --progress=plain nestapp

                    # bring up: force recreate to ensure new image used
                    docker compose up -d --force-recreate --no-deps --build nestapp

                    # wait for health
                    for i in $(seq 1 10); do
                    if curl -sSf http://localhost:3005/health; then
                        echo "✅ App is healthy"
                        exit 0
                    fi
                    echo "⏳ Waiting for app..."
                    sleep 3
                    done
                    echo "❌ App failed to start"
                    exit 1
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
