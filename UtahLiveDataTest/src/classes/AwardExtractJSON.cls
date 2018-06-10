/*
* This class generates JSON content for the award and saves it as an attachment.
* @author: Sarat Mahavratayajula
*/
global with sharing class AwardExtractJSON extends GNT.DynamicLayoutActionRedirect {
	public AwardExtractJSON() {	

	}

	global override PageReference whenClicked(){
		Savepoint sp = Database.setSavepoint();
		try {
			 Id recordId = apexpages.currentpage().getparameters().get('id');
			 Award__c award = [SELECT ID,Name,Application__r.Name,AwardNumber__c,AwardType__c,
			 					Comptroller__c,CurrentAmount__c,DUNSNumber__c,EINumber__c 
			 					FROM Award__c 
			 					where ID = :recordId];
			 String str;
			 if (award != null) {
			 	str = JSON.serializePretty(award);
			 }

			 	Attachment awardAttachment = new Attachment();
			 	awardAttachment.Name = award.Name + '.txt';
			 	awardAttachment.Body = Blob.valueOf(str);
			 	awardAttachment.ContentType = 'text/plain';
			 	awardAttachment.Description = award.Name + '-JSON_Content';
			 	awardAttachment.ParentId = award.Id;

			 	insert awardAttachment;

			 	GNT__AttachmentExtension__c attachmentExtension = new GNT__AttachmentExtension__c();
			 	attachmentExtension.GNT__AttachmentName__c = award.Name + '.txt';
			 	attachmentExtension.GNT__Classification__c = 'Other';
			 	attachmentExtension.GNT__ParentId__c = award.Id;
			 	attachmentExtension.GNT__Attachment__c = awardAttachment.Id;

			 	insert attachmentExtension;

			 	PageReference p = Page.AwardView;
            	p.getParameters().put('id',award.Id);
            	p.setRedirect(true);
            	return p;
			 
		}
		catch(Exception ex) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		 return null;
	}
}