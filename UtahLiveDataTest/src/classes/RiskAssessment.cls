public with sharing class RiskAssessment {
	private Id id;
	private  Grant__c grantObj;
    private  List<Grant__c> grantObjList;
    private  RiskAssessment__c riskObj;
    private  String namespace;

	public RiskAssessment() {
		id  = ApexPages.currentPage().getParameters().get('grantid');
		/*id  = ApexPages.currentPage().getParameters().get('grantid');
		System.Debug('RiskAssessment...'+id);
		namespace = AppUtils.getNamespacePrefix();
        grantObjList = [Select Id, ProgramManager__c, ProjectOfficer__c, GrantMonitor__c,  GrantSupervisor__c from Grant__c where Id = :id Limit 1];


        if(grantObjList != null && grantObjList.size()>0){
        	grantObj = grantObjList[0];
        	riskObj = new RiskAssessment__c();
        	riskObj.ProgramManager__c = grantObj.ProgramManager__c;
        	riskObj.ProjectOfficer__c = grantObj.ProjectOfficer__c;
        	riskObj.GrantMonitor__c = grantObj.GrantMonitor__c;
        	riskObj.GrantSupervisor__c= grantObj.GrantSupervisor__c;
        	riskObj.Status__c = 'In Progress';
        	riskObj.Grant__c = id;
        	insert riskObj;
        	System.Debug('RiskAssessment riskObj.Id...'+riskObj.Id);
        } */

		

	}

	public PageReference redirect(){

		
		System.Debug('RiskAssessment...'+id);
		namespace = AppUtils.getNamespacePrefix();
        grantObjList = [Select Id, ProgramManager__c, ProjectOfficer__c, GrantMonitor__c,  GrantSupervisor__c from Grant__c where Id = :id Limit 1];

 
        if(grantObjList != null && grantObjList.size()>0){
        	grantObj = grantObjList[0];
        	riskObj = new RiskAssessment__c();
        	riskObj.ProgramManager__c = grantObj.ProgramManager__c;
        	riskObj.ProjectOfficer__c = grantObj.ProjectOfficer__c;
        	riskObj.GrantMonitor__c = grantObj.GrantMonitor__c;
        	riskObj.GrantSupervisor__c= grantObj.GrantSupervisor__c;
        	riskObj.Status__c = 'In Progress';
        	riskObj.Grant__c = id;
        	insert riskObj;
        	System.Debug('RiskAssessment riskObj.Id...'+riskObj.Id);
        } 

		return new PageReference('/apex/'+namespace+'riskassessmentedit?id='+riskObj.Id+'&grantid='+id);  
		//return new PageReference('/apex/'+namespace+'GrantView?id='+id);  

	}
}