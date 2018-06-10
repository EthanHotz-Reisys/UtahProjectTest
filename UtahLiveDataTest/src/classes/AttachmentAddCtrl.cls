// We need without sharing because in GG user can add attachment even he has only read only access.
global without sharing class AttachmentAddCtrl { 
    public String parentObjectId ;
    public String isDigitalSign {get;set;}//to get document related to digital signature
    public String classificationVal {
        get;
        set;
    }
    public String attachClassifications;
    public String document {
        get;
        set;
    }
    public String pageBlockId ;
    private transient Map<String,Integer> allowedClassificationCountMap; 
    public Map<String,Integer> classificationCountMap;
    public List < wrapAttachment > wrapAttachmentList {
        get;
        set;
    }

    public set < Id > selectedAttachments {
        get;
        set;
    }
    public Attachment attachmentObj {
        get;
        set;
    }
    String ns = AppUtils.getNameSpacePrefix();
    global AttachmentAddCtrl (){
        wrapAttachmentList = new List<wrapAttachment>();
        attachmentObj = new Attachment();
        parentObjectId = SFDCEncoder.SFDC_JSENCODE(apexpages.currentpage().getparameters().get('parentId'));

        pageblockId = SFDCEncoder.SFDC_JSENCODE(apexpages.currentpage().getparameters().get('pBlockId'));
        attachClassifications = SFDCEncoder.SFDC_JSENCODE(apexpages.currentpage().getparameters().get('classification'));
        document = SFDCEncoder.SFDC_JSENCODE(apexpages.currentpage().getparameters().get('document'));
        isDigitalSign = SFDCEncoder.SFDC_JSENCODE(apexpages.currentpage().getparameters().get('isDigiSign'));
        classificationCountMap = new Map<String,Integer>();
        getWrapperAttachment();
        classificationsList = getClassfications();
    }
    
    public void getWrapperAttachment(){
        wrapAttachmentList.clear();
        if(wrapAttachmentList == null || wrapAttachmentList.size()==0) {
            list<id> attchmentsIds = new list<id>();
            list<Attachment> attach = new list<Attachment>();
            List<GNT__AttachmentExtension__c> attachExtList = new List<GNT__AttachmentExtension__c>();
            if(GNT__AttachmentExtension__c.sObjectType.getDescribe().isAccessible() == true){
                attachExtList = [SELECT Id,GNT__Classification__c,GNT__Attachment__c FROM GNT__AttachmentExtension__c WHERE GNT__Classification__c NOT IN ('Digitally Signed','Digitally Signed Original','History') AND GNT__IsCloned__c != true limit 500];            
            }
            //System.debug('attachExtList========>>>'+attachExtList);
            for(GNT__AttachmentExtension__c ae : attachExtList) {
                //System.debug('AttachmentExtension Details: '+ae.Attachment__c);
                attchmentsIds.add(ae.GNT__Attachment__c);
            }
            if(Attachment.sObjectType.getDescribe().isAccessible() == true){
                attach = [select Id, Name,ParentId,ContentType,Description,LastModifiedDate  from Attachment WHERE Id IN :attchmentsIds];
            }
            for(Attachment a: attach) {              
                wrapAttachmentList.add(new wrapAttachment(a));
            }
        }
    }
    /* Check if classification field present on page Block then get values from record. It can be relationship field. If it is blank then check for
        classfication text field. It will be ; separated values. If it is null then check for sobject config.
    */
    private List<selectOption> getClassfications(){
        system.debug('pageblockId'+pageblockId);
        List<selectOption> options = new List<selectOption>();
        try{
            list<GNT__PageBlockConfig__c> pgblock = [Select GNT__AttachmentClassifications__c,GNT__ClassificationFieldAPIName__c from GNT__PageBlockConfig__c Where id =: pageblockId ];//here pageblock contains both attachemnt classficatioj fields
            String classficationsString;
            String sobjectName = String.valueOf(((Id)parentObjectId).getSobjectType());//This is used to get sojectname from parentObjectId
            if(pgblock.size() > 0 && String.isNotEmpty(pgblock.get(0).GNT__ClassificationFieldAPIName__c)){//this block is used to get feld api name in which classfication are store comma separated
                String query1 = 'Select ' + pgblock.get(0).GNT__ClassificationFieldAPIName__c  + ' From ' + sobjectName + ' Where Id = : parentObjectId';
                system.debug('query----'+query1);
                Sobject sobj1 = Database.query(query1);
                if(AppUtils.getFieldValue(sobj1,pgblock.get(0).GNT__ClassificationFieldAPIName__c) == null){
                    system.debug('pgblock.get(0).GNT__ClassificationFieldAPIName__c----'+AppUtils.getFieldValue(sobj1,pgblock.get(0).GNT__ClassificationFieldAPIName__c));
                   // GNT.CustomExceptions.logException(System.Label.ClassficationDoesNotExist, false,true);//in this we can get relationship field and also normal fields so we use apputils method

                }else{
                    classficationsString = (String)AppUtils.getFieldValue(sobj1,pgblock.get(0).GNT__ClassificationFieldAPIName__c);
                }

            }else if(pgblock.size() > 0 && String.isNotEmpty(pgblock.get(0).GNT__AttachmentClassifications__c)){//this block is used to get classification from normal classgication field.
                classficationsString = pgblock.get(0).GNT__AttachmentClassifications__c;

            }else{// this block is used to get classfications from sobject level
                list<GNT__SobjectConfig__c> sobjectConfig = [Select GNT__AttachmentClassifications__c from GNT__SobjectConfig__c Where Name =: sobjectName ];
                classficationsString = sobjectConfig.get(0).GNT__AttachmentClassifications__c;

            }
            if(String.isNotEmpty(classficationsString)){
                String [] sobjectdataSeparatedList1 = classficationsString.split(';');
                for(String classification : sobjectdataSeparatedList1) {
                    options.add(new selectOption(classification, classification));
                }

            }
        }catch (Exception ex){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            system.debug('msg11---'+msg);
            ApexPages.addMessage(msg);

        } 
        return options;
    }
    
    //Prajakta: Removed code from getter setter because try catch was not working properly. So created getClassfications() new method and in constructor assigned that method to getter setter.
    public List<selectOption> classificationsList{get;set;}
    public void addAttachment() {        
        try{            
            //System.debug('Beginning');
           Boolean addAttachment =  allowAddAttachment();
           if(addAttachment){
             if(attachmentObj.Body == null){
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.DocumentRequiredLabel);
                    ApexPages.addMessage(errorMsg);
                    if(attachmentObj.Description== null){
                    ApexPages.Message errorMsg1= new ApexPages.Message(ApexPages.Severity.ERROR, Label.AttachmentDescriptionRequiredLabel);
                    ApexPages.addMessage(errorMsg1); 
                    attachmentObj = new Attachment();
                    }
             }else if(attachmentObj.Description== null ){
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.AttachmentDescriptionRequiredLabel);
                    ApexPages.addMessage(errorMsg); 
                    attachmentObj = new Attachment();
            }else{
                //FeedItem f = new FeedItem();
                Attachment a = new Attachment();
                Database.SaveResult[] srList = new List<Database.SaveResult>();
                if(Schema.sObjectType.Attachment.isCreateable()){
                    /*
                    List<FeedItem> contentList = new List<FeedItem>();
                    //System.debug(attachmentObj);
                    f.Type = 'ContentPost';
                    f.ContentFileName = attachmentObj.Name;
                    f.ContentData = attachmentObj.Body;
                    f.ContentDescription = attachmentObj.Description;
                    f.ParentId = parentObjectId;
                    f.NetworkScope = 'AllNetworks';
                    f.Visibility = 'AllUsers';                  
                    contentList.add(f);
                    srList = Database.insert(contentList, true);
                    */
                    List<Attachment> attachmentList = new List<Attachment>();
                    a.Name = attachmentObj.Name;
                    a.Body = attachmentObj.Body;
                    a.Description = attachmentObj.Description;
                    a.ParentId = parentObjectId;                
                    attachmentList.add(a);
                    srList = Database.insert(attachmentList, true);
                } else {
                    String errorMessage = 'You lack permission to create the Attachment Object, please Contact support and have this permission enabled to add attachments';
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                    ApexPages.addMessage(errorMsg);
                }   
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        if(Schema.sObjectType.GNT__AttachmentExtension__c.isCreateable()){
                            // Operation was successful, so get the ID of the record that was processed                      
                            GNT__AttachmentExtension__c attExtObj = new GNT__AttachmentExtension__c(); 
                            attExtObj.GNT__Classification__c = classificationVal ;
                            //FeedItem fi = [SELECT RelatedRecordId FROM FeedItem WHERE id =: f.id];
                            //ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE id =: fi.RelatedRecordId];                          
                            attExtObj.GNT__Attachment__c = a.Id;
                            attExtObj.GNT__Description__c = a.Description;
                            attExtObj.GNT__ParentId__c = parentObjectId;                         
                            insert attExtObj;
                            if(classificationCountMap.get(classificationVal) == null){
                                classificationCountMap.put(classificationVal,1);    
                            }else{
                                classificationCountMap.put(classificationVal,classificationCountMap.get(classificationVal) + 1);
                            }
                            //feedItemIds.add(sr.getId());
                        } else {
                            String errorMessage = 'You lack permission to create the GNT__AttachmentExtension__c Object, please Contact support and have this permission enabled to add attachments';
                            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                            ApexPages.addMessage(errorMsg);
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, Label.AttachmentAddSuccessMsg));
                        
                        
                    } else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            //System.debug('The following error has occurred.');                    
                            //System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            //System.debug('Attachment fields that affected this error: ' + err.getFields());
                        }
                    }
                }   
                //List<FeedItem> feedItems = [SELECT RelatedRecordId.ContentDocumentId FROM FeedItem WHERE RelatedRecordId != null AND Id IN: feedItemIds]
             
                //System.debug('End');
                attachmentObj = new Attachment();
            }
        } 
        } catch(DMLException e) {
            //System.debug('e.getMessage()--->>>'+e.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(myMsg);
        } finally {
            if(attachmentObj != null) {
                attachmentObj.Body = null;
            }
        }        
    }  
    
    private boolean allowAddAttachment(){
        boolean addAttachment = true;
        pageBlockId = SFDCEncoder.SFDC_JSENCODE(apexpages.currentpage().getparameters().get('pBlockId'));
        //System.debug('pageBlockId ==='+pageBlockId );
        List<GNT__PageAttachmentConfig__c> pageAttachmentConfigList = new List<GNT__PageAttachmentConfig__c>();
        if(GNT__PageAttachmentConfig__c.sObjectType.getDescribe().isAccessible() == true){  
            pageAttachmentConfigList = [SELECT Id,Name,GNT__HideForProfile__c,GNT__MaximumAttachmentCount__c,GNT__Classification__c,GNT__AttachmentCount__c 
                                                                        FROM GNT__PageAttachmentConfig__c
                WHERE GNT__PageBlockConfig__c = : pageBlockId
            ];
        }
        allowedClassificationCountMap = new Map<String,Integer>();
        if(pageAttachmentConfigList.size() > 0){                
            for(GNT__PageAttachmentConfig__c pageAttachmentConfig : pageAttachmentConfigList ){      
                if(pageAttachmentConfig.GNT__Classification__c != null){                          
                    allowedClassificationCountMap.put(pageAttachmentConfig.GNT__Classification__c.toLowerCase(),(Integer)pageAttachmentConfig.GNT__MaximumAttachmentCount__c);   
                }
            }
        List<String> types = new List<String>();
        types.addAll(allowedClassificationCountMap.keySet());
            if(types.size() > 0){
        String classType = '(';
        for(String typeClass : types){
            classType += '\'' + typeClass + '\',';
        }
        classType = classType.removeEnd(',');
        classType+= ')';
        //System.debug('CLASSTYPE:'+classType);
        String classificationQuery = '';
        if(!classType.equals('()')){
            classificationQuery = 'and GNT__Classification__c in ' + classType;
        }
        // //System.debug('--------------allowAddAttachment----------countQuery -----------:'+countQuery );
        AggregateResult[] groupedResults;
        if(GNT__AttachmentExtension__c.sObjectType.getDescribe().isAccessible() == true){
            String countQuery = 'select count(id),GNT__Classification__c from GNT__AttachmentExtension__c where GNT__parentId__c = \''+ SFDCEncoder.SFDC_JSENCODE(parentObjectId) + '\' ' + classificationQuery + ' group by GNT__Classification__c';
            //System.debug('Count query==='+countQuery);
            groupedResults  =  Database.Query(countQuery);
        }
        Map<String,Integer> classificationCnt = new Map<String,Integer>();
        for(AggregateResult ext : groupedResults){
            if(ext.get(AppUtils.getNamespacePrefix() + 'GNT__Classification__c') != null){
             classificationCnt.put(String.valueOf(ext.get(AppUtils.getNamespacePrefix() + 'GNT__Classification__c')).toLowerCase(),(Integer)ext.get('expr0'));
            }       
        }
        if(classificationCnt.size () > 0  && allowedClassificationCountMap.size () > 0 ){    
        for(String classificationType :allowedClassificationCountMap.keySet()){ 
            if(allowedClassificationCountMap.get(classificationType) != null){
                if(allowedClassificationCountMap.get(classificationVal.toLowerCase()) <= classificationCnt.get(classificationVal.toLowerCase())){
                    String errorMessage = Label.AttachmentLimitReached + ' ' + classificationVal;
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                    ApexPages.addMessage(errorMsg);
                    addAttachment = false;
                }
            }
        }
       }
      }      
        }      
      return addAttachment;
    } 
