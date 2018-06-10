// We need without sharing because in GG user can add attachment even he has only read only access.
global without sharing class AttachmentEditCtrl{
    public Attachment editAttachment {
        get;
        set;
    }
    public String pageBlockId ;
    public GNT__AttachmentExtension__c attachmentExtension {
        get;
        set;
    }
    private String parentObjectId;
    public string classification {
        get;
        set;
    }
    private string attachClassifications ;
    public List < selectOption > classificationsOptions {
            get;
            set;
        }
    //temp
    public String classificationVal {
        get;
        set;
    }
    
    public List < wrapAttachment > wrapAttachmentList {
        get;
        set;
    }
    public Set < Id > selectedAttachments {
        get;
        set;
    }
    public Attachment attachmentObj {
        get;
        set;
    }
    
    global AttachmentEditCtrl() {

        try {
            wrapAttachmentList = new List<wrapAttachment>();
            pageblockId = SFDCEncoder.SFDC_JSENCODE(apexpages.currentpage().getparameters().get('pBlockId'));

            String attachmentId = (SFDCEncoder.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('attachmentId')) != null) ? SFDCEncoder.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('attachmentId')) : null;
            parentObjectId = (SFDCEncoder.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('parentId')) != null) ? SFDCEncoder.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('parentId')) : null;
            classificationVal = (SFDCEncoder.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('classification')) != null) ? SFDCEncoder.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('classification')) : null;
            if( attachmentId == null || attachmentId.trim() == '' ) {
                throw new CustomExceptions.RequiredException('Attachement Id missing. Please contact support team.');
            }
            if(Attachment.sObjectType.getDescribe().isAccessible() == true){
                editAttachment = [SELECT Id, Name, Description, ParentId, Body
                                    FROM Attachment 
                    WHERE Id = : attachmentId
                ];
            }
                                    
            // removed body for view state
            //editAttachment.Body = null;
                                    
            // Pankaj : have a doubt regarding Attachment__c as external id
            if(GNT__AttachmentExtension__c.sObjectType.getDescribe().isAccessible() == true){
                attachmentExtension = [SELECT Id, GNT__Classification__c, GNT__Description__c, GNT__ParentId__c, GNT__Attachment__c 
                                    FROM GNT__AttachmentExtension__c 
                    where GNT__Attachment__c = : attachmentId limit 1
                ];
            }
            if( attachmentExtension == null ) {
                attachmentExtension = new GNT__AttachmentExtension__c();
            }
            getClassificationOptionList();

            getWrapperAttachment();
        
        } catch (Exception ex) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage() ) );
        }
    }
    public void getWrapperAttachment(){
        wrapAttachmentList.clear();
        if(wrapAttachmentList == null || wrapAttachmentList.size()==0) {
           // wrapAttachmentList = new List<wrapAttachment>();
           
            list<id> attchmentsIds = new list<id>();
            List<GNT__AttachmentExtension__c> attachExtList = new List<GNT__AttachmentExtension__c>();
            if(GNT__AttachmentExtension__c.sObjectType.getDescribe().isAccessible() == true){
                attachExtList = [SELECT Id,GNT__Classification__c,GNT__Attachment__c FROM GNT__AttachmentExtension__c WHERE GNT__Classification__c NOT IN ('Digitally Signed','Digitally Signed Original','History') AND GNT__IsCloned__c != true limit 500];
            }            
            //System.debug('attachExtList========>>>'+attachExtList);
            for(GNT__AttachmentExtension__c ae : attachExtList) {
                //System.debug('AttachmentExtension Details: '+ae.Attachment__c);
                attchmentsIds.add(ae.GNT__Attachment__c);
            }
            for(Attachment a: [select Id, Name,ParentId,ContentType,Description,LastModifiedDate  from Attachment WHERE Id IN :attchmentsIds]) {              
                wrapAttachmentList.add(new wrapAttachment(a));
            }
        }
    }
    
     /* Check if classification field present on page Block then get values from record. It can be relationship field. If it is blank then check for
        classfication text field. It will be ; separated values. If it is null then check for sobject config.
    */
    private void getClassificationOptionList() {

        system.debug('pageblockId'+pageblockId);
        //try{
            list<GNT__PageBlockConfig__c> pgblock = [Select GNT__AttachmentClassifications__c,GNT__ClassificationFieldAPIName__c from GNT__PageBlockConfig__c Where id =: pageblockId ];//here pageblock contains both attachemnt classficatioj fields
            classificationsOptions = new List<selectOption>();
            String classficationsString;
            String sobjectName = String.valueOf(((Id)parentObjectId).getSobjectType());//This is used to get sojectname from parentObjectId
            if(pgblock.size() > 0 && String.isNotEmpty(pgblock.get(0).GNT__ClassificationFieldAPIName__c )){//this block is used to get feld api name in which classfication are store comma separated
                String query1 = 'Select ' + pgblock.get(0).GNT__ClassificationFieldAPIName__c  + ' From ' + sobjectName + ' Where Id = : parentObjectId';
                system.debug('query----'+query1);
                Sobject sobj1 = Database.query(query1);
                if(AppUtils.getFieldValue(sobj1,pgblock.get(0).GNT__ClassificationFieldAPIName__c) == null){
                   // CustomExceptions.logException(String.format(System.Label.ClassficationDoesNotExist, new List<String>{}), false);//in this we can get relationship field and also normal fields so we use apputils method

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
                    classificationsOptions.add(new selectOption(classification, classification));
                }

            }
            
        /*}catch (Exception ex){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            system.debug('msg---'+msg);
            ApexPages.addMessage(msg);

        } */
        
    }
     public void updateAttachment() {
        try {
            if( !Schema.sObjectType.Attachment.isUpdateable() ) {
                String errorMessage = 'You lack permission to update the GNT__AttachmentExtension__c Object, please Contact support and have this permission enabled to add attachments';
                throw new CustomExceptions.AuthorizationException( errorMessage );
            }
            
            if( !Schema.sObjectType.GNT__AttachmentExtension__c.isUpdateable() && attachmentExtension.Id != null ) { 
                String errorMessage = 'You lack permission to update the GNT__AttachmentExtension__c Object, please Contact support and have this permission enabled to add attachments';
                throw new CustomExceptions.AuthorizationException( errorMessage );
            }
            
            if( !Schema.sObjectType.GNT__AttachmentExtension__c.isCreateable() && attachmentExtension.Id == null ) {
                String errorMessage = 'You lack permission to create the GNT__AttachmentExtension__c Object, please Contact support and have this permission enabled to add attachments';
                throw new CustomExceptions.AuthorizationException( errorMessage );
            }
            
            if( editAttachment.Body == null ) {
                //throw new CustomExceptions.RequiredException('Missing body.');
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.DocumentRequiredLabel) ); 
                if(editAttachment.Description == null){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.AttachmentDescriptionRequiredLabel) ); 
                }    
            }else if(editAttachment.Description == null){
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.AttachmentDescriptionRequiredLabel) ); 
            }else{
                if(Schema.sObjectType.Attachment.isUpdateable()){
                    update editAttachment;
                    editAttachment.Body = null;
                    upsert( new GNT__attachmentExtension__c( Id = attachmentExtension.Id, GNT__Attachment__c = editAttachment.Id, GNT__Description__c =editAttachment.Description, GNT__ParentId__c  = parentObjectId, GNT__Classification__c = attachmentExtension.GNT__Classification__c ) );
                }
                
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Attachment edited Successfully.' ) );
            }
            
        } catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage() ) );
        } 
    }
    
  public void processSelected() {
    Savepoint sp = Database.setSavepoint();
     try{ 
        selectedAttachments = new Set < Id > ();
        Database.SaveResult[] srList = new List<Database.SaveResult>();
        Database.SaveResult[] srAttachmentExt = new List < Database.SaveResult > ();
        List<Attachment> attachmentListToBeInsrted = new List<Attachment>();   
        List <GNT__AttachmentExtension__c > attachmentExtensionNewList = new List <GNT__AttachmentExtension__c > ();
        List <GNT__AttachmentExtension__c > attachmentExtensionList = new List <GNT__AttachmentExtension__c > ();
        list<Attachment>selectedattachmentrec = new list<Attachment>();
        Map < Id, Attachment > AttachmentOldMap = new Map < Id, Attachment > ();

        if(Schema.sObjectType.Attachment.isCreateable() && Schema.sObjectType.GNT__AttachmentExtension__c.isCreateable()&& Schema.sObjectType.Attachment.isUpdateable() && Schema.sObjectType.GNT__AttachmentExtension__c.isUpdateable()){
            for(wrapAttachment wrapAttachmentObj : wrapAttachmentList) {
              if(wrapAttachmentObj.selected == true) {
                            selectedAttachments.add(wrapAttachmentObj.att.Id);  
              }                      
              }
            if(selectedAttachments.size() == 0 ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one attachment.'));
                return;
            }
            selectedattachmentrec = [SELECT Id, Name,Body,Description FROM Attachment  WHERE Id IN :selectedAttachments];

            String attachmentId = (SFDCEncoder.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('attachmentId')) != null) ? SFDCEncoder.SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('attachmentId')) : null;   
            GNT__AttachmentExtension__c oldAttExt = new GNT__AttachmentExtension__c();
            if(GNT__AttachmentExtension__c.sObjectType.getDescribe().isAccessible() == true){
                oldAttExt = [SELECT Id, GNT__Classification__c, GNT__ParentId__c, GNT__Attachment__c
                                        FROM GNT__AttachmentExtension__c 
                            where GNT__Attachment__c = : attachmentId limit 1
                        ];
            }
                                      
            for(attachment attch :selectedattachmentrec ){
                Attachment a = new Attachment(); //Clone attachment                       
                a.Name = attch.Name;
                a.Body = attch.Body;
                a.Description = attch.Description;                          
                a.ParentId = parentObjectId;  
                a.id = attachmentId;              
                attachmentListToBeInsrted.add(a);
                AttachmentOldMap.put(attch.id, a);
            }
                            
                             
                   // if (Schema.sObjectType.Attachment.isUpdateable()) {
           srList = Database.update(attachmentListToBeInsrted, true);                   //Insert clone Attachment
                  //  }
                    
            if(GNT__AttachmentExtension__c.sObjectType.getDescribe().isAccessible() == true){
                attachmentExtensionList = [SELECT GNT__Attachment__c, GNT__Classification__c FROM GNT__AttachmentExtension__c WHERE GNT__Attachment__c IN: selectedAttachments];
           } 
            Map < Id, String > AttachExtMap = new Map < Id, String > ();
            for (GNT__AttachmentExtension__c attExt: attachmentExtensionList) {
                        AttachExtMap.put(attExt.GNT__Attachment__c, attExt.GNT__Classification__c);
            }
            system.debug('AttachExtMap====>>>' + AttachExtMap);

            for (GNT__AttachmentExtension__c attachmentExtObj: attachmentExtensionList) {
                 Attachment attachment = new Attachment();
                attachment = AttachmentOldMap.get(attachmentExtObj.GNT__Attachment__c);
                           
                GNT__AttachmentExtension__c attExtObj = new GNT__AttachmentExtension__c();                                           
                attExtObj.GNT__Classification__c = AttachExtMap.get(attachmentExtObj.GNT__Attachment__c);
                attExtObj.GNT__Attachment__c = attachment.Id;
                attExtObj.GNT__ParentId__c = parentObjectId;  
                attExtObj.GNT__Description__c = attachment.Description;
                attExtObj.GNT__IsCloned__c = true;
                attExtObj.id = oldAttExt.id;
                attachmentExtensionNewList.add(attExtObj);
                              
           }
                   // if (Schema.sObjectType.AttachmentExtension__c.isUpdateable()) {
          srAttachmentExt = Database.update(attachmentExtensionNewList, true); //clone AttachmentExtension with classification value
                   // }
                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Attachment Edited Successfully'));
                
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