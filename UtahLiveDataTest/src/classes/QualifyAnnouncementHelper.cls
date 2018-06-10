global with sharing class QualifyAnnouncementHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){      
        Id recordId = layoutHolder.getPrimarySObject().Id;
        String ns = AppUtils.getNamespacePrefix();
        Id accountId;
        Savepoint sp = Database.setSavepoint();
        OpportunityQualification__c oppQualifyObj;
        List<OpportunityQualification__c> oppQualifyObjList;
        try{
            
            User u = [select Contact.Account.IsExtensionAllowed__c from User where id =:Userinfo.getUserId()];        
            Boolean HideSubmit = true;
            Announcement__c announcementObj = [Select ApplicationDeadlineWithDateTime__c, ExtensionDays__c, TimeExtensionAllowed__c from Announcement__c where Id = :recordId limit 1];
            Datetime d = Datetime.newInstance(announcementObj.ApplicationDeadlineWithDateTime__c.year(), announcementObj.ApplicationDeadlineWithDateTime__c.month(), announcementObj.ApplicationDeadlineWithDateTime__c.day(),announcementObj.ApplicationDeadlineWithDateTime__c.hour(),announcementObj.ApplicationDeadlineWithDateTime__c.minute(),announcementObj.ApplicationDeadlineWithDateTime__c.second());            if(u.Contact.Account.IsExtensionAllowed__c == true && announcementObj.TimeExtensionAllowed__c == true){          
                if(d + Integer.valueOf(announcementObj.ExtensionDays__c )> Datetime.parse(System.now().format())){
                      HideSubmit = false;
                }
            }else{
                if(d > Datetime.parse(System.now().format())){
                      HideSubmit = false;
                }
            }
    
            if(HideSubmit){
               //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Funding Opportunity cannot be qualified after deadline'));
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-31600'))); 
               return null;
            }
          
            User userObj = [Select Contact.AccountId From User where Id =:UserInfo.getUserId()];
            if(userObj.Contact.AccountId != null){
                accountId = [Select id from Account where Id =: userObj.Contact.AccountId].Id;  
                System.Debug('accountId...'+accountId);
            }
            oppQualifyObjList = [Select id from OpportunityQualification__c where Account__c=:accountId and FundingOpportunity__c=:recordId];
            if(oppQualifyObjList <> null && oppQualifyObjList.size() > 0 ){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity has already been Qualified'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P51-GRNTR-34292')));
                return null;
            }
            if(accountId != null && recordId != null){
                oppQualifyObj = new OpportunityQualification__c();
                oppQualifyObj.Account__c=accountId;
                oppQualifyObj.FundingOpportunity__c=recordId;
                insert oppQualifyObj;
            }
        }catch(Exception ex){
            Database.rollback(sp);
            System.Debug('QualifyAnnouncementHelper Exception>>> '+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Opportunity has been Qualified'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P51-GRNTR-30209')));
        return null;
    }
}