pipeline {
    agent any

    parameters {
        gitParameter name: 'TAG_NAME',
            type: 'PT_TAG',
            defaultValue: 'v1.0.0',
            description: 'เลือก tag ที่ต้องการ deploy',
            branch: '',
            sortMode: 'DESCENDING_SMART',
            selectedValue: 'DEFAULT',
            useRepository: 'https://github.com/thanaphon2539/nest-jenkins.git'
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
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "refs/tags/${params.TAG_NAME}"]],
                    userRemoteConfigs: [[url: 'https://github.com/thanaphon2539/nest-jenkins.git']],
                    extensions: [[$class: 'CloneOption', noTags: false, shallow: false]]
                ])
            }
        }


        stage('Install Dependencies') {
            steps {
                sh '''
                corepack enable || true
                pnpm install
                '''
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
                echo "🔍 Testing Docker connection..."
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
                    echo "🚀 Deploying app version ${APP_VERSION} ..."
                    docker rm -f nestapp || true

                    # build image พร้อม tag
                    docker build -t nestapp:${APP_VERSION} .

                    # run ด้วย docker compose (ใช้ image ตาม tag)
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
