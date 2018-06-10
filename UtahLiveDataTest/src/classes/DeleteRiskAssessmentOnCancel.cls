global class DeleteRiskAssessmentOnCancel extends GNT.DynamicLayoutActionRedirect{
   
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
        riskObjList = [Select Id,CreatedDate,LastModifiedDate,Grant__r.Id from RiskAssessment__c where Id = :recordId Limit 1];
        if(riskObjList != null && riskObjList.size()>0){
            riskObj = riskObjList[0];
            if(riskObj.CreatedDate == riskObj.LastModifiedDate){
                delete  riskObj ; 
                return new PageReference('/apex/'+namespace+'GrantView?id='+riskObj.Grant__r.Id);                
            }else{
                return new PageReference('/apex/'+namespace+'RiskassessmentView?id='+riskObj.Id); 
            }                                   
        } 
        return null;                            
    }
}