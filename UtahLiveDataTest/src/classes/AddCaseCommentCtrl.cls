public with sharing class AddCaseCommentCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues{get;set;}
     @TestVisible
     String parentId;
    
      public CaseComment caseCommentObj{get;set;}
    
      public void addCase() {  
      

     
      
        String comments = caseCommentObj.commentBody;
        
         caseCommentObj.ParentId=parentId;      
         
         insert caseCommentObj;
         
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'Comments Added successfully'));
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-30398')));
         
        //   return new Pagereference('apex/ggsmaster__CaseViewFinal?Id='+recordId);
      
      }
      
    public AddCaseCommentCtrl(ApexPages.StandardController stdController){
    
        recordId = ApexPages.CurrentPage().getParameters().get('Id');   
        
        caseCommentObj = new CaseComment();
        
        system.debug(' AddCaseCommentCtrl--------recordId------'+recordId);
            
        String   retURL = ApexPages.CurrentPage().getParameters().get('retURL');
            
        String[] arrTest = retURL.split('\\&');
  
        system.debug(' AddCaseCommentCtrl--------arrTest------'+arrTest[1]);
        
        parentId = arrTest[1].substring(8);

    }
    
  
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId',ApexPages.currentPage().getParameters().get('id'));      
        return JSON.serialize(keyValueMap);
    }
    
    public Pagereference addComment()
    {
        recordId = ApexPages.CurrentPage().getParameters().get('myrecid');
        Case caseDetails = [Select ID from Case where id =:recordId];
       // caseDetails.Status='Closed';
       // caseDetails.Detailed_Comments__c='Closed by the Requester';
      //  Update caseDetails;
        return new Pagereference('apex/ggsmaster__CaseViewFinal?Id='+recordId);
    }
    
    
}