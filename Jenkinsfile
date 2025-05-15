pipeline {
    // agent any
     agent {
        label 'buildertwo'
    }
    environment {
        sonarqube_token = credentials('sonar-secrets-id')
        IMAGE_NAME = "medlamin13956814/updatedproduction"
        IMAGE_TAG = "latest"
    }
    options {
        skipStagesAfterUnstable()
    }
    
     tools {
        maven 'Maven'
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }


         stage('Trivy Security Scan') {
            steps {
                sh '''
                sudo docker run --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v $PWD:/root/reports \
                aquasec/trivy image \
                --format template \
                --template "@/contrib/html.tpl" \
                --exit-code 1 \
                --severity HIGH,CRITICAL \
                 -o /root/reports/trivy-report.html \
                ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Publish Trivy Report') {
            steps {
                publishHTML(target: [
                allowMissing: true,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'trivy-report.html',
                reportName: 'Trivy Security Report',
                alwaysLinkToLastBuild: true
                ])
            }
        }

   stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=simple-java-maven-app -Dsonar.projectName="simple-java-maven-app"'
                }
            }
        }
        //  Optional: Push Docker image to a registry
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-image-id',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | sudo docker login -u "$DOCKER_USER" --password-stdin
                        sudo sudo docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy Docker Image') {
            steps {
                    // sh 'sudo docker run -d --rm -p 9010:80 ${IMAGE_NAME}:${IMAGE_TAG}'
                   //sh 'sudo docker stop ${IMAGE_NAME}:${IMAGE_TAG} || true && docker rm ${IMAGE_NAME}:${IMAGE_TAG} || true docker run -d -p 9010:80 --name ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:${IMAGE_TAG}'
                    sh '''
                    PORT_IN_USE=$(sudo lsof -t -i:9010)
                    if [ -n "$PORT_IN_USE" ]; then
                    echo "Port 9010 in use, stopping process..."
                    sudo kill -9 $PORT_IN_USE || true
                    fi

                    # Alternatively, remove docker containers using port 9010
                    CONTAINER=$(sudo docker ps -q --filter "publish=9010")
                    if [ -n "$CONTAINER" ]; then
                    echo "Docker container using port 9010 found, stopping itt..."
                    sudo docker rm -f $CONTAINER
                    fi

                    sudo docker run -d -p 9010:80 ${IMAGE_NAME}:${IMAGE_TAG}
                    '''

            }
        }

       

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Deliver') { 
            steps {
                sh './jenkins/scripts/deliver.sh' 
            }
        }
    }
}
