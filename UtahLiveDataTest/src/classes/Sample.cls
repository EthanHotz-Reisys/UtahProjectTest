public with sharing class Sample {
    public transient String themeDocURL {get; set;}
    public transient String imageURL{get;set;}
    
   public Sample ()
  {
     imageURL='/servlet/servlet.FileDownload?file=';
        String docName = GNT.KeyValueStoreHelper.getTextValue('PDFHeaderImageDocName',true);
        List< document > documentList=[select Name from document where Name=:docName ];
        if(documentList.size()>0) {
          imageURL=imageURL+documentList[0].id;
        }
         
        String themeDoc = 'GovGrantsThemeToPrint';
        List<Document> docList = [SELECT Id FROM Document WHERE Name =:themeDoc];
        if(docList.size() > 0){
            themeDocURL = '/servlet/servlet.FileDownload?file=' + docList[0].Id;
        }  
     
  }
    
}