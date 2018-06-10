global class RiskAssessmentSubmitApproval extends GNT.DynamicLayoutActionRedirect{
   
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
        riskObjList = [Select Id, Name,  Status__c, Grant__r.Id,AssessmentDate__c,Title__c from RiskAssessment__c where Id = :recordId Limit 1];
        if(riskObjList != null && riskObjList.size()>0){
            riskObj = riskObjList[0];
            riskObj.Status__c ='Submitted for Approval';
            riskObj.AssessmentDate__c = System.today();
            riskObj.HideSubmitButton__c=true;
            update riskObj;
            
            //List<Task> newTaskList = GNT.TaskCreationHandler.createApprovalProcessTasks(recordId, 'Risk Assessment Process',riskObj.Name, null, true);
            List<Task> newTaskList = GNT.TaskCreationHandler.createApprovalProcessTasks(recordId, 'Risk Assessment Process',riskObj.Name, null, null, riskObj.Title__c, true);

            
            List<Task> taskList = [Select Id, Status, WhatId from Task where 
                                       GNT__ObjectRelationName__c=:riskObj.Name AND 
                                       WhatId = :recordId Limit 1];
            if(taskList != null && taskList.size()>0){
                task = taskList[0];
                task.Status='Completed';
                update task;
            }             
        }     
        return new PageReference('/apex/'+namespace+'GrantView?id='+riskObj.Grant__r.Id);                 
    }
}