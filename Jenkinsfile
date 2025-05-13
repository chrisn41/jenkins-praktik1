pipeline {
    agent any

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }
        stage('Run Tests') {
            steps {
                sh 'pytest test_app.py'
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
        success {
            script {
                def payload = [
                    content: "✅ Build SUCCESS on `${env.BRANCH_NAME}`\nURL: ${env.BUILD_URL}"
                ]
                httpRequest(
                    httpMode: 'POST',
                    contentType: 'APPLICATION_JSON',
                    requestBody: groovy.json.JsonOutput.toJson(payload),
                    url: 'https://discord.com/api/webhooks/1371867088154787982/bcbA9YEBOmOba1_Qc1Ih6xswtBGNoXzEeVfeSXCN2xjM_Z4pb-VRI-Omav2ufTVOf5VP'
                )
            }
        }
        failure {
            script {
                def payload = [
                    content: "❌ Build FAILED on `${env.BRANCH_NAME}`\nURL: ${env.BUILD_URL}"
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
