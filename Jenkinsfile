pipeline {
    agent any

    triggers {
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
        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        stage('Prepare Git Safe Directory') {
            steps {
                sh 'git config --global --add safe.directory "*"'
            }
        }

        stage('Fix Workspace Permissions') {
            steps {
                sh 'chown -R root:root $WORKSPACE'
            }
        }

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
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
                dir("${env.WORKSPACE}") {
                    sh '''
                    set -e
                    echo "🚀 Deploying with Docker Compose..."
                    pwd
                    ls -la

                    docker compose down --remove-orphans || true
                    docker compose build --no-cache --progress=plain nestapp
                    docker compose up -d --force-recreate --no-deps --build nestapp

                    for i in $(seq 1 10); do
                      if curl -sSf http://localhost:3005/; then
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
