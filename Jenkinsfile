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
                    echo "🚀 Force rebuild & redeploy nestapp (using DinD)..."

                    # หยุดและลบ container/service เก่าก่อน
                    docker compose down --remove-orphans || true

                    # build image ใหม่ทุกครั้ง (ไม่ใช้ cache)
                    docker compose build --no-cache nestapp

                    # บังคับ recreate container จาก image ล่าสุด
                    docker compose up -d --force-recreate --no-deps nestapp

                    echo "⏳ Waiting for nestapp health check..."
                    for i in $(seq 1 10); do
                    if curl -sSf http://localhost:3005; then
                        echo "✅ nestapp is healthy"
                        exit 0
                    fi
                    echo "⏳ Waiting..."
                    sleep 3
                    done

                    echo "❌ nestapp failed to start"
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
