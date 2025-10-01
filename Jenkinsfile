pipeline {
    agent any

    triggers {
        // ✅ Trigger เวลา push commit หรือ tag (ถ้าใช้ GitHub/GitLab ให้ตั้ง webhook)
        pollSCM('H/5 * * * *')
    }

    tools {
    nodejs "NodeJS-20"   // ชื่อต้องตรงกับที่ตั้งใน Jenkins
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

        stage('Deploy Local Simulation') {
            steps {
                sh '''
                  echo "🚀 Start app simulation..."
                  nohup pnpm start:prod > app.log 2>&1 &
                  sleep 5
                  curl -f http://localhost:3005 || echo "⚠️ App not responding"
                '''
            }
        }

        stage('Deploy Only On Tag') {
            when {
                buildingTag()
            }
            steps {
                echo "📦 Deploying release tag ${env.GIT_TAG}"
            }
        }
    }

    post {
        success {
            echo '✅ Build success!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
