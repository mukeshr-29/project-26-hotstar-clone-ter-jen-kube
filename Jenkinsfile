pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment{
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages{
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('git checkout'){
            steps{
                git 'https://github.com/mukeshr-29/project-26-hotstar-clone-ter-jen-kube.git'
            }
        }
        stage('static code analysis'){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token', installationName:'sonar-server'){
                        sh '''
                            $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=hotstar \
                            -Dsonar.projectName=hotstar
                        '''
                    }
                }
            }
        }
        stage('quality gate'){
            steps{
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('install dependencies'){
            steps{
                sh 'npm install'
            }
        }
        stage('OWASP file SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'dp-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('docker scout file scan'){
            steps{
                script{
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker'){
                        sh 'docker-scout quickview fs://.'
                        sh 'docker-scout cves fs://.'
                    }
                }
            }
        }
        stage('docker build & push'){
            steps{
                script{
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker'){
                        sh 'docker build -t mukeshr29/hotstar-clone:latest .'
                        sh 'docker push mukeshr29/hotstar-clone:latest'
                    }
                }
            }
        }
        stage('docker scout img'){
            steps{
                script{
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker'){
                        sh 'docker-scout quickview mukeshr29/hotstar-clone:latest'
                        sh 'docker-scout cves mukeshr29/hotstar-clone:latest'
                        sh 'docker-scout recommendations mukeshr29/hotstar-clone:latest'
                    }
                }
            }
        }
        stage('trivy img scan'){
            steps{
                sh 'trivy image mukeshr29/hotstar-clone:latest > trivyimg.txt'
            }
        }
        stage('deploy to docker'){
            steps{
                sh 'docker run -d --name hotstarclone -p 3000:3000 mukeshr29/hotstar-clone:latest'
            }
        }
        stage('deploy to k8s'){
            steps{
                script{
                    dir('k8s'){
                        withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: ''){
                            sh 'kubectl apply -f deployment.yml -f service.yml'
                        }
                    }
                }
            }
        }
    }
}