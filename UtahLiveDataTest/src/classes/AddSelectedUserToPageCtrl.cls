global class AddSelectedUserToPageCtrl{
   // public List<UserInvitation__c> userInvitedList{get; set;}
    public AddSelectedUserToPageCtrl(){     
    }
    public string getListParameters(){
        List<String> recordIds;
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();
        recordIds = GNT.RecordIdStorageHelper.getRecordIds('SelectedUserInvitations');
        Set<String> recordIdSet = new Set<String>();
        recordIdSet.addAll(recordIds);
        listParams.put('selectedRecords',recordIdSet);
        return JSON.serialize(listParams);
    }

}