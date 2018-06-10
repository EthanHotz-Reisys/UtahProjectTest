global class AWSUploadCtrl {
    public static AWS_Keys__c awsKeySet{get;set;}
    public string ForRedirect{get;set;}  
    public static string appParentId{get;set;}
    public string Content_Type {get;set;}  
    public String acessType{get;set;}
    public String recordId{get;set;}
    public String batchType{get;set;}
    public Boolean isMspMember{get;set;}
    public String batchStatus{get;set;}
    public String env{get;set;}

    public AWSUploadCtrl (){
        awsKeySet= AWS_Keys__c.getInstance('govgrantsassets');
        appParentId = ApexPages.currentPage().getParameters().get('parentIdForRedirect');
        ForRedirect = URL.getSalesforceBaseUrl().toExternalForm()+'/'+'apex/AWSSuccess';
        Content_Type ='multipart/form-data';
        acessType ='private';
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        FileBatch__c fb = [SELECT Id, RecordType.Name, Status__c FROM FileBatch__c WHERE Id =:recordId];
        batchType = fb.RecordType.Name;
        batchStatus = fb.Status__c;
        isMspMember = isMspMember();
        env = awsKeySet.ENV__c;
    }

    Datetime expire = system.now().addDays(1);
    String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+ expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';        
    string policy { get {return 
    '{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "'+
    awsKeySet.Bucket_Name__c +'" } ,{ "acl": "'+acessType+'" },'+
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
    global static void updateBatch(String batchId, String fileName, String externalName){
        FileBatch__c fb = [SELECT Id, FileName__c, Status__c, UploadedBy__c, UploadedDatetime__c, ExternalFileName__c, FiscalYear__c FROM FileBatch__c WHERE Id =:batchId];
        fb.FileName__c = fileName;
        fb.Status__c = 'Uploaded';
        fb.UploadedBy__c = UserInfo.getUserId();
        fb.UploadedDatetime__c= System.now();
        fb.ExternalFileName__c = externalName;
        //fb.Name =  fb.FiscalYear__c + '_' + externalName;
        update fb;
    }

    
    public void updateBatchStatus(){
         FileBatch__c fb = [SELECT Id, Status__c FROM FileBatch__c WHERE Id =:recordId];
         batchStatus = fb.Status__c;
    }

    private String make_sig(string canonicalBuffer) {        
        String macUrl ;
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(awsKeySet.AWS_Secret_Key__c)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }

    private Boolean isMspMember(){
        Boolean isMspMember = true;
        //Group mspGroup = [SELECT Id, Name FROM Group WHERE Type = 'Regular' AND Name = 'USBEFINOPS'];
        //List<GroupMember> mspGroupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :mspGroup.Id];
        List<User> mspGroupMembers = [SELECT Id FROM User WHERE ProfileName__c = 'EXE'];
        Set<String> mspGroupMemberIds = new Set<String>();
        for(User gm : mspGroupMembers){
            //mspGroupMemberIds.add(gm.UserOrGroupId);
            mspGroupMemberIds.add(gm.Id);
        }
        if(!mspGroupMemberIds.contains(UserInfo.getUserId())){
            isMspMember = false;
        }
        return isMspMember;
    }
}