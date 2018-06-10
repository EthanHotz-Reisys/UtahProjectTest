global with sharing class UpdateAnnouncementHelper extends GNT.DynamicLayoutActionRedirect{
		global override PageReference whenClicked(){ 
			Id recordId = ApexPages.CurrentPage().getParameters().get('id');
			Announcement__c ann= [Select Id, FOALead__c, LeadLastModifiedDate__c, AnnouncementName__c, Category__c, FundingInstrumentType__c, CategoryOfFundingActivity__c, CategoryExplanation__c, AwardingFedAgency__c, ApplicationDeadlineWithDateTime__c, AwardCeiling__c, AwardFloor__c, ExpectedNumberofAwards__c, Budget__c, AgencyContact__c, FundingOppURL__c, AnnouncementDescription__c, Program__c from Announcement__c where Id = :recordId];
			FOALead__c lead = [Select Id, LastUpdateDate__c, FundingOpportunityTitle__c, OpportunityCategory__c, FundingInstrumentType__c, CategoryOfFundingActivity__c, CategoryExplanation__c, FederalAgency__c, ApplicationsDueDate__c, AwardCeiling__c, AwardFloor__c, ExpectedNumberofAwards__c, EstimatedTotalProgramFunding__c, AgencyContact__c, FundingOppURL__c, FundingOpportunityDescription__c,CFDANumber__c  from FOALead__c where Id = :ann.FOALead__c];
			ann.LeadLastModifiedDate__c = lead.LastUpdateDate__c;
			ann.AnnouncementName__c = lead.FundingOpportunityTitle__c;
			ann.Category__c = lead.OpportunityCategory__c;
			ann.FundingInstrumentType__c = lead.FundingInstrumentType__c;
			ann.CategoryOfFundingActivity__c = lead.CategoryOfFundingActivity__c;
			ann.CategoryExplanation__c = lead.CategoryExplanation__c;
			ann.AwardingFedAgency__c = lead.FederalAgency__c;
			ann.ApplicationDeadlineWithDateTime__c = DateTime.newInstance(lead.ApplicationsDueDate__c.year(), lead.ApplicationsDueDate__c.month(), lead.ApplicationsDueDate__c.day());
			ann.AwardCeiling__c = lead.AwardCeiling__c;
			ann.AwardFloor__c = lead.AwardFloor__c;
			ann.ExpectedNumberofAwards__c = lead.ExpectedNumberofAwards__c;
			ann.Budget__c = lead.EstimatedTotalProgramFunding__c;
			ann.AgencyContact__c = lead.AgencyContact__c;
			ann.FundingOppURL__c = lead.FundingOppURL__c;
			ann.AnnouncementDescription__c = lead.FundingOpportunityDescription__c;
			Program__c program = [Select Id from Program__c where FederalProgramCFDA__c = :lead.CFDANumber__c limit 1];
			ann.Program__c = program.Id;


			update ann;
			PageReference  returnPage = new PageReference('/apex/AnnouncementView?id='+recordId); 
            returnPage.setRedirect(true);
            return returnPage;   
		}
}