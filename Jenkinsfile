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
                checkout([$class: 'GitSCM',
                branches: [[name: '*/main']],
                doGenerateSubmoduleConfigurations: false,
                extensions: [[$class: 'WipeWorkspace']],   // เคลียร์ก่อน
                userRemoteConfigs: [[url: 'https://github.com/thanaphon2539/nest-jenkins.git']]
                ])
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
                set -e
                echo "🚀 Deploying with Docker Compose..."

                docker compose down --remove-orphans
                docker compose build --no-cache nestapp
                docker compose up -d nestapp

                echo "🔍 Checking if app is healthy..."
                for i in {1..10}; do
                    if curl -f http://localhost:3005/health; then
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
