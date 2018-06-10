global with sharing class ChangeRequestEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
     
    public ChangeRequestEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   

        savePage = Page.ChangeRequestView;
        savePage.getParameters().put('id', recordId);
    }
}