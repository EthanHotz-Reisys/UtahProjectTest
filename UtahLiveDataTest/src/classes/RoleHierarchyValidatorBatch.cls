/* ------------------------------------------------------------------------------
Name: RoleHierarchyValidatorBatch
Purpose: This class is used make sure the internal role hierarchy is properly represented as account records.
Author: Prem Pal
------------------------------------------------------------------------------ */

global class RoleHierarchyValidatorBatch implements Database.Batchable<sObject>{
    String query;
    global RoleHierarchyValidatorBatch(String whereClause){
         
        query = 'SELECT Id,ParentRoleId,Name FROM UserRole WHERE PortalAccountId = null AND PortalType = \'none\'';
        if(whereClause != null){
            query += ' AND ' + whereClause;
        }
        query += ' ORDER BY Name ';
        System.debug('----queryqueryquery---'+query);
    }
    global Database.querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> records){  
        List<String> roleNodeNames = new List<String>();
        Map<Id,String> roleIdToRoleNameMap = new Map<Id,String>();
        
        for(sObject sobj : records){
            UserRole ur = (UserRole)sobj;
            roleNodeNames.add(ur.Name);
            roleIdToRoleNameMap.put(ur.Id,ur.Name);
        }
        
        List<UserRole> roleNotInSyncList = new List<UserRole>();
        Map<String,Account> accountNameToAccountMap = new Map<String,Account>();
        Map<Id,Account> accountNodesMap = new Map<Id,Account>([SELECT Name,Parent.Name FROM Account WHERE Name IN :roleNodeNames ORDER BY Name]);
        for(Account acc : accountNodesMap.values()){
            accountNameToAccountMap.put(acc.Name,acc);
        }
        System.debug('records---.'+records.size());
        System.debug('accountNodesMap---.'+accountNodesMap.size()); 
        //if(records.size() == accountNodesMap.size()){
            Boolean inSync = true;  
            for(sObject sobj : records){
                UserRole ur = (UserRole)sobj;
                Account correspondingAcc = accountNameToAccountMap.get(ur.Name);
                if(correspondingAcc == null || (correspondingAcc != null && correspondingAcc.Parent.Name != roleIdToRoleNameMap.get(ur.ParentRoleId))){
                    inSync = false;
                    roleNotInSyncList.add(ur);                    
                }
            }
            if(inSync){
                System.debug('Role and account hierarchy are in sync.');
            }else{
                System.debug('----Role and account hierarchy are not in sync.');
                for(UserRole ur: roleNotInSyncList){
                    System.debug('----Role not in sync.--'+ur);
                }
            }
        //}else{
            //System.debug('Role and account hierarchy are not in sync.');
        //}                   
    }
    global void finish(Database.BatchableContext bc){
        
    }
}