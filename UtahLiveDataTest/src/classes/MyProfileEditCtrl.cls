public with sharing class MyProfileEditCtrl{
    
    //Properties
   
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public MyProfileEditCtrl(ApexPages.StandardController stdController){

        savePage = Page.MyProfileView;
        savePage.getParameters().put('id', ApexPages.currentPage().getParameters().get('Id'));
        cancelPage = Page.MyProfileView;
        cancelPage.getParameters().put('id',ApexPages.currentPage().getParameters().get('Id'));
       
    }
}