public with sharing class RecordShareCtrl {
	
	public List<ShareWrapper> getRecords(){
		Id sobjectId = ApexPages.CurrentPage().getParameters().get('id');
		List<Sobject> shareRec = new List<Sobject>();
    	if(sobjectId.getSobjectType() == PreApplication__c.getSObjectType()){
    		shareRec = [select UserOrGroupId,AccessLevel,RowCause from PreApplication__share where parentId =:sobjectId];
    	}else{
    		shareRec = [select UserOrGroupId,AccessLevel,RowCause from Application__share where parentId =: sobjectId];  
    	} 
		List<ShareWrapper> nameList = new List<ShareWrapper>();
		for(Sobject share : shareRec){
			Id  idVal = String.valueOf(share.get('UserOrGroupId'));
			nameList.add(getShareWrapperRec(share,idVal));
		}
		return 	nameList;
	}
	
	public List<String> getFields(){
		List<String> fieldset = new List<String>();
		fieldSet.add('usertype');
		fieldSet.add('name');
		fieldSet.add('accesslevel');		
		return fieldSet;
	}
	
	
		
	private ShareWrapper getShareWrapperRec(Sobject share,Id UserOrGroupId){
		if(String.valueOf(UserOrGroupId.getSObjectType()) == 'User'){
			User u = [select name from User where id = :UserOrGroupId limit 1];
			return new ShareWrapper(share,'User',u.name);
		}else if(String.valueOf(UserOrGroupId.getSObjectType()) == 'Group'){
			Group g = [select name,developername,type from Group where id = :UserOrGroupId limit 1];
			return new ShareWrapper(share,g.type,g.developername);
		}
		return null;
	}
	
	public class ShareWrapper{
		public String name {get;set;}
		public String usertype {get;set;}
		public String accesslevel {get;set;}
		public String rowCause {get;set;}
		
		public ShareWrapper(Sobject share,string usertype,string name){
			this.name = name;
			this.usertype = usertype;
			this.accesslevel = String.valueOf(share.get('AccessLevel'));
			this.rowCause = String.valueOf(share.get('RowCause'));
		}
	}
	
}