pipeline {
    agent any
    
    tools{
        jdk 'jdk17'
        maven 'maven3'
    }
    
    environment{
        
        SCANNER_HOME=tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/srijanga/Petclinic.git'
            }
        }
        
        stage('Compile') {
            steps {
                sh "mvn clean compile"
            }
        }
        
        stage('Test Cases') {
            steps {
                sh "mvn test"
            }
        }
        
        stage('OWASP Scan') {
            steps {
                dependencyCheck additionalArguments: ' --scan ./ ', odcInstallation: 'DC'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage('Trivy FS') {
            steps {
                sh "trivy fs ."
            }
        }
        
        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Petclinic \
                    -Dsonar.projectKey=Petclinic -Dsonar.java.binaries=. '''
                }
            }
        }
        
        stage('Build') {
            steps {
                sh "mvn package"
            }
        }
        
        
        stage('Publish to Nexus') {
           steps {
               configFileProvider([configFile(fileId: '4e9d9fc4-ae06-4c48-8d3b-d2b553c31f9c', variable: 'mavensettings')]) {
                   sh 'mvn -s $mavensettings clean deploy -DskipTests=true'
               }
           }
       }
        
        
        stage('Docker Build, Tag and Push') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker build -t image1 . "
                        sh "docker tag image1 srijanga/pet-clinic123:latest "
                        sh "docker push srijanga/pet-clinic123:latest "
                    }
                }
            }
        }
        
        stage('Trivy ImageScan') {
            steps {
                sh "trivy image srijanga/pet-clinic123:latest"
            }
        }
        
    
        stage('Deploy in Docker Container') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        
                        sh "docker run -d -p 8082:8082 srijanga/pet-clinic123:latest "
                    }
                }
            }
        }
    }
}
