/*
    Author: Nakul Kadam
    purpose: Create Change Request and Details when change request is initiated.
    Date: 14/1/2014
*/
public with sharing class ChangeRequestCtrl {
    
    //Properties
    private Id recordId{get;set;}
    public List<TabWrapper> tabWithPageBlocks{get;set;}
    public String comments{get;set;}
    private Application__c app{get;set;}
    public boolean showWarning {get;set;}
    public ChangeRequestCtrl(){
        Map<Id, List<PageBlockWrapper>> tabIdToPageBlocksMap = new Map<Id, List<PageBlockWrapper>>();
        Map<Id, String> tabIdToTabNameMap = new  Map<Id, String>();
        Map<Id,Object> tabIdToTabSeqMap = new Map<Id,Object>();
        tabWithPageBlocks = new List<TabWrapper>();
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        Set<String>statuses = new Set<String>();
        statuses.add('Change Request Approved');
        statuses.add('Change Request Disapproved');
        statuses.add('Change Request Rejected');
        List<Application__c> appList = [Select id,Status__c, ChangeRequestStatus__c ,Announcement__c,OwnerId From Application__c Where id = :recordId Limit 1];
        
        app = appList[0];
        if(app.Status__c == 'Submitted' && (String.isEmpty(app.ChangeRequestStatus__c) || statuses.contains(app.ChangeRequestStatus__c))){
            BusinessPackage__c applicationPkg = [Select Id,Name,PackageConfig__r.GNT__PageTemplateConfig__r.GNT__EditLayoutConfig__c from BusinessPackage__c where PackageType__c ='Application' and FundingOpportunity__c =:app.Announcement__c];
            Id editLayoutId = applicationPkg.PackageConfig__r.GNT__PageTemplateConfig__r.GNT__EditLayoutConfig__c;
            
            List<GNT__PageBlockConfig__c> pgBlockConfigList = [Select Id, Name, GNT__PageBlockTitle__c, GNT__TabLayoutConfig__c, 
                GNT__TabLayoutConfig__r.GNT__StandardTabName__c,GNT__TabLayoutConfig__r.GNT__SortOrder__c    from GNT__PageBlockConfig__c 
                Where GNT__TabLayoutConfig__r.GNT__PageLayoutConfig__c = :editLayoutId AND 
                GNT__IsActive__c = true AND GNT__TabLayoutConfig__r.GNT__IsActive__c = true AND RecordType.Name IN ('Attachments', 'Fields', 'Grid', 'Notes and Attachments') Order by GNT__TabLayoutConfig__r.GNT__SortOrder__c];
            
            for(GNT__PageBlockConfig__c pgBlock : pgBlockConfigList){
                List<PageBlockWrapper> pgbList = tabIdToPageBlocksMap.get(pgBlock.GNT__TabLayoutConfig__c);
                if(pgbList == null){
                    pgbList = new List<PageBlockWrapper>();
                }
                pgbList.add(new PageBlockWrapper(pgBlock, false));
                tabIdToPageBlocksMap.put(pgBlock.GNT__TabLayoutConfig__c, pgbList);
                tabIdToTabNameMap.put(pgBlock.GNT__TabLayoutConfig__c, pgBlock.GNT__TabLayoutConfig__r.GNT__StandardTabName__c);
                tabIdToTabSeqMap.put(pgBlock.GNT__TabLayoutConfig__c, pgBlock.GNT__TabLayoutConfig__r.GNT__SortOrder__c);
            }
                        
            for(Id tabId : tabIdToPageBlocksMap.keySet()){
                String tabName = tabIdToTabNameMap.get(tabId);
                Integer tabSeq = Integer.valueOf(tabIdToTabSeqMap.get(tabId));
                tabWithPageBlocks.add(new TabWrapper(tabName, tabIdToPageBlocksMap.get(tabId),tabSeq));
            }           
            tabWithPageBlocks.sort();
            showWarning = false;
        }else{
            showWarning = true;
        }
    }
    
    public class TabWrapper implements Comparable{
        public string tabName{get;set;}
        public List<PageBlockWrapper> pgbList{get;set;}
        public integer sequence {get;set;}
        
        public TabWrapper(String tabName, List<PageBlockWrapper> pgbList,Integer sequence){
            this.tabName = tabName;
            this.pgbList = pgbList;
            this.sequence = sequence;
        }
         public Integer compareTo(Object ObjToCompare) {
            Boolean sortOrder = ((TabWrapper )objToCompare).sequence > sequence;
            if(sortOrder)
            return -1;
            return 1;
        }
    }
    
    public class PageBlockWrapper{
        public boolean selected {get;set;}
        public GNT__PageBlockConfig__c pgBlock{get;set;}
        
        public PageBlockWrapper(GNT__PageBlockConfig__c pgBlock, Boolean selected){
            this.pgBlock = pgBlock;
            this.selected = selected;
        }
    }
    
    public PageReference cancel(){
        String ns = AppUtils.getNamespacePrefix(); 
        PageReference pageRef= new PageReference('/apex/'+ns+'ApplicationView?id='+recordId);
        pageRef.setRedirect(true);  
        return pageRef;
    }
    
    public PageReference save(){
        Set<Id> selectedPageBlockIdSet = new Set<Id>();
    //    List<ChangeRequestDetail__c> crDetailList = new List<ChangeRequestDetail__c>();
        Map<Id,String>mapIdPb = new Map<Id,String>();        
        for(TabWrapper wrapper : tabWithPageBlocks){            
            List<PageBlockWrapper> pgblockList = wrapper.pgbList;
            for(PageBlockWrapper pgb : pgblockList){
                if(pgb.selected){
                    selectedPageBlockIdSet.add(pgb.pgBlock.Id);
                    mapIdPb.put(pgb.pgBlock.Id,pgb.pgBlock.GNT__PageBlockTitle__c);
                }
            }
        }
        if(selectedPageBlockIdSet.size() > 0){
            ChangeRequest__c cr = new ChangeRequest__c();
            cr.Application__c = recordId;
            cr.Comments__c = comments;
            cr.Status__c = 'Initiated';
            cr.ChangeRequestedOnSections__c = GNT.AppUtils.concatenate(mapIdPb.values(), ',');
            insert cr;    
          /*  for(Id pgbId : selectedPageBlockIdSet){
                ChangeRequestDetail__c crDetail = new ChangeRequestDetail__c();
                crDetail.ChangeRequest__c = cr.Id;
                crDetail.PageBlockConfig__c = pgbId;
                crDetailList.add(crDetail);  
            }
            if(crDetailList.size() > 0){
                insert crDetailList;                
                app.Status__c = 'In Progress';
                app.ChangeRequestStatus__c = 'Change Request Assigned'; 
                app.SubmittedOn__c = null;
                update app;
            }*/
            GNT.TaskCreationHandler.createTasks(app.OwnerId, cr.Id, 'Submit Change Request', cr.Name, null, false, null, null, true);
           // GNT.TaskCreationHandler.createTasks(app.OwnerId, cr.Id, 'Submit Change Request', cr.Name, null, false, null, null, cr.ApplicationTitle__c, true);
        }
        String ns = AppUtils.getNamespacePrefix(); 
        PageReference pageRef= new PageReference('/apex/'+ns+'ApplicationView?id='+recordId);
        pageRef.setRedirect(true);  
        return pageRef;
    }
}