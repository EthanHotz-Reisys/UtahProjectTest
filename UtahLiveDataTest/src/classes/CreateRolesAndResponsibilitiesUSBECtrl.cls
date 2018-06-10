//public with sharing class CreateRolesAndResponsibilitiesUSBECtrl extends GNT.MasterCtrl {
global with sharing class CreateRolesAndResponsibilitiesUSBECtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public ID programId{get;set;}
    public ID announcementId{get;set;}
    public ID awardId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String pageTemplateName {get;set;}
    private Account accnt;
    
    public CreateRolesAndResponsibilitiesUSBECtrl (ApexPages.StandardController stdController){
        //recordId = ApexPages.CurrentPage().getParameters().get('programId');
        programId = ApexPages.CurrentPage().getParameters().get('programId');
        announcementId= ApexPages.CurrentPage().getParameters().get('announcementId');
        awardId= ApexPages.CurrentPage().getParameters().get('awardId');
        System.debug('LEON TEST=======>'+programId);
        pageTemplateName = 'RolesAndResponsibilitiesIntermediateLayout';
        
        String recordTypeName = ' ';
        Program__c currentProgram = [SELECT Id, ProgramPathway__c, Status__c FROM Program__c WHERE Id =: programId];
        if (currentProgram.ProgramPathway__c != null) {    
            String insertType;
            if (awardId != null) {
                Award__c currentAward = [SELECT Id, Status__c FROM Award__c WHERE Id =: awardId];
                insertType = (currentAward.Status__c == 'Created') ? 'N/A' : 'New';
            }
            else if (announcementId != null) {
                Announcement__c currentAnnouncement = [SELECT Id, Status__c FROM Announcement__c WHERE Id =: announcementId];
                insertType = (currentAnnouncement.Status__c == 'Created') ? 'N/A' : 'New';
            }
            else {
                insertType = (currentProgram.Status__c == 'Created') ? 'N/A' : 'New';
            }
            System.debug('LEON TEST=======>'+currentProgram);
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
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programId,true);
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
            GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',announcementId,true);
            GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
            GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'InsertType__c',insertType,true);
            listDefaultValues.add(dv);
            listDefaultValues.add(dv1);
            listDefaultValues.add(dv2);
            listDefaultValues.add(dv3);
            listDefaultValues.add(dv4);
            
            ApexPages.CurrentPage().getParameters().put('idVal', programId);
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'A program pathway is required'));
        }
    }
    
    
    /*
    @RemoteAction
    global static Map<String, Object> saveAndContinue(String programId) {

        Map<String, Object> result = new  Map<String, Object>();
        system.debug('Inside saveAndContinue:---------------- ' );
        
        Program__c currentProgram = [
            SELECT Id 
            FROM Program__c 
            WHERE Id = :programId];

        Savepoint sp = Database.setSavepoint();
        try {
            RolesAndResponsibilities__c intermediateRolesAndResp = new RolesAndResponsibilities__c();
            intermediateRolesAndResp.Program__c = programId;
            //
            String baseUrl;
            List<GNT__GlobalConfig__c> entries = [Select GNT__CommunityURLDomain__c from GNT__GlobalConfig__c limit 1];
            if (entries.size() == 1) {
                baseUrl = entries.get(0).GNT__CommunityURLDomain__c;
            }
            // String siteUrl=GNT.KeyValueStoreHelper.getTextValue('PublicAnnouncementsSite', true);
            ann.FundingOppURL__c = baseUrl;
            //Database.SaveResult  saveResult = Database.insert(ann);
            //
            GNT__PageDataHolder__c pageDataHolder = new GNT__PageDataHolder__c(GNT__JSONData1__c = JSON.serialize(intermediateRolesAndResp ));
            insert  pageDataHolder;

            Id pagedataHolderId = pageDataHolder.Id;
            result.put('URL', 'apex/RolesAndResponsibilitiesEdit?pageDataHolder=' + pagedataHolderId);
            result.put('Error', '');
            return result;

        } catch (Exception e) {
            result.put('Error', e.getMessage());
            system.debug('Exception: ' + e);
            Database.rollback(sp);
            return result;
        }
        
        //return null;
    }
    */
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        //keyValueMap.put('UserId',UserInfo.getUserId());    
        keyValueMap.put('programid', programId);
        if (announcementId != null) { keyValueMap.put('announcementId ', announcementId); }
        if (awardId != null) { keyValueMap.put('awardId', awardId); }
        //keyValueMap.put('UserId',UserInfo.getUserId());  
        return JSON.serialize(keyValueMap);
    }
  
}