/*  
     This is a data cleanup batch for FormulaFields.
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-05-22       Charan           Created 
    
    **********************************************************************************************************************  
*/ 
global with sharing class ObsoleteFieldCodeFinder {
	
	String objectName;
	List<String> fieldNames;

	public ObsoleteFieldCodeFinder(String objName) {
		this.objectName=objName;

	}
	/*public ObsoleteFieldCodeFinder(String objName, List<String> fieldNames) {
		this.objectName=objName;
		this.fieldNames = fieldNames;
		//fetch class, trigger, pages & components

	}
	global void execute(SchedulableContext ctx) {

	}*/
	public Map<String,List<String>> findObsoleteFields(List<ApexClass> classes,
														List<ApexTrigger> triggers,
														List<ApexPage> pages,
														List<ApexComponent> components){
		Map<String,List<String>> listNames=new Map<String,List<String>>();
        List<String> fieldNames=listOfFields(objectName);
        for(String field:fieldNames){ 
        	List<String> names=new List<String>();
        	names.addAll(checkInApexClasses(classes,objectName,field));
        	names.addAll(checkInApexTriggers(triggers,objectName,field));
    		names.addAll(checkInApexPages(pages,objectName,field));
    		names.addAll(checkInApexComponent(components,objectName,field));
    		listNames.put(field,names);
        }
        return listNames;
	}

	
	public List<String> listOfFields(String objectName){
        List<String> fieldNames=new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
        	Schema.DescribeFieldResult common=fieldMap.get(fieldName).getDescribe();
            String fieldLabel = common.getLabel();
            Schema.DisplayType fielddataType = common.getType();
             if(fielddataType == Schema.DisplayType.Boolean) {
                fieldNames.add(fieldName);
             }
         }
        return fieldNames;
    }
    private List<String> checkInApexClasses(List<ApexClass> classes,String objName,String x){
		List<String> classNames=new List<String>();
		for(ApexClass classRecord:classes){
				if(classRecord.Body.contains(x) && classRecord.Body.contains(objName)){
					classNames.add('Class: '+classRecord.Name);
				}
			}
		return classNames;
	}
	private List<String> checkInApexTriggers(List<ApexTrigger> triggers,String objName,String x){
		List<String> triggerNames=new List<String>();
		List<ApexTrigger> newList=triggers;
		for(ApexTrigger triggerRecord:newList){
				if(triggerRecord.Body.contains(x) && triggerRecord.Body.contains(objName)){
					triggerNames.add('Trigger: '+triggerRecord.Name);
				}
			}
		return triggerNames;
		
	}
	private List<String> checkInApexPages(List<ApexPage> pages,String objName,String field){
		List<String> pageNames=new List<String>();
		for(ApexPage page:pages){
				if(page.Markup.contains(field) && page.Markup.contains(objName)){
					pageNames.add('Page: '+page.Name);
				}
			}
		return pageNames;
	}

	private List<String> checkInApexComponent(List<ApexComponent> components,String objName,String field){
		List<String> componentNames=new List<String>();
		for(ApexComponent component:components){
				if(component.Markup.contains(field) && component.Markup.contains(objName)){
					componentNames.add('Component: '+component.Name);
				}
			}
		return componentNames;
	}
}