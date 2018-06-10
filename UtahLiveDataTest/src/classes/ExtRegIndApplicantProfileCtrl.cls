public with sharing class ExtRegIndApplicantProfileCtrl{
    public Id recordId {get; set;}
    public String pageTemplateName {get; set;}
    public PageReference savePage {get;set;}
     public PageReference cancelPage {get;set;}
    public PageReference pageRef {get;set;}
    public List <GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public boolean showCaptcha{get;set;}
    public boolean showCaptchaNot{get;set;}
    
    public ExtRegIndApplicantProfileCtrl(ApexPages.StandardController stdController) {
        UserRegistrationTriggerHelper.skipTrigger = true;   
        recordId = ApexPages.CurrentPage().getParameters().get('id');
         String tempLayout= ApexPages.CurrentPage().getParameters().get('tempLayout'); 
         String EIN= ApexPages.CurrentPage().getParameters().get('EIN'); 
         String DUNS= ApexPages.CurrentPage().getParameters().get('DUNS'); 
         String OrganizationName= ApexPages.CurrentPage().getParameters().get('OrganizationName'); 
         String UniqueID = ApexPages.CurrentPage().getParameters().get('UniqueID'); 
         String UniqueType = ApexPages.CurrentPage().getParameters().get('UniqueType'); 
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
             if (UniqueID!= null){     
           GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'UniqueID__c',UniqueID,true);
            listDefaultValues.add(dv3);
            }
             if (UniqueType!= null){     
           GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'    UniqueIdType__c',UniqueType,true);
            listDefaultValues.add(dv4);
            }
            
                pageTemplateName = 'IndApplicantProfile';
               // PageReference pageRef = new PageReference('/apex/ApplicantRegistrationView?tempLayout=1');
                //savePage = Page.pageRef ;
                cancelPage = Page.ApplicantLogin4;
                UserRegistrationTriggerHelper.skipTrigger = true; 
                savePage = Page.capchaPage;
                savePage.getParameters().put('id', recordId);
    }
}