global with sharing class CaseEmailServiceHandler implements Messaging.InboundEmailHandler {
    public static boolean isTest = false;

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {    
    	Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = true;

        String parentId = findParentId(email.plainTextBody);
        if (String.isEmpty(parentId)) {
            createCase(email, envelope);
        } else {
        	addEmailTask(email, parentId, envelope);
        }
    	return null;
    }
    
    private String findParentId(String body) {
        Pattern regexForExtractingId = Pattern.compile('ref:[A-Za-z0-9]{15,18}:ref'); 
        Matcher regexMatcherForExtractingId = regexForExtractingId.matcher(body);        
        String parentId = null;

        if(regexMatcherForExtractingId.find()) {
            parentId = regexMatcherForExtractingId.group();            
            parentId = parentId.substringBetween('ref:',':ref');           
        }
        return parentId;        
    }
    
    private void createCase(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    	Case__c caseObj = new Case__c(Subject__c = email.Subject, Description__c=email.plainTextBody, Origin__c='Email', Priority__c='Medium', 
    								 Status__c='New');
	 	Database.insert(caseObj, true);
	 	addEmailTask(email, caseObj.Id, envelope);
	 	System.debug('caseObj---' + caseObj);
    }
    
    private void addEmailTask(Messaging.InboundEmail email, String parentId, Messaging.InboundEnvelope envelope) {
    	Task taskForCase = new Task();
        taskForCase.WhatId = parentId;
        taskForCase.Type = 'Email';
        taskForCase.GNT__IsRead__c = true;
        taskForCase.GNT__FromAddress__c = envelope.fromAddress;
        //TODO - Assign to Queue
        taskForCase.OwnerId = UserInfo.getUserId();
        taskForCase.GNT__EmailType__c = 'Inbound';
        taskForCase.GNT__EmailSubject__c = email.subject;
        taskForCase.Subject = email.subject;
        taskForCase.Description = email.plainTextBody;
        taskForCase.Status = 'Completed';
        taskForCase.GNT__ToAddress__c = convertRecipientArrayToString(email.toAddresses, true);
        taskForCase.GNT__CCAddress__c = convertRecipientArrayToString(email.ccAddresses, true);
        insert taskForCase;
        System.debug('taskForCase---' + taskForCase);
    }
    
    private String convertRecipientArrayToString(String[] emailAddresses, Boolean isTo) {
        Set<String> resultEmails = new Set<String>(); 

        if (emailAddresses != null && emailAddresses.size() > 0) {
            for (String email : emailAddresses) {
                if (email.startsWith('communication@') == false) {
                    resultEmails.add(email);
                }
            }
        }
        return GNT.AppUtils.concatenate(resultEmails, '; ');
    }
}