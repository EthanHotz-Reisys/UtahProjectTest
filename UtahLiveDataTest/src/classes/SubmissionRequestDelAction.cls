global with sharing class SubmissionRequestDelAction  extends GNT.FlexTableActionHandler{
    
    global SubmissionRequestDelAction() {}
    private String ns{get;set;}
    private Boolean flag=false;
    private String crName;
    public String displayMsg{get;set;}
    private Map<String,Object> resultMap;

    global override Map<String,Object> clickHandler(){
        
         if(selectedRecordIds==null || selectedRecordIds.isEmpty()){
         //resultMap.put('Message','No Records have been selected');
         // return resultMap;
        }  
        
        system.debug('--selectedRecordIds--'+selectedRecordIds);
        resultMap = new Map<String,Object>();
        List<ChangeRequest__c> crList = [SELECT Name, Status__c, Application__c from ChangeRequest__c where id = :selectedRecordIds];
        for(ChangeRequest__c cr : crList){
            crName=cr.Name;  
            if(cr.Status__c ==  GNT.KeyValueStoreHelper.getTextValue('SubmissionReqInitStatus', true)){
                flag = true;
                cr.Status__c= GNT.KeyValueStoreHelper.getTextValue('SubmissionReqDeleteStatus', true);
            }
        }
        if(flag){
            update crList;
            displayMsg = 'Revision Request '+crName+' has been successfully Deleted.';
            resultMap.put('Message', displayMsg);
        }else{
        
            displayMsg = 'Revision Request '+crName+' cannot be deleted if it is already Initiated.';
            resultMap.put('Message', displayMsg);            
        }
        return resultMap;
     }
}