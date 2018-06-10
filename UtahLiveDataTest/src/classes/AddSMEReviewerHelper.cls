global with sharing class AddSMEReviewerHelper extends GNT.FlexTableActionHandler{
    
    public List<id> selectedIds{get; set;}
    
    global override Map<String,Object> clickHandler(){
       Map<String,Object> resultMap = new Map<String,Object>();
       Id appId= urlParams.get('revPanelId');     
       String SME= urlParams.get('type');   
       PanelUserTriggerHelper.skipAll = true;
       ReviewPanel__c app = [Select id,name from ReviewPanel__c where Id =:appId];      
       List<PanelUser__c> relatedPanelUsers=  new  List<PanelUser__c>();
       if(selectedRecordIds!= null && !selectedRecordIds.isEmpty()){
          for(Id selectedId : selectedRecordIds){
                PanelUser__c relatedPanelUser =  new PanelUser__c();
                relatedPanelUser.ReviewPanel__c = appId;
                relatedPanelUser.Reviewer__c = selectedId ;
                relatedPanelUsers.add(relatedPanelUser);           
              }        
          insert relatedPanelUsers;
          
          //resultMap.put('Message','Reviewers added succesfully to Application');
          resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72847'));
        }else{
          //resultMap.put('Message','No records are selected');
          resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
        }         
       return resultMap;
    }
}