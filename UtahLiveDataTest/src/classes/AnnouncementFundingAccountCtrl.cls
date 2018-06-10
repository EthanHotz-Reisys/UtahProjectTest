/**
*  Controller class for the Adding the Funding sources to the Announcements
*
* CHANGE HISTORY
*================================================================ 
* Dated          Name               Description 
* 01/30/2014    Vinayak Sharma      Created 
* 
*
*================================================================
*/

public with sharing class AnnouncementFundingAccountCtrl {

    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}


  public AnnouncementFundingAccountCtrl(){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        pageTemplateName = 'Announcement Funding Account';
        }  
        

  


    //Shah 5/22/2015 Commenting out the below logic due to revised data model
    /*
    public  Id announcementId {get;set;}  
    public  List<FundingAccountYearWrapper> lstFundingAccountYearWrapper {get;set;}
    public  Announcement__c announcement {get;set;}
         
    public AnnouncementFundingAccountCtrl(){                
        announcementId =  ApexPages.currentPage().getParameters().get('id');
        announcement = [Select Name,Program__c,FiscalYear__c from Announcement__c where Id =: announcementId ]; 
        getFundingAccounts();        
    }    

    private  PageReference getFundingAccounts(){
        List<ProgramFundingAccount__c> lstProgramFundingAccount = [Select Id, FundingAccount__c from ProgramFundingAccount__c 
                        where Program__c =: announcement.Program__c ];       
        if(lstFundingAccountYearWrapper == null){
            lstFundingAccountYearWrapper = new List<FundingAccountYearWrapper>();
            List<Id> lstFundingAccountIds = new List<Id>();   
            for(ProgramFundingAccount__c fundingAccount : lstProgramFundingAccount ){
                lstFundingAccountIds.add(fundingAccount.FundingAccount__c);             
            }            
                        
            List<FundingAccountYear__c> lstFundingAccount = [Select Id, FiscalYear__c, FundingAccount__c, FundingAccount__r.Name, FundingSourceYear__r.Name, FundsAvailable__c,
                                                             FundsAwardedByState__c ,ObligationInProgress__c ,TotalFunds__c  from FundingAccountYear__c where
                                                             FiscalYear__c =: announcement.FiscalYear__c and FundingAccount__c in :lstFundingAccountIds and Id NOT IN
                                                             (Select FundingAccountYear__c from AnnouncementFundingAccount__c WHERE Announcement__c = :announcementId) ];               
            for(FundingAccountYear__c fundingAccountYear : lstFundingAccount){
                lstFundingAccountYearWrapper.add(new FundingAccountYearWrapper(fundingAccountYear));     
            }
       }  
          PageReference addSourceListPage = Page.AnnouncementFundingAccount; 
          addSourceListPage.getParameters().put('id',announcementId); 
          return addSourceListPage;  
    }  
     
    
    public PageReference addToAnnouncement(){
        List<FundingAccountYear__c> selectedAccounts = new List<FundingAccountYear__c>();
        List<AnnouncementFundingAccount__c> announcementFundingAccountlst = new List<AnnouncementFundingAccount__c>();      
        for(FundingAccountYearWrapper fundingAccountYearWrapper: lstFundingAccountYearWrapper) {
            if(fundingAccountYearWrapper.selected == true) {
                selectedAccounts.add(fundingAccountYearWrapper.fundingAccountYear); 
            }   
        }   
        for(FundingAccountYear__c fundingAccountYear: selectedAccounts){
            AnnouncementFundingAccount__c announcementFundingAccount = new AnnouncementFundingAccount__c();
            announcementFundingAccount.Announcement__c = announcementId;
            announcementFundingAccount.FundingAccountYear__c = fundingAccountYear.Id;       
            announcementFundingAccountlst.add(announcementFundingAccount);          
        }
        if(selectedAccounts.size()>0){
            try{
                if(Schema.sObjectType.AnnouncementFundingAccount__c.isCreateable()){
                    insert announcementFundingAccountlst;
                }
            }catch(Exception e){
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());  
                 return null;
            } 
        } 
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Please Select atleast one Funding Source to add.');
            ApexPages.addMessage(myMsg);
            return null;
        }    
            PageReference viewPage = Page.AnnouncementView; 
            viewPage.getParameters().put('id',announcementId); 
            return viewPage;        
    }
             
    public PageReference Cancel(){
        PageReference viewPage = Page.AnnouncementView; 
        viewPage.getParameters().put('id',announcementId); 
        return viewPage;
    }
  
    public class FundingAccountYearWrapper{
        public FundingAccountYear__c fundingAccountYear {get;set;}
        public Boolean selected {get;set;}
        
        public FundingAccountYearWrapper(FundingAccountYear__c annFundAccount){
            fundingAccountYear = annFundAccount; 
            selected = false;   
        }   
    }
    */
}