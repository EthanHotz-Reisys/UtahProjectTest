global with sharing class CreateRolesAndResponsibilitiesFINETCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public ID finetprogramid{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String pageTemplateName {get;set;}
    private Account accnt;
    
    public CreateRolesAndResponsibilitiesFINETCtrl (ApexPages.StandardController stdController){
        //recordId = ApexPages.CurrentPage().getParameters().get('programId');
        finetprogramid = ApexPages.CurrentPage().getParameters().get('finetprogramid');
        pageTemplateName = 'RolesAndResponsibilitiesIntermediateLayoutFINET';
        
        RecordType recordType = [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE DeveloperName = 'ProgramUSBE' AND sObjectType =: AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c'];
        System.debug(' The Record Type is '+recordType);
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FINETProgram__c',finetprogramid,true);
        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        listDefaultValues.add(dv);
        listDefaultValues.add(dv1);
        
        ApexPages.CurrentPage().getParameters().put('idVal', finetprogramid);
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
        keyValueMap.put('finetprogramid', finetprogramid);
        //keyValueMap.put('UserId',UserInfo.getUserId());  
        return JSON.serialize(keyValueMap);
    }
  
}