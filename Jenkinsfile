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
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/thanaphon2539/nest-jenkins.git']],
                    extensions: [
                        [$class: 'CloneOption', noTags: false, shallow: false]
                    ]
                ])
                sh "git fetch --tags"  // 🔑 ดึง tag มาด้วย
            }
        }

        stage('Check Tag') {
            steps {
                script {
                    sh "git fetch --tags"   // ✅ กันเหนียวอีกชั้น
                    def tag = sh(returnStdout: true, script: "git describe --tags --exact-match || true").trim()

                    if (tag == "") {
                        echo "❌ ไม่มี tag -> ข้าม Deploy"
                        env.SKIP_DEPLOY = "true"
                    } else {
                        echo "✅ พบ tag: ${tag}"
                        env.APP_VERSION = tag
                        env.SKIP_DEPLOY = "false"
                    }
                }
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
            when {
                expression { env.SKIP_DEPLOY == "false" }
            }
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
