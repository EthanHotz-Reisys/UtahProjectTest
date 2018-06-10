public with sharing class RolesAndResponsibilitiesFINETEditCtrl{
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
    public String profileFilterQueryUSBE {get;set;}
    public List<String> profileTypeListUSBE {get;set;}
    
    public RolesAndResponsibilitiesFINETEditCtrl(ApexPages.StandardController stdController){
        
        profileTypeUSBE = ' ';
        profileFilterQueryUSBE = ' ';
        profileTypeListUSBE = new List<String>();
        
        System.debug('MANUALDEBUG >>> PageParameters: ' + ApexPages.CurrentPage().getParameters());      
        pageDataHolder = ApexPages.CurrentPage().getParameters().get('pageDataHolder');
        System.debug('MANUALDEBUG >>> pageDataHolder: ' + pageDataHolder);
        if(pageDataHolder != null) { //USBE Program adding roles
            rolesAndResp = (RolesAndResponsibilities__c )AppUtils.getSObjectFromJSON();
            System.debug('MANUALDEBUG >>> object = ' + rolesAndResp);
            System.debug('MANUALDEBUG >>> apputil: ' + AppUtils.getSObjectFromJSON());               
        }
        if (rolesAndResp != null) { //FINET
            userId  = UserInfo.getUserId();
            userList =[select Organization__c from user where id =:userId limit 1];
            System.debug('MANUALDEBUG >>> userList: ' + userList);
            Id finetprogramid = (ApexPages.CurrentPage().getParameters().get('retURL')).subString(29,47);
            System.debug('MANUALDEBUG >>> programId: ' + finetprogramid);
            
            RecordType recordType = [
                SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'ProgramUSBE' AND sObjectType =: AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c'];
            System.debug(' The Record Type is '+recordType);

            if(finetprogramid != null){
                String defComments = GNT.KeyValueStoreHelper.getTextValue('DefaultComPrograms',true);
                System.debug('The comments are '+defComments); 
                pageTemplateName = 'Roles and Responsibilities USBE';
                listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FINETProgram__c',finetprogramid,true);
                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',defComments,true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);
                listDefaultValues.add(dv2);
                if (rolesAndResp.BusinessRole__c == 'Owner') {
                    profileTypeUSBE = 'System Administrator';
                    profileFilterQueryUSBE = 'PM';
                }
                else if (rolesAndResp.BusinessRole__c == 'Grants Manager') {
                    profileTypeUSBE = 'PM';
                }
                else if (rolesAndResp.BusinessRole__c == 'Payment Approver 1') {
                    profileTypeUSBE = 'PM';
                }
                else if (rolesAndResp.BusinessRole__c == 'Payment Approver 2') {
                    profileTypeUSBE = 'SEC FIN';
                }
                else if (rolesAndResp.BusinessRole__c == 'Payment Approver 3') {
                    profileTypeUSBE = 'FA2';
                }
                else if (rolesAndResp.BusinessRole__c == 'Payment Approver 4') {
                    profileTypeUSBE = 'FM1';
                }
                else if (rolesAndResp.BusinessRole__c == 'Executive Approver') {
                    profileTypeUSBE = 'EXE';
                } 
            } 
        }
        //else {
        //    recordId = ApexPages.CurrentPage().getParameters().get('id');  
        //    System.debug('MANUALDEBUG >>> recordId: ' + recordId);        
        //    String recType = ApexPages.CurrentPage().getParameters().get('RecordType');   // Get the Developer Name from URL
        //    //organizationId= ApexPages.CurrentPage().getParameters().get('orgId');
        //    ////
        //    userId  = UserInfo.getUserId();
        //    userList =[select Organization__c from user where id =:userId limit 1];
        //    ////
        //    System.debug('The recType is '+ recType);
        //    pageTemplateName = 'Roles and Responsibilities';//TODO get template dynamically from sObjectConfig
        //    RecordType recordType = [Select Id,DeveloperName from RecordType where DeveloperName =:recType and sObjectType =: AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c'];
        //    System.debug(' The Record Type is '+recordType);
        //     Id announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');
        //    System.debug('The Announcment Id is '+ announcementId);
             
        //    // to do get all the templates from the sobjectConfig layout 
            
        //    savePage = Page.RolesAndResponsibilitiesView;
        //    savePage.getParameters().put('id', recordId); 
            
        //    String comments = GNT.KeyValueStoreHelper.getTextValue('DefaultCommentRoleRespon',true); 
        //    System.debug('The comments are '+comments);
    
        //    if (!String.isEmpty(recordId)) {
        //        cancelPage = Page.RolesAndResponsibilitiesView;
        //        cancelPage.getParameters().put('id', recordId);   
        //    }
    
        //    listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            
        //    Id StrategicPlanid = ApexPages.CurrentPage().getParameters().get('StrategicPlanid');
        //    if (StrategicPlanid != null){
        //        pageTemplateName = 'Roles and Responsibilities';
                
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StrategicPlan__c',StrategicPlanid,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);
        //    }  
            
        //    Id serviceAreaId = ApexPages.CurrentPage().getParameters().get('serviceareaid');
        //    if (serviceAreaId != null){
        //        pageTemplateName = 'Roles and Responsibilities 1';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ServiceArea__c',serviceAreaId,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);
        //    }
    
        //    if (announcementId != null){ 
                 
        //         String oppComments = GNT.KeyValueStoreHelper.getTextValue('DefaultComOppRoleResp',true); 
        //    System.debug('The comments are '+Oppcomments);
        //        pageTemplateName = 'Roles and Responsibilities 2';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',announcementId,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',oppComments,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1); 
        //        listDefaultValues.add(dv2);
        //    } 
        //    Id applicationid = ApexPages.CurrentPage().getParameters().get('applicationid');
        //    if (applicationid != null){ 
        //        pageTemplateName = 'Roles and Responsibilities 3';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',applicationid,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',comments,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);
        //        listDefaultValues.add(dv2); 
        //    } 
        //    Id preapplicationid = ApexPages.CurrentPage().getParameters().get('preapplicationid');
        //    System.debug('>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<');
        //    System.debug('PREAPPLICATION ID IS '+preapplicationid);
        //    System.debug('>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<');
            
        //    if (preapplicationid != null){ 
        //        pageTemplateName = 'Roles and Responsibilities 4';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PreApplication__c',preapplicationid,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',comments,true);
        //        listDefaultValues.add(dv);  
        //        listDefaultValues.add(dv1); 
        //        listDefaultValues.add(dv2);
        //    } 
        //    Id awardId = ApexPages.CurrentPage().getParameters().get('awardId');
        //    System.debug('award context: awardId: ' + awardId);
        //    if(awardId != null){
        //        pageTemplateName = 'Roles and Responsibilities 5';
        //        System.debug('pageTemplateName: ' + pageTemplateName);
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1); 
        //    }
        //    Id amendmentId =  ApexPages.CurrentPage().getParameters().get('amendmentId');
        //    if(amendmentId != null){
        //        pageTemplateName = 'Roles and Responsibilities 6';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AmendmentRequest__c',amendmentId,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);
        //    }
        //    Id programId =  ApexPages.CurrentPage().getParameters().get('programid');
        //    if(programId != null){
        //        Program__c currentProgram = [SELECT Id, Account__r.Name FROM Program__c WHERE Id=: programId];
        //        /*
        //        RolesAndResponsibilities__c rolesAndResp = [SELECT Id, BusinessRole__c FROM RolesAndResponsibilities__c WHERE Id =: recordId];
        //        if (currentProgram.Account__r.Name == 'USBE') { 
        //            pageTemplateName = 'Roles and Responsibilities USBE';
        //            if (rolesAndResp.BusinessRole__c == 'Owner') {
        //                profileTypeUSBE = 'System Administrator';
        //                profileFilterQueryUSBE = 'PM';
        //            }
        //            else if (rolesAndResp.BusinessRole__c == 'Grants Manager') {
        //                profileTypeUSBE = 'PM';
        //            }
        //            else if (rolesAndResp.BusinessRole__c == 'Payment Approver 1') {
        //                profileTypeUSBE = 'PM';
        //            }
        //            else if (rolesAndResp.BusinessRole__c == 'Payment Approver 2') {
        //                profileTypeUSBE = 'SEC FIN';
        //            }
        //            else if (rolesAndResp.BusinessRole__c == 'Payment Approver 3') {
        //                profileTypeUSBE = 'FA2';
        //            }
        //            else if (rolesAndResp.BusinessRole__c == 'Payment Approver 4') {
        //                profileTypeUSBE = 'FM1';
        //            }
        //            else if (rolesAndResp.BusinessRole__c == 'Executive Approver') {
        //                profileTypeUSBE = 'EXE';
        //            } 
        //        }
        //        else { }*/
        //        pageTemplateName = 'Roles and Responsibilities 7';
        //        String defComments = GNT.KeyValueStoreHelper.getTextValue('DefaultComPrograms',true);
        //        System.debug('The comments are '+defComments); 
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programId,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Responsibility__c',defComments,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);
        //        listDefaultValues.add(dv2);   
        //    }
        //    Id progressReportId=  ApexPages.CurrentPage().getParameters().get('progressReportId');
        //    if(progressReportId!= null){ 
        //        pageTemplateName = 'Roles and Responsibilities 8';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProgressReport__c',progressReportId,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);   
        //    }
            
        //     Id siteVisitId=  ApexPages.CurrentPage().getParameters().get('siteVisitId');
        //    if(siteVisitId!= null){ 
        //        pageTemplateName = 'Roles and Responsibilities 9';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SiteVisit__c',siteVisitId,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);   
        //    }
            
        //    Id closeOutId=  ApexPages.CurrentPage().getParameters().get('closeOutId');
        //    if(closeOutId!= null){ 
        //        pageTemplateName = 'Roles and Responsibilities 10';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Closeout__c',closeOutId,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);   
        //    }
    
        //    Id riskAssessmentId=  ApexPages.CurrentPage().getParameters().get('riskAssessmentId');
        //    if(riskAssessmentId!= null){ 
        //        pageTemplateName = 'Roles and Responsibilities 11';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'RiskAssessment__c',riskAssessmentId,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);   
        //    }
        //    Id finetprogramid=  ApexPages.CurrentPage().getParameters().get('finetprogramid');
        //    if(finetprogramid!= null){ 
        //        pageTemplateName = 'Roles and Responsibilities 12';
        //        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FINETProgram__c',finetprogramid,true);
        //        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        //        listDefaultValues.add(dv);
        //        listDefaultValues.add(dv1);   
        //    }   
        //}
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        //keyValueMap.put('applicationid',ApexPages.currentPage().getParameters().get('id'));
        //keyValueMap.put('orgId',organizationId);  
        keyValueMap.put('orgId',userList[0].Organization__c);
        keyValueMap.put('profileTypeUSBE', profileTypeUSBE); 
        keyValueMap.put('profileFilterQueryUSBE ', profileFilterQueryUSBE); 
        //keyValueMap.put('profileTypeListUSBE', profileTypeListUSBE);
        return JSON.serialize(keyValueMap);
    }

}