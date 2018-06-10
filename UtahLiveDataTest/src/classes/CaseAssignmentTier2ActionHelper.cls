global with sharing class CaseAssignmentTier2ActionHelper  extends GNT.DynamicLayoutActionRedirect {
    global override Pagereference whenClicked() {
        try {
            String recordId = ApexPages.CurrentPage().getParameters().get('id');
            //check the profile of logged in user.
            Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            Case__c caseObj = [Select Id,CaseCommentsAll__c,  CaseComments__c,Tier1Analysis__c,Tier2Analysis__c,CreatedBy.Email, Owner.Email, ReportedBy__r.Email from Case__c where id=:recordId]; 
            String tier1Profile = GNT.KeyValueStoreHelper.getTextValue('TS_Tier1ProfileName', true);
            String tier2Profile = GNT.KeyValueStoreHelper.getTextValue('TS_Tier2ProfileName', true);
            String daProfile = GNT.KeyValueStoreHelper.getTextValue('TS_DAProfileName', true);
            String adminProfile = GNT.KeyValueStoreHelper.getTextValue('TS_AdminProfileName', true);
            String caseCommentAll = caseObj.CaseComments__c !=null ? caseObj.CaseComments__c : ( ' Updated by ' +userinfo.getFirstName() + ' ' +userinfo.getLastName() );
            caseCommentAll = caseCommentAll + ' on  '+ datetime.now();        
            caseObj.CaseCommentsAll__c = ( caseObj.CaseCommentsAll__c != null ? caseObj.CaseCommentsAll__c : '') +  caseCommentAll;       
            // Validation Check            
            String tier2QueueName = GNT.KeyValueStoreHelper.getTextValue('TS_Tier2QueueName', true);
            List<Group> tier2Groups = [Select Id, Name from Group where Name=:tier2QueueName and Type='Queue' Limit 1];
            if(tier2Groups.size() == 0) {
                throw new CustomExceptions.RequiredException('No Queue found for given name:' + tier2QueueName + '. Please contact System administrator.');
            }                            
            caseObj.OwnerId=tier2Groups[0].Id; // assign to tier2 Queue
            caseObj.status__c='Tier2 Support';                      
            if(userProfile.Name.equalsIgnoreCase(daProfile) || userProfile.Name.equalsIgnoreCase(adminProfile) || userProfile.Name.equalsIgnoreCase(tier1Profile) )  {// DA Profile and Admin Profile can re-assign without comments       
                if( String.isEmpty(caseObj.Tier1Analysis__c) && userProfile.Name.equalsIgnoreCase(tier1Profile) ) {
                    throw new CustomExceptions.RequiredException(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-49125'));
                }
            } else {
                throw new CustomExceptions.RequiredException('Cases can be assigned by Tier 1 or Admin Users');
            }
            Update caseObj;
            sendCreateMail(caseObj);
            PageReference pg= AppUtils.getHomePage();
            return pg;
            //Pagereference pg=new Pagereference('/apex/CasesMaster');
            //pg.setRedirect(true);
            //return pg;
        } catch (Exception ex) {
            ApexPages.Message msg =new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addmessage(msg);
            return null;
        }
    }
    
    public static void sendCreateMail(Case__c caseObj) {
        String[] userEmails = new List<String>();
        Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]>();
        userEmails.add(caseObj.Owner.Email);
        recIdToAddressMap.put(caseObj.Id, userEmails);
        Contact con = [select id from Contact limit 1];
        EmailTemplate emailTemaple = [select id from EmailTemplate where Name='GovGrants_CO_Email_CaseCreation'];
        AppUtils.sendEmailUsingTemplate(emailTemaple.Id, recIdToAddressMap, String.valueOf(con.Id), true);
    }
}