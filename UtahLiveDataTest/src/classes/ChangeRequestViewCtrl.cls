public with sharing class ChangeRequestViewCtrl{
    //Properties
    public ID recordId{get;set;}
    
    public ChangeRequestViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    }
}