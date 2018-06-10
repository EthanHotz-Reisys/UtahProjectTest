public class EntityHierarchyResolver {
     private Map<String, List<String>> entityNames = new Map<String, List<String>>{
          'Program__c' => new List<String>{'Announcement__c', 'RolesAndResponsibilities__c', 'BudgetPeriod__c', 'ProgramContacts__c', 'GoalObjective__c', 'KeyOutcome__c', 'ReviewStepTemplate__c', 'ProgramBudgetCategory__c', 'TermCondition__c', 'BusinessPackage__c'}, 
          'Announcement__c' => new List<String>{'Application__c', 'BudgetPeriod__c', 'FundingOpportunityBudgetCategory__c', 'ReviewStepTemplate__c', 'TermCondition__c', 'BusinessPackage__c', 'ReviewGroup__c', 'GNT__AttachmentExtension__c'},
          'ReviewStepTemplate__c' => new List<String>{'ReviewPanelTemplate__c'},
          'ReviewPanelTemplate__c' => new List<String>{'PanelUserTemplate__c'},
          'ReviewGroup__c' => new List<String>{'ReviewStep__c'}, 
          'ReviewStep__c' => new List<String>{'ReviewPanel__c', 'ReviewStepApplication__c', 'Review__c'},
          'ReviewPanel__c' => new List<String>{'PanelUser__c', 'PanelApplication__c'},
          'Application__c' => new List<String>{'Grant__c', 'BudgetPeriod__c', 'ApplicationBudgetCategory2__c'},
          'Grant__c' => new List<String>{'Award__c', 'BudgetPeriod__c', 'Closeout__c', 'BusinessPackage__c', 'Case__c', 'SiteVisit__c', 'ProgressReports__c'},
          'Award__c' => new List<String>{'PaymentRequest__c', 'AmendmentRequest__c', 'GrantContact__c', 'AwardFINETCode__c', 'AwardBudgetCategory__c', 'GoalObjective__c', 'TermCondition__c', 'GNT__AttachmentExtension__c'},
          'ApplicationBudgetCategory2__c' => new List<String>{'BuildUpItem__c'},
          'AwardBudgetCategory__c' => new List<String>{'BuildUpItem__c'},
          'AmendmentRequestBudgetCategory__c' => new List<String>{'BuildUpItem__c'},
          'PaymentBudgetCategory__c' => new List<String>{'BuildUpItem__c'}
     };
     private Map<string, string> fieldNames = new Map<string,string>{
          'Program__c' => 'Id',
               'RolesAndResponsibilities__c' => 'Program__c', 
               'BudgetPeriod__c' => 'Program__c',
               'ProgramContacts__c' => 'Program__c',
               'GoalObjective__c' => 'Program__c',
               'KeyOutcome__c' => 'Program__c',
               'ReviewStepTemplate__c' => 'Program__c',
               'ProgramBudgetCategory__c' => 'Program__c',
               'TermCondition__c' => 'Program__c',
               'BusinessPackage__c' => 'Program__c',
          'Announcement__c' => 'Program__c', 
               'BudgetPeriod__c' => 'FundingOpportunity__c',
               'FundingOpportunityBudgetCategory__c' => 'FundingOpportunity__c',
               'ReviewStepTemplate__c' => 'Announcement__c',
               'TermCondition__c' => 'Announcement__c',
               'BusinessPackage__c' => 'FundingOpportunity__c',
               'ReviewGroup__c' => 'Announcement__c',
               'GNT__AttachmentExtension__c' => 'GNT__ParentId__c',
          'ReviewPanelTemplate__c' => 'ReviewStepTemplate__c',
               'PanelUserTemplate__c' => 'ReviewPanelTemplate__c',
          'Application__c' => 'Announcement__c', 
               'BudgetPeriod__c' => 'Application__c',
               'ApplicationBudgetCategory2__c' => 'Application__c',
          'ReviewStep__c' => 'ReviewGroup__c',
               'ReviewStepApplication__c' => 'ReviewStep__c',
               'Review__c' => 'ReviewStep__c',
          'ReviewPanel__c' => 'ReviewStep__c',
               'PanelUser__c' => 'ReviewPanel__c',
               'PanelApplication__c' => 'ReviewPanel__c',
          'Grant__c' => 'Application__c', 
               'BudgetPeriod__c' => 'Grant__c',
               'Closeout__c' => 'Grant__c',
               'BusinessPackage__c' => 'Grant__c',
               'Case__c' => 'RelatedRecordId__c',
               'SiteVisit__c' => 'Grant__c',
               'ProgressReports__c' => 'Grant__c',
          'Award__c' => 'Grant__c',
               'GrantContact__c' => 'Award__c',
               'AwardFINETCode__c' => 'Award__c',
               'AwardBudgetCategory__c' => 'Award__c',
               'GoalObjective__c' => 'Award__c',
               'TermCondition__c' => 'Award__c',
               'GNT__AttachmentExtension__c' => 'GNT__ParentId__c',
          'BuildUpItem__c' => 'AwardBudgetCategory__c'
     };
     //'BuildUpItem__c' => 'AmendmentRequestBudgetCategory__c', 'BuildUpItem__c' => 'PaymentBudgetCategory__c', 'BuildUpItem__c' => 'AwardBudgetCategory__c',

     private Set<string> objectTypes = new Set<string>{ 
          'BuildUpItem__c', 'GrantContact__c', 'AwardFINETCode__c', 'AwardBudgetCategory__c', 'GoalObjective__c', 'TermCondition__c', 'GNT__AttachmentExtension__c', 'Award__c',  'ProgressReports__c', 'SiteVisit__c', 'Case__c', 'BusinessPackage__c', 'Closeout__c', 'BudgetPeriod__c','Grant__c', 'PanelApplication__c', 'PanelUser__c', 'ReviewPanel__c', 'ReviewStepApplication__c', 'Review__c', 'ReviewStep__c', 'ReviewGroup__c', 'ApplicationBudgetCategory2__c', 'Application__c', 'PanelUserTemplate__c', 'ReviewPanelTemplate__c', 'ReviewStepTemplate__c', 'FundingOpportunityBudgetCategory__c', 'Announcement__c', 'ProgramBudgetCategory__c', 'KeyOutcome__c', 'ProgramContacts__c', 'RolesAndResponsibilities__c', 'Program__c'
     };
     
     public Set<Id> getIds(string entityName, Set<Id> ids){
          Set<Id> results = new Set<Id>();
          if(fieldNames.containsKey(entityName) &&  ids != null && ids.size() > 0 ){
               if(fieldNames.get(entityName).length()> 0){
                    string query= 'Select Id from ' + entityName + ' where ' +  fieldNames.get(entityName) + ' in '  + GNT.AppUtils.soqlList(ids);
                    System.debug(query);
                    List<SObject> entities = Database.query(query);
                    System.debug('>>>'+entities.size());
                    Set<Id> myIds = resolveSObjects(entities);
                    if(myIds != null && myIds.size() > 0){
                         results.addAll(myIds);
                    }
               }
               if(entityNames.containsKey(entityName)){
                    List<String> children = entityNames.get(entityName);
                    for(string child : children){
                         system.debug('>>> for child' + child);
                         Set<Id> childIds = getIds(child, results);
                         if(childIds != null && childIds.size() > 0){
                              results.addAll(childIds);
                         }
                    }
               }
          }
          return results;
     }     
     private Set<Id> resolveSObjects(List<SObject> entities){
          Set<Id> ids = new Set<Id>();
          for(SObject entity : entities){
               Id id = (Id) entity.get('Id');
                    if(id != null){
                         ids.add(id);
                    }
          }
          return ids;
     }
     public void deleteEntities(string entityName, Set<Id> ids){ //Acquires           
          Set<Id> childIds = getIds(entityName, ids);
          Map<String, List<SObject>> idObjectMap = getSObjects(childIds);       
          for(string objectName : objectTypes) {
               List<SObject> sObjects = idObjectMap.get(objectName);
               if (sObjects != null && sObjects.size() > 0) {
                    System.debug(sObjects);
                    delete sObjects;
               }
          }  
     }
     private Map<String, List<SObject>> getSObjects(Set<Id> ids) { //Take in set of Ids, sort into map of object type to object ids Map<String, List<Id>>
          Map<String, List<SObject>> sObjects = new Map<String, List<SObject>>();              
          for (Id id : ids) {          
               String objectType = String.valueOf(id.getSObjectType());
               List<SObject> results = sObjects.get(objectType);
               if(results == null){
                   results = new List<SObject>();
                   sObjects.put(objectType, results);
               }
               results.add(Schema.getGlobalDescribe().get(String.valueOf(id.getSObjectType())).newSObject(Id = id));
          }
          //System.debug(sObjects);
          return sObjects;
     }
     public Map<String, List<SObject>> getSObjects(String entityName, Set<Id> ids) {
          Set<Id> idSet = getIds(entityName, ids);
          Map<String, List<SObject>> sObjectMap = getSObjects(idSet);
          for (String objectType : sObjectMap.keySet()) {
              System.debug(sObjectMap.get(objectType));
          }
          return sObjectMap;
     }
}