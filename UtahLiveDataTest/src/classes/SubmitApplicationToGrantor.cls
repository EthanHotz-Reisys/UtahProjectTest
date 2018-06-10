global with sharing class SubmitApplicationToGrantor extends GNT.DynamicLayoutActionRedirect {

     global override PageReference whenClicked(){
      System.debug(LoggingLevel.ERROR,'*** Entered into class');
     
        /* Pranjali : The below line is commented for test coverage. Also recordId is not used in this class */
        //Id recordId = layoutHolder.getPrimarySObject().Id;
        String ns = AppUtils.getNamespacePrefix(); 
        Id applicationId = apexpages.currentpage().getparameters().get('id');

        System.debug(LoggingLevel.ERROR,'*** sarat test' + applicationId );

       
        //System.debug('The record Id is 00 '+recordId);
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        User u = [select GNT__OrganizationId__c from User where id =:Userinfo.getUserId()];
         System.debug('The record Id is 11 '+(appName == 'StateasGrantee'));
        if(appName == 'StateasGrantee'){ 
            List<Application__c> applst = [SELECT Id,Status__c,SubmitToGrants__c FROM Application__c WHERE Id =: applicationId];
            List<Form__c> formLst = [SELECT Id FROM Form__c WHERE Application__c=: applicationId];      
            if(formLst.size()>0){
                for(Form__c forms:formLst){
                    forms.Date__c=System.Today();         
                }
                update formLst;              
            }
         
            if(applst.size()>0){
                 System.debug('The record Id is 22 '+applst); 
                 System.debug('The record Id is 33 '+ (applst[0].Status__c =='Submitted to Grantor'));
                if(applst[0].Status__c =='Approved'){
                   /* if(applst[0].SubmitToGrants__c){  
                        return submitApplicationToGrantsGov(applst[0].id);
                    } */
                    applst[0].Status__c ='Submitted to Grantor';
                    update applst[0];
                    PageReference page = new PageReference('/apex/'+ns+'ApplicationView?id=' + applst[0].id);   
                    page.setRedirect(true); 
                    return page;
                }else if(applst[0].Status__c =='Submitted to Grantor'){
                    applst[0].Status__c ='Accepted'; 
                    System.debug('The record Id is 44 '+applst[0]);
                    update applst[0];
                    PageReference page = new PageReference('/apex/'+ns+'ApplicationView?id=' + applst[0].id);   
                    page.setRedirect(true); 
                    return page;
                } 
                 
            }  
        }  
            return null;
    }
    
    private PageReference submitApplicationToGrantsGov(String appId){
      String ns = AppUtils.getNamespacePrefix();
      PageReference page = new PageReference('/apex/'+ns+'ApplicationView?id=' + appId);

      String intUrl = GNT.KeyValueStoreHelper.getTextValue('GrantsGovIntegrationUrl',true);
      String intKey = GNT.KeyValueStoreHelper.getTextValue('GrantsGovIntegrationKey',true);

      List<String> errors = new List<String>();

      if(String.isEmpty(intUrl) || String.isEmpty(intKey)){
        throw new IntegrationException('Required configuration is missing for Application submission.');
      }
    
      try{
        HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                String url = (intUrl + '?skey=' + intKey + '&appreference=' + appId);
                System.debug('url>>>>>>>>>>>>' + url);
                req.setEndpoint(url);
                req.setTimeout(60000);
                
                HTTPResponse httpRes = new Http().send(req);
                Integer statusCode = httpRes.getStatusCode();
                String res = httpRes.getBody();
                
                System.debug('Status>>>>>>>>>>>>' + statusCode);
                System.debug('getBody>>>>>>>>>>>>' + res);
                
        if(statusCode != 200){
          throw new IntegrationException('Status is ' + statusCode + '. Response:' + res);
        }

                Map<String, Object> response =  (Map<String, Object>)JSON.deserializeUntyped(res);
                String status = (String)response.get('status');
                System.debug('>>>>>>>>status>>>:' + status);
                String appref = (String)response.get('appreference');
                System.debug('>>>>>>>appref>>>>:' + appref);
                
                if(status == 'success'){
                  Application__c app = new Application__c();
                  app.Id = appId;
              app.Status__c ='Submission in Progress';
              update app;
                }else if(status == 'fail'){
                  List<Object> errs = (List<Object>)response.get('Errors');
          System.debug('>>>>>>>Errors>>>>:' + errs);
                  for(Object err:errs){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, (String)err));
          } 
          return null;
                }
      }catch(Exception e){
        String msg = 'Error in comminicating to Grants.gov. Please contact System administrator: ' + e;
        System.debug(msg);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
        return null;
      }
          
        page.setRedirect(true);
      return page;
    }
    
    global with sharing class IntegrationException extends Exception{

    }
}