global with sharing class EventAcceptActionHelper extends GNT.DynamicLayoutActionRedirect{
//public Id eventId {get;set;}
   global override PageReference whenClicked(){ 
        Map<String,Object> resultMap = new Map<String,Object>();
        Id recordId = layoutHolder.getPrimarySObject().Id;
        Id eventId = ApexPages.CurrentPage().getParameters().get('id');
        System.debug('===> record Id '+recordId);
        System.debug('===> eventId '+eventId);
        //eventId = urlParams.get('id'); 
        EventRelation eveRel = [Select Id,RelationId,EventId,Status from EventRelation where EventId =: recordId];
        eveRel.Status = 'Accepted';
        update eveRel;
        
        System.debug('No records found');
        //resultMap.put('Error','Invitation accepted successfully.');
        resultMap.put('Error',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-84018'));
        return NULL;   
       }
}