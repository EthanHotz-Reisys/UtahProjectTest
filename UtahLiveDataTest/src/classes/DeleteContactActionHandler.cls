global with sharing class DeleteContactActionHandler extends GNT.FlexTableActionHandler{
	global with sharing class KeyPocException extends Exception{}
	global override Map<String,Object> clickHandler() {
		Map<String,Object> resultMap = new Map<String,Object>();
		Boolean error = false;
		try{
			List<Contact> cont = [Select Id,keycontact__c from COntact where Id = :selectedRecordIds];
			List<Contact> keypoccont = [Select Id,keycontact__c from COntact where Id = :selectedRecordIds 
			and keycontact__c = true];
			if (keypoccont.size() == 1){
				if (cont[0].id == keypoccont[0].id){
				throw new KeyPocException();
				}
			}
			SystemContextMethodsHelper helper = new SystemContextMethodsHelper();
			helper.deleteSobjectList(cont);
		}catch(DmlException e){
			resultMap.put('Message' , 'Delete operation failed. Please make sure there is no user under this contact');
            error = true;
		}
		catch(KeyPocException e){
			resultMap.put('Message' , 'Please make another SPI user a Key POC before deleting the existing one.');
            error = true;
		}
		if(error){
            return resultMap;
        }else{
        	resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-28211'));
        	return resultMap;
        }
	}
}