public void processSelected() {
    Savepoint sp = Database.setSavepoint();
     try{  

        selectedAttachments = new set < Id > ();
        Database.SaveResult[] srList = new List<Database.SaveResult>();
        Database.SaveResult[] srAttachmentExt = new List < Database.SaveResult > ();
        List<Attachment> attachmentListToBeInsrted = new List<Attachment>();   
        List <GNT__AttachmentExtension__c > attachmentExtensionNewList = new List <GNT__AttachmentExtension__c > ();
        List <GNT__AttachmentExtension__c > attachmentExtensionList = new List <GNT__AttachmentExtension__c > ();
        list<Attachment>selectedattachmentrec = new list<Attachment>();
        Map < Id, Attachment > AttachmentOldMap = new Map < Id, Attachment > ();

        if (Schema.sObjectType.Attachment.isCreateable() && Schema.sObjectType.GNT__AttachmentExtension__c.isCreateable() && Attachment.sObjectType.getDescribe().isAccessible() == true) {
            for(wrapAttachment wrapAttachmentObj : wrapAttachmentList) {
                if(wrapAttachmentObj.selected == true ) {
                    selectedAttachments.add(wrapAttachmentObj.att.Id);  
                }                        
            }
            if(selectedAttachments.size() == 0 ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one attachment.'));
                return;
            }

            selectedattachmentrec = [SELECT Id, Name,Body,Description FROM Attachment  WHERE Id IN :selectedAttachments];
            
            for(attachment attch :selectedattachmentrec ){
                Attachment a = new Attachment(); //Clone attachment                           
                a.Name = attch.Name;
                a.Body = attch.Body;
                a.Description = attch.Description;                          
                a.ParentId = parentObjectId;                
                attachmentListToBeInsrted.add(a);
                AttachmentOldMap.put(attch.id, a);
            }
                        
            srList = Database.insert(attachmentListToBeInsrted, true);                  //Insert clone Attachment
            
            if(GNT__AttachmentExtension__c.sObjectType.getDescribe().isAccessible() == true){
                attachmentExtensionList = [SELECT GNT__Attachment__c, GNT__Classification__c FROM GNT__AttachmentExtension__c WHERE GNT__Attachment__c IN: selectedAttachments];
            }           
            Map < Id, String > AttachExtMap = new Map < Id, String > ();
            for (GNT__AttachmentExtension__c attExt: attachmentExtensionList) {
                AttachExtMap.put(attExt.GNT__Attachment__c, attExt.GNT__Classification__c);
            }
            
            for (GNT__AttachmentExtension__c attachmentExtObj: attachmentExtensionList) {
                Attachment attachment = new Attachment();
                attachment = AttachmentOldMap.get(attachmentExtObj.GNT__Attachment__c);
                GNT__AttachmentExtension__c attExtObj = new GNT__AttachmentExtension__c();                                           
                attExtObj.GNT__Classification__c = AttachExtMap.get(attachmentExtObj.GNT__Attachment__c);
                attExtObj.GNT__Attachment__c = attachment.Id;
                attExtObj.GNT__Description__c = attachment.Description;
                attExtObj.GNT__ParentId__c = parentObjectId;   
                attExtObj.GNT__IsCloned__c = true;                      
                attachmentExtensionNewList.add(attExtObj);
                          
            }
            srAttachmentExt = Database.insert(attachmentExtensionNewList, true);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, Label.AttachmentAddSuccessMsg));
            
            
        } else {
                String errorMessage = 'You lack permission to create the Attachment Object, please Contact support and have this permission enabled to add attachments';
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                ApexPages.addMessage(errorMsg);
        } 
        
        
        getWrapperAttachment();
        
        } catch(DMLException e) {
            Database.rollback(sp);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(myMsg);
        } 
    }
    
    public class wrapAttachment {
        public Attachment att {
            get;
            set;
        }
        public Boolean selected {
            get;
            set;
        }
 
        public wrapAttachment(Attachment a) {
            att = a;
            selected = false;
        }
    }
}