
pipeline{
	agent any
	tools{
		maven 'Maven'
	}
	parameters{
        booleanParam(name: 'sonar', defaultValue: false, description: 'want to do Sonarqube test')
    }
	environment{
        remoteServer = '192.168.1.6'
    }
	stages{
		stage('Git Checkout'){
			steps{
				git branch: 'dev', url: 'https://github.com/goswami97/mytestappdouble7.git'
				script{
					subject="${currentBuild.projectName} - Build # ${currentBuild.number}"
                    body="<html><body>Hi all,<br><br>CI-CD Pipeline has been initiated.<br><br>Regards,<br>DevOps Team.</body></html>"
                    mail_to="santoshgoswami691@gmail.com"
                    mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
					
					sh '''
                    LATEST_TAG=$(git  describe --tag | awk -F "-" '{print $1}')
                    major=$(echo "$LATEST_TAG" | awk -F "." '{print $1}')
                    minor=$(echo "$LATEST_TAG" | awk -F "." '{print $2}')
                    patch=$(echo "$LATEST_TAG" | awk -F "." '{print $3}')

                    echo "major $major"
                    echo "minor $minor"
                    echo "patch $patch"

                    newpatch=$(expr $patch + 1)
                    echo "new patch $newpatch"

                    new_tag="${major}.${minor}.${newpatch}"
                    echo "the new git tag generated $new_tag"
                    
                    commit_id=$(git log --pretty=oneline|head -1| awk '{print $1}')
                    
                    echo $commit_id > /tmp/commitID
                    echo $new_tag > /tmp/gitTag     
                    '''
				}
			}
			post{
				failure{
					script{
						subject="${currentBuild.projectName} - Build # ${currentBuild.number}"
						body="<html><head></head><body>Hi all,<br><br>Some problem occurred while building code.<br>${build_logs}<br><br>Regards,<br>DevOps Team.</body></html>"
						mail_to="santoshgoswami691@gmail.com"
						mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
						
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
						subject="${currentBuild.projectName} - Build # ${currentBuild.number}"
						body="<html><head></head><body>Hi all,<br><br>Some problem occurred while building code.<br>${build_logs}<br><br>Regards,<br>DevOps Team.</body></html>"
						mail_to="santoshgoswami691@gmail.com"
						mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
						
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
						currentBuild.result = "FAILED"
						def sonar_report = readFile("${workspace}/FdaServerParent/target/sonar/report-task.txt")
						subject= "FDA - Build # ${currentBuild.number} -- Frontend Sonar Test ${currentBuild.result}!"
						body="<html><head></head><body>Hi all,<br><br>Some problem occurred while sonar scanning for frontend.<br>${sonar_report}.<br>Regards,<br>DevOps Team.</body></html>"
						mail_to="santoshgoswami691@gmail.com"
						mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
						
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
						currentBuild.result = "FAILED"
						subject= "FDA - Build # ${currentBuild.number} -- Frontend Build ${currentBuild.result}!"
						body="<html><head></head><body>Hi all,<br><br>Some problem occurred while building Docker image.<br><br>Regards,<br>DevOps Team.</body></html>"
						mail_to="santoshgoswami691@gmail.com"
						mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
						
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
						currentBuild.result = "FAILED"
						subject= "FDA - Build # ${currentBuild.number} -- Frontend Build ${currentBuild.result}!"
						body="<html><head></head><body>Hi all,<br><br>Some problem occurred while sending Docker image to Docker Hub.<br><br>Regards,<br>DevOps Team.</body></html>"
						mail_to="santoshgoswami691@gmail.com"
						mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
						
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
						currentBuild.result = "FAILED"
						subject= "FDA - Build # ${currentBuild.number} -- Frontend Build ${currentBuild.result}!"
						body="<html><head></head><body>Hi all,<br><br>Some problem occurred while Deploying Docker container to Dev server.<br><br>Regards,<br>DevOps Team.</body></html>"
						mail_to="santoshgoswami691@gmail.com"
						mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
						
					}
				}
			}
		}
		stage('Deployment Status'){
			steps{
				script{
					echo "Checking url:- http://$remoteServer:8000/LoginWebApp-1/"
					sleep 30
					withCredentials([string(credentialsId: 'githubAccessToken', variable: 'githubAccessToken')]) {
                        sh '''
                        new_tag=$(cat /tmp/gitTag)
                        status=$(curl -so /dev/null -w '%{response_code}' http://$remoteServer:8000/LoginWebApp-1/) || true
                        if [[ "$status" -eq 200 ]]
                        then
							echo "Deployment Successfull"
                            echo 'SUCCESS' > /tmp/deployment_status
                            git tag "$new_tag"
                            git push https://goswami97:"$githubAccessToken"@github.com/goswami97/testingrepo.git --tags
                        else
                            echo "Deployment Fail"
                            echo 'FAIL' > /tmp/deployment_status
                        fi
                        '''
                    }
					def output=readFile('/tmp/deployment_status').trim()
					if( "$output" == "FAIL"){
						echo "Deployment Fail, Reverting to previos build"
						sh '''
						current_build=`cat /tmp/gitTag`
                        major=$(echo "$current_build" | awk -F "." '{print $1}')
                        minor=$(echo "$current_build" | awk -F "." '{print $2}')
                        patch=$(echo "$current_build" | awk -F "." '{print $3}')
                        oldpatch=$(expr $patch - 1)
						previous_build="${major}.${minor}.${oldpatch}"
        
                        echo "Previous tag $previous_build"

                        cont_ID=$(ssh jnsadmin@$remoteServer 'docker ps -qa --filter name=samplewebapp')
                        ssh jnsadmin@$remoteServer docker rm "${cont_ID}" -f
                        docker -H ssh://jnsadmin@$remoteServer run --name samplewebapp  -d -p 8000:8080 santoshgoswami/samplewebapp:$previous_build                   
						'''
					}else{
						echo "Deployment Success"
						
						def ver=readFile('/tmp/gitTag').trim()
						def msg=readFile('/tmp/commitID').trim()
						
						subject= "FDA - Build # ${currentBuild.number} - DEV Deployment Successful"
                        //body="<html><body>Hi all,<br><br>FDA Container has been deployed on DEV environment.<br>URL: http://$remoteServer:8000/LoginWebApp-1/<br>${msg}<br><br>Regards,<br>DevOps Team.</body></html>"
                        body= "\n FDA Container has been deployed on QA environment. \n\n FDA Container Version: ${ver} \n URL: https://$TEST_APP_NAME_1.azurewebsites.net/AdminPortal/  \n\n URL: https://$TEST_APP_NAME_2.azurewebsites.net/AdminPortal/"
	
						mail_to="santoshgoswami691@gmail.com"
                        mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"

                        subject= "FDA - Build # ${currentBuild.number} -- DEV Revert Request"
                        //body= "<html><head><meta http-equiv=Content-Type content=text/html; charset=utf-8><style>.button{background-color:red;border-color:red;border:2px solid red;padding:10px;text-align:center;}.link{display:block;color:#ffffff;font-size:12px;text-decoration:none; text-transform:uppercase;}</style></head><body><br>In order to revert to previous deployment click on below button.<br><br>Current Deployed FDA Container Version : ${ver}<br><br><table><tr><td class=button><a class=link href=#>Revert</a></td><td></td><td></td></tr></table></body></html>"
                        body= "<html><head><meta http-equiv=Content-Type content=text/html; charset=utf-8><style>.button{background-color:red;border-color:red;border:2px solid red;padding:10px;text-align:center;}.link{display:block;color:#ffffff;font-size:12px;text-decoration:none; text-transform:uppercase;}</style></head><body><br>In order to revert to previous deployment click on below button.<br><br>Current Deployed FDA Container Version : ${ver}<br><br><table><tr><td class=button><a class=link href=https://jenkins-psic.necect.com/job/SA_SaaS_Dev/buildWithParameters?action=testRollback>Revert</a></td><td></td><td></td></tr></table></body></html>"
		
						mail_to="santoshgoswami691@gmail.com"
                        mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
                                                            
                        subject= "FDA - Build # ${currentBuild.number} -- QA Deployment Request"
                        //body= "<html><head><meta http-equiv=Content-Type content=text/html; charset=utf-8><style>.button{background-color:green;border-color:green;border:2px solid green;padding:10px;text-align:center;}.link{display:block;color:#ffffff;font-size:12px;text-decoration:none; text-transform:uppercase;}</style></head><body><br>In order to deploy FDA container on QA environment click on below button.<br><br>FDA Container Version: ${ver}<br><br><table><tr><td class=button><a class=link href=#>Approve</a></td><td></td><td></td></tr></table></body></html>"
                        body= "<html><head><meta http-equiv=Content-Type content=text/html; charset=utf-8><style>.button{background-color:green;border-color:green;border:2px solid green;padding:10px;text-align:center;}.link{display:block;color:#ffffff;font-size:12px;text-decoration:none; text-transform:uppercase;}</style></head><body><br>In order to deploy FDA container on UAT environment click on below button.<br><br>FDA Container Version: ${ver}<br><br><table><tr><td class=button><a class=link href=https://jenkins-psic.necect.com/job/SA_SaaS_Dev/buildWithParameters?action=deployUat>Approve</a></td><td></td><td></td></tr></table></body></html>"
		
						mail_to="santoshgoswami691@gmail.com"
                        mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
                            
                        echo 'Mail Sent'
                        
					}
				}
			}
			post{
				failure{
					script{
						currentBuild.result = "FAILED"
						subject= "FDA - Build # ${currentBuild.number} -- Frontend Build ${currentBuild.result}!"
						body="<html><head></head><body>Hi all,<br><br>Some problem occurred while checking deployment status for DEV environment.<br><br>Regards,<br>DevOps Team.</body></html>"
						mail_to="santoshgoswami691@gmail.com"
						mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
							
					}
				}
			}
		}
		
		
	}
}
