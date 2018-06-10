public interface FileBatchProcess {
	Map<String, String> getData(FileBatch__c fb);
	Map<String, List<String>> approve(FileBatch__c fb);
	Map<String, List<String>> reject(FileBatch__c fb);
}