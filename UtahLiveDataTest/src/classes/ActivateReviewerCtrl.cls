global without sharing class ActivateReviewerCtrl extends GNT.FlexTableActionHandler {
  
  public List<id> selectedIds{get; set;}
  public List<User> userList;
  public List<User> userListToBeUpdated;
  public List<String> emailList;
  public String emailSingleString;
  public String successMessage;
  public String reviewPanelId;
        
  public ActivateReviewerCtrl(){    
    selectedIds = selectedRecordIds;
    emailSingleString ='';    
       //RecordIdStorageHelper.deleteRecordIds('ReviewersToBeActivated');       
  }
  global override Map<String,Object> clickHandler(){
    reviewPanelId = UrlParams.get('reviewPanelId');
    system.debug('reviewPanelId--->>>>'+reviewPanelId);
    Map<String,Object> resultMap = new Map<String,Object>();
    userListToBeUpdated = new List<User>();
    emailList = new List<String>();
    system.debug('selectedIds-------->>>>>'+selectedIds);
    system.debug('selectedRecordIds-------->>>>>'+selectedRecordIds);
    userList = [SELECT Id,Name,IsActive,FirstName,LastName,Email FROM User Where Id IN :selectedRecordIds];
    if(userList.size() > 0){
        for(User singleUser : userList){
          singleUser.IsActive = true;
          userListToBeUpdated.add(singleUser);
          emailSingleString = emailSingleString+singleUser.FirstName+' '+singleUser.LastName+',';
          emailList.add(singleUser.Email);
        }
        emailSingleString = emailSingleString.removeEnd(',');
        system.debug('emailSingleString-------->>>>>'+emailSingleString);
        update userListToBeUpdated;  
        successMessage = 'Following users are Activated successfully :'+emailSingleString;
        
        String ns = AppUtils.getNamespacePrefix();        
           // GNT.RecordIdStorageHelper.setRecordIds(selectedRecordIds,'activatedReviewers');
            PageReference pageRef= new PageReference('/apex/'+ns+'DOH_PanelExternalUserAdd');
            pageRef.getParameters().put('id',reviewPanelId);
            pageRef.setRedirect(false);  
            String PageReferenceURL = '/apex/'+ns+'DOH_PanelExternalUserAdd?id='+reviewPanelId;
            resultMap.put('Message',successMessage);     
            //resultMap.put('PageReference',PageReferenceURL);        
    }else{
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72161'));
    }          
    return resultMap;
  }

}