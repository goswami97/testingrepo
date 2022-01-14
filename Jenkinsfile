def remoteServer='192.168.1.6'
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
		stage('Docker Image Build and Tag'){
			steps{
				script{
					withCredentials([usernamePassword(credentialsId: 'dockerCred', passwordVariable: 'dockerPass', usernameVariable: 'dockerID')]) {
                        sh '''
                        new_tag=$(cat /tmp/gitTag)
                        cp $WORKSPACE/target/*.war /home/projectX
                        cd /home/projectX/
                        docker login --username "$dockerID" --password "$dockerPass"
                        docker build -t santoshgoswami/samplewebapp:$new_tag .
                        
                        rm /home/projectX/*.war -f
                        '''   
                    }
				}
			}
			post{
				failure{
					script{
						echo 'This is Docker image build stage'	
					}
				}
			}
		}
		stage('Docker image push to docker hub'){
			steps{
				script{
					sh '''
					new_tag=$(cat /tmp/gitTag)
                    docker push santoshgoswami/samplewebapp:$new_tag
					'''
				}
			}
			post{
				failure{
					script{
						echo 'This is Docker image push stage'	
					}
				}
			}
		}
		stage('Deploy container in Remote server'){
			steps{
				script{
					sh '''
                    new_tag=$(cat /tmp/gitTag)
                    cont_ID=$(ssh jnsadmin@$remoteServer 'docker ps -qa --filter name=samplewebapp')
                    if [[ -z "$cont_ID" ]];
                    then
                        docker -H ssh://jnsadmin@$remoteServer run --name samplewebapp  -d -p 8000:8080 santoshgoswami/samplewebapp:$new_tag       
					else
						ssh jnsadmin@$remoteServer docker rm "${cont_ID}" -f
						docker -H ssh://jnsadmin@$remoteServer run --name samplewebapp  -d -p 8000:8080 santoshgoswami/samplewebapp:$new_tag       
                    
                    fi
					'''
				}
			}
			post{
				failure{
					script{
						echo 'This is Deployment stage'	
					}
				}
			}
		}
		
		
	}
}
