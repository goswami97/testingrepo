pipeline{
    
    agent any
    
    parameters{
        choice(name: 'action', choices: ['deployDev', 'deployTest', 'deployUat'], description: 'Choose environment')
    }
    
    stages{
        
        stage('Git Checkout'){
            steps{
                git branch: 'master', url: 'https://github.com/goswami97/testingrepo.git'
            }
        }
        
        stage('Mail Intemation'){
            steps{
                script{
                    subject= "${currentBuild.projectName} - Build # ${currentBuild.number}"
                    body="<html><body>Hi all,<br><br>CI-CD Pipeline has been initiated.<br><br>Regards,<br>DevOps Team.</body></html>"
				    mail_to = "santoshgoswami691@gmail.com"
				    mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
				
                }		
            }
        }
        
        stage('Git tag'){
            steps{
                script{
                    if("$action" == "deployDev"){
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
                    
		                echo $new_tag > /tmp/buildNo
                        '''
                    }
                }
            }
        }
        
        stage('Code build'){
            steps{
                script{
                    if("$action" == "deployDev"){
                        sh '''
                        mvn clean package
                        new_tag=$(cat /tmp/buildNo)
                        git tag "$new_tag"
		                git push https://goswami97:"$githubAccessToken"@github.com/goswami97/testingrepo.git --tags
                        '''
                    }
                }
            }
        }
        
        stage('Docker Build and Tag'){
            steps{
                script{
                    if("$action" == "deployDev"){
                        sh '''
                        cd /home/projectX/
                        new_tag=$(cat /tmp/buildNo)
                        docker login --username "$dockerid" --password "$dockerpass"
                        docker build -t santoshgoswami/samplewebapp:$new_tag .
                        '''
                    }
                }
            }
        }
        
        stage('Docker image push to docker hub'){
            steps{
                script{
                    if("$action" == "deployDev"){
                        sh '''
                        new_tag=$(cat /tmp/buildNo)
                        docker push santoshgoswami/samplewebapp:$new_tag
                        '''
                    }
                }
            }
        }
        
        stage('Deploy container in Remote server'){
            steps{
                script{
                    if("$action" == "deployDev"){
                        sh '''
                        new_tag=$(cat /tmp/buildNo)
                        ssh jnsadmin@172.31.33.26 'docker rm $(docker ps -qa) -f'
                        docker -H ssh://jnsadmin@172.31.33.26 run -d -p 8000:8080 santoshgoswami/samplewebapp:$new_tag
                        '''
                    }
                }
            }
        }
        
        stage('Deployment Status'){
            steps{
                sleep 60
                script{
                    sh '''
                    status=`curl -so /dev/null -w '%{response_code}' http://13.234.213.1:8000/LoginWebApp-1/`
                    if [[ "$status" -eq 200 ]]
                    then
                        echo "Deployment Successfull"
                        echo 'SUCESS' > /tmp/deployment_status.txt
                    else
                        echo "Deployment unsuccessfull"
                        echo 'FAIL' > /tmp/deployment_status.txt
                    fi
                    '''
            }
            }
        }
        
        stage('Test'){
            steps{
                script{
                    if("$action" == "deployTest"){
                    sh '''
                    echo "This is Testing stage"
                    '''
                    }
                }
            }
        }
        
        stage('UAT'){
            steps{
                script{
                    if("$action" == "deployUat"){
                        sh '''
                        echo "This is Uat stage"
                        '''
                    }
                }
            }
        }
        
        
        
        
        
    }
}
