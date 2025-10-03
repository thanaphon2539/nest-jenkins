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

        stage('Deploy Container') {
            steps {
                script {
                    // map environment -> port
                    def portMap = [
                        dev: "7790:3005",
                        sit: "7791:3005"
                    ]
                    def containerName = "nestapp-${params.DEPLOY_ENV}"
                    def port = portMap[params.DEPLOY_ENV]

                    env.APP_VERSION = params.TAG_NAME

                    sh """
                    echo "🚀 Deploying ${containerName} with tag ${APP_VERSION} ..."
                    docker rm -f ${containerName} || true

                    # build image พร้อม tag
                    docker build -t ${containerName}:${APP_VERSION} .

                    # run container ตาม env + port ที่เลือก
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
            echo '❌ Build/Deploy pipeline failed!'
        }
    }
}
