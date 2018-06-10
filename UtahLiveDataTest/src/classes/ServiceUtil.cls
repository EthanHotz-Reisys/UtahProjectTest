public with sharing class ServiceUtil {

	private static Map<String, Schema.SObjectType> typeMap = new Map<String, Schema.SObjectType>();  //key->sobject name
	private static Map<String, Schema.DescribeFieldResult> fieldMap = new Map<String, Schema.DescribeFieldResult>(); //key->sobjectname + fieldname
	
	public static String concatenate(Set<String> arr, String sep) {
	    String result = '';
	    if (arr == null) return result;
	    Integer i=1;
	    for (String ele : arr) {
	        result += ele;
	        if (i < arr.size()) result += sep;
	        i++;
	    }
	    return result;
	}

	public static String concatenate(List<String> arr, String sep) {
	    String result = '';
	    if (arr == null) return result;
	    Integer i=1;
	    for (String ele : arr) {
	        result += ele;
	        if (i < arr.size()) result += sep;
	        i++;
	    }
	    return result;
	}

	public static String captureErrorMessages(Database.Error[] errors) {
		List<String> messages = new List<String>();
		if (errors != null) {
			for(Database.Error err : errors) {
				List<String> values = new List<String>();
				if (err.getFields() != null && err.getFields().size() > 0) {
					values.add('Fields: ' + concatenate(err.getFields(), ', '));
				}
				if (err.getStatusCode() != null) {
					values.add('Error Code: ' + err.getStatusCode());
				}
				if (String.isNotEmpty(err.getMessage())) {
					values.add('Error Message: ' + err.getMessage());	
				}

				if (values.isEmpty() == false) {
					messages.add(concatenate(values, '; '));
				}
			}
		}
		return concatenate(messages, '\n');
	}	

	//input: 2017-05-23
	public static Date convertDate(String dt) {
		String[] arr = dt.split('-');
		String newDt = arr[1] + '/' + arr[2] + '/' + arr[0];  //converts to: mm/dd/yyyy
		return Date.parse(newDt);
	}

	//input: yyyy-MM-ddTHH:mm:ss.000Z. Example: 2017-04-18T17:12:01.000Z
	public static DateTime convertDateTime(String dtTime) {
		dtTime = dtTime.replace('T', ' ');
		dtTime = dtTime.replace('.000Z', '');
		return DateTime.valueOfGmt(dtTime);
	}

	// typeName must be a valid API name (i.e. custom objects should be suffixed with "__c"):
	public static SObject newSObject(String sobjectName) {
		return getSObjectType(sobjectName).newSObject();
	}	

	public static Schema.SObjectType getSObjectType(String sobjectName) {
		Schema.SObjectType targetType = typeMap.get(sobjectName.toLowerCase());
		if (targetType == null) {
			targetType = Schema.getGlobalDescribe().get(sobjectName);
			if (targetType == null) {
				throw new CustomException('The requested SObject type [' + sobjectName + 
								'] not found on this org.');
			}
			typeMap.put(sobjectName.toLowerCase(), targetType);
		}
		return targetType;
	}

	public static DescribeFieldResult describeField(String fieldName, String sobjectName) {
		DescribeFieldResult result = fieldMap.get((sobjectName + fieldName).toLowerCase());
		if (result == null) {
			Schema.SObjectType targetType = getSObjectType(sobjectName);
			Schema.DescribeSObjectResult objectResult = targetType.getDescribe();
            for (Schema.SObjectField sf : objectResult.fields.getMap().values()) {
                Schema.DescribeFieldResult fieldResult = sf.getDescribe();
                fieldMap.put((sobjectName + fieldResult.getName()).toLowerCase(), fieldResult);                 
            }

            result = fieldMap.get((sobjectName + fieldName).toLowerCase());
			if (result == null) {
				throw new CustomException('The requested field [' + fieldName + 
								'] cannot be found in ' + sobjectName);
			}
		}
		return result;
	}

	public class CustomException extends Exception {}
}