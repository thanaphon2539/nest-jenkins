pipeline {
    agent any

    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['dev', 'sit'],
            description: 'เลือก environment ที่ต้องการ deploy'
        )
        gitParameter(
            name: 'TAG_NAME',
            type: 'PT_TAG',
            defaultValue: 'v1.0.0',
            description: 'เลือก Git Tag ที่ต้องการ deploy',
            sortMode: 'DESCENDING_SMART',
            useRepository: 'https://github.com/thanaphon2539/nest-jenkins.git'
        )
    }

    environment {
        PNPM_HOME = "$HOME/.local/share/pnpm"
        PATH = "$PNPM_HOME:$PATH"
        APP_VERSION = "${params.TAG_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "refs/tags/${params.TAG_NAME}"]],
                    userRemoteConfigs: [[url: 'https://github.com/thanaphon2539/nest-jenkins.git']]
                ])
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                export PATH=$PNPM_HOME:$PATH
                corepack enable
                corepack prepare pnpm@latest --activate
                npm install -g pnpm
                pnpm install
                '''
            }
        }

        stage('Build') {
            steps {
                sh 'pnpm build'
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    def containerName = "nestapp-${params.DEPLOY_ENV}"
                    def portMap = [
                        dev: "7790:3005",
                        sit: "7791:3005",
                    ]
                    def port = portMap[params.DEPLOY_ENV]

                    sh """
                    echo "🚀 Deploying ${containerName} with image version ${APP_VERSION}"
                    docker rm -f ${containerName} || true
                    docker build -t ${containerName}:${APP_VERSION} .
                    docker run -d --name ${containerName} -p ${port} ${containerName}:${APP_VERSION}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deploy สำเร็จ → Env=${params.DEPLOY_ENV}, Tag=${params.TAG_NAME}"
        }
        failure {
            echo "❌ Deploy ล้มเหลว"
        }
    }
}
