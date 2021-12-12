pipeline{

	agent any
	
	parameters{
		choice(
			name: 'environment',
			choices: "deployDev\ndeployTest\ndeployUat",
			description: 'Choose environment'
		)
	}
	
	stages{
		
		stage('Deployment'){
			steps{
				echo "Deployment started"
				script{
					if("$environment" == "deployDev"){
						echo "This is Development stage"
						
						git branch: 'main', url: 'https://github.com/goswami97/linux.git'
						subject= "${currentBuild.projectName} - Build # ${currentBuild.number}"
						body = '''Hi,
We would like to inform you CICD trigger has been initiated.
						
Regards,
DevOps Team'''
						mail_to = "santoshgoswami691@gmail.com"
						mail bcc: '', body: "${body}", cc: '', charset: 'UTF-8', from: '', replyTo: '', subject: "${subject}", to: "${mail_to}";
						
					}else if("$environment" == "deployTest"){
						echo "This is Test stage"
					}else if("$environment" == "deployUat"){
						echo "This is UAT stage"
					}else{
						echo "This is Default"
					}
				}
			}
		}
	}
}
