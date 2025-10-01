pipeline {
    agent any

    triggers {
        // ✅ Trigger ทุกครั้งที่ push หรือ tag (หรือจะใช้ webhook ก็ได้)
        pollSCM('H/2 * * * *')
    }

    tools {
        nodejs "NodeJS-20"   // ต้องตรงกับที่ตั้งค่าใน Jenkins
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

        stage('Deploy Local Container') {
            steps {
                sh '''
                  echo "🚀 Deploying with Docker Compose..."

                  # ปิด container เก่าทั้งหมด
                  docker compose down --remove-orphans

                  # สร้าง image ใหม่
                  docker compose build --no-cache nestapp

                  # รัน container ใหม่
                  docker compose up -d nestapp

                  echo "🔍 Checking if app is healthy..."
                  for i in {1..10}; do
                    if curl -f http://localhost:3005; then
                      echo "✅ App is running!"
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

    post {
        success {
            echo '✅ CI/CD pipeline finished successfully!'
        }
        failure {
            echo '❌ Build/Deploy pipeline failed!'
        }
    }
}
