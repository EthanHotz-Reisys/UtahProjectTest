@isTest
private class TestSubTotalJSONBuilderCtrl {
    
    @isTest static void testConstructor() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.currentPage().getParameters().put('id', account.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.selectedFieldsName = 'test';
            st.selectedoperator = 'test';
        }
        */
    }
    
    @isTest static void testaddNewRow() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.subTotalColumn = '10';
            st.labelColumn = '5';
            st.currentRow = '3';
            st.prefix = 'test';
            st.suffix = 'test';
            st.addNewRow();
            
        }
        */
    }

    @isTest static void testaddSubTotalRow() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.mainRowNumber = 10;
            st.expressionTextArea = '5';
            st.labelColumn = '3';
            st.labelValue = '3';
            st.prefix = 'test';
            st.suffix = 'test';
            st.addSubTotalRow();
        }
        */
    }

    @isTest static void testaddNewRow2() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.subTotalColumn = '10';
            st.labelColumn = '5';
            st.currentRow = 'test';
            st.prefix = 'test';
            st.suffix = 'test';
            st.addNewRow();
        }
        */
    }

    @isTest static void testSave() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.mainRowNumber = 10;
            st.expressionTextArea = '5';
            st.labelColumn = '3';
            st.labelValue = '3';
            st.prefix = 'test';
            st.suffix = 'test';
            st.save();
        }
        */
    }

    @isTest static void testaddAnotherString() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.expressionTextArea = 'test';
            st.addAnotherString();
        }
        */
    }
    @isTest static void testrefresh() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.expressionTextArea = 'test';
            st.refresh();
        }
        */
    }

    @isTest static void testgenerateExpression() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.storeTextValue = 'test';
            st.storeResult = 'test';
            st.generateExpression();
        }
        */
    }

    @isTest static void testchangeBracket() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.expressionTextArea = 'test';
            st.var = '(';
            st.changeBracket();
        }
        */
    }

    @isTest static void testchangeBracket2() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.expressionTextArea = 'test';
            st.var = ')';
            st.changeBracket();
        }
        */
    }


    //@isTest(SeeAllData = false) static void testgetFieldNames() {
    //  UserTriggerHelper.skipTrigger = true;
    //  User u = TestHelper.getAdminUser(true);
    //  System.runAs(u){
    //      AccountTriggerHelper.skipTrigger = true;
    //      Account account = TestHelper.getAccount(true);
    //      GNT__DataTableConfig__c dataTableConfig = [SELECT GNT__FieldNames__c FROM GNT__DataTableConfig__c limit 1];
    //      ApexPages.currentPage().getParameters().put('id', dataTableConfig.Id);
    //      ApexPages.StandardController sc = new ApexPages.StandardController(account);
    //      SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
    //      st.getFieldNames();
    //  }
    //}

    @isTest static void testgetOperator() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        System.runAs(u){
            AccountTriggerHelper.skipTrigger = true;
            Account account = TestHelper.getAccount(true);
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            SubTotalJSONBuilderCtrl st = new SubTotalJSONBuilderCtrl(sc);
            st.getOperator();
        }
        */
    }
    
}