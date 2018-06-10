global class NewPreAwardRequestCtrl extends GNT.FlexTableActionHandler{
    global Map<String,Object> resultMap;
    global override Map<String,Object> clickHandler(){
    system.debug('=========in new pre award ======');
        resultMap = new Map<String,Object>();
        String[] status = GNT.KeyValueStoreHelper.getTextValue('ChangeRequestNewCRValidation',true).split(',');
        System.debug('UrlParams--->>>'+urlParams);
        String recordId = urlParams.get('parentRecordIdOfFlexTable');
        system.debug('=========in new pre award ==recordId ===='+recordId );
        List<Application__c> appList = [SELECT Id,Name,ProjectOfficer__c,GrantMonitor__c,DataEvaluator__c,Announcement__c  FROM Application__c WHERE Id =:recordId];
        if(appList.size() > 0){
               List<ChangeRequest__c> changeReqList = [Select Id  from ChangeRequest__c where Application__c=:recordId AND Status__c in :status ];
               if(changeReqList.size() > 0){
                   resultMap.put('Error',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-13127'));
               }else{
                   resultMap.put('PageReference','/apex/'+AppUtils.getNamespacePrefix()+'SubmissionRequestEdit?applicationid='+recordId);
                    appList[0].DisplayInitiateAward__c = true;
                    update appList[0];
               } 
         }
        return resultMap;    
    }
}