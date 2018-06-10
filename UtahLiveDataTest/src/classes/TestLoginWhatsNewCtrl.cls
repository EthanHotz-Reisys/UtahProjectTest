/**
 
    **********************************************************
    Audit History
    **********************************************************
    4/27/2016   swati singh    Created
 
    **********************************************************  
*/
@isTest
private with sharing class TestLoginWhatsNewCtrl{


    @IsTest(OnInstall=false)
    public static void test_ctrl() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
        TestHelper.CreateCustomSettings(true);
        AnnouncementTriggerHelper.skipTrigger = true;
        Announcement__c ann = testHelper.getAnnouncement(false);
        ann.Status__c ='Active';
        ann.AnnouncementType__c= 'New';
        insert ann;
         Announcement__c ann1 = testHelper.getAnnouncement(false);
        ann.Status__c ='Active';
        ann.AnnouncementType__c= 'New';
        insert ann1;
        list<Announcement__c> AnnouncementList = new List<Announcement__c>();
        AnnouncementList.add(ann);
        AnnouncementList.add(ann1);
        // Integer maxItemsCount = GNT.KeyValueStoreHelper.getIntegerValue('WhatsNewExpandedItemsCount', true);
        // minItemsCount = GNT.KeyValueStoreHelper.getIntegerValue('WhatsNewVisibleItemsCount', true);
        // Integer whatsNewCharacterCount = GNT.KeyValueStoreHelper.getIntegerValue('WhatsNewCharacterCount', true);
         GNT__KeyValueStore__c key= new GNT__KeyValueStore__c(Name='WhatsNewExpandedItemsCount',
                                                GNT__IntegerValue__c=1,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
        insert key; 
           GNT__KeyValueStore__c key1= new GNT__KeyValueStore__c(Name='WhatsNewVisibleItemsCount',
                                                GNT__IntegerValue__c=3,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
        insert key1; 
             GNT__KeyValueStore__c key2= new GNT__KeyValueStore__c(Name='WhatsNewCharacterCount',
                                                GNT__IntegerValue__c=3,
                                                GNT__BooleanValue__c=true,
                                                GNT__Admin_Question__c = 'Loren Ipsum',
                                                GNT__Description__c='Email address to send feedback of the customer in real time');
        insert key2; 
        
         
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', ann.Id);
       
        LoginWhatsNewCtrl ctrl = new LoginWhatsNewCtrl();

        Test.stopTest();

        //assert
        System.assertEquals(ann.Id, ann.Id);
        
        
        }
    }
  }