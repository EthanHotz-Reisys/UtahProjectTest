global with sharing class NotifyPreApplicationHelper extends GNT.DynamicLayoutActionRedirect { 

   
    global override PageReference whenClicked(){
    Savepoint sp = Database.setSavepoint();
    List<String> errors = new List<String>();   

    try{
        Id recordId = apexpages.currentpage().getparameters().get('id');
        Announcement__c ann = [Select Id,Name,FundingAllocationStatus__c from Announcement__c where Id =:recordId ];
           
      
       if(ann.FundingAllocationStatus__c!='Approved')
       {
        //errors.add('Funding Allocation Plans should be approved before notifying applicants.');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-53211'));
       }
       else if(ann.FundingAllocationStatus__c=='Approved'){
       
       
       AggregateResult[] groupedResults =[Select Sum(AllocationPercentage__c) Total from PreApplication__c where Announcement__c =: recordId];
       Decimal totalAllocation=0.0;
       
       for (AggregateResult ar : groupedResults)  {
        totalAllocation = (Decimal) ar.get('Total');
        }
        
        if(totalAllocation <100){
           //errors.add('Funding Allocation Plans should have 100% Allocations.');
           errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-99419'));
         }
               
       }


         if(errors.size() > 0){
            for(String error: errors){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
        }else  {
        
            ann.FundingAllocationStatus__c='Notified';
            notifyUsers(ann);
            update ann;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Funding Allocation has been notified to applicants.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-31810')));           
            PageReference  pageref = Page.FundingAllocationPlan;
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true);
            return pageref;   
        }

            return null;               
      } catch(Exception e){
        
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    
    global Boolean notifyUsers(Announcement__c announcement)
    {

       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();    //Email needs to be sent only if number of inactive users >0
    
             /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              String[] toAddresses = new String[] {};
             OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];
             EmailTemplate templateId = [Select id from EmailTemplate where developername = 'GrantorFundingAllocationNotification'];
              Contact cont = [select id, Email from Contact where email <> null limit 1];
             mail.saveAsActivity = false;  
             //  mail.setOrgWideEmailAddressId(owa.id);

             mail.setTargetObjectId(UserInfo.getuserId());
             mail.setTemplateID(templateId.Id); 
             mails.add(mail);
           //  Messaging.sendEmail(mails);
             Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
             toAddresses.add(UserInfo.getuserId());
             recIdToAddressMap.put(announcement.Id, toAddresses);

             GNT.AppUtils.sendEmailUsingTemplate(templateId.Id, recIdToAddressMap, cont.Id, false);*/
			new GNT.EmailFeeder().TargetObjectId(UserInfo.getUserId()).template('GrantorFundingAllocationNotification').contextRecordId(announcement.Id).send();
        return false;

    }
    
    
}