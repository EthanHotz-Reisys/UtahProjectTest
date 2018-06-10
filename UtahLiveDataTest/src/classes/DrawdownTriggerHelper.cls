global with sharing class DrawdownTriggerHelper extends GNT.TriggerHelper{
     
     private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
     public static Boolean skipTrigger = false;
     public override void processAfterInsert() {
        if(skipTrigger == false){
            if(appName == 'StateasGrantee'){
                buildAdvanceOrReimburseGrid();
            }
          }
     }
     
     private void buildAdvanceOrReimburseGrid(){
        List<RequestAdvanceOrReimburse__c> paymentCat = [SELECT Id FROM RequestAdvanceOrReimburse__c];

        Set<Id> grantIds = new Set<Id>();
        for(Drawdown__c draw : (List<Drawdown__c>) Trigger.New) {
            grantIds.add(draw.Grant__c);
        }

        Map<Id, List<GrantServiceArea__c>> drawServArea = new  Map<Id, List<GrantServiceArea__c>>();  //key->grant id
        List<GrantServiceArea__c> servAreaLst = [SELECT Id, Grant__c, ServiceArea__c FROM GrantServiceArea__c WHERE Grant__c in :grantIds];
        for (GrantServiceArea__c gsa : servAreaLst) {
            List<GrantServiceArea__c> innerList = drawServArea.get(gsa.Grant__c);
            if (innerList == null) {
                innerList = new List<GrantServiceArea__c>();
                drawServArea.put(gsa.Grant__c, innerList);
            }
            innerList.add(gsa);
        }

        List<DrawdownDetail__c> drawReports = new List<DrawdownDetail__c>();
        for(Drawdown__c draw : (List<Drawdown__c>) Trigger.New){
            List<GrantServiceArea__c> saList = drawServArea.get(draw.Grant__c);
            for (GrantServiceArea__c sa : saList) {
                for (RequestAdvanceOrReimburse__c ra : paymentCat) {
                    DrawdownDetail__c drawReport = new DrawdownDetail__c();
                    drawReport.Drawdown__c= draw.Id;
                    drawReport.ServiceArea__c = sa.ServiceArea__c;
                    drawReport.RequestAdvanceOrReimburse__c = ra.Id;
                    drawReport.Amount__c = 0.0;
                    drawReports.add(drawReport);
                }
            }
        }

        insert drawReports;

     }
}