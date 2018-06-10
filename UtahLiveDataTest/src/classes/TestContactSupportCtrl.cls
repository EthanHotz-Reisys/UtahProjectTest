@isTest
public with sharing class TestContactSupportCtrl {
    public string recordType {get;set;}
 	@isTest 
 	public static void validateGetKeyValueMap(){
		 Contact cont=TestHelper.getContact(true);
		  ApexPages.Standardcontroller sc1 = New ApexPages.StandardController(cont);
         ContactSupportCtrl contSup=new ContactSupportCtrl(sc1);
		 ApexPages.currentPage().getParameters().put('recordId',cont.Id);
		 String returnString=contSup.getKeyValueMap();
		 }
}