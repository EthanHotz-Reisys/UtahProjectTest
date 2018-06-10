global with sharing class CaseDiscussionCtrl {
    @RemoteAction
    global static List<CaseDisucssion> getCaseNotes(String caseId) {
    	List<Note> notes = SystemContextMethodsHelper.getNotes(caseId);
        List<String> userIds = new List<String>();
        for(Note n : notes) {
        	userIds.add(n.CreatedById);
        }
        List<CaseDisucssion> discussions = new List<CaseDisucssion>();
        Map<String, User> userMap = SystemContextMethodsHelper.getUsers(userIds);
        for(Note n : notes) {
        	CaseDisucssion caseObj = new CaseDisucssion(n.CreatedBy, n.CreatedDate, n.Body, userMap.get(n.CreatedById).smallPhotoUrl);
        	discussions.add(caseObj);
        }
    	return discussions;
    }
    
    @RemoteAction
    global static void createNote(String caseId, String description) {
    	Note note = new Note(ParentId = caseId, Body = description, Title= 'Case Comments');
    	insert note;
    	
    	//todo - send email
    	Case__c caseObj = [select id,CaseNumber__c,CreatedBy.Email, Owner.Email, ReportedBy__r.Email from Case__c where Id=:caseId];
    	Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]>();
 		String[] userEmails = new List<String>();
 		String[] ccMails = new List<String>();
 		if(caseObj.CreatedBy.Email != null) {
	 		userEmails.add(caseObj.CreatedBy.Email);
 		}
 		if(caseObj.Owner.Email != null) {
	 		userEmails.add(caseObj.Owner.Email);
 		}
 		if(caseObj.ReportedBy__r.Email != null) {
	 		userEmails.add(caseObj.ReportedBy__r.Email);
 		}
 		
 		String htmlBody = 'Hello,<br/>	User ' + UserInfo.getLastName() + ' ' + UserInfo.getFirstName() + ' added new comment.<br/> Comment:' + description;
 		String subject = 'New comment added. Case : ' + caseObj.CaseNumber__c;
 		String replyEMailAddress = GNT.KeyValueStoreHelper.getTextValue('caseReplyToEmailAddress', true);
 		if(String.isEmpty(replyEMailAddress)) {
 			throw new CustomExceptions.InputDataException('Reply Email address is not defined in key value Custom setting. Pleae Contact administrator.');
 		}
    	GNT.AppUtils.sendEmail(userEmails, ccMails, replyEMailAddress, false, subject, htmlBody, htmlBody);
    }
    
    global class CaseDisucssion {
    	public String userName;
    	public String createdDate;
    	public String description;
    	public String createdDays;
    	public String photoURL;
    	public String nameInitials = '';
    	public String commentDetails = '';
    	global CaseDisucssion(User userObj, DateTime createdDate, String description, String photoURL) {
    		this.userName = userObj.Name;
    		this.createdDate = String.valueOf(createdDate);
    		this.description = description;
    		this.photoURL = photoURL;
    		this.nameInitials = (userObj.FirstName != null ? userObj.FirstName.substring(0,1) : '') + userObj.LastName.substring(0,1);
    		Long dt1Long = DateTime.now().getTime();
			Long dt2Long = createdDate.getTime();
			Long milliseconds = dt1Long - dt2Long;
			Long seconds = milliseconds / 1000;
			Long minutes = seconds / 60;
			Long hours = minutes / 60;
			if(minutes < 120) {
				if(minutes < 2) {
					this.createdDays = minutes + ' minute';
				} else {
					this.createdDays = minutes + ' minutes';
				}
				commentDetails = 'Commented ' + this.createdDays + ' ago';
			} else if(hours < 25) {
	    		this.createdDays = hours + ' hours';
	    		commentDetails = 'Commented ' + this.createdDays + ' ago';
			} else {
				//Long days = hours / 24;
				//this.createdDays = days + ' days';
				commentDetails = 'Commented on ' + this.createdDate;
			}
    	}
    }
}