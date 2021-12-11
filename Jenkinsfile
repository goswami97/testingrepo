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
