global with sharing class FieldSetsConfigSetupIconCtrl {
  global static  String customObjectId {get;set;}
  global static String fieldSetId {get;set;}
  global static String customObFieldSet {get;set;}
  
    @RemoteAction 
  global static String readFieldSetSync(String objName,String fsApiName) {
      /* String fifteenCharacterFieldSetId = GNT.SchemaManager.getFieldSetId(objName,fsApiName);
       String fifteenCharacterCustomObjectId = GNT.SchemaManager.getCustomObjectId(objName);        
        customObFieldSet = fifteenCharacterCustomObjectId +','+ fifteenCharacterFieldSetId;
        return customObFieldSet; */
        return null;
  }
  
}