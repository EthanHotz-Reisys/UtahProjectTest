global with sharing class AddAwardTermConditionCtrl extends GNT.FlexTableActionHandler{
    
    public List<id> selectedIds{get; set;}
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String awardId= urlParams.get('parentid');
        System.debug('>>>>>>>>>>>>>>'); 
        system.debug('----'+awardId);
        System.debug('>>>>>>>>>>>>>');
        if(selectedRecordIds==null||selectedRecordIds.size()<1)
        {
        resultMap.put('PageReference',null);// Message will be shown on Popup window itself
        //resultMap.put('Message','Please select a record.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-67180'));
        return resultMap;
        }
        
        Map<Id,TermCondition__c> termConditionsMap= new Map<Id,TermCondition__c>([select id,Name,Description__c,Status__c,Source__c,Program__c,Title__c,EffectiveFrom__c,EffectiveTill__c from TermCondition__c where id in :selectedRecordIds]); 
        List<TermCondition__c> awardTermConditions =  new  List<TermCondition__c>();
        for(Id selectedId : selectedRecordIds){
            TermCondition__c relatedtermCondition = new TermCondition__c ();
            relatedtermCondition.Description__c = termConditionsMap.get(selectedId).Description__c;
            relatedtermCondition.Status__c = termConditionsMap.get(selectedId).Status__c;
            relatedtermCondition.Title__c = termConditionsMap.get(selectedId).Title__c;  
            relatedtermCondition.Source__c = termConditionsMap.get(selectedId).Source__c;           
            relatedtermCondition.EffectiveFrom__c = termConditionsMap.get(selectedId).EffectiveFrom__c;   
            relatedtermCondition.EffectiveTill__c = termConditionsMap.get(selectedId).EffectiveTill__c;   
            relatedtermCondition.CopiedFrom__c = selectedId;   
            relatedtermCondition.Program__c =   termConditionsMap.get(selectedId).Program__c;
            relatedtermCondition.Award__c =   awardId;

            awardTermConditions.add(relatedtermCondition);
        }
        try{
            insert awardTermConditions;
         }catch(Exception e){
            System.debug('The Excpetion is '+e);
             resultMap.put('PageReference',null);// Message will be shown on Popup window itself
             //resultMap.put('Message','Error in associating Term/Condition.');
             resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-53982'));
             return resultMap;
        } 
        
        PageReference pageRef = Page.ProgramView;
        pageRef.getParameters().put('id',awardId);
        resultMap.put('PageReference',null);// Message will be shown on Popup window itself
        //resultMap.put('Message','Terms associated succesfully to Award.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-78129'));
        return resultMap;
    }
}