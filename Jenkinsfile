pipeline {
    agent any

    tools {
        maven 'Maven3'
        jdk 'Java17'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Ziad-Wagih-DevOps/spring-petclinic.git'
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean verify'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=petclinic'
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Push Image to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-docker', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                        echo "$NEXUS_PASS" | docker login localhost:8082 -u "$NEXUS_USER" --password-stdin
                        docker build -t localhost:8083/petclinic-analysis:latest .
                        docker push localhost:8083/petclinic-analysis:latest
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    docker rm -f petclinic || true
                    docker run -d -p 7071:7071 --name petclinic --restart always localhost:8083/petclinic-analysis:latest
                   '''      
            }
        }
    }
}
