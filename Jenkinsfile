pipeline {
    agent any

    tools {
        maven 'Maven3'
        jdk 'Java21'
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
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            mvn sonar:sonar \
                            -Dsonar.projectKey=Petclinic \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Push Image to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-docker', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                        echo "$NEXUS_PASS" | docker login localhost:8083 -u "$NEXUS_USER" --password-stdin
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

    post {
        success {
            slackSend channel: '#ci-cd', message: """
            ✅ SUCCESS: Pipeline finished successfully!
            • Job: ${env.JOB_NAME}
            • Build: #${env.BUILD_NUMBER}
            • Duration: ${currentBuild.durationString}
            • URL: ${env.BUILD_URL}
            """
        }
        failure {
            slackSend channel: '#ci-cd', message: """
            ❌ FAILURE: Pipeline failed!
            • Job: ${env.JOB_NAME}
            • Build: #${env.BUILD_NUMBER}
            • Duration: ${currentBuild.durationString}
            • URL: ${env.BUILD_URL}
            """
        }
        unstable {
            slackSend channel: '#ci-cd', message: """
            ⚠️ UNSTABLE: Pipeline unstable.
            • Job: ${env.JOB_NAME}
            • Build: #${env.BUILD_NUMBER}
            • Duration: ${currentBuild.durationString}
            • URL: ${env.BUILD_URL}
            """
        }
    }
}
