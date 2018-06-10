/**
	Fetches meta data for sobjects and fields. It uses caching to avoid governor limit issues
	and improves performance.

	@author Shah kadirmohideen
*/
public with sharing class MetaDataService {
	public static Map<String, SObjectMD> metadataMap = new Map<String, SObjectMD>(); //key->sobject name

	public static Map<String, String> getForeignKeys(String sobjectName) {
		System.debug('finding foreign keys for ' + sobjectName);
		SObjectMD meta = metadataMap.get(sobjectName);
		if (meta == null) {
			meta = fetchForeignKeys(sobjectName);
		}
		return meta.foreignKeys;
	}

	public static Boolean isForeignKey(String sobjectName, String fieldName) {
		Map<String, String> foreignKeys = getForeignKeys(sobjectName); //key->field API name, value->referencing object API name
		Boolean success = foreignKeys != null && foreignKeys.containsKey(fieldName);
		System.debug(sobjectName + '.' + fieldName + ' => is it foreign key? ' + success);
		return success;
	}

	public static String getReferencingObjectName(String sobjectName, String fieldName) {
		Map<String, String> foreignKeys = getForeignKeys(sobjectName); //key->field API name, value->referencing object API name
		return foreignKeys.get(fieldName);
	}

	/* PRIVATE METHODS */

	private static SObjectMD fetchForeignKeys(String sobjectName) {
		System.debug('invoke describe call to fetch foreign keys for ' + sobjectName);
		Schema.SObjectType stype = Schema.getGlobalDescribe().get(sobjectName);
		Map<String, SObjectField> fields = stype.getDescribe().fields.getMap();
		Map<String, String> foreignKeys = new Map<String, String>();
        for(SObjectField fieldToken : fields.values()) {
            DescribeFieldResult fr = fieldToken.getDescribe();
            if (fr.getReferenceTo() != null && fr.getReferenceTo().size() > 0) {
            	foreignKeys.put(fr.getName(), fr.getReferenceTo().get(0).getDescribe().getName());
            }
        }

		SObjectMD md = new SObjectMD(sobjectName, foreignKeys);
		metadataMap.put(sobjectName, md);

		System.debug('foreign keys found: ' + foreignKeys);
		return md;
	}

	public class SObjectMD {
		public String sobjectName;
		public Map<String, String> foreignKeys = new Map<String, String>();  //key->field API name, value->referencing object API name

		public SObjectMD(String sobjectName, Map<String, String> foreignKeys) {
			this.sobjectName = sobjectName;
			this.foreignKeys = foreignKeys;
		}
	}
}