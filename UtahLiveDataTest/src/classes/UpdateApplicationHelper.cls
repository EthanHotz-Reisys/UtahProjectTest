global with sharing class UpdateApplicationHelper extends GNT.DynamicLayoutActionRedirect{
	global override PageReference whenClicked(){ 
			Id recordId = ApexPages.CurrentPage().getParameters().get('id');
			Application__c app = [Select LeadLastModifiedDate__c, Announcement__r.FOALead__c, OpportunityTitle__c, FederalAwardingAgency__c, ApplicationDeadlineWithDateTime__c, AwardCeiling__c, AgencyContact__c, AwardFloor__c, FederalProgram__c from Application__c where Id = :recordId];
			FOALead__c lead = [Select LastUpdateDate__c, FundingOpportunityTitle__c, FederalAgency__c, ApplicationsDueDate__c,AwardCeiling__c, AgencyContact__c, AwardFloor__c, CFDANumber__c from FOALead__c where Id = :app.Announcement__r.FOALead__c];
			app.LeadLastModifiedDate__c = lead.LastUpdateDate__c;
			app.OpportunityTitle__c = lead.FundingOpportunityTitle__c;
			app.FederalAwardingAgency__c = lead.FederalAgency__c;
			app.ApplicationDeadlineWithDateTime__c = DateTime.newInstance(lead.ApplicationsDueDate__c.year(), lead.ApplicationsDueDate__c.month(), lead.ApplicationsDueDate__c.day());
			app.AwardCeiling__c = lead.AwardCeiling__c;
			app.AgencyContact__c = lead.AgencyContact__c;
			app.AwardFloor__c = lead.AwardFloor__c;
			Program__c program = [Select Id from Program__c where FederalProgramCFDA__c = :lead.CFDANumber__c limit 1];
			app.FederalProgram__c = program.Id;
			update app;
			PageReference  returnPage = new PageReference('/apex/ApplicationView?id='+recordId); 
            returnPage.setRedirect(true);
			return returnPage;  
		}
}