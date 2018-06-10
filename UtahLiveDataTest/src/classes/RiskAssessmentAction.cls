global class RiskAssessmentAction extends GNT.FlexTableActionHandler{
   
    private  Id recordId;
    private  Sobject sobj;
    private  String namespace;
    private  Grant__c grantObj;
    private  List<Grant__c> grantObjList;
    private  RiskAssessment__c riskObj;
    private List<RiskAssessment__c> riskObjList;

    global override Map<String,Object> clickHandler(){ 
        Map<String,Object> resultMap = new Map<String,Object>();
        //String[] str = Label.RiskAssessmentActionStatus.split(',');
        String[] str = GNT.KeyValueStoreHelper.getTextValue('RiskAssessmentActionStatus',true).split(',');
        //List<String> statuses = new List<String>{str};
        recordId = urlParams.get('id');
        namespace = AppUtils.getNamespacePrefix();
        
        

        //System.Debug('statuses.. '+str);
        //('In Progress','Submitted for Approval','Approved by Grant Supervisor')
        riskObjList = [Select Id from RiskAssessment__c where Grant__c=:recordId AND Status__c IN :str];
        grantObjList = [Select Id, ProgramManager__c, ProjectOfficer__c, GrantMonitor__c from Grant__c where Id = :recordId Limit 1];
        if(grantObjList != null && grantObjList.size()>0){
            grantObj = grantObjList[0];
        }
        if(UserInfo.getUserId() == grantObj.ProjectOfficer__c || UserInfo.getUserId() == grantObj.GrantMonitor__c){        
            if(riskObjList.size() > 0){
                resultMap.put('Message', Label.RiskAssessmentActionWarning);
            }else{      
                riskObj = new RiskAssessment__c();
                riskObj.ProgramManager__c = grantObj.ProgramManager__c;
                riskObj.ProjectOfficer__c = grantObj.ProjectOfficer__c;
                riskObj.GrantMonitor__c = grantObj.GrantMonitor__c;
                //riskObj.GrantSupervisor__c= grantObj.GrantSupervisor__c;
                riskObj.Status__c = 'In Progress';
                riskObj.Grant__c = recordId;
                insert riskObj;
                
                resultMap.put('PageReference','/apex/'+namespace+'riskassessmentedit?id='+riskObj.Id+'&grantid='+recordId);        
            }
        }else{
                resultMap.put('Message', Label.RiskAssessmentNewRequestWarning);
        }

        
        return resultMap;
         
    }

}