global class AWS_Upload {
    Public  static AWS_Keys__c awsKeySet{get;set;}
    public string ForRedirect{get;set;}  
    public static string appParentId{get;set;}
    public string Content_Type {get;set;}  
    Public String acessType{get;set;}
    public String recordId{get;set;}
    public AWS_Upload(){
        awsKeySet= AWS_Keys__c.getInstance('govgrantsassets');
        appParentId = ApexPages.currentPage().getParameters().get('parentIdForRedirect');
        ForRedirect = URL.getSalesforceBaseUrl().toExternalForm()+'/'+'apex/AWSSuccess';
        Content_Type ='multipart/form-data';
        acessType ='private';
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    }

    Datetime expire = system.now().addDays(1);
    String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+ expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';        
    string policy { get {return 
    '{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "'+
    awsKeySet.Name +'" } ,{ "acl": "'+acessType+'" },'+
    '{"content-type":"'+Content_Type+'"},'+
    '{"success_action_redirect": "'+ForRedirect+'"},' +
    '["starts-with", "$key", ""] ]}';   } } 

    public String getPolicy() {
        return EncodingUtil.base64Encode(Blob.valueOf(policy));
    }

    public String getSignedPolicy() {    
        return make_sig(EncodingUtil.base64Encode(Blob.valueOf(policy)));        
    }
    
    @RemoteAction
    global static void updateBacthAndCallAPI(String batchId, String fileName, String externalName){
        POC_FinancialBatch__c fb = [SELECT Id, FileName__c, Status__c, UploadedBy__c, UploadedDateandTime__c, ExternalFileName__c FROM POC_FinancialBatch__c WHERE Id =:batchId];
        fb.FileName__c = fileName;
        fb.Status__c = 'Uploaded';
        fb.UploadedBy__c = UserInfo.getUserId();
        fb.UploadedDateandTime__c = System.now();
        fb.ExternalFileName__c = externalName;
        update fb;
    }

    @RemoteAction
    global static void makeAPICall(String fb){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://dd1nw3jsx0.execute-api.us-east-1.amazonaws.com/prod/parser?batchId=' + fb);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }

    private String make_sig(string canonicalBuffer) {        
        String macUrl ;
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(awsKeySet.AWS_Secret_Key__c)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }
}