global with sharing class CreatePreApplicationHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){      
        Id recordId = layoutHolder.getPrimarySObject().Id;
        String ns = AppUtils.getNamespacePrefix(); 
        Id preapplicationId = apexpages.currentpage().getparameters().get('id');
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        User u = [select GNT__OrganizationId__c from User where id =:Userinfo.getUserId()];
        if(appName == 'Recipient'){
            OpportunityQualification__c qualifiedAnnouncement = [Select Id, FundingOpportunity__c,PreApplicationCreated__c from OpportunityQualification__c where id=:recordId limit 1];
            if(qualifiedAnnouncement.PreApplicationCreated__c==false){
                //qualifiedAnnouncement.PreApplicationCreated__c =true;
                update qualifiedAnnouncement;
                return new PageReference('/apex/'+ns+'PreApplicationEdit?announcementId=' + qualifiedAnnouncement.FundingOpportunity__c);
             }else{
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-77373')));   
                return null;
            }
        }
        if(appName == 'StateasGrantee'){
          List<PreApplication__c> preapplicationList = [SELECT Id,Status__c FROM PreApplication__c WHERE Announcement__c =: recordId AND CreatedBy.GNT__OrganizationId__c =:u.GNT__OrganizationId__c];//CreatedById =: Userinfo.getUserId()];
          System.debug('The preapplicationList is '+preapplicationList);
            if(preapplicationList.size() == 0){
                return new PageReference('/apex/'+ns+'PreApplicationEdit?announcementId=' + recordId+'&t=GranteeApplication' ); 
            }            
            List<PreApplication__c> applst = [SELECT Id,Status__c FROM PreApplication__c WHERE Id =: preapplicationId AND CreatedBy.GNT__OrganizationId__c =:u.GNT__OrganizationId__c];
            if(applst.size()>0){
                System.debug('THE APPLICATION LIST IS '+applst); 
                if(applst[0].Status__c =='Approved'){
                    applst[0].Status__c ='Submitted to Grantor';
                    update applst[0];
                }
                if(applst[0].Status__c =='Submitted to Grantor'){
                    applst[0].Status__c ='Accepted';
                    update applst[0];
                } 
                 PageReference page = new PageReference('/apex/'+ns+'PreApplicationView?id=' + applst[0].id);   
                 page.setRedirect(true); 
                 return page;
            } 
        }  
            return null;
    }
}