/*
    This class has methods to execute methods related to Funding Source Trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-06-19 Manasi Gangal       Created
    2015-18-12 Ramu Loke           Edited
    **********************************************************  
*/


global class FundingSourceTriggerHelper extends GNT.TriggerHelper{
	global static boolean skipTrigger = false;
    
     public override void processbeforeInsert() {
      if(skipTrigger == false) {
       Populatereferenceno();
       GNT.NameTemplateTriggerHelper.beforeInsert(); 
      }
    } 
    public override void processBeforeUpdate() {
     if(skipTrigger == false) {
       Populatereferenceno();
     }
       
    } 
    public override void processAfterInsert(){
      if(skipTrigger == false) { 
       createExternalBudgetCategories((List<FundingSource__c>)Trigger.New);
       UpdateSumofFundingSourceAmounts(Trigger.new);
       shareToInternalUsers(Trigger.New);
      }
    }
    public override void processAfterUpdate() {
     if(skipTrigger == false) {
       UpdateSumofFundingSourceAmounts(Trigger.new);
       UpdateFundingAccountStatus();
      // shareToInternalUsers(Trigger.New);
     }
    }
    public override void processAfterDelete() {
     if(skipTrigger == false) {
        UpdateSumofFundingSourceAmounts(Trigger.old);
     }
    }
    
    private void shareToInternalUsers(List<FundingSource__c> fsources) {
        Set<Id> ownerIds = new Set<Id>();
        for(FundingSource__c fs : fsources) {
            ownerIds.add(fs.OwnerId);
        } 

        Map<Id, Id> userRoleMap = new Map<Id, Id>();  //key->user id, value->role id
        for (User u : [Select Id, UserRoleId from User where Id in :ownerIds and UserRoleId != null]) {
            userRoleMap.put(u.Id, u.UserRoleId);
        }

        Map<Id, Group> roleGroupMap = new Map<Id, Group>(); //key->role id, value->group
        for (Group gp : [Select Id, RelatedId from Group where RelatedId in :userRoleMap.values() and Type='RoleAndSubordinatesInternal']) {
            roleGroupMap.put(gp.RelatedId, gp);
        }

        List<FundingSource__Share> sharesToInsert = new List<FundingSource__Share>();
        for(FundingSource__c fs : fsources) {
            Id roleId = userRoleMap.get(fs.OwnerId);
            if (roleId != null) {
                Group gp = roleGroupMap.get(roleId);
                FundingSource__Share share = new FundingSource__Share();
                share.ParentId = fs.Id; 
                share.UserOrGroupId = gp.Id;
                share.AccessLevel = 'edit';
                share.Rowcause = Schema.FundingSource__Share.RowCause.SharetoUsersinSameAccount__c;
                sharesToInsert.add(share);
            }
        }        
        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.upsertFundingSourceShare(sharesToInsert);

    }

    /*Method for Creating External Budget Categories that are at Award level with in same Grant*/
   private void createExternalBudgetCategories(List<FundingSource__c> fsource) {
        Map<Id, List<FundingSource__c>> grantFsMapList = new Map<Id, List<FundingSource__c>>();
        List<Id> grantIds = new List<Id>();
        list<id> funsourceids = new List<id>();
        for (FundingSource__c funsource :fsource){
              funsourceids.add(funsource.id);
            }
        for (FundingSource__c funsource :fsource){
              grantIds.add(funsource.Grant__c);
              system.debug('GrantIds is:'+grantIds);
              if(grantFsMapList.get(funsource.Grant__c) == null){
                    List<FundingSource__c> fsList = new List<FundingSource__c>();
                    fsList.add(funsource);
                    grantFsMapList.put(funsource.Grant__c,fsList);                  
              }else{
                 grantFsMapList.get(funsource.Grant__c).add(funsource);
              }
              
            }
        
        Map<Id, String> latestAwardIdMap = new Map<Id, String>();
        for (Grant__c grant : [Select Id, LatestAwardId__c from Grant__c where Id in :grantIds]) {
          latestAwardIdMap.put(grant.Id, grant.LatestAwardId__c);
        }

        Map<Id, Award__c> awardMap = new Map<Id, Award__c>([Select Id,IndirectCostRateDecision__c,ApprovedIndirectCostRate__c,AwardedAmountthisAction__c, Grant__r.TypeOfBudgetCategories__c,
                                                     (Select Id, BudgetCategory__c,Amount1__c,BudgetCategoryName__c,RemainingAmount__c from Award_Budget_Categories__r) 
                                                      from Award__c where Id in :latestAwardIdMap.values()]);
        List<FundingSourceBudgetCategory__c> fsbclist = new List<FundingSourceBudgetCategory__c>();
        for (FundingSource__c fs : fsource) {
           if (fs.Grant__c == null || fs.Type__c != 'Federal') continue;
           String latestAwardId = latestAwardIdMap.get(fs.Grant__c);
           Decimal IndirectAmount = 0;
           Award__c latestAward = awardMap.get(latestAwardId);
           String budgetCat = latestAward.Grant__r.TypeOfBudgetCategories__c;

           if(budgetCat.equals('Construction & Non Construction')){
              budgetCat='Indirect Cost Construction';
           }
           else{
              budgetCat = 'Indirect Cost' + ' '+ budgetCat;
           }

           if (latestAward.Award_Budget_Categories__r != null){
                boolean implicit = false;
                FundingSourceBudgetCategory__c fsbcImp = new FundingSourceBudgetCategory__c();
             
             if(latestAward.IndirectCostRateDecision__c == 'Explicit'){
               for (AwardBudgetCategory__c abc : latestAward.Award_Budget_Categories__r) {
                  FundingSourceBudgetCategory__c fsbc = new FundingSourceBudgetCategory__c();
                  fsbc.FundingSource__c  = fs.Id;
                  fsbc.BudgetCategory__c = abc.BudgetCategory__c;
                  fsbc.TotalAmountAllocated__c = abc.Amount1__c;
                  fsbc.AwardBudgetCategory__c = abc.Id;
                  fsbclist.add(fsbc);
                }
             }
            else if(latestAward.IndirectCostRateDecision__c == 'Implicit' ){
                  implicit = true;
                    for (AwardBudgetCategory__c abc : latestAward.Award_Budget_Categories__r) {
                      if((abc.BudgetCategoryName__c != GNT.KeyValueStoreHelper.getTextValue(budgetCat,true))){
                            FundingSourceBudgetCategory__c fsbc = new FundingSourceBudgetCategory__c();
                            fsbc.FundingSource__c  = fs.Id;
                            fsbc.BudgetCategory__c = abc.BudgetCategory__c;
                            fsbc.TotalAmountAllocated__c = abc.Amount1__c - ((abc.Amount1__c * latestAward.ApprovedIndirectCostRate__c)/100);
                            fsbc.AwardBudgetCategory__c = abc.Id;
                            IndirectAmount = IndirectAmount + ((abc.Amount1__c * latestAward.ApprovedIndirectCostRate__c)/100);
                            fsbclist.add(fsbc);
                      }
                      else if(abc.BudgetCategoryName__c == GNT.KeyValueStoreHelper.getTextValue(budgetCat,true)){
                            fsbcImp.FundingSource__c  = fs.Id;
                            fsbcImp.BudgetCategory__c = abc.BudgetCategory__c;
                            fsbcImp.AwardBudgetCategory__c = abc.Id;
                        }
                  }
                  if(implicit){
                  fsbcImp.TotalAmountAllocated__c = IndirectAmount;
                  fsbclist.add(fsbcImp);
                } 
              }
           }
        }
        if(!fsbclist.isEmpty()){
             insert fsbclist;
        } 
   } 
   
   private void UpdateSumofFundingSourceAmounts(List<FundingSource__c> lstfundingsource){
        Set<Id> grantids = new Set<Id>();
        map<id,double> grantMap = new map<id,double> ();
        for (FundingSource__c funsource : lstfundingsource) {   
        if (funsource.Grant__c != null) {
            grantids.add(funsource.Grant__c);
        }
       }
      List<Grant__c> funsourceToRollup = new List<Grant__c>();
      for (AggregateResult ar : [select Grant__c,sum(TotalAllocatedAmount__c) total
                                 from FundingSource__c where Grant__c IN :grantids 
                                 group by Grant__c]){
        grantMap.put((Id)ar.get(AppUtils.getNamespacePrefix()+'Grant__c'),(Double)ar.get('total'));
      }
      List<Grant__c> GrantsToUpdate = new List<Grant__c> ();
      for(Grant__c grant : [Select Id, TotalFundingSourceAllocatedAmount__c from Grant__c where Id IN :grantids]){
               Double Fundingsourcesum = grantMap.get(grant.Id);
               grant.TotalFundingSourceAllocatedAmount__c = Fundingsourcesum;
               GrantsToUpdate.add(grant);
      }
      update GrantsToUpdate;
    }
    
   /* METHOD TO UPDATE THE STATUS OF THE FUNDING ACCOUNTS IF FUNDING SOURCE IS UPDATED */
    private static void UpdateFundingAccountStatus(){
        Set<id> fundingsourceids = new Set<id>();
        List<FundingAccount__c> updatefunacctslist= new List<FundingAccount__c>();
        for(FundingSource__c fsource: (list<FundingSource__c>)Trigger.new){
            fundingsourceids.add(fsource.id);
        }
        List<FundingAccount__c> fundingaccntlist = [select id,FundingSource__c, FundingSource__r.Status__c,Status__c from FundingAccount__c where FundingSource__c IN:fundingsourceids];
      if (!fundingaccntlist.isempty()){
       // for(FundingSource__c fsource: (list<FundingSource__c>)Trigger.new){
            for(FundingAccount__c faccnt: fundingaccntlist){
                if(faccnt.FundingSource__r.Status__c == 'Created' || faccnt.FundingSource__r.Status__c == 'Approved'){
                    faccnt.Status__c = 'Created';
                }
                else if(faccnt.FundingSource__r.Status__c == 'Active'){
                    faccnt.Status__c = 'Funded';
                }
                else{
                    faccnt.Status__c = 'Closed';
                }
                updatefunacctslist.add(faccnt);
             }
       //   }
          if(!updatefunacctslist.isempty()){
             update updatefunacctslist;
          }
        }       
    }
    
   /* METHOD to Update the Reference number based on Grant ID*/
    private static void Populatereferenceno(){
        Set<Id> grantIds = new Set<Id>();
        
        for(FundingSource__c fsource: (list<FundingSource__c>)Trigger.new){
            if(fsource.Grant__c != null){
             grantIds.add(fsource.Grant__c);
            }
          }

        // SOQL the parent records
         Map<Id, Grant__c> grants = new Map<Id, Grant__c>(); 
         if(!grantIds.isEmpty()){ 
                grants = new Map<Id, Grant__c>([select id, Name,LatestAwardLink__c from Grant__c where id in: grantIds]);
         }

         for(FundingSource__c fsource: (list<FundingSource__c>)Trigger.new){
            if(fsource.Grant__c != null){
              Grant__c grant = grants.get(fsource.Grant__c);
              fsource.ReferenceNumber__c = grant.LatestAwardLink__c ; 
       }
     }
   }
}