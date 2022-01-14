pipeline{
	agent any
	tools{
		maven 'Maven'
	}
	stages{
		stage('Git Checkout'){
			steps{
				git branch: 'dev', url: 'https://github.com/goswami97/testingrepo.git'
				
			}
			post{
				failure{
					script{
						echo 'This is Santosh Goswami'
					}
				}
			}
		}
		stage('Code Build'){
			steps{
				sh '''
				new_tag=$(cat /tmp/gitTag)
				sed -i "s/Login Page/Login Page : $new_tag/g" /var/lib/jenkins/workspace/$JOB_NAME/src/main/webapp/index.jsp
                mvn clean package > /tmp/buildlog
				'''
			}
		}
	}
}
