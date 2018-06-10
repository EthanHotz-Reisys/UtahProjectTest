@isTest
public with sharing class TestApplicationDiscussionHandler {
   /* 
    @isTest
    private static void testSendEmail(){
         User u = TestHelper.getAdminUser(true);
         
         system.runAs(u){
             TestHelper.createCustomSettings(true);
             Test.startTest();             
             Messaging.InboundEmail email = new Messaging.InboundEmail();
             Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
             email.subject = 'test';
             email.plainTextBody='test email';
             env.fromAddress = 'user@acme.com';
             //ApexPages.StandardController controller;
             
             EmailConversationHandler  sendEmail=new EmailConversationHandler ();
             sendEmail.handleInboundEmail(email, env ); 
             Test.stopTest();
         }
         //system.assert();
    }*/
    
     
}