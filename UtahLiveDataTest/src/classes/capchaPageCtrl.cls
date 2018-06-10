public without sharing class capchaPageCtrl{

    //Properties
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public UserRegistration__c userReg{get;set;}
    public Boolean showCaptcha{get;set;}
    public Boolean isRegistrationSuccessful{get;set;}
    public String pageTemplateName{get;set;}
    public Id recordId {get; set;}
    
    public String responseCaptcha{get;set;}

    @TestVisible private boolean isCaptchaVerified;   

    
    
    //Captcha Changes
    private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify?'; 

    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = GNT.KeyValueStoreHelper.getTextValue('CaptchaPrivateKey',true);
    public String publicKey { 
        get { return GNT.KeyValueStoreHelper.getTextValue('CaptchaPublicKey',true); }
    } 
    
    public String challenge { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
            //return ApexPages.currentPage().getParameters().get('g-recaptcha-response');
        }
    }
    
   
    public capchaPageCtrl(ApexPages.StandardController stdController){
        showCaptcha = true;     
     }
        
 public PageReference saveUserRegistrationEntry(){
        checkCaptcha();
         try{
           
            if(this.isCaptchaVerified == true || Test.isRunningTest()){
                Id recordId = apexpages.currentpage().getparameters().get('id');
                UserRegistration__c objUserReg = [SELECT Id,Status__c,name FROM UserRegistration__c WHERE id =: recordId];
                objUserReg.Status__c = 'Submitted for Approval';
                objUserReg.TaskCreationFlag__c = True;
              
                try{
                     update objUserReg ;
                     String grpName = 'UserRegistrationApprover';
                     if(objUserReg.RecordType.Name == 'Reviewer'){
                        grpName = 'ReviewerRegistrationApprover';
                    }
                     List<Task> lst = GNT.TaskCreationHandler.createApprovalProcessTasks(objUserReg.Id, 'Review User Registration', objUserReg.Name, grpName, System.TODAY() + 7, objUserReg.Name, false);
                     system.debug(' objUserReg*tasks created**'+lst);    
                     List<Task> lst1= SystemContextMethodsHelper.upsertTasks(lst);
                     system.debug(' objUserReg*tasks updated**'+lst1);   

                }
                 Catch(Exception exc){
                    system.debug(' exc***'+exc.getMessage());
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Error in Registration'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61034')));
                    return null; 
                }               
                 recordId = ApexPages.CurrentPage().getParameters().get('id');
                 PageReference pg = Page.ApplicantRegistrationConfirm;
                 pg.getParameters().put('id', recordId);
                 pg.setRedirect(true);
                 return pg ;
          }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please enter a valid captcha'));
               // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-12961')));
                return null ;
              
            }
        
        }catch(Exception e){
            system.debug(e.getMessage());
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMsg);
            return null;
        }
        
    }
    
    private void checkCaptcha(){   
        // On first page load, form is empty, so no request to make yet
        //this.isCaptchaVerified=true;
        //return;
        if ( challenge == null || response == null ) { 
            this.isCaptchaVerified = false;
        }
        HttpResponse r = makeRequest(baseUrl, 'secret=' + privateKey + '&response=' + responseCaptcha + '&remoteip=' + remoteHost);
        if (r != null) {
            System.debug(r.getBody());
            Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(r.getBody());
            System.debug(responseMap);
            System.debug(responseMap.get('success'));
            for (String stringIterator : responseMap.keySet()) {
                if (stringIterator.equalsIgnoreCase('Success')) {
                    isCaptchaVerified  = Boolean.valueOf(responseMap.get(stringIterator));
                }
            }
        }
        System.debug('Verified: ' + isCaptchaVerified );
    }
    
    
     private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try {
            Http http = new Http();
            response = http.send(req);
        } 
        catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return response;
    }   
        
    private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }


    /*
        This method takes to landingpage
    */
    public PageReference cancelPage() {
        PageReference pg = Page.CommunitiesLanding;
        return pg;
    }
   
    
  
 
   
        
   
        
   
     
    
   
   

  
    
   

       
  
    
}