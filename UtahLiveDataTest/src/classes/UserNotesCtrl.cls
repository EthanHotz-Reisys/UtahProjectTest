global with sharing class UserNotesCtrl {
	
	@RemoteAction
	global static List<UserNote__c> getUserNotes() {
		return [select Id, Tittle__c, Description__c, LastModifiedDate from UserNote__c where User__c=:UserInfo.getUserId() order by LastModifiedDate limit 20];
	}
	
	@RemoteAction
	global static List<UserNote__c> deleteNote(String noteId) {
		delete [select Id from UserNote__c where Id=:noteId];
		return [select Id, Tittle__c, Description__c, LastModifiedDate from UserNote__c where User__c=:UserInfo.getUserId() order by LastModifiedDate limit 20];
	}
	
	@RemoteAction
	global static List<UserNote__c> saveNote(String noteStr) {
		UserNote__c userNote = (UserNote__c)JSON.deserialize(noteStr, UserNote__c.Class);
		userNote.User__c = UserInfo.getUserId();
		upsert userNote;
		return [select Id, Tittle__c, Description__c, LastModifiedDate from UserNote__c where User__c=:UserInfo.getUserId() order by LastModifiedDate limit 20];
	}
}