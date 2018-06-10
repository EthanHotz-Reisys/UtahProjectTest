public with sharing class AnnouncementFundingAccountsHelper extends GNT.flexTableActionHandler {
      public List<id> selectedIds{get; set;}
   
   public override Map<String,Object> clickHandler(){
        if(urlParams.containsKey('announcementId')) {
            Map<String,Object> resultMap = new Map<String,Object>();
            String announcementId = urlParams.get('announcementId');//ApexPages.CurrentPage().getParameters().get('announcementId');
            Map<Id,FundingAccount__c> fAcc = new Map<Id,FundingAccount__c>([select id,Name from FundingAccount__c where id in :selectedRecordIds]); 
            List<AnnouncementFundingAccount__c> annFundingAccts =  new  List<AnnouncementFundingAccount__c>();
            if(selectedRecordIds.size () == 0){
                resultMap.put('Message',Label.SelectFundingAccountError);
                return resultMap;
            }
            for(Id selectedId : selectedRecordIds){
                AnnouncementFundingAccount__c annFundingAcct = new AnnouncementFundingAccount__c ();
                annFundingAcct.Announcement__c =   announcementId ;
                annFundingAcct.FundingAccount__c = selectedId ;
                annFundingAccts.add(annFundingAcct);
            }
            upsert annFundingAccts;
            PageReference pageRef = Page.AnnouncementView;
            pageRef.getParameters().put('id',announcementId );
            resultMap.put('PageReference',pageRef);
            return resultMap;
        } 
        
        return null;
    }
    
}