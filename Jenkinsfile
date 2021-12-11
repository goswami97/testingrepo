pipeline {

	agent any
	
	environment {
		name = "Santosh Goswami"
	}
	
	
	stages {
		
		stage('Git Checkout') {
			steps {
				git branch: 'main', url: 'https://github.com/goswami97/linux.git'
			}
		}
		
		stage('Test 1') {
			steps {
				echo "${name}"
			}
		}
	}
	
	
	
	
	
}
