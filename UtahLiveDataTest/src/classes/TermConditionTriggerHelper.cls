/*
    This class has methods to execute methods related to TermCondition Trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-05-19      Nakul Kadam     Created 
    08/08/2014      Nakul Kadam     Added shareGrantToRelatedExternalUsers method
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************  
*/

public class TermConditionTriggerHelper extends GNT.TriggerHelper{
	
	public static boolean skipTrigger = false;

    public override void processBeforeInsert() {
    	if(skipTrigger==false){
        	populateType(trigger.new);        	
        	checkDuplicateReportingRequirements(trigger.new);
    	}
    }
    
    public override void processAfterInsert() {
       
        if(skipTrigger==false){
        	populateSubmissionType(trigger.new);
        }
       
    }
    
    public override void processBeforeUpdate() {
    	if(skipTrigger==false){
        	populateType(trigger.new);
    	}
    }

    public override void processAfterUpdate() {
        
    }
    
    private void populateSubmissionType(List<TermCondition__c> termConditionList){
        system.debug('Populate999:');
        List<Id> tcIds = new List<Id>();
        for(TermCondition__c tc : termConditionList) {
            tcIds.add(tc.Id);
        } 
        //Shah CRF: Use RecordType.DeveloperName instead of RecordType.Name
        List<TermCondition__c> tConditionList = [select Id,SubmissionType__c,RecordType.Name FROM TermCondition__c where ID in : tcIds];
        for(TermCondition__c obj : tConditionList) {
            system.debug('populate: '+obj);
            if(obj.RecordType.Name == 'Progress Report') {  //Shah CRF: use developername to compare instead of name field
                system.debug('OBJ: '+obj);
                obj.SubmissionType__c = 'Progress Report';
            }
            else if(obj.RecordType.Name == 'Payment Request') {
                obj.SubmissionType__c = 'Payment Request';
            }
        }
        update tConditionList;
    }

    private void populateType(List<TermCondition__c> termConditionList){
        for(TermCondition__c obj : termConditionList){
            if(obj.Program__c != null){
                obj.Type__c = 'Program';
            }else if(obj.Grant__c != null){
                obj.Type__c = 'Grant';
            }else if(obj.Award__c != null){
                obj.Type__c = 'Award';
            }else{
                obj.Type__c = 'State';
            }
            // Make default value of Term and condition as Inactive on Insert.
            if(trigger.isInsert){
                obj.status__c = 'Inactive';
            }
       }
    }
    
    
    // Method to check if Duplicate reporting requirements are added.
     private void checkDuplicateReportingRequirements(List<TermCondition__c> termConditionList)
    {
            system.debug('Term Condition List ***' + termConditionList.size());
            List<Id> awardIds = new List<Id>();
            for(TermCondition__c tc : termConditionList) {
                awardIds.add(tc.Award__c);
            } 
            
        List<TermCondition__c> tConditionList = [select Id,RecordType.Name,ReportingFrequency__c,Frequency__c,Category__c FROM TermCondition__c where Award__c in : awardIds and RecordType.Name ='Reporting Requirement'];
         system.debug('***tconditionlist' + tConditionList + ' size -- ' + tConditionList.size());
         
           for(TermCondition__c tc : termConditionList)  {
           
                for(TermCondition__c tncnew : tConditionList) {
                        
                   String frequency = tncnew.Frequency__c;  // monthly, quarterly etc
                    String reportingFrequency = tncnew.ReportingFrequency__c; //fixed,recurring
                    
                    //Shah CRF: use map to avoid nested for loop which will improve processing speed
                    if(tncnew.ReportingFrequency__c==tc.ReportingFrequency__c && tncnew.Category__c==tc.Category__c)
                    {
                         
                         if(tc.ReportingFrequency__c=='Fixed')// Duplicate Report type, not allowed
                         {
                          //tc.addError('A Reporting Requirement of '+tc.Category__c +' Fixed type is already present.'); 
                          tc.addError(GNT.ErrorMessageHelper.fetchMessage('P26-GRNTR-83297') + tc.Category__c + GNT.ErrorMessageHelper.fetchMessage('P26-GRNTR-24373'));
                         // error message, return
                         }
                         else if(tc.ReportingFrequency__c=='Recurring' && tc.Frequency__c == tncnew.Frequency__c)
                         {
                         //tc.addError('A Reporting Requirement of  '+tc.Category__c +' with Recurring type and '+tc.Frequency__c +' is already present.');
                         // error message again
                           tc.addError(GNT.ErrorMessageHelper.fetchMessage('P26-GRNTR-83297') + tc.Category__c + GNT.ErrorMessageHelper.fetchMessage('P26-GRNTR-96127')+tc.Frequency__c +GNT.ErrorMessageHelper.fetchMessage('P26-GRNTR-85584'));                     
                         }
                    }                        
                }
           }      
    }    
}