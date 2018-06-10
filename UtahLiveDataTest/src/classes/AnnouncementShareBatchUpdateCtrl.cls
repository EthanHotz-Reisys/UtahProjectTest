global class AnnouncementShareBatchUpdateCtrl implements Database.Batchable<sObject>{
    
    global Set<ID> programIds;
    global Set<ID> accountIds;
    global AnnouncementShareBatchUpdateCtrl(Set<ID> programIds,Set<ID> accountIds){
        this.programIds = programIds;
        this.accountIds = accountIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('select id,AccountName__c from Announcement__c where program__c in :programIds');
    }

    /*Perform fake update*/
    global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Id> announcementIds = new List<Id>();
       Set<String> acctNames = new Set<String>();
       List<Announcement__c> announcements =  (List<Announcement__c>) scope;
       for(Announcement__c announcement : announcements){
          announcementIds.add(announcement.id); 
       }
       List<Account> accounts = [select name from Account where id in :accountIds];
       for(Account account : accounts){
           acctNames.add(account.Name);
       }
       Map<Id, UserRole> roleMap = new Map<Id, UserRole>([Select Id, Name from UserRole where Name in :acctNames]);
       Map<String, UserRole> acctRoleMap = new Map<String, UserRole>();
       List<Group> groups= [select id,Name,RelatedId from Group where type='Role' and RelatedId in :roleMap.keySet()];
       Set<Id> grpId = new Set<Id>();
       for (Group gp : groups) {
            grpId.add(gp.id); 
       }
             
           /* Delete Old Announcement Share */
       List<Announcement__Share> oldAnnouncementShare =[select id from Announcement__Share where UserOrGroupId in :grpId and parentId in :announcementIds AND RowCause IN ('SharetoExternalUsers__c', 'SharetoInternalUsers__c', 'SharingforReviewandApproval__c')]; 
       if(!oldAnnouncementShare.isEmpty()){
            Database.Delete(oldAnnouncementShare, false);
        }       
        /*End*/
       new AnnouncementTriggerHelper().shareToInternalUsers(announcements);
    }

   global void finish(Database.BatchableContext BC){
       system.debug('Batch Job Completed Successfully!!');
   }
}