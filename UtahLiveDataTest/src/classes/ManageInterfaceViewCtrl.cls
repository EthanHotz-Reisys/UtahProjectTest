/**
    Custom controller to display External API stats 
    
    **********************************************************
    Audit History
    **********************************************************
    06-24-2015      Shrawan Raina          Created
    **********************************************************  
*/
public with sharing class ManageInterfaceViewCtrl extends GNT.ParentController{
    public transient String flexTableName {get; set;}
    private List<InterfaceConfig__c> allInterface {get;set;}
    
    public Integer activeAPICount {get;set;}
    public Integer inactiveAPICount {get;set;}
    public Integer totalAPICount {get;set;}
    
    public ManageInterfaceViewCtrl() {
        flexTableName = ApexPages.currentPage().getParameters().get('ft');
        allInterface = InterfaceConfig__c.getall().values();
        totalAPICount = 0;       
        activeAPICount = 0;
        inactiveAPICount = 0;
        calculateCount();
    }
    
    private void calculateCount() {
        try{
            totalAPICount = InterfaceConfig__c.getall().size();
            for(InterfaceConfig__c interfaceObj : allInterface) {
                if(interfaceObj.isEnabled__c == true) {
                    activeAPICount++;
                }
                else if(interfaceObj.isEnabled__c == false) {
                    inactiveAPICount++;
                }
            }
        }
        catch(Exception e) {
            System.debug('The following exception has occured : ' + e);
        }
    }
}