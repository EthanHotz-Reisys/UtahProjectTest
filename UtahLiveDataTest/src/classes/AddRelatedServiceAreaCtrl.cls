global with sharing class AddRelatedServiceAreaCtrl extends GNT.FlexTableActionHandler{
    
    public List<id> selectedIds{get; set;}
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String programId= urlParams.get('parentid');
        String objecttype= urlParams.get('type');
        System.debug('>>>>>>>>>>>>>>'); 
        system.debug('----'+programId);//ApexPages.CurrentPage().getParameters().get('announcementId');
        System.debug('>>>>>>>>>>>>>');
        Map<Id,ServiceArea__c> serviceAreas= new Map<Id,ServiceArea__c>([select id,Name from ServiceArea__c where id in :selectedRecordIds]); 
        List<ProgramServiceArea__c> relatedServiceAreas=  new  List<ProgramServiceArea__c>();
        if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
         for(Id selectedId : selectedRecordIds){
            ProgramServiceArea__c relatedServicerea = new ProgramServiceArea__c ();
            relatedServicerea .Program__c =   programId;
            relatedServicerea .ServiceArea__c = selectedId ;
            relatedServiceAreas.add(relatedServicerea);
        }
        //try{
            upsert relatedServiceAreas;
        //}catch(Exception e){
        //  System.debug('The Excpetion is '+e);
        //} 
        
        //PageReference pageRef = Page.ProgramView;
        PageReference pageRef = new PageReference('/apex/SelectRecordsPopUp?parentid='+programId+'&flextable=SelectProgramServiceArea&type='+objecttype); 
        pageRef.getParameters().put('id',programId);
       // resultMap.put('PageReference',pageRef);// Message will be shown on Popup window itself
        //resultMap.put('Message','Service area associated succesfully to Program.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-54103'));
        }
        else{
            //resultMap.put('Message','No records are selected.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
        }
        return resultMap;
    }
}