public with sharing class ReviewerEmailRegViewCtrl{
    public ID recordId{get;set;}
    public String contactId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    public boolean dummy4{get;set;}
    public List <GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
   
    
    
    public ReviewerEmailRegViewCtrl(ApexPages.StandardController stdController){
        dummy4 = false;
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        String tempLayout= ApexPages.CurrentPage().getParameters().get('tempLayout'); 
        contactId = ApexPages.CurrentPage().getParameters().get('conId'); 
        System.debug('--Inside ReviewerEmailRegViewCtrl--'+ApexPages.CurrentPage().getParameters());
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
           if (contactId != null){     
           GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Contact__c',contactId,true);
            listDefaultValues.add(dv);
            }
       
        
        if(tempLayout <> null){
        
            if(tempLayout == '1'){
               // pageTemplateName = 'Applicant Org Detail';
                pageTemplateName = 'External Reviewer COI';
            
               
            }
            if(tempLayout == '2'){
                pageTemplateName = 'Applicant Profile Detail';
            }
              if(tempLayout == '3'){
                pageTemplateName = 'Applicant Confirmation';
            }
            
           
        }
        else{
            pageTemplateName = 'External Reviewer Edit';//TODO get template dynamically from sObjectConfig
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('conId',contactId);
        system.debug('---contactId-'+contactId);
        return JSON.serialize(keyValueMap);
    } 

}