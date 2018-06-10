public with sharing class AddAnnouncementDocumentCtrl{

    public String flexTableHeader {get;set;}
    public string announcementId {get;set;}
    public string programId {get;set;}
    private string required {get;set;}
    
    public AddAnnouncementDocumentCtrl(){
        announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');
        programId = ApexPages.CurrentPage().getParameters().get('programId');
        required  = ApexPages.CurrentPage().getParameters().get('required');
        system.debug('required==='+required);
        flexTableHeader  = 'Select Applicable forms to add';
    }
    
     public string getkeyValueMap (){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('required','Optional');
        keyValueMap.put('programId',programId); 
        keyValueMap.put('announcementId',announcementId); 
        if(required == 'true'){
            keyValueMap.put('required','Required');
        } 
        return JSON.serialize(keyValueMap);
    }
    
    public string getListParams(){
        return null;
    }
    

}