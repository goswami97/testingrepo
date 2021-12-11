pipeline {

	agent any
	
	
	stages {
		stage('Variable declaration') {
			steps {
				script {
					def leaders_email_dev = 'neha.gupta@india.nec.com, manpreet.singh@india.nec.com'
				}
			}
		}
		
		stage('Git Checkout') {
			steps {
				git branch: 'main', url: 'https://github.com/goswami97/linux.git'
			}
		}
	}
	
	
	
	
	
}
