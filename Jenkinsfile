// pipeline {
//     // agent any
//      agent {
//         label 'buildertwo'
//     }
//     options {
//         skipStagesAfterUnstable()
//     }
    
//      tools {
//         maven 'Maven'
//     }

//     stages {
//         stage('Build') {
//             steps {
//                 sh 'mvn -B -DskipTests clean package'
//             }
//         }
//         stage('Test') {
//             steps {
//                 sh 'mvn test'
//             }
//             post {
//                 always {
//                     junit 'target/surefire-reports/*.xml'
//                 }
//             }
//         }
//         stage('Deliver') { 
//             steps {
//                 sh './jenkins/scripts/deliver.sh' 
//             }
//         }
//     }
// }





pipeline {
    agent {
        label 'buildertwo'
    }

    environment {
        sonarqube_token = credentials('sonar-secrets-id')
    }
    
    tools {
        maven 'Maven'
    //    jdk 'JDK11'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=simple-java-maven-app -Dsonar.projectName="simple-java-maven-app"'
                }
            }
        }
        
        //The good things at the end
        // stage('Quality Gate') {
        //     steps {
        //         timeout(time: 1, unit: 'HOURS') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }
        // post {
        //     always {
        //         cleanWs()
        //     }
        // }

    }
}