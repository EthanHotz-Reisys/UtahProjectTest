Public with sharing class ReleaseNotesCtrl{
   public Document document{get;set;}

     public PageReference viewReleaseNotes(){
          ApexPages.CurrentPage().getParameters().get('Name'); 
         document=[SELECT Id FROM Document WHERE Name='GovGrants Release Notes'];
         PageReference pageRef = new PageReference('/servlet/servlet.FileDownload?file='+document.id);
         return pageRef;
    }
 }