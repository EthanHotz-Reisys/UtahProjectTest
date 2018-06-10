public with sharing class RolesAndResponsibilitiesEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
   // public ID organizationId {get;set;}
    public List<User> userList {get;set;}
    public ID userId {get;set;}
    
    
    private Id pageDataHolder;
    private String retURL;
    private RolesAndResponsibilities__c rolesAndResp;
    public String profileTypeUSBE {get;set;}
    public String profileFilterUSBE {get;set;}
    public String profileNameTypeUSBE {get;set;}
    public String userIdUSBE {get;set;}
    private String recordTypeName {get;set;}
    public Boolean hideCancelButton {get; set;}
    
    public RolesAndResponsibilitiesEditCtrl(ApexPages.StandardController stdController){
        hideCancelButton = false;
        profileTypeUSBE = 'praise';
        profileFilterUSBE = 'the';
        profileNameTypeUSBE = 'sun';
        userIdUSBE = '000000000000000000';
        recordTypeName = ' ';
        
        System.debug('MANUALDEBUG >>> PageParameters: ' + ApexPages.CurrentPage().getParameters());      
        pageDataHolder = ApexPages.CurrentPage().getParameters().get('pageDataHolder');
        Map<String, Object> pageDataHolderJsonMap;
        
        System.debug('MANUALDEBUG >>> pageDataHolder: ' + pageDataHolder);
        if(pageDataHolder != null) { //USBE Program adding roles
            rolesAndResp = (RolesAndResponsibilities__c )AppUtils.getSObjectFromJSON();
            System.debug('MANUALDEBUG >>> object = ' + rolesAndResp);
            System.debug('MANUALDEBUG >>> apputil: ' + AppUtils.getSObjectFromJSON());              
        }
        if (rolesAndResp != null) { //USBE Program R&R
            pageDataHolderJsonMap = (Map<String, Object>)JSON.deserializeUntyped([SELECT Id, GNT__JSONData1__c FROM GNT__PageDataHolder__c WHERE Id =: pageDataHolder].GNT__JSONData1__c);
            userId  = UserInfo.getUserId();
            userList =[select Organization__c from user where id =:userId limit 1];
            System.debug('MANUALDEBUG >>> userList: ' + userList);
            Id programId = String.valueOf(pageDataHolderJsonMap.get('Program__c'));
            Id announcementId = String.valueOf(pageDataHolderJsonMap.get('Announcement__c'));
            Id awardId = String.valueOf(pageDataHolderJsonMap.get('Award__c'));
            String insertType = String.valueOf(pageDataHolderJsonMap.get('InsertType__c'));   
            System.debug('MANUALDEBUG >>> programId: ' + programId);            
            //savePage = Page.ProgramView;
            //savePage.getParameters().put('id', programId);
            //cancelPage = Page.ProgramView;
            //cancelPage.getParameters().put('id', programId); 
            savePage = redirectToParentPage();
            cancelPage = redirectToParentPage();   
                        
            if(programId != null){
                Program__c currentProgram = [SELECT Id, ProgramPathway__c FROM Program__c WHERE Id =: programId];
                if(currentProgram.ProgramPathway__c.equals('MSP') || currentProgram.ProgramPathway__c.equals('Lump-Sum-No-App')) {
                    recordTypeName = 'ProgramUploadUSBE';
                }
                else {
                    recordTypeName = 'ProgramUSBE';
                }
                RecordType recordType = [
                    SELECT Id, DeveloperName 
                    FROM RecordType 
                    WHERE DeveloperName =: recordTypeName AND sObjectType =: AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c'];
                System.debug(' The Record Type is '+recordType);
            
                String defComments = GNT.KeyValueStoreHelper.getTextValue('DefaultComPrograms',true);
                System.debug('The comments are '+defComments); 
                if (insertType.equals('N/A')) {
                    if (announcementId != null) { pageTemplateName = 'Roles and Responsibilities Announcement Initial USBE'; }
                    else if (awardId != null) { pageTemplateName = 'Roles and Responsibilities Award Initial USBE'; }
                    else { pageTemplateName = 'Roles and Responsibilities Initial USBE'; }
                }
                else {
                    if (announcementId != null) { pageTemplateName = 'Roles and Responsibilities Announcement USBE'; }
                    else if (awardId != null) { pageTemplateName = 'Roles and Responsibilities Award USBE'; }
                    else { pageTemplateName = 'Roles and Responsibilities USBE'; }
                }
                listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',defComments,true);
                GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',String.valueOf(pageDataHolderJsonMap.get('Announcement__c')),true);
                GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',String.valueOf(pageDataHolderJsonMap.get('Award__c')),true);
                GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ChangeChildObjects__c','Update All Derivative Records',true);                
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);
                listDefaultValues.add(dv2);
                listDefaultValues.add(dv3);
                listDefaultValues.add(dv4);
                listDefaultValues.add(dv5);
                
                if (recordTypeName == 'ProgramUploadUSBE' && (rolesAndResp.BusinessRole__c.equals('Payment Approver 1') || rolesAndResp.BusinessRole__c.equals('Payment Approver 2'))) {
                    //If ProgramPathway is either MSP or LumpSumNoApp, then both Payment Approver 1 & 2 need to be of EXE profile AND both cannot be the same person
                    profileTypeUSBE = 'EXE';
                    List<RolesAndResponsibilities__c> programRolesAndResp = [SELECT Id, Name__c, BusinessRole__c FROM RolesAndResponsibilities__c WHERE Program__c =: programId AND (BusinessRole__c = 'Payment Approver 1' OR BusinessRole__c = 'Payment Approver 2')];
                    //Only if we have either payment approver 1 or 2, check the user id of them and do not allow the lookup to view said user
                    if (programRolesAndResp.size() == 1) {
                        userIdUSBE = programRolesAndResp[0].Name__c;
                    } 
                }
                else {
                    if (rolesAndResp.BusinessRole__c == 'Payment Approver 1') {
                        profileTypeUSBE = 'GMO'; //'SEC FIN';
                        profileFilterUSBE = 'PO'; //'PM';
                        //profileNameTypeUSBE = 'GMO';
                    }
                    else if (rolesAndResp.BusinessRole__c == 'Payment Approver 2') {
                        profileTypeUSBE = 'GMO'; //'SEC FIN';
                        profileFilterUSBE = 'PO'; //'PM';
                        //profileNameTypeUSBE = 'GMO';
                    }
                }
                //Regardless, the other role types are consistent across USBE programs
                if (rolesAndResp.BusinessRole__c == 'Owner') {
                    profileTypeUSBE = 'System Administrator';
                    profileFilterUSBE = 'PM';
                    profileNameTypeUSBE = 'EXE';
                }
                else if (rolesAndResp.BusinessRole__c == 'Grants Manager') {
                    profileTypeUSBE = 'GMO'; //'PM';
                    //profileFilterUSBE = 'GMO';
                }
                else if (rolesAndResp.BusinessRole__c == 'Payment Approver 3') {
                    profileTypeUSBE = 'EXE'; //'FA2';
                    profileFilterUSBE = 'FO'; //'EXE';
                    //profileNameTypeUSBE = 'FM1';
                }
                else if (rolesAndResp.BusinessRole__c == 'Payment Approver 4') {
                    profileTypeUSBE = 'EXE'; //'FM1';
                    profileFilterUSBE = 'FO'; //'EXE';
                    //profileNameTypeUSBE = 'FA2';
                }
                else if (rolesAndResp.BusinessRole__c == 'Executive Approver') {
                    profileTypeUSBE = 'EXE';
                }
                else if (rolesAndResp.BusinessRole__c == 'Program Approver') {
                    profileTypeUSBE = 'EXE'; //'FM1';
                    //profileFilterUSBE = 'EXE';
                    //profileNameTypeUSBE = 'FA2';
                }
                else if (rolesAndResp.BusinessRole__c == 'Award Approver 1' || rolesAndResp.BusinessRole__c == 'Award Approver 2') {
                    profileTypeUSBE = 'FO'; //'FM1';
                    //profileNameTypeUSBE = 'FA2';
                }
                System.debug('MANUALDEBUG >>> 1: ' + profileTypeUSBE + ' , 2: ' + profileFilterUSBE + ' 3: ' + profileNameTypeUSBE);
            } 
        }
        else {
            recordId = ApexPages.CurrentPage().getParameters().get('id');  
            System.debug('MANUALDEBUG >>> recordId: ' + recordId);        
            String recType = ApexPages.CurrentPage().getParameters().get('RecordType');   // Get the Developer Name from URL
            //organizationId= ApexPages.CurrentPage().getParameters().get('orgId');
            ////
            userId  = UserInfo.getUserId();
            userList =[select Organization__c from user where id =:userId limit 1];
            ////
            System.debug('The recType is '+ recType);
            pageTemplateName = 'Roles and Responsibilities';//TODO get template dynamically from sObjectConfig
            RecordType recordType = [Select Id,DeveloperName from RecordType where DeveloperName =:recType and sObjectType =: AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c'];
            System.debug(' The Record Type is '+recordType);
             Id announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');
            System.debug('The Announcment Id is '+ announcementId);
            
            hideCancelButton = true; 
            // to do get all the templates from the sobjectConfig layout 
            savePage = Page.RolesAndResponsibilitiesView;
            savePage.getParameters().put('id', recordId); 
            
            
            String comments = GNT.KeyValueStoreHelper.getTextValue('DefaultCommentRoleRespon',true); 
            System.debug('The comments are '+comments);
    
            if (!String.isEmpty(recordId)) {
                cancelPage = Page.RolesAndResponsibilitiesView;
                cancelPage.getParameters().put('id', recordId);   
            }
    
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            
            Id StrategicPlanid = ApexPages.CurrentPage().getParameters().get('StrategicPlanid');
            if (StrategicPlanid != null){
                pageTemplateName = 'Roles and Responsibilities';
                
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StrategicPlan__c',StrategicPlanid,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);
            }  
            
            Id serviceAreaId = ApexPages.CurrentPage().getParameters().get('serviceareaid');
            if (serviceAreaId != null){
                pageTemplateName = 'Roles and Responsibilities 1';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ServiceArea__c',serviceAreaId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);
            }
    
            if (announcementId != null){ 
                 
                 String oppComments = GNT.KeyValueStoreHelper.getTextValue('DefaultComOppRoleResp',true); 
            System.debug('The comments are '+Oppcomments);
                pageTemplateName = 'Roles and Responsibilities 2';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',announcementId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',oppComments,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1); 
                listDefaultValues.add(dv2);
            } 
            Id applicationid = ApexPages.CurrentPage().getParameters().get('applicationid');
            if (applicationid != null){ 
                pageTemplateName = 'Roles and Responsibilities 3';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',applicationid,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',comments,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);
                listDefaultValues.add(dv2); 
            } 
            Id preapplicationid = ApexPages.CurrentPage().getParameters().get('preapplicationid');
            System.debug('>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<');
            System.debug('PREAPPLICATION ID IS '+preapplicationid);
            System.debug('>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<');
            
            if (preapplicationid != null){ 
                pageTemplateName = 'Roles and Responsibilities 4';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PreApplication__c',preapplicationid,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',comments,true);
                listDefaultValues.add(dv);  
                listDefaultValues.add(dv1); 
                listDefaultValues.add(dv2);
            } 
            Id awardId = ApexPages.CurrentPage().getParameters().get('awardId');
            System.debug('award context: awardId: ' + awardId);
            if(awardId != null){
                pageTemplateName = 'Roles and Responsibilities 5';
                System.debug('pageTemplateName: ' + pageTemplateName);
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1); 
            }
            Id amendmentId =  ApexPages.CurrentPage().getParameters().get('amendmentId');
            if(amendmentId != null){
                pageTemplateName = 'Roles and Responsibilities 6';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AmendmentRequest__c',amendmentId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);
            }
            Id programId =  ApexPages.CurrentPage().getParameters().get('programid');
            if(programId != null){
                Program__c currentProgram = [SELECT Id, Account__r.Name, ProgramPathway__c FROM Program__c WHERE Id=: programId]; 
                if (currentProgram.Account__r.Name == 'USBE') {                    
                    if(currentProgram.ProgramPathway__c.equals('MSP') || currentProgram.ProgramPathway__c.equals('Lump-Sum-No-App')) {
                        recordTypeName = 'ProgramUploadUSBE';
                    }
                    else {
                        recordTypeName = 'ProgramUSBE';
                    } 
                    RolesAndResponsibilities__c rolesAndResp = [SELECT Id, BusinessRole__c FROM RolesAndResponsibilities__c WHERE Id =: recordId];
                    if (announcementId != null) { pageTemplateName = 'Roles and Responsibilities Announcement USBE'; }
                    else if (awardId != null) { pageTemplateName = 'Roles and Responsibilities Award USBE'; }
                    else { pageTemplateName = 'Roles and Responsibilities USBE'; }
                    if (recordTypeName.equals('ProgramUploadUSBE')) {
                        //If ProgramPathway is either MSP or LumpSumNoApp, then both Payment Approver 1 & 2 need to be of EXE profile AND both cannot be the same person
                        profileTypeUSBE = 'EXE';
                        List<RolesAndResponsibilities__c> programRolesAndResp = [SELECT Id, Name__c, BusinessRole__c FROM RolesAndResponsibilities__c WHERE Program__c =: programId AND (BusinessRole__c = 'Payment Approver 1' OR BusinessRole__c = 'Payment Approver 2')];
                        //Only if we have either payment approver 1 or 2, check the user id of them and do not allow the lookup to view said user
                        if (programRolesAndResp.size() == 1 && recordId == programRolesAndResp[0].Id) {
                            userIdUSBE = programRolesAndResp[0].Name__c;
                        } 
                    }
                    else {
                        if (rolesAndResp.BusinessRole__c == 'Payment Approver 1') {
                            profileTypeUSBE = 'GMO'; //'SEC FIN';
                            profileFilterUSBE = 'PO'; //'PM';
                            //profileNameTypeUSBE = 'GMO';
                        }
                        else if (rolesAndResp.BusinessRole__c == 'Payment Approver 2') {
                            profileTypeUSBE = 'GMO'; //'SEC FIN';
                            profileFilterUSBE = 'PO'; //'PM';
                            //profileNameTypeUSBE = 'GMO';
                        }
                    }
                    //Regardless, the other role types are consistent across USBE programs
                    if (rolesAndResp.BusinessRole__c == 'Owner') {
                        profileTypeUSBE = 'System Administrator';
                        profileFilterUSBE = 'PM';
                        profileNameTypeUSBE = 'EXE';
                    }
                    else if (rolesAndResp.BusinessRole__c == 'Grants Manager') {
                        profileTypeUSBE = 'GMO'; //'PM';
                        //profileFilterUSBE = 'GMO';
                    }
                    else if (rolesAndResp.BusinessRole__c == 'Payment Approver 3') {
                        profileTypeUSBE = 'EXE'; //'FA2';
                        profileFilterUSBE = 'FO'; //'EXE';
                        //profileNameTypeUSBE = 'FM1';
                    }
                    else if (rolesAndResp.BusinessRole__c == 'Payment Approver 4') {
                        profileTypeUSBE = 'EXE'; //'FM1';
                        profileFilterUSBE = 'FO'; //'EXE';
                        //profileNameTypeUSBE = 'FA2';
                    }
                    else if (rolesAndResp.BusinessRole__c == 'Executive Approver') {
                        profileTypeUSBE = 'EXE';
                    }
                    else if (rolesAndResp.BusinessRole__c == 'Program Approver') {
                        profileTypeUSBE = 'EXE'; //'FM1';
                        //profileFilterUSBE = 'EXE';
                        //profileNameTypeUSBE = 'FA2';
                    }
                    else if (rolesAndResp.BusinessRole__c == 'Award Approver 1' || rolesAndResp.BusinessRole__c == 'Award Approver 2') {
                        profileTypeUSBE = 'FO'; //'FM1';
                        //profileNameTypeUSBE = 'FA2';
                    }
                }
                else { 
                    pageTemplateName = 'Roles and Responsibilities 7'; 
                }
                String defComments = GNT.KeyValueStoreHelper.getTextValue('DefaultComPrograms',true);
                System.debug('The comments are '+defComments); 
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',defComments,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);
                listDefaultValues.add(dv2);   
            }
            Id progressReportId=  ApexPages.CurrentPage().getParameters().get('progressReportId');
            if(progressReportId!= null){ 
                pageTemplateName = 'Roles and Responsibilities 8';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProgressReport__c',progressReportId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);   
            }
            
             Id siteVisitId=  ApexPages.CurrentPage().getParameters().get('siteVisitId');
            if(siteVisitId!= null){ 
                pageTemplateName = 'Roles and Responsibilities 9';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SiteVisit__c',siteVisitId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);   
            }
            
            Id closeOutId=  ApexPages.CurrentPage().getParameters().get('closeOutId');
            if(closeOutId!= null){ 
                pageTemplateName = 'Roles and Responsibilities 10';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Closeout__c',closeOutId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);   
            }
    
            Id riskAssessmentId=  ApexPages.CurrentPage().getParameters().get('riskAssessmentId');
            if(riskAssessmentId!= null){ 
                pageTemplateName = 'Roles and Responsibilities 11';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'RiskAssessment__c',riskAssessmentId,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);   
            }
            Id finetprogramid=  ApexPages.CurrentPage().getParameters().get('finetprogramid');
            if(finetprogramid!= null){ 
                pageTemplateName = 'Roles and Responsibilities 12';
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FINETProgram__c',finetprogramid,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);   
            }   
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        //keyValueMap.put('applicationid',ApexPages.currentPage().getParameters().get('id'));
        //keyValueMap.put('orgId',organizationId);  
        keyValueMap.put('orgId',userList[0].Organization__c);
        keyValueMap.put('profileTypeUSBE', profileTypeUSBE); 
        keyValueMap.put('profileFilterUSBE', profileFilterUSBE);
        keyValueMap.put('profileNameTypeUSBE', profileNameTypeUSBE);
        keyValueMap.put('userIdUSBE', userIdUSBE);
        System.debug('keyValueMap==='+keyValueMap);
        return JSON.serialize(keyValueMap);
    }
    
    public PageReference redirectToParentPage() {
        if(pageDataHolder != null) { //USBE Program adding roles
            rolesAndResp = (RolesAndResponsibilities__c )AppUtils.getSObjectFromJSON();           
        }
        else {
            return null;
        }
        if (rolesAndResp != null) { //USBE Program R&R
            Map<String, Object> pageDataHolderJsonMap = (Map<String, Object>)JSON.deserializeUntyped([SELECT Id, GNT__JSONData1__c FROM GNT__PageDataHolder__c WHERE Id =: pageDataHolder].GNT__JSONData1__c);
            System.debug('MANUALDEBUG >>> userList: ' + userList);
            Id programId = String.valueOf(pageDataHolderJsonMap.get('Program__c'));
            Id announcementId = String.valueOf(pageDataHolderJsonMap.get('Announcement__c'));
            Id awardId = String.valueOf(pageDataHolderJsonMap.get('Award__c'));
            Id objectId;//whichever object the rr is for
            if (announcementId != null) { objectId = announcementId; }
            else if (awardId != null) { objectId = awardId; }
            else { objectId = programId; }
            
            Map<String, String> roleMapLookupField = new Map<String, String> {
                'Executive Approver' => 'ExecutiveApprover__c',
                'Grants Manager' => 'GrantsManager__c',
                'Payment Approver 1' => 'PaymentApprover1__c',
                'Payment Approver 2' => 'PaymentApprover2__c',
                'Payment Approver 3' => 'PaymentApprover3__c',
                'Payment Approver 4' => 'PaymentApprover4__c',
                'Program Approver' => 'ProgramApprover__c',
                'Award Approver 1' => 'AwardApprover1__c',
                'Award Approver 2' => 'AwardApprover2__c'
            };
            if (announcementId != null) { roleMapLookupField.put('Executive Approver', 'Executive__c');}
    
            String query = 'SELECT Id, ' + roleMapLookupField.get(rolesAndResp.BusinessRole__c) + ' FROM ' + String.valueOf(objectId.getSObjectType()) + ' WHERE Id =  \'' + objectId + '\' LIMIT 1';
            System.debug(query);
            SObject objectCheck = Database.query(query);
            if (objectCheck.get(roleMapLookupField.get(rolesAndResp.BusinessRole__c)) != null) { //Object has that lookup field filled, thus is no longer insert USBE role
                Map<String, PageReference> objectTypeMapPageRef = new Map<String, PageReference>{
                    'Award__c' => Page.AwardView,
                    'Announcement__c' => Page.AnnouncementView,
                    'Program__c' => Page.ProgramView
                };
                PageReference redirectPage = objectTypeMapPageRef.get(String.valueOf(objectId.getSObjectType()));
                redirectPage.setRedirect(true);
                redirectPage.getParameters().put('id', objectId);
                return redirectPage; //You can't waive/accept an allocation change if there is already an active allocation change budget revision for your award, so redirect to the award page
            }
            else {
                return null;
            }    
        }
        else {
            return null; 
        }
    }
    

}