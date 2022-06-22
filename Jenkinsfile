pipeline{
	agent any
	
	environment {
	    remoteServer = "192.168.1.7"
	}
	
	stages{
		stage("Git Checkout"){
			steps{
				git branch: 'dev', credentialsId: 'githubAccessToken', url: 'https://github.com/goswami97/testingrepo.git'
				sh '''
				LATEST_TAG=$(cat /tmp/gitTag)
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
                
                echo $new_tag > /tmp/newTag
				'''
			}
		}
		stage("Build dependencies"){
			steps{
				script{
					sh '''
					new_tag=$(cat /tmp/newTag)
					sed -i "s/Login Page/Login Page: $new_tag/g" $WORKSPACE/src/main/webapp/index.jsp
					mvn clean package
					'''
				}
			}
		}
		stage("Docker Image Build & Pust to Docker hub"){
			steps{
				script{
					withCredentials([usernamePassword(credentialsId: 'dockerCred', passwordVariable: 'dockerPass', usernameVariable: 'dockerID')]) {
                        sh '''
                        new_tag=$(cat /tmp/newTag)
                        cp $WORKSPACE/target/*.war /home/projectX
                        cd /home/projectX/
                        docker login --username "$dockerID" --password "$dockerPass"
                        docker build -t santoshgoswami/samplewebapp:$new_tag .
                        docker push santoshgoswami/samplewebapp:$new_tag
                        rm /home/projectX/*.war -f
                        
                        '''   
                    }
				}
			}
		}
		
		stage("Deploy to K8s-Cluster"){
			steps{
				script{
				    sh '''
				    new_tag=$(cat /tmp/newTag)
				    sed "s/{{ appver }}/$new_tag/g" samplewebapp.yml | kubectl apply -f -
				    '''
				}
			}
		}
		
		stage('Verify Deployment'){
        steps{
            script{
                sh '''
                new_tag=$(cat /tmp/newTag)
                
                echo "Checking url:- http://$remoteServer:31200/LoginWebApp-1/"
                sleep 5
                status=$(curl -so /dev/null -w '%{response_code}' http://"${remoteServer}":31200/LoginWebApp-1/) || true
                
                if [[ "$status" -eq 200 ]]
                then
                    echo "Deployment Successfull"
                    echo 'SUCCESS' > /tmp/deployment_status
                    echo $new_tag > /tmp/gitTag
                else
                    echo "Deployment Fail"
                    echo 'FAIL' > /tmp/deployment_status
                fi
                '''
            }
        }
    }
		
    }
}
