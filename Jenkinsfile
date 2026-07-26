pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = 'kalash655/todo-app'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Kalash0098/todo-app.git'
            }
        }
        stage('Security Scan - Source Code') {
            steps {
                sh 'pip3 install bandit --break-system-packages'
                sh 'python3 -m bandit -r . -f txt -o bandit-report.txt || true'
                archiveArtifacts artifacts: 'bandit-report.txt'
    }
}
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh "kubectl set image deployment/todo-app todo-app=${IMAGE_NAME}:${env.BUILD_NUMBER} --kubeconfig=/var/lib/jenkins/.kube/config"
                sh "kubectl rollout status deployment/todo-app --kubeconfig=/var/lib/jenkins/.kube/config"
            }
        }
    }
}
