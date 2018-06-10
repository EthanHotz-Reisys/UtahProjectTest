global with sharing class EditTermConditionScheduleHandler extends GNT.FlexTableActionHandler {
    public EditTermConditionScheduleHandler() {
        
    }
    global override Map<String,Object> clickHandler() {
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix(); 
        
        
        
        List<TermCondition__c> tcs = new List<TermCondition__c>();
      
      
        
       
        
       
            String PageReferenceURL = '/apex/'+ns+'TermConditionScheduleEdit?id={!' + ns + 'TermConditionSchedule__c.Id}&template=TermConditionNewScheduleTemplate&termConditionId={!termConditionId}';
            
            resultMap.put('PageReference',PageReferenceURL);
        
        
        
        
       
        return resultMap;
    }
}