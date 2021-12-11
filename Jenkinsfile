pipeline {

	agent any
	
	
	stages {
		stage('Variable declaration') {
			steps {
				script {
					def leaders_email_dev = 'neha.gupta@india.nec.com, manpreet.singh@india.nec.com'
					def name = 'Santosh Goswami'
				}
			}
		}
		
		stage('Git Checkout') {
			steps {
				git branch: 'main', url: 'https://github.com/goswami97/linux.git'
			}
		}
		
		stage('Test 1') {
			steps {
				sh echo ${name}
				sh print${name}
				println ${name}
				println "${name}"
			}
		}
	}
	
	
	
	
	
}
