/**********************************************************
  This class creates review step templates for announcements
  by fetching relevant templates from the program.
  **********************************************************
  07 May 2014 Prem Pal Created
  **********************************************************  
*/

public with sharing class ReviewStepTemplateHelper{ 
    public static void afterInsert(){                
        //1.At first, get all the announcements that are inserted.
        Map<Id, Announcement__c> announcementsMap = new Map<Id, Announcement__c>([SELECT Id, Program__c, IsNoReviewStepProgram__c 
                                                                                    FROM Announcement__c 
                                                                                WHERE Id IN :Trigger.NewMap.keyset()]); 
        
            system.debug('--ReviewStepTemplateHelper--');   
        //2.Get the list of programs related to those announcements.
        List<Id> relatedProgramsList = new List<Id>();
        for(Announcement__c ann:announcementsMap.values()){
            if (ann.IsNoReviewStepProgram__c != true) {
                relatedProgramsList.add(ann.Program__c);
            }
        }           
        
        //3. Get the review step templates related to programs fetched above.
        Map<Id, ReviewStepTemplate__c> rstMap = new Map<Id, ReviewStepTemplate__c>([SELECT Id,Name,Program__c,OwnerId,RecordTypeId,
            Description__c,EndDate__c,ReviewPackage__c,StartDate__c,StepNumber__c,ReviewStepLayout__c,RejectionEmailTemplate__c,
            ApprovalEmailTemplate__c,RejectionConfirmationFlexTableName__c,ApprovalConfirmationFlexTableName__c,
            PreventDuplicateReviewers__c,IsStepRequired__c,IsStepOptional__c,MultiplePanelsRequired__c,ReviewLevelAcceptance__c,UserType__c,PanelHeadAssignNotificationTemplate__c, ReviewTypeName__c
            FROM ReviewStepTemplate__c WHERE Program__c IN :relatedProgramsList]); 
        
        List<ReviewStepTemplate__c> newRSTList = new List<ReviewStepTemplate__c>();
        Id rstAppRecTypeId = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id rstPreAppRecTypeId = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();

        //Iterate over the incoming announcements
        for(Announcement__c ann: (List<Announcement__c>)Trigger.NewMap.values()){            
            //Iterate over all review step templates
            for(ReviewStepTemplate__c rstObj:rstMap.values()){ 
                //Check if program linked to review step template and announcement are same. 
                if(rstObj.Program__c == ann.Program__c){           
                    ReviewStepTemplate__c newRSTobj = rstObj.clone(false,true,false,false); 
                    newRSTobj.Name = rstObj.Name;
                    newRSTobj.ClonedFrom__c = rstObj.Id;
                    newRSTobj.Announcement__c = ann.Id; //set the announcement id for the cloned review step template
                    newRSTobj.Program__c = null;  // nullify program id     
                    newRSTobj.Description__c = rstObj.Description__c;     
                    newRSTobj.EndDate__c = rstObj.EndDate__c;  
                    newRSTobj.ReviewPackage__c = rstObj.ReviewPackage__c;      
                    newRSTobj.StartDate__c = rstObj.StartDate__c;
                    newRSTobj.StepNumber__c = rstObj.StepNumber__c;   
                    newRSTobj.IsStepRequired__c=rstObj.IsStepRequired__c;
                    newRSTobj.ReviewTypeName__c = rstObj.ReviewTypeName__c;

                    if(ann.AnnouncementType__c=='Sole Source/Formula' && rstObj.StepNumber__c==2 )
                    newRSTobj.IsStepOptional__c='Optional';
                    else
                    newRSTobj.IsStepOptional__c=rstObj.IsStepOptional__c;

                    newRSTobj.MultiplePanelsRequired__c=rstObj.MultiplePanelsRequired__c;
                    newRSTobj.ReviewStepLayout__c = rstObj.ReviewStepLayout__c;     
                    newRSTobj.RejectionEmailTemplate__c = rstObj.RejectionEmailTemplate__c;  
                    newRSTobj.ApprovalEmailTemplate__c = rstObj.ApprovalEmailTemplate__c;  
                    newRSTobj.RejectionConfirmationFlexTableName__c = rstObj.RejectionConfirmationFlexTableName__c;      
                    newRSTobj.ApprovalConfirmationFlexTableName__c = rstObj.ApprovalConfirmationFlexTableName__c;   
                    newRSTobj.PreventDuplicateReviewers__c = rstObj.PreventDuplicateReviewers__c;     
                    newRSTobj.ReviewLevelAcceptance__c = rstObj.ReviewLevelAcceptance__c;  
                    newRSTobj.UserType__c = rstObj.UserType__c;      
                    newRSTobj.PanelHeadAssignNotificationTemplate__c = rstObj.PanelHeadAssignNotificationTemplate__c;
                    newRSTList.add(newRSTobj); // add to the list     
                        system.debug('--ReviewStepTemplateHelper--'+newRSTobj);                                              
                      
                }
            }            
        }                
        //try{        
            insert  newRSTList;
        //}catch(Exception e){
        //    System.debug('Problem inserting Review Step Templates'+e.getMessage());
        //}
    }   
    public static void beforeInsert(){        
        
        //Get the list of programs related to those announcements.
        List<Id> relatedProgramsList = new List<Id>();
        Map<Id,Boolean> programHasRSTMap = new Map<Id,Boolean>();
        for(Announcement__c ann:(List<Announcement__c>)Trigger.new){
            if (ann.IsNoReviewStepProgram__c != true) {
                relatedProgramsList.add(ann.Program__c);
                programHasRSTMap.put(ann.Program__c, false);
            }
        }              
        for(AggregateResult aggResult : [SELECT Program__c, COUNT(Id) cnt FROM ReviewStepTemplate__c WHERE Program__c IN :relatedProgramsList GROUP BY Program__c]) {
            Id id = (Id)aggResult.get(AppUtils.getNamespacePrefix()+'Program__c');
            Boolean hasRSTs = (Integer)aggResult.get('cnt') > 0 ? true :false;
            programHasRSTMap.put(id, hasRSTs);
        }        
        
        //Iterate over the incoming announcements
        for(Announcement__c ann: (List<Announcement__c>)Trigger.new){            
            if(programHasRSTMap.get(ann.Program__c) == false){
                //ann.addError('There are no Review Step Templates defined for the related Program. It is necessary to associate a Review Step  Template to the Program to create an Announcement.');
                ann.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-73586'));
            }         
        }
    }
}