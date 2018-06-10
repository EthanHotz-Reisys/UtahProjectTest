global with sharing class SendDigitalSignatureHelper extends GNT.FlexTableActionHandler{
    global SendDigitalSignatureHelper() {}
    Map<String,Object> resultMap = new Map<String,Object>(); 
    /*String apikey ='TIo1JdhZDAui1lp7XLFJ7gpShJYQDSMR';
    String apiSig ='7087E5C5AF8DDF9F51DD73573F18B683';*/
    String apiKey = GNT.KeyValueStoreHelper.getTextValue('DocverifyAPIKey', true);
    String apiSig = GNT.KeyValueStoreHelper.getTextValue('DocverifyAPISignature', true); 
    global override Map<String,Object> clickHandler(){
        String docId = urlParams.get('docId');
        String pageBlockId = urlParams.get('pageBlockId');
       if(selectedRecordIds.size() == 0){ 
         //resultMap.put('Message','No Records have been selected');
         resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58429'));
          return resultMap;
        }  
          
        try {         
            List<Contact> emailList = [Select Email,Name,Title from Contact where Id IN: selectedRecordIds ];
            GNT__PageBlockConfig__c pb = [SELECT GNT__OwnerSignOrder__c From GNT__PageBlockConfig__c WHERE Id =: pageBlockId];
            String ownerSignOrder = pb.GNT__OwnerSignOrder__c;
            System.debug('emailList=---'+emailList);
            String emails = '';
            if(emailList.size() > 0) {
                for(Contact a :emailList) {
                    emails += a.Email;
                    emails += ';';
                }
                emails = emails.removeEnd(';');
                System.debug('emails--->>>'+emails);
            }
            String messageTorecipient = 'This document is sent for digital signature.';
            System.debug('apikey---'+apikey);
            System.debug('apiSig---'+apiSig);
            System.debug('docId---'+docId);
            System.debug('apikey---'+emailList[0].Title);
            System.debug('messageTorecipient---'+messageTorecipient);
            System.debug('emailList[0].Name---'+emailList[0].Name);            
            docverifySend(apikey,apiSig, docId,emailList[0].Title,emails,messageTorecipient,emailList[0].Name,ownerSignOrder);
            resultMap.put('Message','Document sent to selected contacts.');
            return resultMap;       
        }
        catch(Exception exc){
         System.debug(exc);
        }
       return null; 
      }
      public static void docverifySend(String apiKey,String apiSig,String DocumentId,String DocumentName,String Emails,String MessageToSigners,String rName, String ownerSignOrder){
        Attachment att =[SELECT Id,Body FROM Attachment WHERE Id =: DocumentId];
        System.debug('documentId deocverify send---'+DocumentId);
        Blob Document1 = att.Body;
        //String Document2 = Document1.toString();
        String pdf = EncodingUtil.base64Encode(Document1);
        system.debug('Document fronm id---->'+pdf);
        GNT.DocverifyCtrl.DocVerify_x0020_Web_x0020_ServiceSoap stub = new GNT.DocverifyCtrl.DocVerify_x0020_Web_x0020_ServiceSoap();    
        System.debug('apikey ---'+apikey+'====apiSign==='+apiSig);                            
        String output = stub.AddNewDocumentESign(apikey, apiSig, pdf, DocumentName, Emails, MessageToSigners, ownerSignOrder);             
        system.debug('output------------'+output);
        GNT__AttachmentExtension__c attex = [SELECT Id,GNT__Attachment__c FROM GNT__AttachmentExtension__c WHERE GNT__Attachment__c =: att.Id ];
        if(output.length()> 5){
            GNT__DigitalSignature__c ds =new GNT__DigitalSignature__c();
            ds.Name = rName;
            ds.GNT__RecipientTitle__c = DocumentName;
            ds.GNT__RecipientEmail__c = Emails;
            ds.GNT__DocverifyId__c = output;
            ds.GNT__Notes__c = MessageToSigners;
            insert ds;
            GNT__AttachmentExtension__c attExtObj = new GNT__AttachmentExtension__c(Id = attex.Id, GNT__DigitalSignature__c = ds.id); 
            update attExtObj;
        }
      }
  }