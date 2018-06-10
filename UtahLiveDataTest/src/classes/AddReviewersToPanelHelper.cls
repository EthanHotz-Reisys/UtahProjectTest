global with sharing class AddReviewersToPanelHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix(); 
        Id panelId = urlParams.get('parentid');
        String tabName = urlParams.get('tabName');       

        if(selectedRecordIds.isEmpty()) {
          resultMap.put('PageReference',null);
          resultMap.put('Message','No Record Selected');
          return resultMap;
        }
     
        ReviewPanel__c reviewPanel = [SELECT Id, Name,ReviewStep__c FROM ReviewPanel__c WHERE Id=:panelId];
        List<PanelUser__c> panelUserList = new List<PanelUser__c>();
   
        for(String selectedId:selectedRecordIds){
            PanelUser__c panelUser = new PanelUser__c();
            panelUser.Reviewer__c = selectedId;
            panelUser.ReviewPanel__c = panelId;
            panelUserList.add(panelUser);
        }                
        
        if(Schema.sObjectType.PanelUser__c.isCreateable()){
            insert panelUserList;
        }
  
        String PageReferenceURL = '/apex/'+ns+'ReviewPanelView?id=' + reviewPanel.Id;
        if(!String.isEmpty(tabName)){
            PageReferenceURL+='&tabName='+tabName;
        }
      //  resultMap.put('PageReference',PageReferenceURL);                                         
        resultMap.put('PageReference',null);
       // resultMap.put('Message','Reviewer successfully added to Panel.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-60722'));
        return resultMap;
    }    
}