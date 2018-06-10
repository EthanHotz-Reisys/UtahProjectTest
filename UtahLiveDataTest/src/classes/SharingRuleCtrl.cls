public with sharing class SharingRuleCtrl {
    private Map<String,String> roleDevnametoParentRoleIdMap;
    
    public ID recordId{get;set;}
    public String type{get;set;}
    public String saveSuccessful {get;set;}
    
    public List<String> selectedObjects {get;set;}
    public List<String> createdForRoles {get;set;}
    public List<String> sharedWithRoles {get;set;}
    public List<String> participatingRoles {get;set;}
    public String selectedDirection {get;set;}
    public String selectedAccessLevel {get;set;}
    public String selectedRuleType {get;set;}
    public String selectedFamilyRole {get;set;}
    public String activeBlock {get;set;}
    public String shareWith {get;set;}
    public List<String> sharedWithGroups {get;set;}
    public Map<String,String[]> sobjidToNameMap {get;set;}
    public Map<String,String> roleDevnametoNameMap {get;set;}
    public Map<String,String> roleDevnametoIdMap {get;set;}
    public Map<String,String> groupDevnametoIdMap {get;set;}
    public Map<String,String> roleDevnametoGroupIdMap {get;set;}    
    public List<Database.SaveResult> srList {get;set;}
    public List<Integer> indexList {get;set;}
    public Map<Integer,GNT__SObjectSharingRule__c> indexSharingRuleMap {get;set;}
    public Map<Integer,String> indexSuccessMap {get;set;}
    
    public PageReference saveSharingRule(){
        try{
            roleDevnametoGroupIdMap = new Map<String,String>();
            
            for(Group g: [SELECT Id,DeveloperName,Name FROM Group WHERE DeveloperName IN :roleDevnametoIdMap.keySet()]){
                roleDevnametoGroupIdMap.put(g.DeveloperName,g.Id);
            }
            
            String createdRolesString = '';
            String createdRoleCodesString = '';
            String sharedWithRolesString = '';
            String sharedWithRoleCodesString = '';
            String sharedWithRolesIdString = '';
            String participatingRolesString = '';
            String participatingRolesIdString = '';
            String participatingRoleCodesString = '';
            String sharedWithGroupsString = '';
            String sharedWithGroupsIdString = '';
            
            if(selectedDirection == 'One Way'){            
                for(String cr : createdForRoles){
                    createdRolesString += roleDevnametoNameMap.get(cr) + ',';
                    createdRoleCodesString += cr + ',';
                }
                createdRolesString = createdRolesString.length() > 1 ? createdRolesString.substring(0, createdRolesString.length() - 1) : null;
                createdRoleCodesString = createdRoleCodesString.length() > 1 ? createdRoleCodesString.substring(0, createdRoleCodesString.length() - 1) : null;
                
                if(shareWith == 'UserRole'){
                    for(String sr : sharedWithRoles){
                        sharedWithRolesString += roleDevnametoNameMap.get(sr) + ',';
                        sharedWithRolesIdString += roleDevnametoGroupIdMap.get(sr) + ',';
                        sharedWithRoleCodesString += sr + ',';
                    }
                    sharedWithRolesString = sharedWithRolesString.length() > 1 ? sharedWithRolesString.substring(0, sharedWithRolesString.length() - 1) : null;
                    sharedWithRolesIdString = sharedWithRolesIdString.length() > 1 ? sharedWithRolesIdString.substring(0, sharedWithRolesIdString.length() - 1) : null;
                    sharedWithRoleCodesString = sharedWithRoleCodesString.length() > 1 ? sharedWithRoleCodesString.substring(0, sharedWithRoleCodesString.length() - 1) : null;
                }else if(shareWith == 'Group'){
                    for(String gr : sharedWithGroups){
                        sharedWithGroupsString += gr + ','; 
                        sharedWithGroupsIdString  +=  groupDevnametoIdMap.get(gr) + ',';  
                    }
                    sharedWithGroupsString = sharedWithGroupsString.length() > 1 ? sharedWithGroupsString.substring(0, sharedWithGroupsString.length() - 1) : null;
                    sharedWithGroupsIdString = sharedWithGroupsIdString.length() > 1 ? sharedWithGroupsIdString.substring(0, sharedWithGroupsIdString.length() - 1) : null;
                }
            }else{
                if(selectedRuleType == 'Sibling'){
                    String parentRoleId = roleDevnametoParentRoleIdMap.get(selectedFamilyRole); 
                    List<UserRole> siblingList = [SELECT DeveloperName 
                                                        FROM UserRole 
                                                        WHERE PortalAccountId = null 
                                                        AND ParentRoleId =:parentRoleId
                                                        ORDER BY Name];
                    participatingRoles = new List<String>();
                    for(UserRole ur : siblingList){
                        participatingRoles.add(ur.DeveloperName);
                    }
                                                       
                }
                if(selectedRuleType == 'Guest' || selectedRuleType == 'Sibling'){
                    for(String pr : participatingRoles){
                        participatingRolesString += roleDevnametoNameMap.get(pr) + ',';
                        participatingRolesIdString += roleDevnametoGroupIdMap.get(pr) + ',';
                        participatingRoleCodesString += pr + ',';
                    }
                    participatingRolesString = participatingRolesString.length() > 1 ? participatingRolesString.substring(0, participatingRolesString.length() - 1) : null;
                    participatingRolesIdString = participatingRolesIdString.length() > 1 ? participatingRolesIdString.substring(0, participatingRolesIdString.length() - 1) : null;
                    participatingRoleCodesString = participatingRoleCodesString.length() > 1 ? participatingRoleCodesString.substring(0, participatingRoleCodesString.length() - 1) : null;
                }
            }
            List<GNT__SObjectSharingRule__c> sobjSharingRulesList = new List<GNT__SObjectSharingRule__c>();
            indexSharingRuleMap = new Map<Integer,GNT__SObjectSharingRule__c>();
            indexList = new List<Integer>();
            Integer index = 0;
            for(String selectedObj : selectedObjects){
                GNT__SObjectSharingRule__c sobjrule = new GNT__SObjectSharingRule__c();
                indexSharingRuleMap.put(index,sobjrule);
                indexList.add(index);
                sobjrule.GNT__AccessLevel__c = selectedAccessLevel;
                sobjrule.GNT__RuleType__c = selectedRuleType;
                sobjrule.GNT__Direction__c = selectedDirection;
                sobjrule.GNT__SObject__c= selectedObj;
                if(selectedDirection == 'Mutual'){            
                    if(selectedRuleType == 'Family' || selectedRuleType == 'Home'){
                        sobjrule.GNT__CriteriaRoleNames__c  = roleDevnametoNameMap.get(selectedFamilyRole);        
                        sobjrule.GNT__ShareWithRoleNames__c = roleDevnametoNameMap.get(selectedFamilyRole);
                        //sobjrule.GNT__ShareWithGroupIds__c  = roleDevnametoGroupIdMap.get(selectedFamilyRole);
                        //sobjrule.GNT__CriteriaRoleCodes__c  = selectedFamilyRole;        
                        //sobjrule.GNT__ShareWithRoleCodes__c = selectedFamilyRole;
                    }else{
                        System.debug('participatingRolesString--12-'+participatingRolesString);
                        sobjrule.GNT__CriteriaRoleNames__c  = participatingRolesString;        
                        sobjrule.GNT__ShareWithRoleNames__c = participatingRolesString;
                        //sobjrule.GNT__CriteriaRoleCodes__c  = participatingRoleCodesString ;        
                        //sobjrule.GNT__ShareWithRoleCodes__c = participatingRoleCodesString ;
                        //sobjrule.GNT__ShareWithGroupIds__c  = participatingRolesIdString; 
                    }
                }else{
                    sobjrule.GNT__RuleType__c = 'Guest';
                    sobjrule.GNT__CriteriaRoleNames__c  = createdRolesString;
                    //sobjrule.GNT__CriteriaRoleCodes__c  = createdRoleCodesString ;         
                    if(shareWith == 'UserRole'){       
                        sobjrule.GNT__ShareWithRoleNames__c = sharedWithRolesString;
                        //sobjrule.GNT__ShareWithRoleCodes__c = sharedWithRoleCodesString ;
                        //sobjrule.GNT__ShareWithGroupIds__c  = sharedWithRolesIdString;
                    }else if(shareWith == 'Group'){
                        sobjrule.GNT__ShareWithPublicGroupNames__c = sharedWithGroupsString;
                        sobjrule.GNT__ShareWithGroupIds__c  = sharedWithGroupsIdString;
                    }                                        
                }
                System.debug('sobjrule---'+sobjrule);
                sobjSharingRulesList.add(sobjrule);
                index++;
            }
            System.debug('sobjSharingRulesList---'+sobjSharingRulesList);
            System.debug('indexSharingRuleMap---'+indexSharingRuleMap );
            System.debug('indexList---'+indexList);
            srList = Database.insert(sobjSharingRulesList,false);
            saveSuccessful = 'true';
            indexSuccessMap = new Map<Integer,String>();
            Integer i = 0;
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    indexSuccessMap.put(i,'Record inserted successfully.');//Click  <a href="#" data-toggle="modal" data-target="#myModal" onClick="showData(sr.sr.getId())">here</a> to view'
                }
                else {
                    // Operation failed, so get all errors  
                    String errorMsg = '';              
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        errorMsg += err.getMessage();
                    }
                    indexSuccessMap.put(i,'Problems in inserting record.'+errorMsg);//Click <a href="#" data-toggle="modal" data-target="#myModal">here</a> to errors.
                }
                i++;
            }
            activeBlock = 'final';
            System.debug('indexSuccessMap---'+indexSuccessMap);
        }catch(Exception e){
            saveSuccessful = 'false';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,e.getMessage()));
        }        
        return null;
    }
    
    
    public SharingRuleCtrl(ApexPages.StandardController controller) {
        
        type = ApexPages.CurrentPage().getParameters().get('type');
        if(type == 'OneWay'){
            selectedDirection = 'One Way';
        }else if(type == 'Mutual'){
            selectedDirection = 'Mutual';
        } 
        activeBlock = 'first';
        sobjidToNameMap = new Map<String,String[]>();           
        saveSuccessful = 'true'; 
        selectedAccessLevel =  'Read';
        selectedRuleType = 'Home';  
        shareWith = 'UserRole';     
    }
    public List<SelectOption> getAvailableObjects() {
        List<SelectOption> options = new List<SelectOption>();
        Set<String> businessObjectNames = new Set<String>();
        List<GNT__BusinessShareConfig__c> bizShareConfigList = GNT__BusinessShareConfig__c.getAll().values();
        for(GNT__BusinessShareConfig__c bsc : bizShareConfigList){
            businessObjectNames.add(bsc.Name);
        }
        for(GNT__SobjectConfig__c sobjConfig : [SELECT Id,GNT__ObjectLabel__c,Name 
                                                    FROM GNT__SobjectConfig__c 
                                                    WHERE Name IN :businessObjectNames
                                                    ORDER BY Name]){
            options.add(new SelectOption(sobjConfig.Id,sobjConfig.Name));
            String[] data = new String[]{sobjConfig.GNT__ObjectLabel__c,sobjConfig.Name}; 
            sobjidToNameMap.put(sobjConfig.Id,data);
        }       
        return options;
    }
    
    public List<SelectOption> getAvailableRoles() {
        List<SelectOption> options = new List<SelectOption>();
        roleDevnametoNameMap = new Map<String,String>();
        roleDevnametoIdMap = new Map<String,String>();
        roleDevnametoParentRoleIdMap = new Map<String,String>();
        for(UserRole ur : [SELECT Id,Name,DeveloperName,ParentRoleId FROM UserRole WHERE PortalAccountId = null ORDER BY Name]){
            options.add(new SelectOption(ur.DeveloperName,ur.Name));
            roleDevnametoNameMap.put(ur.DeveloperName,ur.Name);
            roleDevnametoIdMap.put(ur.DeveloperName,ur.Id);
            roleDevnametoParentRoleIdMap.put(ur.DeveloperName,ur.ParentRoleId);
        }       
        return options;
    }
    
    public List<SelectOption> getAvailableShareWithOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('UserRole','Role'));   
        options.add(new SelectOption('Group','Public Group'));         
        return options;
    }
    
    public List<SelectOption> getAvailablePublicGroups() {
        groupDevnametoIdMap = new Map<String,String>();
        List<SelectOption> options = new List<SelectOption>();        
        for(Group gr : [SELECT Id,Name,DeveloperName FROM Group WHERE Type = 'Regular' ORDER BY Name]){
            options.add(new SelectOption(gr.DeveloperName,gr.Name)); 
            groupDevnametoIdMap.put(gr.DeveloperName,gr.Id);           
        }       
        return options;
    }
    
    public List<SelectOption> getDirections() {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> directionList = GNT__SObjectSharingRule__c.GNT__Direction__c.getDescribe().getPicklistValues();

        for(Schema.PicklistEntry pe : directionList){
            options.add(new SelectOption(pe.getValue(),pe.getLabel()));
        }       
        return options;
    }
    
    public List<SelectOption> getAccessLevels() {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> directionList = GNT__SObjectSharingRule__c.GNT__AccessLevel__c.getDescribe().getPicklistValues();
        
        for(Schema.PicklistEntry pe : directionList){
            options.add(new SelectOption(pe.getValue(),pe.getLabel()));
        }  
            
        return options;
    }
    
    public List<SelectOption> getRuleTypes() {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> directionList = GNT__SObjectSharingRule__c.GNT__RuleType__c.getDescribe().getPicklistValues();

        for(Schema.PicklistEntry pe : directionList){
            options.add(new SelectOption(pe.getValue(),pe.getLabel()));
        }      
        
        return options;
    }
    public PageReference showSecondBlock(){
        if(type == 'OneWay'){
            activeBlock = 'oneway';
        }else if(type == 'Mutual'){
            activeBlock = 'mutual';
        }
        return null;
    }
    public PageReference showPreviousBlock(){
        if(activeBlock == 'oneway' || activeBlock == 'mutual'){
            activeBlock = 'first';
        }
        return null;
    }
    
    public PageReference dummyFunc(){
        System.debug('--selectedRuleType--'+selectedRuleType);
        return null;
    }
    
}