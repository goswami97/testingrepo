pipeline{
	agent any
	tools{
		maven 'Maven'
	}
	parameters{
        booleanParam(name: 'sonar', defaultValue: false, description: 'want to do Sonarqube test')
    }
	stages{
		stage('Git Checkout'){
			steps{
				git branch: 'dev', url: 'https://github.com/goswami97/testingrepo.git'
				
			}
			post{
				failure{
					script{
						echo 'This is Checkout stage'
					}
				}
			}
		}
		stage('Code Build'){
			steps{
				sh '''
				new_tag=$(cat /tmp/gitTag)
				sed -i "s/Login Page/Login Page : $new_tag/g" $WORKSPACE/src/main/webapp/index.jsp
                mvn clean package > /tmp/buildlog
				'''
			}
			post{
				failure{
					script{
						echo 'This is Code build stage'
					}
				}
			}
		}
		stage('SonarQube Test'){
			when{
				environment name: 'sonar', value: 'true'
			}
			steps{
				script{
					sh '''
					mvn sonar:sonar \
	                    -Dsonar.projectKey=MyTestProject \
	                    -Dsonar.host.url=http://192.168.1.5:9000/sonarqube \
	                    -Dsonar.login=95dcd3657c25d6e065a0fce11a89849d5210435a
					'''
				}
			}
			post{
				failure{
					script{
						echo 'This is SonarQube stage'
					}
				}
			}
		}
		
		
		
		
	}
}
