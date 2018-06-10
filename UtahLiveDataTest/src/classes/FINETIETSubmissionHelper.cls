global with sharing class FINETIETSubmissionHelper extends GNT.DynamicLayoutActionRedirect { 

    global override PageReference whenClicked(){
    /*Savepoint sp = Database.setSavepoint();
    List<String> errors = new List<String>();  
    try{
        Id recordId = apexpages.currentpage().getparameters().get('id');
        IntegCGIAdv_IET_Document a = new IntegCGIAdv_IET_Document('400');
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET header = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET( date.newInstance(2017, 10, 18), '1', 2018, '0000,000,00', '00', 'P' );
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET vendor = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET( 1, '44348A', '00', 'IN04', '7000', '050', '7560', 'null', 'null', 'null', 'null', '4052', 'null', 'null', 'null', 37026.82 );
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[] accountingLines = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[]{};
        accountingLines.add( new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET( 1, 2, '17T1FT Flow-through FFY2017 FY 2018 Fiscal Month 4', 37026.82, '2480', '400', '0664', 'PAE', 'null', '7508', 'null', 'null', '17T1FT', '020', 'null' ) );
        ////
        IntegCGIAdv_IET_Document a1 = new IntegCGIAdv_IET_Document('400');
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET header1 = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET( date.newInstance(2017, 10, 18), '1', 2018, '0000,000,00', '00', 'P' );
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET vendor1 = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET( 1, '44348A', '00', 'IN04', '7000', '050', '7560', 'null', 'null', 'null', 'null', '4052', 'null', 'null', 'null', 37026.82 );
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[] accountingLines1 = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[]{};
        accountingLines1.add( new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET( 1, 2, '17T1FT Flow-through FFY2017 FY 2018 Fiscal Month 4', 37026.82, '2480', '400', '0664', 'PAE', 'null', '7508', 'null', 'null', '17T1FT', '020', 'null' ) );
        a1.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null', '', header1, vendor1, accountingLines1);
        ////
        a.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null', '', header, vendor, accountingLines );
        system.debug(a.renderJSON(true));
        
        document doc = new document( FolderId='00lt0000000Dzww', name = userinfo.getName() + 'Temp' );
        doc.body =  blob.valueOf( a.renderJSON(true) );
        webCallout(a.renderJSON(false));
        insert doc;
        
        

        return null; 
       } catch(Exception e){
            Database.rollback(sp);
            System.debug('***exception caught' + e.getCause());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
       @Future(callout=true)
       private static void webCallout(String jsonString){
             httpresponse r = IntegUtahGrantsAPI.postIETPaymentDetails(jsonString);
             system.debug('response from server'+ r); 
             system.debug(r.getbody());
             */
             return null;
         
        }   
       
    
    
}