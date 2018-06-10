public with sharing class SelectRecordsPopUpCtrl{
    
    public String templateName{get;set;}
    private Set<String> recordsIdSet;
    private List<Id> addedRecords =new List<Id>();
    private String accountId {get;set;}
    
    private Set<String> budgetCategoryRowNumberSet; 

    public SelectRecordsPopUpCtrl(){
        templateName = ApexPages.CurrentPage().getParameters().get('flextable');
        String type  = ApexPages.CurrentPage().getParameters().get('type');
        accountId = ApexPages.CurrentPage().getParameters().get('accountId');
        if(type=='ProgramFA')
        {
            Id programID =  ApexPages.CurrentPage().getParameters().get('parentid');
            for(ProgramFundingAccount__c prFA :[Select Id,FundingAccount__c from ProgramFundingAccount__c where Program__c =: programID])
            {
                addedRecords.add(prFA.FundingAccount__c);
            }
        Map<Id,FundingAccount__c>  fundingAcMap = new Map<Id,FundingAccount__c> ([Select Id, Name from FundingAccount__c where Id Not in :addedRecords]);
       recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(fundingAcMap.keyset()), Set<String>.class);
       }
       else if(type=='ProgramSA')
        {
            Id programID =  ApexPages.CurrentPage().getParameters().get('parentid');
            for(ProgramServiceArea__c prSA :[Select Id,ServiceArea__c from ProgramServiceArea__c where Program__c =: programID])
            {
                addedRecords.add(prSA.ServiceArea__c);
            }
        Map<Id,ServiceArea__c>  serviceAreaMap = new Map<Id,ServiceArea__c> ([Select Id, Name from ServiceArea__c where Id Not in :addedRecords]);
       recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(serviceAreaMap.keyset()), Set<String>.class);
       }
       /* swati added for strategic plan SA */
         else if(type=='StrategicPlanSA')
        {
            Id strategicPlanID =  ApexPages.CurrentPage().getParameters().get('parentid');
            for(StrategicPlanServiceArea__c spSA :[Select Id,ServiceArea__c from StrategicPlanServiceArea__c where StrategicPlan__c =: strategicPlanID])
            {
                addedRecords.add(spSA.ServiceArea__c);
            }
        Map<Id,ServiceArea__c>  serviceAreaMap = new Map<Id,ServiceArea__c> ([Select Id, Name from ServiceArea__c where Id Not in :addedRecords]);
       recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(serviceAreaMap.keyset()), Set<String>.class);
       }
     
        else if(type=='AnnouncementFA')
        {
            Id annID =  ApexPages.CurrentPage().getParameters().get('parentid');
            for(AnnouncementFundingAccount__c annFA :[Select Id,FundingAccount__c from AnnouncementFundingAccount__c where Announcement__c =: annID])
            {
                addedRecords.add(annFA.FundingAccount__c);
            }
        Map<Id,FundingAccount__c>  fundingAcMap = new Map<Id,FundingAccount__c> ([Select Id, Name from FundingAccount__c where Id Not in :addedRecords]);
       recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(fundingAcMap.keyset()), Set<String>.class);
       }
       else if(type=='FedPrograms')
        {
            Id programID =  ApexPages.CurrentPage().getParameters().get('parentid');
            system.debug('--programID--'+programID);
            for(JXPrograms__c prg :[Select Id,FederalProgram__c from JXPrograms__c where StateProgram__c =: programID])
            {
                addedRecords.add(prg.FederalProgram__c);
            }

            system.debug('--addedRecords--'+addedRecords);
        Map<Id,Program__c>  programMap = new Map<Id,Program__c> ([Select Id, Name from Program__c where Id Not in :addedRecords ]);
       recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(programMap.keyset()), Set<String>.class);
       system.debug('--recordsIdSet--'+recordsIdSet);
       }
       else if(type=='ProgramBC')
        {
            Id programID =  ApexPages.CurrentPage().getParameters().get('parentid');
            system.debug('--programID--'+programID);
            for(ProgramBudgetCategory__c prgBC :[Select Id,  BudgetCategory__c from ProgramBudgetCategory__c where Program__c =: programID])
            {
                addedRecords.add(prgBC.BudgetCategory__c);
            }
            system.debug('--addedRecords--'+addedRecords);
        Map<Id,BudgetCategory__c>  budgetCatMap = new Map<Id,BudgetCategory__c> ([Select Id, Name from BudgetCategory__c where Id Not in :addedRecords ]);
       recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(budgetCatMap.keyset()), Set<String>.class);
       system.debug('--recordsIdSet--'+recordsIdSet);
       }
       else if(type =='AwardFA')
        {
            Id awardID =  ApexPages.CurrentPage().getParameters().get('parentid');
            for(AwardFundingAccount__c awdFA :[Select Id,FundingAccount__c from AwardFundingAccount__c where Award__c =: awardID])
            {
                addedRecords.add(awdFA.FundingAccount__c);
            }

            system.debug('--addedRecords--'+addedRecords);
        Map<Id,FundingAccount__c>  fundingaccountMap = new Map<Id,FundingAccount__c> ([Select Id, Name from FundingAccount__c where Id Not in :addedRecords ]);
       recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(fundingaccountMap.keyset()), Set<String>.class);
       system.debug('--recordsIdSet--'+recordsIdSet);
       }
       
       //Filter for the budget categories that correspond to the current program's organization
       system.debug('program id is '+ApexPages.CurrentPage().getParameters().get('parentId'));
        List<Program__c> currentProgram = [SELECT Id, OrganizationName__c FROM Program__c WHERE Id =: ApexPages.CurrentPage().getParameters().get('parentId')];
        String currentProgramGrantorOrg = currentProgram[0].OrganizationName__c;
        System.debug ('MANUALDEBUG---Org Name is: ' + currentProgramGrantorOrg);  
        if (currentProgramGrantorOrg == 'USBE') { //program grantor org = USBE
            budgetCategoryRowNumberSet = new Set<String> {'510', '520', '530', '540', '550', '558', '560', '570', '580'};
        }
        else if (currentProgramGrantorOrg == 'UOVC') { //program grantor org = UOVC
            budgetCategoryRowNumberSet = new Set<String> {'201', '202', '203', '204', '205', '212', '210', '208'};
        }
        else { //program grantor org is something other than USBE or UOVC, modify this section as needed
            budgetCategoryRowNumberSet = new Set<String> {'201', '202', '203', '204', '205', '212', '210', '208'};
        }
        System.debug('MANUALDEBUG---budgetCategoryRowNumberSet: '+ budgetCategoryRowNumberSet);
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('parentid',ApexPages.CurrentPage().getParameters().get('parentid'));
        keyValueMap.put('accountId',ApexPages.CurrentPage().getParameters().get('accountId'));
        
        return JSON.serialize(keyValueMap);
    }

     public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();     
        listParams.put('recordsIdSet',recordsIdSet);
        listParams.put('budgetCategoryRowNumberSet', budgetCategoryRowNumberSet);
        return JSON.serialize(listParams);
      }
}