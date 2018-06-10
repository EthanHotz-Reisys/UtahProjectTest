global with sharing class AddProgramTermConditionCtrl extends GNT.FlexTableActionHandler{
    
    public List<id> selectedIds{get; set;}
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String programId= urlParams.get('parentid');
        Integer sequence=0;
        System.debug('>>>>>>>>>>>>>>'); 
        system.debug('----'+programId);
        System.debug('>>>>>>>>>>>>>');
        Map<Id,TermCondition__c> termConditionsMap= new Map<Id,TermCondition__c>([select id,Name,Description__c,Status__c,Title__c,EffectiveFrom__c from TermCondition__c where id in :selectedRecordIds]); 
        List<TermCondition__c> programTermConditions =  new  List<TermCondition__c>();

        if(selectedRecordIds==null||selectedRecordIds.size()<1)
        {
        resultMap.put('PageReference',null);// Message will be shown on Popup window itself
        //resultMap.put('Message','Please select a record.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-67180'));
        return resultMap;
        }

        List<TermCondition__c> tcList = [Select id,SequenceNo__c,Description__c,Status__c,Title__c,EffectiveFrom__c from TermCondition__c where Program__c =:programId];

        if(tcList!=null)
        sequence= tcList.size();

        for(Id selectedId : selectedRecordIds){ 
            TermCondition__c relatedtermCondition = new TermCondition__c ();
            sequence=sequence+1;
            relatedtermCondition.Description__c   = termConditionsMap.get(selectedId).Description__c;
            relatedtermCondition.Status__c        = termConditionsMap.get(selectedId).Status__c;
            relatedtermCondition.Title__c         = termConditionsMap.get(selectedId).Title__c;            
            relatedtermCondition.EffectiveFrom__c = termConditionsMap.get(selectedId).EffectiveFrom__c;   
            relatedtermCondition.SequenceNo__c    = sequence;
            relatedtermCondition.CopiedFrom__c    = selectedId;   
            relatedtermCondition.Program__c       = programId;


            programTermConditions.add(relatedtermCondition);
             system.debug('--relatedtermCondition--'+relatedtermCondition);
        }
        try{
            insert programTermConditions;
            system.debug('--programTermConditions--'+programTermConditions);
        }catch(Exception e){
            System.debug('The Excpetion is '+e);
            resultMap.put('PageReference',null);// Message will be shown on Popup window itself
            //resultMap.put('Message','Error in associating selected Term/Condition.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-53982'));
            return resultMap;
        } 
        
        PageReference pageRef = Page.ProgramView;
        pageRef.getParameters().put('id',programId);
        resultMap.put('PageReference',null);// Message will be shown on Popup window itself
        //resultMap.put('Message','Terms associated successfully to Program.');
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-14350'));
        return resultMap;
    }
}