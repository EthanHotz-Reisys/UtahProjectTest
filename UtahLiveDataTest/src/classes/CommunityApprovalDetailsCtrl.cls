public class CommunityApprovalDetailsCtrl {

    public PageReference cancelPage() {
        return Page.CommunityApprovalList;
    }
    public String messageString {get;set;}
    public Boolean processCompleted{get;set;}
    public CommunityApprovalDetailsCtrl(ApexPages.StandardController controller) {

    }
    
    public void approveRecord(){
        Approval.ProcessResult result = processRecord('Approve');
        if(result != null && result.isSuccess()){
            messageString = 'This user has been successfully Approved';
        }else{
            messageString = 'Failed to submit record for Approval';
        }
    }
    
    public void rejectRecord(){
        Approval.ProcessResult result = processRecord('Reject');
        if(result != null && result.isSuccess()){
            messageString = 'This user has been successfully Rejected';
        }else{
            messageString = 'Failed to reject record';
        }
    }
    
    private Approval.ProcessResult processRecord(String ApprovalStatus){
        processCompleted = true;
        Approval.ProcessResult result;
        try{
            List<ProcessInstance> proInstanceList = [SELECT Id FROM ProcessInstance 
                    Where TargetObjectId = :ApexPages.currentPage().getParameters().get('Id') LIMIT 1];
            if(proInstanceList.size() > 0){
                List<ProcessInstanceWorkitem> proWorkItemList = [SELECT ActorId,Id,ProcessInstanceId 
                            FROM ProcessInstanceWorkitem Where ProcessInstanceId = :proInstanceList[0].Id LIMIT 1];
                if(proWorkItemList.size() > 0){
                    Approval.ProcessWorkitemRequest workItemRequest = new Approval.ProcessWorkitemRequest();
                    workItemRequest.setWorkitemId(proWorkItemList[0].Id);
                    workItemRequest.setAction(ApprovalStatus);
                    result =  Approval.process(workItemRequest);
                }
            }
        }catch(Exception e){
            System.debug('++ exec ' + e);
            messageString = e.getMessage();
        }
        if(result == null){
            messageString = 'Error in processing the record';
        }
        return result;
    }
}