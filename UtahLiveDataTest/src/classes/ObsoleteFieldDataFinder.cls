/*  
     This is a data cleanup batch for FormulaFields.
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-05-18       Charan           Created 
    
    **********************************************************************************************************************  
*/ 
global with sharing class ObsoleteFieldDataFinder implements Schedulable{
    List<GNT__PageBlockConfig__c> pageblocks;
    List<GNT__PageBlockDetailConfig__c> pageBlockDetails;
    List<GNT__PageAttachmentConfig__c> pageAttchs;
    List<GNT__PageLayoutActionConfig__c> pageLayouts;
    List<GNT__MessageConfig__c> msgConfigs;
    List<GNT__TabConfig__c> tabConfigs;
    List<GNT__DataTableAction__c> dataTableActns;
    String objectName;

    public ObsoleteFieldDataFinder(String objName, List<String> fieldNames) {
        /*this.objectName=objName;
        this.fieldNames = fieldNames;
        //fetch class, trigger, pages & components
*/
    }
    global void execute(SchedulableContext ctx) {

    }

    public ObsoleteFieldDataFinder(String objName) {
        this.objectName=objName;
        this.pageblocks=[Select GNT__HideDecisionField__c 
                        from GNT__PageBlockConfig__c 
                        where GNT__HideDecisionField__c!=null];
        this.pageBlockDetails=[Select GNT__HideDecisionExpression__c,
                                GNT__HideDecisionField__c,
                                GNT__DisableDecisionExpression__c,
                                GNT__ReadDecisionField__c,
                                GNT__RenderCondition__c 
                                from GNT__PageBlockDetailConfig__c];
        this.pageAttchs=[Select GNT__HideDecisionField__c 
                            from GNT__PageAttachmentConfig__c 
                            where GNT__HideDecisionField__c!=null];
        this.pageLayouts=[Select GNT__HideDecisionExpression__c,
                                GNT__HideDecisionField__c,
                                GNT__DisableDecisionExpression__c,
                                GNT__DisableDecisionField__c 
                                from GNT__PageLayoutActionConfig__c];
        this.msgConfigs=[Select GNT__RenderDecisionField__c 
                        from GNT__MessageConfig__c 
                        where GNT__RenderDecisionField__c!=null];
        this.tabConfigs=[Select GNT__HideDecisionField__c 
                        from GNT__TabConfig__c 
                        where GNT__HideDecisionField__c!=null];
        this.dataTableActns=[Select GNT__HideDecisionField__c 
                        from GNT__DataTableAction__c 
                        where GNT__HideDecisionField__c!=null];
    }

    public List<String> findObsoleteFields(){
        List<String> obsoleteFields= new List<String>();
        List<String> fieldNames=listOfFields(objectName);
        System.debug(fieldNames);
        for(String field:fieldNames){
            Integer count=0;
            List<String> commonField=new List<String>(); 
            commonField.add('GNT__HideDecisionField__c');
            count+=checkForReference(pageblocks,commonField,field);
            List<String> pageBlockFields=new List<String>();
            pageBlockFields.add('GNT__HideDecisionExpression__c');
            pageBlockFields.add('GNT__HideDecisionField__c');
            pageBlockFields.add('GNT__DisableDecisionExpression__c');
            pageBlockFields.add('GNT__ReadDecisionField__c');
            pageBlockFields.add('GNT__RenderCondition__c');
            if(count==0){
                count+=checkForReference(pageBlockDetails,pageBlockFields,field);
            }
            if(count==0){
                count+=checkForReference(pageAttchs,commonField,field);
            }
            List<String> pageLayFields=new List<String>();
            pageLayFields.add('GNT__HideDecisionExpression__c');
            pageLayFields.add('GNT__HideDecisionField__c');
            pageLayFields.add('GNT__DisableDecisionExpression__c');
            pageLayFields.add('GNT__DisableDecisionField__c');
            if(count==0){
                count+=checkForReference(pageLayouts,commonField,field);
            }
            List<String> msgConfFields=new List<String>(); 
            msgConfFields.add('GNT__RenderDecisionField__c');
            if(count==0){
                count+=checkForReference(msgConfigs,msgConfFields,field);
            }
            if(count==0){
                count+=checkForReference(tabConfigs,commonField,field);
            }
            if(count==0){
                count+=checkForReference(dataTableActns,commonField,field);
            }
            if(count==0){
                obsoleteFields.add(field);
            }
        }
        return obsoleteFields;
    }

    private List<String> listOfFields(String objectName){
        List<String> fieldNames=new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
        	Schema.DescribeFieldResult common=fieldMap.get(fieldName).getDescribe();
            String fieldLabel = common.getLabel();
            Schema.DisplayType fielddataType = common.getType();
             if(fielddataType == Schema.DisplayType.Boolean)
                fieldNames.add(fieldName);
         }
        return fieldNames;
    }

    private Integer checkForReference(SObject[] records, String[] srcFieldNames, 
            String targetFieldName) {
        Boolean contains=false;
        for(SObject record:records){
            for(String src:srcFieldNames){
            	Object recordObj=record.get(src);
                if(recordObj!=null){
                    String recordValue=String.valueof(record.get(src));
                if(recordValue.contains(targetFieldName)){
                    contains=true;
                    break;
                }

            }
            if(contains){
                break;
            } 
        }
    
    	}
	    if(contains){
	        return 1;
	    }
	    else{
	    	return 0;
	    }
	}

}