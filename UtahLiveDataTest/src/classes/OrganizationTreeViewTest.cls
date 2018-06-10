@isTest
public class OrganizationTreeViewTest {
    static testMethod void someTest() {
         OrganizationTreeView e = new OrganizationTreeView();        
         ApexPages.currentPage().getParameters().put('rt','');   
         e.getKeyValueMap();     
         ApexPages.currentPage().getParameters().put('rt','test');
         e.getKeyValueMap();
    }
     
}