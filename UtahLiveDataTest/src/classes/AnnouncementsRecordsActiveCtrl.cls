public with sharing class AnnouncementsRecordsActiveCtrl{
    
    public String templateName{get;set;}
    private Set<String> recordsIdSet;
    private List<Id> addedRecords =new List<Id>();
    Map<String,String> keyValueMap = new Map<String,String>();

    public AnnouncementsRecordsActiveCtrl(){
         //templateName = 'AnnouncementsExternal';
        templateName = 'AnnouncementsExternalActive';
        String type  = ApexPages.CurrentPage().getParameters().get('type');
             User currentUser= [Select GNT__OrganizationId__c from User where Id=:UserInfo.getUserId()];
             system.debug('--currentUser--'+currentUser);
             List<SoleSourceAwardRecipient__c> solesourceList=   [Select Id,Name,FundingOpportunity__c from SoleSourceAwardRecipient__c where Account__r.Id =:currentUser.GNT__OrganizationId__c];
                          system.debug('--solesourceList--'+solesourceList);
        //     Announcement__c annList = [Select Id, Name from announcement__c where announcementType__c='Competitive' OR Id IN :solesource.FundingOpportunity__c];             
            Set<Id> annIds = new Set<Id>();
            for(SoleSourceAwardRecipient__c ss : solesourceList)
            {
            annIds.add(ss.FundingOpportunity__c);
            
            }
            
            system.debug('--annIds--'+annIds);

            Account acct = [Select ApplicantType__c, ApplicantTypeOther__c from Account where Id = :currentUser.GNT__OrganizationId__c];
            String whereClause = '(EligibleApplicantTypes__c INCLUDES (\'' + acct.ApplicantType__c + '\') OR OtherEligibleApplicantTypes__c = \'' + acct.ApplicantTypeOther__c + '\')' + 'AND Status__c = \'Published\' AND ApplicationDeadlineWithDateTime__c >= TODAY and RecordType.Name = \'Grantor\'';
            keyValueMap.put('whereClause', whereClause);
        
            Map<Id,announcement__c>  fundingOppMap = new Map<Id,announcement__c> ([Select Id, Name from announcement__c where (Status__c='Published'  AND ApplicationDeadlineWithDateTime__c >=TODAY) and RecordType.Name = 'Grantor' and (announcementType__c='Competitive' OR announcementType__c='Formula Grants' OR Id IN :annIds)]);
           recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(fundingOppMap.keyset()), Set<String>.class);
     
          system.debug('--fundingOppMap --'+fundingOppMap );
         
          system.debug('--recordsIdSet --'+recordsIdSet ); 
          
           system.debug('--recordsIdSet --'+recordsIdSet.size() );
        
    }
    
    public string getKeyValueMap(){
        
        return JSON.serialize(keyValueMap);
    }

     public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();     
        listParams.put('recordsIdSet',recordsIdSet);
        return JSON.serialize(listParams);
      }
}