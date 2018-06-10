public with sharing class ReviewerRegistrationEditCtrl {
    public Id recordId {get; set;}
    public String pageTemplateName {get; set;}
    public PageReference savePage {get;set;}
     public PageReference cancelPage {get;set;}
    public PageReference pageRef {get;set;}
    public string recId{get;set;}
    public List <GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public boolean showCaptcha{get;set;}
    public boolean showCaptchaNot{get;set;}
    
    public ReviewerRegistrationEditCtrl(ApexPages.StandardController stdController) {
  
        recordId = ApexPages.CurrentPage().getParameters().get('id');
       
        // swati added record type 
         String recordtype = ApexPages.CurrentPage().getParameters().get('RecordType');
         String tempLayout= ApexPages.CurrentPage().getParameters().get('tempLayout'); 
         String EIN= ApexPages.CurrentPage().getParameters().get('EIN'); 
         String DUNS= ApexPages.CurrentPage().getParameters().get('DUNS'); 
         String OrganizationName= ApexPages.CurrentPage().getParameters().get('OrganizationName'); 
             system.debug('--contactId--'+ApexPages.CurrentPage().getParameters().get('conId'));
     
         listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
           if (EIN!= null){     
           GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'EINText__c',EIN,true);
            listDefaultValues.add(dv);
            }
           if (DUNS!= null){     
           GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'DUNS__c',DUNS,true);
            listDefaultValues.add(dv1);
            }
           if (OrganizationName!= null){     
           GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OrganizationName__c',OrganizationName,true);
            listDefaultValues.add(dv2);
            }
            
            // swati : added for assigning record type 
            //Recordtype recordType1 = [Select Id,DeveloperName from RecordType where DeveloperName =:recordtype and sObjectType =: AppUtils.getNamespacePrefix()+'UserRegistration__c'];
  
            if(recordtype!=null){
           Recordtype recordType1 = [Select Id,DeveloperName from RecordType where DeveloperName =:recordtype and sObjectType =: AppUtils.getNamespacePrefix()+'UserRegistration__c'];
  
            GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType1.Id,true);
            listDefaultValues.add(dv3);
           } 
            
        
         recId = recordId;
         if(tempLayout <> null){
        
            if(tempLayout == '1'){
             showCaptcha = false;
             showCaptchaNot = true;
               
                  pageTemplateName = 'Reviewer Profile Detail';
               // PageReference pageRef = new PageReference('/apex/ApplicantRegistrationView?tempLayout=1');
                //savePage = Page.pageRef ;
                cancelPage = Page.ApplicantRegistrationPage2;
                //savePage = Page.ApplicantRegistrationView;
               
               savePage = Page.ReviewerRegistrationEdit;
                //savePage.getParameters().put('tempLayout', '2');
                savePage.getParameters().put('id', recordId);
                //pageTemplateName = 'Applicant Org Detail';
                
                
            }
            if(tempLayout == '2'){
            showCaptcha = false;
            showCaptchaNot = true;
                pageTemplateName = 'Applicant Profile Detail';
                cancelPage = Page.ApplicantRegistrationEdit;
                cancelPage .getParameters().put('tempLayout', '1');
                cancelPage .getParameters().put('id', recordId);
                 savePage = Page.ApplicantRegistrationEdit;
                 //savePage = Page.ApplicantRegistrationView;
                  savePage.getParameters().put('id', recordId);
                 //savePage.getParameters().put('tempLayout', '2');
                
                
            }
           
        }
        else{
            showCaptcha = true;
            showCaptchaNot = false;
            //pageTemplateName = 'External Applicant Edit';
             //savePage = Page.ApplicantRegistrationEdit;
            // savePage = Page.tmpCapcha;
        }
  

       
    }
}