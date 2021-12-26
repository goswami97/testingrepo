pipeline{
    agent any
    tools{
        maven 'Maven'
    }
    
    stages{
        stage('Git Checkout'){
            steps{
                script{
                    git branch: 'master', url: 'https://github.com/goswami97/testingrepo.git'
                }
            }
        }
        stage('Mail'){
            steps{
                script{
                    subject="${currentBuild.projectName} - Build # ${currentBuild.number}"
                    body="<html><body>Hi all,<br><br>CI-CD Pipeline has been initiated.<br><br>Regards,<br>DevOps Team.</body></html>"
                    mail_to="santoshgoswami691@gmail.com"
                    mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
                                
                }
            }
        }
        stage('Git tag'){
            steps{
                script{
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
                    
                    echo $commit_id > /tmp/commitID.txt
                    echo $new_tag > /tmp/buildNo.txt
                                
                    '''
                }
            }
        }
        stage('Code Build'){
            steps{
                script{
                    sh '''
                    mvn clean package
                    cp target/*.war /home/projectX
                    '''
                }
            }
        }
        stage('Docker Image Build and Tag'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'dockerCred', passwordVariable: 'dockerPass', usernameVariable: 'dockerID')]) {
                        sh '''
                        new_tag=$(cat /tmp/buildNo.txt)
                        cd /home/projectX/
                        docker login --username "$dockerID" --password "$dockerPass"
                        docker build -t santoshgoswami/samplewebapp:$new_tag .
                        '''   
                    }
                }
            }
        }
        stage('Docker image push to docker hub'){
            steps{
                script{
                    sh '''
                    new_tag=$(cat /tmp/buildNo.txt)
                    docker push santoshgoswami/samplewebapp:$new_tag
                    '''
                }
            }
        }
        stage('Deploy container in Remote server'){
            steps{
                script{
                    sh '''
                    new_tag=$(cat /tmp/buildNo.txt)
                    cont_ID=$(ssh jnsadmin@172.30.70.184 'docker ps -qa --filter name=samplewebapp')
                    ssh jnsadmin@172.30.70.184 docker rm "${cont_ID}" -f
                    docker -H ssh://jnsadmin@172.30.70.184 run --name samplewebapp  -d -p 8000:8080 santoshgoswami/samplewebapp:$new_tag       
                    '''
                }
            }
        }
        stage('Deployment Status'){
            steps{
                sleep 30
                withCredentials([string(credentialsId: 'githubAccessToken', variable: 'githubAccessToken')]) {
                    sh '''
                    new_tag=$(cat /tmp/buildNo.txt)
                    status=$(curl -so /dev/null -w '%{response_code}' http://172.30.70.184:8000/LoginWebApp-1/) || true
                    if [[ "$status" -eq 200 ]]
                    then
                        echo "Deployment Successfull"
                        echo 'SUCCESS' > /tmp/deployment_status.txt
                        git tag "$new_tag"
                        git push https://goswami97:"$githubAccessToken"@github.com/goswami97/testingrepo.git --tags
                    else
                        echo "Deployment Fail"
                        echo 'FAIL' > /tmp/deployment_status.txt
                    fi
                    '''
                }
            }
        }
        stage('Verificatioin'){
            steps{
                script{
                    def output=readFile('/tmp/deployment_status.txt').trim()
                    if( "$output" == "FAIL"){
                        echo "Its Fail"
                    }else{
                        echo "Its Success"
                    def ver=readFile('/tmp/buildNo.txt').trim()
                    def msg=readFile('/tmp/commitID.txt').trim()
                                    
                    subject= "FDA - Build # ${currentBuild.number} - DEV Deployment Successful"
                    body="<html><body>Hi all,<br><br>FDA Container has been deployed on DEV environment.<br>URL: http://172.30.70.184:8000/LoginWebApp-1/<br>${msg}<br><br>Regards,<br>DevOps Team.</body></html>"
                    mail_to="santoshgoswami691@gmail.com"
                    mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"

                    subject= "FDA - Build # ${currentBuild.number} -- DEV Revert Request"
                    body= "<html><head><meta http-equiv=Content-Type content=text/html; charset=utf-8><style>.button{background-color:red;border-color:red;border:2px solid red;padding:10px;text-align:center;}.link{display:block;color:#ffffff;font-size:12px;text-decoration:none; text-transform:uppercase;}</style></head><body><br>In order to revert to previous deployment click on below button.<br><br>Current Deployed FDA Container Version : ${ver}<br><br><table><tr><td class=button><a class=link href=#>Revert</a></td><td></td><td></td></tr></table></body></html>"
                    mail_to="santoshgoswami691@gmail.com"
                    mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
                                                
                    subject= "FDA - Build # ${currentBuild.number} -- QA Deployment Request"
                    body= "<html><head><meta http-equiv=Content-Type content=text/html; charset=utf-8><style>.button{background-color:green;border-color:green;border:2px solid green;padding:10px;text-align:center;}.link{display:block;color:#ffffff;font-size:12px;text-decoration:none; text-transform:uppercase;}</style></head><body><br>In order to deploy FDA container on QA environment click on below button.<br><br>FDA Container Version: ${ver}<br><br><table><tr><td class=button><a class=link href=#>Approve</a></td><td></td><td></td></tr></table></body></html>"
                    mail_to="santoshgoswami691@gmail.com"
                    mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '',mimeType: 'text/html', replyTo: '', subject: "${subject}", to: "${mail_to}"
                    }
                }
            }
        }
        


    }
}