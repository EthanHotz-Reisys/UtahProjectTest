global with sharing class SendToSubrecipientHelper extends GNT.DynamicLayoutActionRedirect {
    Boolean isError = false;
     global override PageReference whenClicked(){
        //String siteVisitReportId = layoutHolder.recordId;
        Id siteVisitReportId=apexpages.currentpage().getparameters().get('id');
        system.debug('siteVisitReportId: '+siteVisitReportId);
        Savepoint sp = Database.setSavepoint();
        try {
            if(siteVisitReportId != null) {
                SiteVisit__c sv = [Select id,Name,DateReportSubmitted__c,SubmittedOn__c,SubmittedBy__c,ActivityQuestion2__c,ProjectTitle__c, FormsValidated__c, SubAwardee__c, SiteVisitName__c FROM SiteVisit__c where id =: siteVisitReportId limit 1];
                system.debug('Site Visit sv------ '+sv);
                Id svid = sv.id;
                List<SiteVisitActivity__c> sva = new List<SiteVisitActivity__c>([Select id,ActivityDescription__c,Date__c FROM SiteVisitActivity__c WHERE SiteVisit__c = :svid] );
                system.debug('Site Visit sva--------' +sva.size());
                if(sva.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please include Site Visit Findings'));
                return null;
                }
                sv.Status__c='Sent to Subrecipient';
                update sv;
                new GNT.EmailFeeder().TargetObjectID(sv.SubAwardee__c).template('Report_sent_to_subrecipient').contextRecordId(svid).send();
                GNT.TaskCreationHandler.createTasks(sv.SubAwardee__c,sv.Id,'Send to subrecipient',sv.Name,null,false,System.TODAY()+7,null, sv.SiteVisitName__c+'- Review site visit findings and submit feedback',true);
                //GNT.TaskCreationHandler.createApprovalProcessTasks(sv.Id,'Review Site Visit Report',sv.Name,null,System.Today() + 7,true);
                system.debug('Site Visit task completion------ ');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Site Visit Report has been successfully sent to subrecipient'));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-09537')));
                system.debug('Site Visit Report sent to subrecipient successfully------ ');             
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
            system.debug('siteVisitReportId: exception '+e.getMessage());
            //return e.getMessage();
        }
        PageReference pageUrl = Page.SiteVisitView;
        pageUrl.getParameters().put('id',siteVisitReportId);
        pageUrl.setRedirect(true);
        return pageUrl;
    }
}