pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = "eu-west-1"
    }
    
    stages {
        stage("git clone") {
            steps {
                git 'https://github.com/WojciechCichy/cloudificationpoc.git'
            }
        }
        
        stage("tf init") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'deda889e-fb1b-4a88-9d8d-0d491da9d735', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
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
                withCredentials([usernamePassword(credentialsId: 'deda889e-fb1b-4a88-9d8d-0d491da9d735', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh "terraform plan -out=tfplan -input=false -var aws_access_key_id=${AWS_ACCESS_KEY_ID} -var aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}"
                }
            }
        }
        
        stage("tf apply") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'deda889e-fb1b-4a88-9d8d-0d491da9d735', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh "terraform apply -auto-approve tfplan"
                }
            }
        }
    }
}