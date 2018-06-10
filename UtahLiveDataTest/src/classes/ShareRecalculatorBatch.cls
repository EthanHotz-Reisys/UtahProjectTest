/* ------------------------------------------------------------------------------
Name: ShareRecalculatorBatch
Purpose: This class is used to recalcuate share records when any sharing rule is changed.
Author: Prem Pal
------------------------------------------------------------------------------ */

global class ShareRecalculatorBatch implements Database.Batchable<sObject>{
    String query;    
    String businessObjectName;
    String bizObjectName;
    String whereClause; 
    Boolean allObjects;   
    Integer index;    
    GNT__BusinessShareConfig__c bizShareConfig;
    Schema.SObjectType shareObjectType;
    String shareObjectName;
    global ShareRecalculatorBatch(String businessObjectName, String whereClause,Boolean allObjects,Integer index){
        this.bizObjectName = businessObjectName;
        if(businessObjectName == null){           
            bizShareConfig = GNT__BusinessShareConfig__c.getAll().values().get(index);
            System.debug('----bizShareConfig----'+bizShareConfig);          
            businessObjectName = bizShareConfig.Name;            
        }else{
            bizShareConfig = GNT__BusinessShareConfig__c.getValues(businessObjectName);
        }
        
        shareObjectName = bizShareConfig.GNT__ShareObjectName__c;
        shareObjectType = Schema.getGlobalDescribe().get(shareObjectName);
        
        query = 'SELECT Id,'+bizShareConfig.GNT__RoleCodeFieldName__c +' FROM ' + businessObjectName ;
        if(whereClause != null){
            query += ' WHERE ' + whereClause;
        }
        System.debug('----queryqueryquery---'+query);       
        this.businessObjectName = businessObjectName;
        this.bizShareConfig = bizShareConfig;
        this.whereClause = whereClause;
        this.allObjects = allObjects;
        this.index = index;
        
    }
    global Database.querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> records){                    
        Map<String,String> sobjectIdToRoleCodeMap = new Map<String,String>();
        
        for(SObject sObj : records){                                   
            System.debug('----sObj----'+sObj);            
            String roleCodeValue = (String)sObj.get(bizShareConfig.GNT__RoleCodeFieldName__c);
            sobjectIdToRoleCodeMap.put((String)sObj.get('Id'),roleCodeValue);
        } 
        System.debug('----sobjectIdToRoleCodeMap----'+sobjectIdToRoleCodeMap);
        insertSharingRecords(businessObjectName,shareObjectType,sobjectIdToRoleCodeMap,records);  
    }
    public void insertSharingRecords(String businessObjectName,Schema.SObjectType shareObjectType,
                                    Map<String,String> sobjectIdToRoleCodeMap,List<sObject> records){
        
        List<Sobject> shareRecordsList = new List<Sobject>();        
        for(GNT__SObjectSharingRule__c sobjSharingRule : [SELECT GNT__AccessLevel__c,GNT__CriteriaRoleCodes__c,GNT__Direction__c,
                                                                    GNT__RuleType__c,GNT__ShareWithGroupIds__c,GNT__SobjectName__c,
                                                                    GNT__SObject__c,Id 
                                                                    FROM GNT__SObjectSharingRule__c
                                                                    WHERE GNT__SobjectName__c =: businessObjectName]){
            System.debug('----sobjSharingRule----'+sobjSharingRule);                                          
            getSharingRecordsList(sobjSharingRule,sobjectIdToRoleCodeMap,shareRecordsList,shareObjectType,records);            
        }
        deleteExistingRecords(sobjectIdToRoleCodeMap.keySet());
        System.debug('----shareRecordsList----'+shareRecordsList);
        if(shareRecordsList.size() > 0){
            
            insert shareRecordsList;                        
        }
    }
    public void deleteExistingRecords(Set<String> parentIdSet){
        String deleteQuery = 'SELECT Id FROM ' + shareObjectName + ' WHERE ParentId =: parentIdSet'+
        ' AND RowCause IN (\'Home__c\',\'Sibling__c\',\'Guest__c\',\'Family__c\')';
        System.debug('----deleteQuery----'+deleteQuery);
        List<Sobject> deleteShareRecordsList = Database.query(deleteQuery);
        System.debug('----deleteShareRecordsList----'+deleteShareRecordsList);
        delete deleteShareRecordsList;
    }
    public void getSharingRecordsList(GNT__SObjectSharingRule__c sobjSharingRule,
                            Map<String,String> sobjectIdToRoleCodeMap,List<Sobject> shareRecordsList,
                            Schema.SObjectType shareObjectType,List<sObject> records){
        
        List<String> roleCodeList = sobjSharingRule.GNT__CriteriaRoleCodes__c.split(',');
        Set<String> roleCodeSet = new Set<String>(roleCodeList);
        String shareWithGroupIds = sobjSharingRule.GNT__ShareWithGroupIds__c;
        String accessLevel = sobjSharingRule.GNT__AccessLevel__c ;
        
        for(SObject record : records){
            System.debug('----record----'+record);            
            String roleCodeValue = sobjectIdToRoleCodeMap.get((String)record.get('Id'));
            System.debug('----roleCodeValue----'+roleCodeValue);
            if(roleCodeValue != null && roleCodeSet.contains(roleCodeValue)){
                if(shareWithGroupIds != null){
                    List<String> shareWithGroupIdsList = shareWithGroupIds.split(',');
                    for(String shareGroupId : shareWithGroupIdsList){                        
                        sObject shareRecord = shareObjectType.newSObject(); 
                        shareRecord.put('ParentId', (String)record.get('Id'));
                        shareRecord.put('UserOrGroupId', shareGroupId);
                        shareRecord.put('AccessLevel', accessLevel);
                        shareRecord.put('RowCause', sobjSharingRule.GNT__RuleType__c + '__c');
                        shareRecordsList.add(shareRecord);
                        System.debug('----shareRecord----'+shareRecord);
                    }
                }
            }
        }          
    }   
    global void finish(Database.BatchableContext bc){
        if(allObjects == true){
            List<GNT__BusinessShareConfig__c> bizShareConfigList = GNT__BusinessShareConfig__c.getAll().values();
            index = index + 1;
            System.debug('----index----'+index);
            if(index < bizShareConfigList.size()){
                Id batchInstanceId = Database.executeBatch(new ShareRecalculatorBatch(bizObjectName,whereClause,allObjects,index));
            }else{
                Id loggedInUserId = UserInfo.getUserId();
                User u = [SELECT Id,Email FROM User WHERE Id =:loggedInUserId];
                new GNT.emailFeeder().template('SharingRecalculationCompleted').toEmail(u.Email).send();
            }
        }else{
            Id loggedInUserId = UserInfo.getUserId();
            User u = [SELECT Id,Email FROM User WHERE Id =:loggedInUserId];
            new GNT.emailFeeder().template('SharingRecalculationCompleted').toEmail(u.Email).send();
        }        
    }
}