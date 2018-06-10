global class CampaignEmailServiceHandler implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          String str = email.plainTextBody;
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          System.debug('===> email '+email.plainTextBody);
          if(email.plainTextBody.contains('Ref :')){
              str = str.substring(str.indexOf('Ref :') + 5);
              str = str.substring(0, 7);
              Campaign__c campaignRecord = [Select CampaignCompleted__c from Campaign__c where CampaignNo__c =:str  limit 1];
              campaignRecord.CampaignCompleted__c = true;
              campaignRecord.Status__c = 'Sent';
              update campaignRecord;
              System.debug('===> campaignRecord  '+campaignRecord );
          }
          System.debug('===> envelope '+envelope);
          return result;
      }
}