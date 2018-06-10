/*
  <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
global with sharing class SubmittoGrantorHelper extends GNT.DynamicLayoutActionRedirect {
	global override PageReference whenClicked(){ 
		  Id recordId = apexpages.currentpage().getparameters().get('id');
		  AmendmentRequest__c amdreq = [SELECT Id,OwnerId,Name,CreatedbyId,Status__c,AmendmentContact__c,AmendmentContact__r.email FROM AmendmentRequest__c WHERE id =: recordId];
		  //Shah CRF: use developername field to fetch email templates
      EmailTemplate et = [SELECT id,Name FROM EmailTemplate WHERE Name = 'Amendment Request Submit to Grantor'];
		  if(amdreq.AmendmentContact__c != null){
          //Shah CRF: use utility methods to send emails.
	      	  /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	String[] toAddresses = new String[]{amdreq.AmendmentContact__r.email};
        	mail.setToAddresses(toAddresses);
       	 	//mail.setReplyTo('SMaster@gmail.com');
        	mail.setSenderDisplayName('CRM Support');  //Shah CRF: Use orgwide email address to specify sender.
        	mail.setBccSender(false);
        	mail.setUseSignature(false);
        	mail.setTargetObjectId(amdreq.OwnerId);
        	mail.setTemplateId(et.id);
        	mail.saveAsActivity = false;
        //Set email file attachments
        	List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
       	 	mail.setFileAttachments(fileAttachments);
      //Send email
          if(!Test.isRunningTest()) {
        	   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          }
        // Add to attachment file list
        	Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        	efa.setFileName(a.Name);
        	efa.setBody(a.Body);
        	fileAttachments.add(efa);*/
	          String attchIds;
		    	for (Attachment a : [select Id,Name, Body, BodyLength from Attachment where ParentId = :amdreq.Id]) {
		    		if(attchIds == null) {
		    			attchIds = a.Id;
		    		} else {
		    			attchIds += ',' + a.Id;
		    		}
		    	}
	          new GNT.EmailFeeder().toEmail(amdreq.AmendmentContact__r.email).TargetObjectId(amdreq.OwnerId).template('Amendment Request Submit to Grantor').attachment(attchIds).send();
        	}
	      amdreq.status__c='Submitted to Grantor';
	      update amdreq;  //Shah CRF: Perform update before sending email. Because emails can't be rolled back, but DML statements can.
	      PageReference  returnPage = Page.amendmentrequestview;
          returnPage.getParameters().put('Id', amdreq.Id);
          returnPage.setRedirect(true);
          return returnPage;
	 }
 }