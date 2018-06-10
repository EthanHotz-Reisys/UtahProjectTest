@isTest
public with sharing class TestAddCaseCommentCtrl {
    static CaseComment caseComeObj;
@isTest
    public static void testAddCaseCommentControll(){
        Case cs=new Case(); ///Case ll act as a reserve KeyWord in eclipse so gives error here.
        insert cs;
        
        caseComeObj=new CaseComment();
        caseComeObj.parentId=cs.Id;
        insert caseComeObj;
        Test.setCurrentPageReference(new pageReference('Page.AddCaseComment'));
        system.currentPageReference().getParameters().put('id',caseComeObj.id);
        ApexPages.currentPage().getParameters().put('recordId','true');
        ApexPages.CurrentPage().getParameters().put('myrecid',cs.Id);
        ApexPages.CurrentPage().getParameters().put('retURL','https://ggpdev2-dev-ed.my.salesforce.com/apex/hello?id=1&name=abc');
        ApexPages.StandardController sc1=new ApexPages.StandardController(caseComeObj);
        AddCaseCommentCtrl addCaseCommentObj=new AddCaseCommentCtrl(sc1);
        addCaseCommentObj.parentId=cs.Id;
        //addCaseCommentObj.addCase();
        addCaseCommentObj.getKeyValueMap();
        addCaseCommentObj.addComment();
        
    }
}