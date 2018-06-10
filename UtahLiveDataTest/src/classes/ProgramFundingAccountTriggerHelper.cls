global class ProgramFundingAccountTriggerHelper extends GNT.TriggerHelper{
    
    global override void processAfterInsert() {
    //  updateFundingSourceShare();   
       updateFundedAmount(Trigger.New);  
    }

    public override void processAfterDelete() {
        updateFundedAmount(Trigger.old);
    }
    
     /*
        Share (EDIT) the programs with Internal users based on the Account -> Role -> Group
    */
   /* private void updateFundingSourceShare(){
        Set<Id> programIds = new Set<Id>();
        Set<Id> fundingAccountIds = new Set<Id>();
        // get all the accounts associated with the programs
        for(ProgramFundingAccount__c programFundAccount :(List<ProgramFundingAccount__c>) trigger.new){
            programIds.add(programFundAccount.program__c);
            fundingAccountIds.add(programFundAccount.FundingAccount__c);
        }
        List<Program__c> programs = [select id,OrganizationName__c from Program__c where id in :programIds];
        Map<Id,String> programAccountName = new Map<Id,String>();
        for(Program__c program :programs){
            programAccountName.put(program.id,program.OrganizationName__c); 
        }
        List<FundingAccount__c> fundingAccounts = [select id,FundingSource__c from FundingAccount__c where id in :fundingAccountIds];
        Map<Id,String> fundingAccountSourceMap = new Map<Id,String>();
        for(FundingAccount__c fundingAccount :fundingAccounts){
            fundingAccountSourceMap.put(fundingAccount.id,fundingAccount.FundingSource__c); 
        }
        // get all the Roles associated with thse Accounts
        Map<Id, UserRole> roleMap = new Map<Id, UserRole>([Select Id, Name from UserRole where Name in :programAccountName.values()]);
        Map<String, UserRole> acctRoleMap = new Map<String, UserRole>();
        for (UserRole role : roleMap.values()) {
            acctRoleMap.put(role.Name, role);
        }
        // get all the Groups associated with these Roles
        List<Group> groups= [select id,Name,RelatedId from Group where type = 'Role' and RelatedId in :roleMap.keySet()];
        Map<Id, Group> groupMap = new Map<Id, Group>(); //key->role id
        for (Group gp : groups) {
            groupMap.put(gp.RelatedId, gp);
        }
        // share the programs created with all the internal user who belong to the fetched Groups
        List<FundingSource__Share> FundingSourceShares = new List<FundingSource__Share>();
        for (ProgramFundingAccount__c progFundAccount : (List<ProgramFundingAccount__c>) Trigger.New) {
            string accountName = programAccountName.get(progFundAccount.program__c);
            UserRole role = acctRoleMap.get(accountName);
            Id fundingSource = fundingAccountSourceMap.get(progFundAccount.FundingAccount__c);
            if(groupMap != null && role != null){
                Group gp = groupMap.get(role.Id);
                if(gp != null){
                    FundingSource__Share share = new FundingSource__Share();
                    share.ParentId = fundingSource; 
                    share.UserOrGroupId = gp.Id;
                    share.AccessLevel = 'edit';
                    FundingSourceShares.add(share);
                }
            }
        }
        insert FundingSourceShares;
    }*/

    // Method to update Program Funded Amount based on Funding Accounts added to ProgramFundingAccount
      private void updateFundedAmount(List<ProgramFundingAccount__c> listProgramFA){

         Set<Id> programIds = new Set<Id>();
        Set<Id> fundingAccountIds = new Set<Id>();
        Decimal SumofFundingAccounts;
        // get all the accounts associated with the programs
        for(ProgramFundingAccount__c programFundAccount :listProgramFA){
            programIds.add(programFundAccount.program__c);
            fundingAccountIds.add(programFundAccount.FundingAccount__c);
        }       
       List<aggregateResult> results = [select Sum(FundingAccount__r.SumOfBudgetCategories__c) Total from ProgramFundingAccount__c where program__c in :programIds];

        for (AggregateResult ar : results)  
        SumofFundingAccounts=(Decimal)ar.get('Total');

        List<Program__c> pgmList = [Select Id, FundedAmount__c from Program__c where  Id In :programIds ];

        pgmList[0].FundedAmount__c=SumofFundingAccounts;

        update pgmList[0];
      }
}