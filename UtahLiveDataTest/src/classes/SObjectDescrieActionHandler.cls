global with sharing class SObjectDescrieActionHandler extends GNT.FlexTableActionHandler{
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        List<GNT__SobjectConfig__c> liObjects1 = [Select name,GNT__ObjectLabel__c from GNT__SobjectConfig__c];
        system.debug(liObjects1 );
         
        for (GNT__SobjectConfig__c obj : liObjects1 ){
           try{
               List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{obj.name}); 
                String objectLabel = describeSobjectsResult[0].getLabel();
                obj.GNT__ObjectLabel__c=objectLabel;
                system.debug('objectLabel '+objectLabel );
                
           }catch(Exception e){
                obj.GNT__ObjectLabel__c=obj.name;
           }
           
        } 
        
        upsert liObjects1 ;
          resultMap.put('Message','Records Updated.');
          return resultMap;
   }
    
    
}