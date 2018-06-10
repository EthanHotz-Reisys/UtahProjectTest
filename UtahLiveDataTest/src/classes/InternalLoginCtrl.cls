public with sharing class InternalLoginCtrl {
    public List<String> URLStringList{get; set;}
     /** This is a hack to determine is the page is using SSL or not.  If CipherSuite is defined that means it is HTTPS **/
    public Boolean hasSSL { get { return ApexPages.currentPage().getHeaders().get('CipherSuite') != null; }}

    /** This is used to determine the device type **/
    public String userAgent { get { return ApexPages.currentPage().getHeaders().get('USER-AGENT');  } }
   
    /** This will return which Salesforce Server you are on, example: na8.salesforce.com **/
    //public String currentServer { get {return ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To'); } }
    public String currentServer { get {return ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To'); } }
    
    
    
    public String namespace{get;set;}
    public InternalLoginCtrl(){
        namespace = AppUtils.getNamespacePrefix();
    }
    
    /** Check the useragent string and assign the device **/
    public String deviceType { get; set; } {
       getSliderImageURL();
       if(userAgent.contains('iPhone')) deviceType = 'iPhone';
       else if(userAgent.contains('iPad')) deviceType = 'iPad';
       else if(userAgent.contains('BlackBerry')) deviceType = 'BlackBerry';
       else deviceType = 'Other';
    }
    
    /** You could query a custom object to determine your home page, check the device or simply hard code it here **/   
    public String returnUrl {get; set; } {
        if (deviceType == 'iPad') {
            returnUrl = '/apex/tablet'; 
        } else {
            Id annId = System.currentPageReference().getParameters().get('applyId');
            if(annId != '' && annId != null){
                returnUrl = '/apex/' + AppUtils.getNamespacePrefix() + 'InternalLoginRedirect?applyId='+annId;
            }else{
                returnUrl = '/apex/' + AppUtils.getNamespacePrefix() + 'InternalLoginRedirect';
            }
        }
    }

    /** Check to see if the page is using HTTPS, if not redirect it back to itself with HTTPS **/
    public PageReference redirect() {
        if (!hasSSL) {
            string host = ApexPages.currentPage().getHeaders().get('host');
            string url = ApexPages.currentPage().getUrl();
            PageReference homePage = new PageReference('https://'+host+url);
            homePage.setRedirect(true);
            return homePage;
        } else {
            return null;    
        } 
    }
     public string getAcceptTermsURL(){
        String url;
        List<GNT__CustomAppFooterConfig__c> entries = [Select GNT__TargetURL__c from GNT__CustomAppFooterConfig__c where GNT__CustomAppName__c='StateasGrantor' and 
                GNT__TermsAndConditions__c=true limit 1];
        if(entries.size() == 1){
            url = entries.get(0).GNT__TargetURL__c;
        }
        return url;
    }
    public void dummyRefresh()
    {        
    }
    
      /**This call is used to populate Images for Slider shown on Internal Login Page**/
    public List<string> getSliderImageURL(){
        String orgId = UserInfo.getOrganizationId();
        String docName = GNT.KeyValueStoreHelper.getTextValue('GovGrantsInternalBanner',true);
        List<Document> docList= new List<Document>();
        String query='SELECT id, Name FROM Document WHERE Name Like \''+docName+'%'+'\'';
        docList = Database.query(query);                  
        String baseURL; 
        if(docList.size() > 0){
            URLStringList = new List<String>(); 
            for(Document doc:docList){
                baseURL = URL.getSalesforceBaseUrl().toExternalForm();
                URLStringList .add(baseURL+'/servlet/servlet.ImageServer?oid='+orgId +'&id='+doc.id);
             }             
             return URLStringList; 
        }else{
            return null;
        
        }  
    }
    
    
}