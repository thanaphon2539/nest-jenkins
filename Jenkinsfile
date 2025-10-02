pipeline {
  agent any
  triggers { pollSCM('H/2 * * * *') }
  tools { nodejs "NodeJS-20" }
  environment {
    PNPM_HOME = "$HOME/.local/share/pnpm"
    PATH = "$PNPM_HOME:$PATH"
  }
  stages {
    stage('Checkout') {
      steps { git branch: 'main', url: 'https://github.com/thanaphon2539/nest-jenkins.git' }
    }
    stage('Install Dependencies') {
      steps {
        sh 'corepack enable'
        sh 'pnpm install'
      }
    }
    stage('Lint') { steps { sh 'pnpm lint' } }
    stage('Build') { steps { sh 'pnpm build' } }
    stage('Test') { steps { sh 'pnpm test' } }

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

    stage('Deploy to host via SSH') {
      steps {
        sshagent (credentials: ['jenkins-ssh-key']) {
          sh """
            set -e
            REMOTE_PATH="/Users/fongbeer/path/to/project"
            ssh -o StrictHostKeyChecking=no fongbeer@host.docker.internal \\
              '
                set -e
                cd ${REMOTE_PATH} || exit 1
                git fetch --all
                git reset --hard origin/main
                docker compose pull || true
                docker compose up -d --build --remove-orphans nestapp
              '
          """
        }
      }
    }
  }

  post {
    success { echo '✅ CI/CD pipeline finished successfully!' }
    failure { echo '❌ Build/Deploy pipeline failed!' }
  }
}
