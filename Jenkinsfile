pipeline {
    agent any

    stages {
        stage("git clone") {
            steps {
                git 'https://github.com/WojciechCichy/poc.git'
            }
        }
        
        stage("tf init") {
            steps {
                withCredentials([usernamePassword(credentialsId: '9984d9b6-c595-4db1-b67c-e3a3c7f95ce4', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh "terraform init"
                }
            }
        }
        
        stage("tf validate") {
            steps {
                sh "terraform validate"
            }
        }
        
        stage("tf plan") {
            steps {
                withCredentials([usernamePassword(credentialsId: '9984d9b6-c595-4db1-b67c-e3a3c7f95ce4', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh "terraform plan -out=tfplan -input=false -var aws_access_key_id=${AWS_ACCESS_KEY_ID} -var aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}"
                }
            }
        }
        
        stage("approve") {
            steps {
                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        input(id: 'Deploy Gate', message: 'Deploy Terraform?', ok: 'Deploy')
                    }
                }
            }
        }
        
        stage("tf apply") {
            steps {
                withCredentials([usernamePassword(credentialsId: '9984d9b6-c595-4db1-b67c-e3a3c7f95ce4', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh "terraform apply -auto-approve tfplan"
                }
            }
        }
    }
}