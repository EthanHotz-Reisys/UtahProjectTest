global class GenerateRiskItemsHelper extends GNT.DynamicLayoutActionRedirect{
   
    private  Id recordId;
    private  Sobject sobj;
    private  String namespace;
    private  RiskAssessment__c riskObj;
    private List<RiskAssessment__c> riskObjList;
    private Task task;

    global override Pagereference whenClicked(){ 
        recordId = layoutHolder.getPrimarySObject().Id;
        sobj = layoutHolder.getPrimarySObject();
        namespace = AppUtils.getNamespacePrefix();
        riskObjList = [Select Id, Name,  Status__c,Submittedby__c,SubmittedOn__c, Grant__c,Program__c, AssessmentDate__c,FormsValidated__c from RiskAssessment__c where Id = :recordId Limit 1];
        
        if(riskObjList != null && riskObjList.size()>0){
            riskObj = riskObjList[0];
            if(!riskObj.FormsValidated__c){
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill the Risk Forms before completing the Risk Assessment.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Validate the forms before proceeding to Completion'));
                return null;
            }
            riskObj.Status__c ='Completed';
            riskObj.AssessmentDate__c = System.today();
            riskObj.HideSubmitButton__c=true;
            riskObj.SubmittedOn__c = System.today();
            update riskObj;         
        }

        if(riskObj.Grant__c != null){
            return new PageReference('/apex/'+namespace+'GrantView?id='+riskObj.Grant__c);
        }else if(riskObj.Program__c != null){
            return new PageReference('/apex/'+namespace+'ProgramView?id='+riskObj.Program__c);
        }else{     
            return new PageReference('/apex/'+namespace+'RiskAssessmentView?id='+recordId);
        }                 
    }
}