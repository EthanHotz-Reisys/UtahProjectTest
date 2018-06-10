public with sharing class PublicProgramDetailsCtrl{
    
    //Properties Please configure template.
    public  ID recordId{get;set;}
    public  ID programId {get;set;}
    private Boolean rfaParameter;
    public  string templateName {get;set;}
    public  string packageName {get;set;}
    public boolean isExternal {get;set;}
    public boolean isGuest {get; set;}
    private String annType ;
    boolean isInternal;
    public Boolean hideSideBar {get;set;}
    public PublicProgramDetailsCtrl(ApexPages.StandardController stdController){
     recordId = ApexPages.CurrentPage().getParameters().get('id');
       
               
                templateName = 'ProgramExternalGrantor';
                }
             
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();

        //String announcementid = ApexPages.currentPage().getParameters().get('id');
       // keyValueMap.put('announcementId',recordId); 
     

        return JSON.serialize(keyValueMap);
    }

}