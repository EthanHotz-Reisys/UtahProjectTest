global with sharing class DeepCloneProgramHelper extends GNT.DynamicLayoutActionRedirect {
    Program__c currentRecord;
    public DeepCloneProgramHelper() {

    }
    public DeepCloneProgramHelper(GNT.DynamicLayoutHolder layoutHolder) {
        this.layoutHolder = layoutHolder;
    }
    public DeepCloneProgramHelper(ApexPages.StandardController controller) {
        currentRecord = (Program__c)controller.getRecord();
    }
    global override PageReference whenClicked(){
    	Program__c newRecord;
    	Savepoint sp = Database.setSavepoint();
    	Id recordId = layoutHolder.getPrimarySObject().Id;
    	try{
    		currentRecord = [select id,name,ProgramName__c,FederalProgramCFDA__c,ProgramType__c,ProgramSubType__c,
    		                 Account__c,Division__c,StartDate__c,EndDate__c,FunderType__c,PrimaryFundingOrganization__c,  
    		                 KeyPerformanceIndicator__c,WebsiteAddress__c,Objectives__c,FundingAccountsneeded__c,
    		                 BudgetingPreference__c,IsProjectServiceAreaneeded__c,BuildupFunctionalityNeeded__c
    		                 from Program__c where id =:recordId];
    		
    		newRecord = currentRecord.clone(false);
    		newRecord.Program__c = recordId;
    		insert newRecord;
    		List<ProgramContacts__c> pgmcontactlist = new List<ProgramContacts__c>();
            for(ProgramContacts__c pgmcontact :[select Contact__c from ProgramContacts__c where Program__c=:recordId]){
                ProgramContacts__c newpgmcontact = pgmcontact.clone(false);
                newpgmcontact.Program__c = newRecord.id;
                pgmcontactlist.add(newpgmcontact);
            }
            insert pgmcontactlist;
            List<GoalObjective__c> goalobjectivelist = new List<GoalObjective__c>();
            for(GoalObjective__c goalobj :[select Title__c,Status__c,ParentGoal__c,	IsParent__c,ExpenditureAmount__c,
                                           DueDate__c,Description__c,AllocatedAmount__c,Allocated__c 
                                           from GoalObjective__c where Program__c=:recordId]){
                GoalObjective__c newgoalobj = goalobj.clone(false);
                newgoalobj.Program__c = newRecord.id;
                goalobjectivelist.add(newgoalobj);
            }
            insert goalobjectivelist;
            List<KeyOutcome__c> keyoutcomelist = new List<KeyOutcome__c>();
            for(KeyOutcome__c outcome :[select KeyPerformanceIndicator__c,KeyPerformanceCategory__c,Orientation__c,Unit__c,Target__c 
                                        from KeyOutcome__c where Program__c=:recordId]){
                KeyOutcome__c newoutcome = outcome.clone(false);
                newoutcome.Program__c = newRecord.id;
                keyoutcomelist.add(newoutcome);
            }
            insert keyoutcomelist;
            List<RolesAndResponsibilities__c> rolesandresplist = new List<RolesAndResponsibilities__c>();
            for(RolesAndResponsibilities__c roles :[select Name__c,BusinessRole__c,Responsibility__c,Recordtypeid 
                                        from RolesAndResponsibilities__c where Program__c=:recordId]){
                RolesAndResponsibilities__c newrole = roles.clone(false);
                newrole.Program__c = newRecord.id;
                rolesandresplist.add(newrole);
            }
            insert rolesandresplist;
            List<ProgramFundingAccount__c> fundingaccountlist = new List<ProgramFundingAccount__c>();
            for(ProgramFundingAccount__c fundingaccount :[select FundingAccount__c from ProgramFundingAccount__c where Program__c=:recordId]){
                ProgramFundingAccount__c newfundingaccount = fundingaccount.clone(false);
                newfundingaccount.Program__c = newRecord.id;
                fundingaccountlist.add(newfundingaccount);
            }
            insert fundingaccountlist;
            List<RiskAssessment__c> riskassessmentlist = new List<RiskAssessment__c>();
            for(RiskAssessment__c riskassessment :[select Title__c,Area__c,AssessmentDate__c,Type__c 
                                                   from RiskAssessment__c where Program__c=:recordId]){
                RiskAssessment__c newriskassessment = riskassessment.clone(false);
                newriskassessment.Program__c = newRecord.id;
                riskassessmentlist.add(newriskassessment);
            }
            insert riskassessmentlist;
            List<RiskItem__c> riskitemlist = new List<RiskItem__c>();
            for(RiskItem__c riskitem :[select Title__c,Status__c,Probability__c,Type__c,Impact__c,RiskIdentifiedDate__c,Description__c,
                                       Source__c,PlanofAction__c,AssignedTo__c,DueDate__c from RiskItem__c where Program__c=:recordId]){
                RiskItem__c newriskitem = riskitem.clone(false);
                newriskitem.Program__c = newRecord.id;
                riskitemlist.add(newriskitem);
            }
            insert riskitemlist;
            List<TermCondition__c> termslist = new List<TermCondition__c>();
            for(TermCondition__c term :[select Name,Recordtypeid,Title__c,Description__c,TermType__c,EffectiveFrom__c 
                                        from TermCondition__c where Program__c=:recordId]){
                TermCondition__c newterm = term.clone(false);
                newterm.Program__c = newRecord.id;
                termslist.add(newterm);
            }
            insert termslist;
            List<GNT__AttachmentExtension__c> attachmentlist = new List<GNT__AttachmentExtension__c>();
            for(GNT__AttachmentExtension__c attachment :[SELECT Name,GNT__Attachment__c,GNT__Classification__c,GNT__HistoryReason__c,
                                                         GNT__ParentId__c FROM GNT__AttachmentExtension__c 
                                                         where GNT__ParentId__c=:recordId]){
                GNT__AttachmentExtension__c newprogramatt = attachment.clone(false);
                newprogramatt.GNT__ParentId__c = newRecord.id;
                attachmentlist.add(newprogramatt);
            }
            insert attachmentlist;
    	   }
    	catch(Exception e){
    	 	Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
    	 }
    	 return new PageReference('/'+newRecord.id);
     }
}