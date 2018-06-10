global with sharing class RiskItemEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public ID riskAssessmentID{get;set;}
    public ID grantId{get;set;}
    public ID programId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String templateName {get;set;}
    public Boolean hideCancelBtn {get;set;}
    
    private  Grant__c grantObj;
    private  List<Grant__c> grantObjList;
    private  RiskAssessment__c riskObj;
    
    public RiskItemEditCtrl (ApexPages.StandardController stdController){
        
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        riskAssessmentID = ApexPages.CurrentPage().getParameters().get('riskAssessmentID');  
        grantId = ApexPages.CurrentPage().getParameters().get('grantId');  
        programId = ApexPages.CurrentPage().getParameters().get('programId');

        

        system.debug('recordId---'+recordId);
        system.debug('riskAssessmentID ---'+riskAssessmentID );

         List<RiskAssessment__c> riskAssessment = [select id,Grant__c 
                                from RiskAssessment__c 
                                where id =: riskAssessmentID limit 1];
            if(riskAssessment!=null&&riskAssessment.size()>0)
            {
                 grantId= riskAssessment[0].Grant__c;
            }
                                         
              
        savePage = Page.RiskItemView; 
        hideCancelBtn = false;
        
        if(recordId!=null)
        {
        savePage.getParameters().put('id', recordId);
        }

        if(riskAssessmentID!=null){
        cancelPage =Page.RiskAssessmentView;
        cancelPage.getParameters().put('id', riskAssessmentID);
        }
        else{
        savePage = Page.RiskItemView; 
        savePage.getParameters().put('id', recordId);
        }
        
      
     
      listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (riskAssessmentID != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'RiskAssessment__c',riskAssessmentID,true);            
            listDefaultValues.add(dv);            
            savePage.getParameters().put('riskAssessmentID', riskAssessmentID);
         }
        if (grantId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);            
            listDefaultValues.add(dv);            
            savePage.getParameters().put('grantId', grantId);
         }

    if (programId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programId,true);            
            listDefaultValues.add(dv);            
            savePage.getParameters().put('programId', programId);
         }

            templateName='Risk Item Config';
    }
    
   
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('id',recordId);
        if (riskAssessmentID != null){
            keyValueMap.put('riskAssessmentID',riskAssessmentID);
        }
        if (grantId != null){
            keyValueMap.put('grantId',grantId);
        }
        
        return JSON.serialize(keyValueMap);
    }

    
}