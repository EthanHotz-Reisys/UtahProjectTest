/**
    All review tasks comes to this page which inspects the type of sobject and based on that
    it redirects to the appropriate VF page for the actual approval.
    **********************************************************
    Audit History
    **********************************************************  
    2014-05-22     Shah Kadirmohideen           Created
    **********************************************************  
*/
public with sharing class TaskReviewRedirectCtrl {  private Id taskId;

    public TaskReviewRedirectCtrl(ApexPages.StandardController stdController) {
        taskId = stdController.getRecord().Id;
    }

    public PageReference redirect() {
        Boolean firstRun = false;
        PageReference p = null;
        List<GNT__TaskConfig__c> tasList  =  new List<GNT__TaskConfig__c>();
        GNT__TaskConfig__c tas;
        Task t = [Select Id,Status, GNT__TaskAction__c,GNT__StartDate__c,GNT__AssignedToQueue__c, GNT__ObjectRelationName__c, WhatId,WhoId,Who.Id from Task where Id=:taskId];
        system.debug('task----------->>>>'+t);
        if(t!=null){
            if(t.Status=='Not Started'){
              //  if(t.GNT__StartDate__c!= null && System.today() < t.GNT__StartDate__c ){
              //      return new PageReference('/apex/'+AppUtils.getNamespacePrefix() + 'TaskDetail?id='+taskId);
             //   }
                t.Status='In Progress';
                update t;
                firstRun = true;
                
                // TODO - update the status of the sobject as per custom setting entry
                // Use Over all try catch - show exception message to UI, and database rollback
            }
            system.debug('t.GNT__TaskAction__c ---'+t.GNT__TaskAction__c);
            if(t.GNT__AssignedToQueue__c == true){
                 tasList = [SELECT id,GNT__TaskAction__c,GNT__ViewPageProfiles__c,GNT__TaskViewPage__c,GNT__GroupType__c,
                        GNT__TaskEditPage__c, GNT__SobjectName__c,GNT__TaskInitiationFieldUpdate__c,GNT__CompleteOnView__c FROM GNT__TaskConfig__c WHERE 
                        GNT__TaskAction__c=:t.GNT__TaskAction__c AND GNT__GroupType__c = 'GroupTasks'];
            }
            else
            {   
                 tasList = [SELECT id,GNT__TaskAction__c,GNT__ViewPageProfiles__c,GNT__TaskViewPage__c,GNT__GroupType__c,
                         GNT__TaskEditPage__c,GNT__SobjectName__c, GNT__TaskInitiationFieldUpdate__c,GNT__CompleteOnView__c FROM GNT__TaskConfig__c WHERE 
                         GNT__TaskAction__c=:t.GNT__TaskAction__c AND GNT__GroupType__c = 'MyTasks'];
                  system.debug('tasList---'+tasList); 
            }                               
            if( tasList.size() > 0){
                tas = tasList[0];
                if(tas.GNT__CompleteOnView__c == true) {
                    t.Status = 'Completed';
                    update t;
                }
                system.debug('tas---'+tas);
                // if a task is clicked for first time - update status of the parent record    
                system.debug('firstRun------->>>'+firstRun);         
                if(firstRun){
                    system.debug('t.WhatId-------->>>>>'+t.WhatId);
                    system.debug('t.WhoId-------->>>>>'+t.WhoId);
                    if(t.WhatId != null){
                        updateSobject(t.WhatId, tas);
                    }else if(t.WhoId != null){
                        updateSobject(t.WhoId, tas);
                    }                    
                }
                system.debug('ViewPageProfiles__c---'+tas.GNT__ViewPageProfiles__c);
                GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());                
                if(t.Status == 'Completed') {
                    if(tas.GNT__TaskViewPage__c != null){                                
                                p = new PageReference('/apex/'+tas.GNT__TaskViewPage__c);
                                p.getParameters().put('id', t.WhatId);
                                p.getParameters().put('taskId', t.id);
                                return p;
                            }
                            else{system.debug('IN: ');
                                   p = new PageReference('/' + t.WhatId); 
                                   p.getParameters().put('taskId', t.id);
                                   return p;
                               }
                }
                
                else if(tas.GNT__ViewPageProfiles__c != null) { //if GNT__ViewPageProfiles__c is populated
                    system.debug('debugging 111------>>>'); 
                    List<String> viewPageProfilesList = tas.GNT__ViewPageProfiles__c.split(';');   
                     system.debug('debugging 111-1-----userPrefs->>>'+userPrefs);              
                    for(String prof : viewPageProfilesList) {
                        system.debug('debugging 111-2-----prof.trim()->>>'+prof.trim()); 
                        system.debug('debugging 111-2-----userPrefs.GNT__ProfileName__c->>>'+userPrefs.GNT__ProfileName__c); 
                        if(prof.trim()== userPrefs.GNT__ProfileName__c){
                              system.debug('debugging 111-2-1-----prof->>>'); 
                            //if current user profile name is present,redirect to view page                            
                            If(tas.GNT__TaskViewPage__c != null){  
                                 system.debug('debugging 112------>>>');                               
                                p = new PageReference('/apex/'+tas.GNT__TaskViewPage__c);
                                p.getParameters().put('id', t.WhatId);
                                p.getParameters().put('taskId', t.id);
                                return p;
                            }
                            else{
                                     system.debug('debugging 113------>>>'); 
                                   p = new PageReference('/' + t.WhatId); 
                                   p.getParameters().put('taskId', t.id);
                                   return p;
                               }
                        }
                        //if current user profile name is not present,redirect to edit page
                        else{
                                 system.debug('debugging 114------>>>'); 
                            If(tas.GNT__TaskEditPage__c != null){  
                                         system.debug('debugging 115------>>>'); 
                                p = new PageReference('/apex/'+tas.GNT__TaskEditPage__c);
                                if(t.WhatId != null){
                                    p.getParameters().put('id', t.WhatId);
                                }else if(t.Who.Id != null){
                                    p.getParameters().put('id', t.WhoId);
                                }                                
                            }
                            else{
                                     system.debug('debugging 116------>>>'); 
                                if(t.WhatId != null){
                                    p = new PageReference('/' + t.WhatId+'/e');
                                }else if (t.WhoId != null){
                                    p = new PageReference('/' + t.WhoId+'/e');
                                }                               
                                
                            }
                                
                        }
                    }
                }//if GNT__ViewPageProfiles__c is not populated, redirect to edit page, irrespective of profile.
                else{
                         system.debug('debugging 117------>>>'); 
                    system.debug('TaskEditPage__c---'+tas.GNT__TaskEditPage__c);
                     If(tas.GNT__TaskEditPage__c != null){
                         p = new PageReference('/apex/'+tas.GNT__TaskEditPage__c);
                         p.getParameters().put('id', t.WhatId);
                         p.getParameters().put('retURL',ApexPages.currentPage().getParameters().get('retURL'));
                     }
                    else{
                        if(t.WhatId != null){
                            p = new PageReference('/' + t.WhatId+'/e');
                        }                       
                        else if(t.WhoId != null){
                            p = new PageReference('/' + t.WhoId+'/e');
                        }
                        
                    }
                        
                }                    
            }else{
                     system.debug('debugging 118------>>>'); 
                 if(t.WhatId != null){
                            p = new PageReference('/' + t.WhatId+'/e');
                        }                       
                        else if(t.WhoId != null){
                            p = new PageReference('/' + t.WhoId+'/e');
                        }
            }
        }  
        p.getParameters().put('taskId', t.id);
        return p;
    }
    
    private void updateSobject(Id parentId, GNT__TaskConfig__c tas){      
     //   if(!String.isEmpty(tas.SobjectName__c)){
     
     system.debug('In updateSobject========>>>>');
     system.debug('tas========>>>>'+tas);
        if(!String.isEmpty(tas.GNT__TaskInitiationFieldUpdate__c)){
            List<String> tokens = tas.GNT__TaskInitiationFieldUpdate__c.split('=');         
            if(tokens.size()==2){
                String objectName = parentId.getSObjectType().getDescribe().getName();
                String qry = 'SELECT '+tokens[0]+' FROM '+objectName+' WHERE ID =\''+parentId+'\'';   
                system.debug('qry====>>>'+qry);          
                Sobject sobj = Database.query(qry);
                system.debug('sobj====>>>'+sobj);
                String oldValue = String.valueOf(sobj.get(tokens[0]));
                if(!oldValue.endsWith(tokens[1])){
                    sobj.put(tokens[0], tokens[1]);
                    update sobj;
                }
            }
        }
    }
}