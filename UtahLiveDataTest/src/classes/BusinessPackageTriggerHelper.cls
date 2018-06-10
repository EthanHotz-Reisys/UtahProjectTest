/*
    All code for Trigger on BusinessPackage Object
    ***********************************************************
    Audit History
    ***********************************************************
    12/14/2015         Davinder Singh           Created 
   
    *********************************************************** 
*/
public with sharing class BusinessPackageTriggerHelper extends GNT.TriggerHelper{
    public static Boolean skipTrigger= false;
    

    public override void processAfterInsert() {
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
         updatePackageName();
      	if(appName == 'StateasGrantor') {
			updateReviewStepTemplate(); 
        }
  	}     
    
     private void updateReviewStepTemplate(){
        Savepoint sp = Database.setSavepoint();
        Map<String, String> bizPackIdByRecordId = new Map<String, String>();
        String type;
        List<ReviewStepTemplate__c> rstList= new List<ReviewStepTemplate__c>();
        List<GNT__Package__c> lst= new List<GNT__Package__c>();
        Map<String, ReviewStepTemplate__c> rstObjList = new Map<String, ReviewStepTemplate__c>();            
		for(BusinessPackage__c businessPkg : (List<BusinessPackage__c>) Trigger.New){
			if(businessPkg.Program__c!=null){
       			bizPackIdByRecordId.put( businessPkg.Id, businessPkg.Program__c);
				type='Program';
          	} else if(businessPkg.FundingOpportunity__c!=null){
               bizPackIdByRecordId.put( businessPkg.Id, businessPkg.FundingOpportunity__c);
               type='Announcement';
            } else {
            	return;
            }    
        }
        system.debug('-inside BusinessPackageTriggerHelper--bizPackIdByRecordId--'+bizPackIdByRecordId);
       	if(type=='Program') {
			rstList = [Select Id,Program__c,PreviewForm__c,StepNumber__c from ReviewStepTemplate__c where Program__c =:bizPackIdByRecordId.values() ];
       	} else if(type=='Announcement') {
	         rstList = [Select Id,Program__c,PreviewForm__c,StepNumber__c from ReviewStepTemplate__c where Announcement__c =:bizPackIdByRecordId.values() ];
       	}
       	system.debug('---rstList-1--'+rstList);
       	if(type=='Program') {
			lst =  [Select (SELECT Id,GNT__FormConfig__c,GNT__FormConfig__r.GNT__FormType__c FROM  GNT__PackageFormsConfig__r order By GNT__Order__c ) FROM GNT__Package__c where id IN (Select PackageConfig__c from BusinessPackage__c where Program__c IN :bizPackIdByRecordId.values() and PackageType__c='App-Review') Limit 1];
       	} else if(type=='Announcement') {
			lst =  [Select (SELECT Id,GNT__FormConfig__c,GNT__FormConfig__r.GNT__FormType__c FROM  GNT__PackageFormsConfig__r order By GNT__Order__c ) FROM GNT__Package__c where id IN (Select PackageConfig__c from BusinessPackage__c where FundingOpportunity__c IN :bizPackIdByRecordId.values() and PackageType__c='App-Review') Limit 1];
       	}

        // For showing the Form Preview link
        // Pankaj : We need to refactor below logic.
        String baseUrl =URL.getSalesforceBaseUrl().toExternalForm();            
        if(lst!=null && lst.size()>0) { 
            List<GNT__PackageFormConfig__c> pkgForm = lst[0].GNT__PackageFormsConfig__r;
            for(GNT__PackageFormConfig__c pkg : pkgForm) {
				for(ReviewStepTemplate__c rst : rstList) {
					System.debug('rst--' + rst);
               		if(rst.StepNumber__c==1 && pkg.GNT__FormConfig__r.GNT__FormType__c=='Pre-Screening') {
              			rst.PreviewForm__c=baseUrl+'/apex/DynamicViewLayout?isPreviewLayout=true&formPackageId='+pkg.Id;
                  		rst.ReviewFormConfig__c=pkg.GNT__FormConfig__c;
                  		rst.previewId__c=pkg.Id;
                  		rstObjList.put(rst.Id, rst);
                  	} else if(rst.StepNumber__c==2 && pkg.GNT__FormConfig__r.GNT__FormType__c=='SME Review') {
                  		rst.PreviewForm__c=baseUrl+'/apex/DynamicViewLayout?isPreviewLayout=true&formPackageId='+pkg.Id;
                  		rst.ReviewFormConfig__c=pkg.GNT__FormConfig__c;
                  		rst.previewId__c=pkg.Id;
                  		rstObjList.put(rst.Id, rst);
                  	} else if(rst.StepNumber__c==3 && pkg.GNT__FormConfig__r.GNT__FormType__c=='Management Review') {
                  		rst.PreviewForm__c=baseUrl+'/apex/DynamicViewLayout?isPreviewLayout=true&formPackageId='+pkg.Id;
                  		rst.ReviewFormConfig__c=pkg.GNT__FormConfig__c;
                  		rst.previewId__c=pkg.Id;
                  		rstObjList.put(rst.Id, rst);
                  	}
        		}
          	}
        }
        try{
      		update rstObjList.values();
        }
        catch(Exception e){
        	Database.rollback(sp);
        	ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Select a Proper Review Package');
            ApexPages.addMessage(errorMessage);
        }
	}

  /* This method creates a unique package name for a package associated with Grant/Program/Announcement 
    It prepends the Id of associated parent to the Package name provided by the user */
  private void updatePackageName(){

      List<BusinessPackage__c> businessLst = new List<BusinessPackage__c>();
      List<BusinessPackage__c> businessLst2 = [Select Id, UniquePackageName__c, FundingOpportunity__r.Name ,Grant__r.Name,Program__r.Name, PackageName__c from BusinessPackage__c where id =:Trigger.New ];
      for(BusinessPackage__c businessPkg : businessLst2){
          if(businessPkg.FundingOpportunity__c !=null){
            String uniqueName = businessPkg.FundingOpportunity__r.Name+' '+ '-'+' '+ businessPkg.PackageName__c;
            businessPkg.UniquePackageName__c = uniqueName;
            businessLst.add(businessPkg);
          }
          else if(businessPkg.Grant__c!=null){
            String uniqueName = businessPkg.Grant__r.Name+' '+ '-'+' '+ businessPkg.PackageName__c;
            businessPkg.UniquePackageName__c = uniqueName;
            businessLst.add(businessPkg);
          }
          else if(businessPkg.Program__c!=null){
            String uniqueName = businessPkg.Program__r.Name+' '+ '-'+' '+ businessPkg.PackageName__c;
            businessPkg.UniquePackageName__c = uniqueName;
            businessLst.add(businessPkg);
            System.debug(businessLst);
          }
          else{
               businessPkg.UniquePackageName__c = businessPkg.PackageName__c;
          }
      }

      update businessLst;
  }
}