global class AddSelectedGrantContactToPageCtrl {
    public List<Grant__c> grantList{get; set;}
    public AddSelectedGrantContactToPageCtrl(){
      
                              
         
    }
    public string getListParameters(){
        List<String> recordIds;
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        recordIds = GNT.RecordIdStorageHelper.getRecordIds('SelectedGrants');
        Set<String> recordIdSet = new Set<String>();
        recordIdSet.addAll(recordIds);
        
        listParams.put('selectedRecords',recordIdSet);
        return JSON.serialize(listParams);
    }
}