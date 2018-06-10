global with sharing class ApplicationRejectionHelper extends GNT.DynamicLayoutActionRedirect {
    global override PageReference whenClicked() { 
         Id applicationId = apexpages.currentpage().getparameters().get('id');
         String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
         if(appName == 'StateasGrantee'){  
            String ns = AppUtils.getNamespacePrefix(); 
            User u = [select GNT__OrganizationId__c from User where id =:Userinfo.getUserId()];           
            List<Application__c> applst = [SELECT Id,Status__c FROM Application__c WHERE Id =: applicationId AND CreatedBy.GNT__OrganizationId__c =:u.GNT__OrganizationId__c ];
            if(applst.size()>0){
                System.debug('THE APPLICATION LIST IS '+applst); 
                if(applst[0].Status__c =='Submitted to Grantor'){
                    applst[0].Status__c ='Rejected';
                    update applst[0];
                } 
                 PageReference page = new PageReference('/apex/'+ns+'ApplicationView?id=' + applst[0].id);   
                 page.setRedirect(true);
                 return page;
            } 
        }   
        return null;                
    }
}