Public with sharing class DocumentsCtrl{
   public Document document{get;set;}

     public PageReference viewReleaseNotes(){
     
         String docName=ApexPages.CurrentPage().getParameters().get('Name'); 
         document=[SELECT Id FROM Document WHERE Name=:docName];
         PageReference pageRef = new PageReference('/servlet/servlet.FileDownload?file='+document.id);
         return pageRef;
         
  
    }
 }