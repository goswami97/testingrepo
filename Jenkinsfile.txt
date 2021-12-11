pipeline {

	agent any
	
	def leaders_email_dev = 'neha.gupta@india.nec.com, manpreet.singh@india.nec.com'
	
	def send_mail = { subject, body, mail_to ->
		mail to: "${mail_to}",
		subject: "${subject}",
		body: "${body}"
	}
	
	def send_mail_html = { subject, body, mail_to ->
		mail to: "${mail_to}",
		mimeType: 'text/html',
		subject: "${subject}",
		body: "${body}"
	}
	
	
}