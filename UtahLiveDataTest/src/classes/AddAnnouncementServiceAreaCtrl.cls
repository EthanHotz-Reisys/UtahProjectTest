global with sharing class AddAnnouncementServiceAreaCtrl extends GNT.FlexTableActionHandler{
    
    public List<id> selectedIds{get; set;}
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String annId= urlParams.get('parentid');
        System.debug('>>>>>>>>>>>>>>'); 
        system.debug('----'+annId);//ApexPages.CurrentPage().getParameters().get('announcementId');
        Announcement__c ann = [Select RecordType.Name from Announcement__c where Id =:annId];
        System.debug('>>>>>>>>>>>>>'+ann.RecordType.Name );
     //   Map<Id,ProgramServiceArea__c> serviceAreas= new Map<Id,ServiceArea__c>([select id,Name from ProgramServiceArea__c where id in :selectedRecordIds]); 
       // System.debug('>>>>>serviceAreas>>>>>>>>'+serviceAreas); 
        System.debug('>>>>>selectedRecordIds>>>>>>>>'+selectedRecordIds);
        List<AnnouncementServiceArea__c> relatedServiceAreas=  new  List<AnnouncementServiceArea__c>();
        
        if(ann.RecordType.Name =='Grantor'){
            for(Id selectedId : selectedRecordIds){
                AnnouncementServiceArea__c relatedServicerea = new AnnouncementServiceArea__c ();
                relatedServicerea .Announcement__c =   annId;
                relatedServicerea .ProgramServiceArea__c = selectedId ;
                relatedServiceAreas.add(relatedServicerea);
            }
        }if(ann.RecordType.Name =='Grantee'){
            for(Id selectedId : selectedRecordIds){
                AnnouncementServiceArea__c relatedServicerea = new AnnouncementServiceArea__c ();
                relatedServicerea .Announcement__c =   annId;
                relatedServicerea .ServiceArea__c = selectedId ;
                relatedServiceAreas.add(relatedServicerea);
            }  
        }
        try{
            upsert relatedServiceAreas;
        }catch(Exception e){
            System.debug('The Excpetion is '+e);
        } 
        
        PageReference pageRef = Page.AnnouncementView;
        pageRef.getParameters().put('id',annId);
        resultMap.put('PageReference',null);
        //resultMap.put('Message','Service area associated succesfully to Announcement.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-87285'));
        return resultMap;
    }
}