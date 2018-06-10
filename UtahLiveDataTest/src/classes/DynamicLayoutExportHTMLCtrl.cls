/**
* Class to handle the DynamicLayoutExport page.
* This class is used to export the contents of a Dynamic Layout Page in a PDF. 
*   
*   Inputs Expected: ViewPageTemplateName & RecordID    
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 02/12/2014    Kunal Shah      Created
* 02/14/2014    Kunal Shah      Searching for a Print Layout for a given TemplateName
* =============================================================================
*/

public with sharing class DynamicLayoutExportHTMLCtrl {
    
    //Properties
    public transient ID recordId{get;set;}
    public transient Id pkgId{get;set;}
    public transient string printTemplateName{get;set;}
    
    public transient String topLeftImageURL{get;set;}
    public transient String topMiddleImageURL{get;set;}
    public transient String topRightImageURL{get;set;}
    public transient String bottomLeftImageURL{get;set;}
    public transient String bottomRightImageURL{get;set;}
    
    public transient String topLeftString{get;set;}
    public transient String topMiddleString{get;set;}
    public transient String topRightString{get;set;}
    public transient String bottomLeftString{get;set;}
    public transient String bottomRightString{get;set;}
    public transient String themeDocURL {get; set;}
    
    public DynamicLayoutExportHTMLCtrl(){
        //PageLayoutConfigHelper.isPrint = true;
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pkgId = (ApexPages.CurrentPage().getParameters().get('packageId') != '') ? ApexPages.CurrentPage().getParameters().get('packageId') : null;
        string viewTemplateName = ApexPages.CurrentPage().getParameters().get('viewTemplateName');
        System.debug('viewTemplateName--->>>'+viewTemplateName);  
        findPrintTemplate(viewTemplateName);
        Set<String> docNames = new Set<String>();
        String PDFTopLeftImageDocName = GNT.KeyValueStoreHelper.getTextValue('PDFTopLeftImageDocName',true);
        docNames.add(PDFTopLeftImageDocName);
        String PDFTopMiddleImageDocName = GNT.KeyValueStoreHelper.getTextValue('PDFTopMiddleImageDocName',true);
        docNames.add(PDFTopMiddleImageDocName);
        String PDFTopRightImageDocName = GNT.KeyValueStoreHelper.getTextValue('PDFTopRightImageDocName',true);
        docNames.add(PDFTopRightImageDocName);
        String PDFBottomLeftImageDocName = GNT.KeyValueStoreHelper.getTextValue('PDFBottomLeftImageDocName',true);
        //right side logo can be dept logo. Which will have high priority
        docNames.add(PDFBottomLeftImageDocName);
        String PDFBottomRightImageDocName = GNT.KeyValueStoreHelper.getTextValue('PDFBottomRightImageDocName',true);
        docNames.add(PDFBottomRightImageDocName);
        
        topLeftString = GNT.KeyValueStoreHelper.getTextValue('PDFTopLeftText',true);
        topMiddleString = GNT.KeyValueStoreHelper.getTextValue('PDFTopMiddleText',true);
        topRightString = GNT.KeyValueStoreHelper.getTextValue('PDFTopRightText',true);
        bottomLeftString = GNT.KeyValueStoreHelper.getTextValue('PDFBottomLeftText',true);
        bottomRightString = GNT.KeyValueStoreHelper.getTextValue('PDFBottomRightText',true);
        List< document > documentList = [select Name from document where Name in:docNames ];
        if(documentList.size()>0) {
            for(Document doc : documentList) {
                if(PDFTopLeftImageDocName != null && doc.name == PDFTopLeftImageDocName) {
                    topLeftImageURL='/servlet/servlet.FileDownload?file='+doc.id;
                }
                if(PDFTopMiddleImageDocName != null && doc.name == PDFTopMiddleImageDocName) {
                    topMiddleImageURL='/servlet/servlet.FileDownload?file='+doc.id;
                }
                if(PDFTopRightImageDocName != null && doc.name == PDFTopRightImageDocName) {
                    topRightImageURL='/servlet/servlet.FileDownload?file='+doc.id;
                }
                if(PDFBottomLeftImageDocName != null && doc.name == PDFBottomLeftImageDocName) {
                    bottomLeftImageURL='/servlet/servlet.FileDownload?file='+doc.id;
                }
                if(PDFBottomRightImageDocName != null && doc.name == PDFBottomRightImageDocName) {
                    bottomRightImageURL='/servlet/servlet.FileDownload?file='+doc.id;
                }
                
            }
        }
        
        String themeDoc = 'GovGrantsThemeToPrint';
        List<Document> docList = [SELECT Id FROM Document WHERE Name =:themeDoc];
        if(docList.size() > 0){
            themeDocURL = '/servlet/servlet.FileDownload?file=' + docList[0].Id;
        }
    }
    
    /*
    * Method to find the print layout for a given view template
    */
    public void findPrintTemplate(string template) {
        //1. Get the Page Template Name
       GNT__PageTemplate__c printTemplate = [SELECT ID,NAME,GNT__PrintLayoutConfig__c FROM GNT__PageTemplate__c 
                                            WHERE NAME = : template];
        if(printTemplate != null) {
            printTemplateName = printTemplate.Name;                                     
        }
        
        
    }
}