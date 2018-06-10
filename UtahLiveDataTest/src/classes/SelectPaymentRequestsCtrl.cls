public with sharing class SelectPaymentRequestsCtrl {
    private Set<String> recordsIdSet;
    private Set<String> subgrantsIdSet;
    private Set<ID> subgrantids;
    private List<Id> addedRecords =new List<Id>();
    public SelectPaymentRequestsCtrl(){
    	    
            Id drawId =  ApexPages.CurrentPage().getParameters().get('parentid');
            for(DrawdownDetail__c drawDownDetail :[Select Id,PaymentRequest__c from DrawdownDetail__c where Drawdown__c =: drawId])
            {
                addedRecords.add(drawDownDetail.PaymentRequest__c);
            }

            system.debug('--addedRecords--'+addedRecords);
        	Map<Id,PaymentRequest__c>  payreqMap = new Map<Id,PaymentRequest__c> ([Select Id, Name from PaymentRequest__c where Id Not in :addedRecords ]);
       		recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(payreqMap.keyset()), Set<String>.class);
       		system.debug('--recordsIdSet--'+recordsIdSet);
       		
       		Drawdown__c drawdown = [select id,Grant__c from Drawdown__c where id=:drawId];
       		List<GrantConnector__c> grantconnectorlist = [select MasterGrant__c,ChildGrant__c from GrantConnector__c 
       		                                                                   where MasterGrant__c=:drawdown.Grant__c];
       		
       		//subgrantids = (Set<String>)JSON.deserialize(JSON.serialize(grantconnectormap.ChildGrant__c), Set<String>.class);
       		if(grantconnectorlist.size()!= null){
       		for(GrantConnector__c grantconnector:grantconnectorlist){
       			subgrantids.add(grantconnector.ChildGrant__c);
       		}
       	 }
         Map<Id,Grant__c> grantmap = new Map<Id,Grant__c>([Select id from Grant__c where Id in:subgrantids]);
         subgrantsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(grantmap.keyset()), Set<String>.class);
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('parentid',ApexPages.CurrentPage().getParameters().get('parentid'));
        return JSON.serialize(keyValueMap);
    }

     public string getListParameters(){
        Map<String,Set<String>> listParams = new Map<String,Set<String>>();     
        listParams.put('recordsIdSet',recordsIdSet);
        listParams.put('subgrantsIdSet',subgrantsIdSet);
        return JSON.serialize(listParams);
    }
}