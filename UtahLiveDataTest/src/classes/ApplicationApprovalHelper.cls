global with sharing class ApplicationApprovalHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix();         
        Id announcementId = urlParams.get('id');        
        //Get all the Applications for an Announcement and reset the SelectedForApprovalAction Flag
        List<application__c> allApplicationList = [Select Id, SelectedforApprovalAction__c From Application__c 
                                                Where Announcement__c = :announcementId LIMIT :GNT.AppUtils.SOQL_LIMIT];
                           
        //Reset the SelectedForApprovalAction Flag
        for(application__c appInstance: allApplicationList){
            appInstance.SelectedforApprovalAction__c = false;
        }
        if(Schema.sObjectType.Application__c.isUpdateable()){
            update allApplicationList;
        }                
        
        //Get the selected Application List and set the SelectedForApprovalAction Flag to true                          
        List<application__c> selectedApplicationList = [Select Id, SelectedforApprovalAction__c From Application__c 
                                                Where id in :selectedRecordIds LIMIT :GNT.AppUtils.SOQL_LIMIT];
                
        if(selectedApplicationList.isEmpty() != true){
            for(Application__c appInstance : selectedApplicationList){
                appInstance.SelectedforApprovalAction__c = true;
            }
        }
        if(Schema.sObjectType.Application__c.isUpdateable()){
            update selectedApplicationList;
        }        
        // Replacing all the spaces with underscores in the Action String
        String action = actionConfig.GNT__developeractionname__c.replace(' ', '_');
        String PageReferenceURL = '/apex/'+ns+'ConfirmApplicationApproval?id=' + announcementId + '&action=' + action;
        resultMap.put('PageReference',PageReferenceURL);                                         
        return resultMap;
    }    
}