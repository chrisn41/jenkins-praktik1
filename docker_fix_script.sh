pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'python:3.10'
    }

    stages {
        stage('Fix Docker (Auto)') {
            steps {
                script {
                    // Menjalankan script fix Docker
                    sh 'bash docker_fix_script.sh'
                }
            }
        }

        stage('Check Docker') {
            steps {
                script {
                    // Memastikan Docker tersedia
                    sh 'docker --version || (echo "Docker is not installed!" && exit 1)'
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    // Menggunakan Docker untuk install dependencies
                    sh "docker run --rm -v \$(pwd):/app -w /app ${DOCKER_IMAGE} pip install -r requirements.txt"
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    // Menjalankan test dengan Docker
                    sh "docker run --rm -v \$(pwd):/app -w /app ${DOCKER_IMAGE} pytest test_app.py"
                }
            }
        }

        stage('Deploy') {
            when {
                anyOf {
                    branch 'main'
                    branch pattern: 'release/.*', comparator: "REGEXP"
                }
            }
            steps {
                echo "Simulating deploy from branch ${env.BRANCH_NAME}"
            }
        }
    }

    post {
        always {
            script {
                def payload = [
                    content: "${currentBuild.result == 'SUCCESS' ? '✅' : '❌'} Build ${currentBuild.result} on `${env.BRANCH_NAME}`\nURL: ${env.BUILD_URL}"
                ]
                httpRequest(
                    httpMode: 'POST',
                    contentType: 'APPLICATION_JSON',
                    requestBody: groovy.json.JsonOutput.toJson(payload),
                    url: 'https://discord.com/api/webhooks/1371867088154787982/bcbA9YEBOmOba1_Qc1Ih6xswtBGNoXzEeVfeSXCN2xjM_Z4pb-VRI-Omav2ufTVOf5VP'
                )
            }
        }
    }
}
