global with sharing class ConvertToAnnouncementHelper extends GNT.DynamicLayoutActionRedirect {
    
    global override PageReference whenClicked(){ 
        //String ns = AppUtils.getNamespacePrefix(); 
        //String fundingoppid;
        //Id recordId = apexpages.currentpage().getparameters().get('id');
        //FOALead__c objFoaLead;
       
        
        //objFoaLead = [SELECT Id, Score__c,FundingOpportunityNumber__c,DaysLeft__c,Justification__c, RecipientAgency__c,CFDANumber__c,ApplicationsDueDate__c FROM FOALead__c WHERE id =: recordId];
        
        
        //List<String> errors = new List<String>();
        
        //if(String.isEmpty(objFoaLead.Justification__c)){
        //    //errors.add('Justfication is required - Review tab.');
        //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-84190'));
        //}
        //  //if(objFoaLead.Score__c == null || Integer.valueOf(objFoaLead.Score__c) <= 2){
        //   if(objFoaLead.Score__c == null || objFoaLead.Score__c <= 10/5){
        //    //errors.add('Score must be greater than 2 - Review tab');
        //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-90293'));
        //}
        //if(objFoaLead.DaysLeft__c == 0){
        //    //errors.add('Lead cannot be converted to opportunity if Application deadline is less than today');
        //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-59900'));
        //}
        //if(objFoaLead.RecipientAgency__c == null){
        //    //errors.add('Applying Agency must be selected - Review tab');
        //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-53671'));
        //}
        //  if(objFoaLead.ApplicationsDueDate__c < date.today()){
        //    //errors.add('Application due date has passed hence cannot convert into opportunity');
        //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-97986'));
        //}

        //if(errors.size() > 0){
        //    for(String error: errors){
        //        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
        //    }
        //}else{
        
        //    if(objFoaLead.FundingOpportunityNumber__c!=null){
        //        OppWebserviceCallout(objFoaLead.FundingOpportunityNumber__c);
        //    } 
            
        //    //Convert the lead to Announcement
        //    fundingoppid = createAnnouncement(objFoaLead);
            
        //    objFoaLead.Status__c = 'Converted to Opportunity';
        //    update objFoaLead;
            
            
            
        //    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Converted to opportunity'));
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-74777')));
        //    PageReference  returnPage = new PageReference('/apex/AnnouncementView?id='+fundingoppid); 
        //    returnPage.setRedirect(true);
        //    return returnPage;   
        //}
        
        return null;
    }
    
    
    
    //private static void OppWebserviceCallout(String oppNumber){
        
    //    OpportunitiesExpandedRequestCallout.opportunitiesExpandedCallout(oppNumber);
            
    //}
    
    
    //@TestVisible private String createAnnouncement(FOALead__c objFOALead){
    //    List<Id> IdList = new List<Id>();
    //    IdList.add(objFOALead.id);
    //    Announcement__c annObj;
    //    system.debug('**IdList'+IdList);
    //    List<Sobject> announcements = GNT.AppUtils.copyRecords(AppUtils.getNamespacePrefix()+'FOALead__c', AppUtils.getNamespacePrefix()+'Announcement__c', IdList, false);
    //    system.debug('***Listannouncements'+announcements);
    //    if(!announcements.isempty()) {
    //        annObj = (Announcement__c)announcements.get(0); 
    //        String cfdaNumber = objFOALead.CFDANumber__c;
    //        if(!String.isEmpty(cfdaNumber)){
    //            List<Program__c> pgms = [SELECT Id FROM Program__c WHERE FederalProgramCFDA__c = :cfdaNumber LIMIT 1];
    //            if(!pgms.isempty()){
    //                annObj.Program__c = pgms.get(0).Id;
    //            }
    //        }
    //        System.debug('***beforeannobj1'+annobj);
    //        //System.assert(1==2);
    //        system.debug('***beforeannobj1');
    //        annobj.ApplicationCreatedOutside__c = 'No';   
    //        insert annobj;
    //    }
    //      return annobj.id; 
    // } 
}