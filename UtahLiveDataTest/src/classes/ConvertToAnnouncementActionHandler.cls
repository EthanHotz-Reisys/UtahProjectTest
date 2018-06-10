global with sharing class ConvertToAnnouncementActionHandler extends GNT.FlexTableActionHandler {
    global override Map<String,Object> clickHandler() {
        
        String ns = AppUtils.getNamespacePrefix(); 
        String fundingoppid;
        Id recordId = urlParams.get('id');
        FOALead__c objFoaLead;
        Boolean error = false;
       
        Map<String,Object> resultMap = new Map<String,Object>();
        
        objFoaLead = [SELECT Id, FundingOpportunityNumber__c,DaysLeft__c,LastUpdateDate__c,CFDANumber__c,ApplicationsDueDate__c FROM FOALead__c WHERE id =: recordId];
        ApplicationReview__c currentAppReview = [Select Id, Justification__c, Score__c, Agency__c from ApplicationReview__c where FOALead__c = :recordId AND CreatedById = :UserInfo.GetUserId()];
        
        
        if(String.isEmpty(currentAppReview.Justification__c)){
            //errors.add('Justfication is required - Review tab.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-84190'));
            error = true;
        }
          //if(objFoaLead.Score__c == null || Integer.valueOf(objFoaLead.Score__c) <= 2){
        if(currentAppReview.Score__c == null || currentAppReview.Score__c <= 10/5){
            //errors.add('Score must be greater than 2 - Review tab');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-90293'));
            error = true;
        }
        if(objFoaLead.DaysLeft__c == 0){
            //errors.add('Lead cannot be converted to opportunity if Application deadline is less than today');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-59900'));
            error = true;
        }
        //if(currentAppReview.RecipientAgency__c == null){
        //    //errors.add('Applying Agency must be selected - Review tab');
        //    resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-53671'));
        //    error = true;
        //}
          if(objFoaLead.ApplicationsDueDate__c < date.today()){
            //errors.add('Application due date has passed hence cannot convert into opportunity');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-97986'));
            error = true;
        }

        if(error){
            return resultMap;
        }else{
                Id pkg=null;
                String oppPkgId='';
                Boolean pkgFound=false;
                String formNamesStr='';
                Boolean isGrantsOpp=false;
            try{
            //Added by Sirisha D
                boolean isComplete=false;
                if(objFoaLead.FundingOpportunityNumber__c!=null){
                    Set<String> formNames=new Set<String>();
                    List<FormElement> formElements=OpportunitiesExpandedRequestCallout.opportunitiesExpandedCallout(objFoaLead.FundingOpportunityNumber__c); //WS callout that brings all the required/optional forms from Grants.gov
                    if(formElements==null){
                        System.debug('OPPORTUNITY or PACKAGE DOESNOT EXIST IN GRANTS.GOV');
                    }
                    else{
                        isGrantsOpp=true;
                        for(FormElement f:formElements){
                            oppPkgId=f.oppPackageID;
                            System.debug('form Name-----'+f.Name);
                            formNames.add(f.Name);
                            formNamesStr+=f.Name+';';
                        }
                    
                        
                        Set<String> existingForms=new Set<String>();
                        Map<String,GNT__PageTemplate__c> existingFormMap=new Map<String,GNT__PageTemplate__c>();
                        integer expectedFormsCount=formNames.size();
                        
                        Id customConfig;
                        
                        for(GNT__PageTemplate__c  existingForm:[select id,Name,GNT__CustomAppConfig__c from GNT__PageTemplate__c where name in:formNames and GNT__CustomAppConfig__r.Name='StateasGrantee' and GNT__Status__c='Active']){
                            existingFormMap.put(existingForm.Name,existingForm);
                            customConfig=existingForm.GNT__CustomAppConfig__c;
                        }
                        existingForms=existingFormMap.keySet();
                        integer formsCount=existingForms.size();
                        System.debug('Existing forms------------------------'+existingForms);
                        integer actualPkgFormsCount=0;
                        Map<Id,Integer> matchingPkgFormMap=new Map<Id,Integer>();
                        Map<Id,Integer> pkgFormMap=new Map<Id,Integer>();
                        Set<String> formsList;
                        
                        if(formsCount> 0 ){ //forms exist in system
                            //get the package where the existing forms are present
                            for (List<AggregateResult> pkgFormCfg:[Select count(g.id), g.GNT__PackageConfig__c From GNT__PackageFormConfig__c g where g.GNT__FormConfig__r.Name in:existingForms group by g.GNT__PackageConfig__c order by count(g.id) DESC]){
                                for(AggregateResult res:pkgFormCfg){                                 
                                        system.debug('****************************************'+res);
                                        matchingPkgFormMap.put((Id)res.get('GNT__PackageConfig__c'),Integer.valueOf(res.get('expr0')));
                                }
                            }
                            
                        }
                        
                        System.debug('matchingPkgFormMap---------------------------'+matchingPkgFormMap);
                        
                        for (List<AggregateResult> pkgFormCfg:[Select count(g.id),g.GNT__PackageConfig__c From GNT__PackageFormConfig__c g where g.GNT__PackageConfig__c in:matchingPkgFormMap.keySet() group by g.GNT__PackageConfig__c order by count(g.id) DESC]){
                                for(AggregateResult res:pkgFormCfg){                                 
                                        system.debug('****************************************'+res);
                                        pkgFormMap.put((Id)res.get('GNT__PackageConfig__c'),Integer.valueOf(res.get('expr0')));
                                }
                        }
                        
                        System.debug('pkgFormMap---------------------------'+pkgFormMap);
                            
                        for(Id pId:matchingPkgFormMap.keySet()){
                            if(pkgFormMap.get(pId)==matchingPkgFormMap.get(pId) && pkgFormMap.get(pId)== expectedFormsCount ){
                                pkgFound=true;
                                pkg=pId;
                                break;
                            }
                        }
                        
                        if(!pkgFound && formsCount>0){
                        
                            GNT__Package__c newPkg=new GNT__Package__c();
                            newPkg.Name=oppPkgId;
                            newPkg.GNT__Status__c='Active';
                            newPkg.GNT__Source__c='Federal';
                            newPkg.GNT__CustomAppConfig__c=customConfig;
                            newPkg.GNT__SubmissionType__c='Application';
                            insert newPkg;
                            pkg=newPkg.id;
                            
                            System.debug('New inserted pkg---------------------------'+newPkg);
                            
                            GNT__PackageFormConfig__c newPkgCfg;
                            List<GNT__PackageFormConfig__c> pkgFormConfigList=new List<GNT__PackageFormConfig__c>();
                            
                            for(String form:existingForms){
                                
                                    newPkgCfg= new GNT__PackageFormConfig__c();
                                    newPkgCfg.GNT__FormConfig__c=existingFormMap.get(form).id;
                                    newPkgCfg.GNT__PackageConfig__c= pkg;
                                    pkgFormConfigList.add(newPkgCfg);
                                    
                                
                            }
                            
                            System.debug('New Business package config records- before insert------------'+pkgFormConfigList);
                            if(pkgFormConfigList.size()>0){
                                insert pkgFormConfigList;
                                System.debug('New Business package config records--After insert-----------'+pkgFormConfigList);
                            }
                        }
                    
                 }   
                    
                } 
            }catch(Exception e){
                System.debug('Exception'+e.getMessage());
            }
            //Convert the lead to Announcement
            fundingoppid = createAnnouncement(objFoaLead,pkgFound,formNamesStr,isGrantsOpp);
            System.debug('fundingoppid -------------------'+fundingoppid );
            objFoaLead.Status__c = 'Converted to Opportunity';
            update objFoaLead;
            
            if(isGrantsOpp && pkg!=null){
                BusinessPackage__c bpkg=new BusinessPackage__c();
                bpkg.FundingOpportunity__c=fundingoppid ;
                bpkg.PackageConfig__c=pkg;
                insert bpkg;
                System.debug('Inserted business pkg----------------'+bpkg);
            }
            
            List<ApplicationReview__c> evas = [Select EvaluationStatus__c, FundingOpportunity__c from ApplicationReview__c where FOALead__c = :recordId AND Agency__c = :currentAppReview.Agency__c];
            for(ApplicationReview__c ar : evas){
                ar.EvaluationStatus__c = 'Converted to Opportunity';
                ar.Announcement__c = fundingoppid;
            }
            update evas;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Converted to opportunity'));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-74777')));
            
            PageReference returnPage = new PageReference('/apex/AnnouncementView?id='+fundingoppid); 
            resultMap.put('PageReference',returnPage);
            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-74777'));
            //returnPage.setRedirect(true);
            //return returnPage;   
        }
        return resultMap;
    }

    @TestVisible private String createAnnouncement(FOALead__c objFOALead,Boolean pkgFound,String formNamesStr,Boolean isGrantsOpp){
        List<Id> IdList = new List<Id>();
        IdList.add(objFOALead.id);
        Announcement__c annObj;
        system.debug('**IdList'+IdList);
        List<Sobject> announcements = GNT.AppUtils.copyRecords(AppUtils.getNamespacePrefix()+'FOALead__c', AppUtils.getNamespacePrefix()+'Announcement__c', IdList, false);
        system.debug('***Listannouncements'+announcements);
        if(!announcements.isempty()) {
            annObj = (Announcement__c)announcements.get(0); 
            String cfdaNumber = objFOALead.CFDANumber__c;
            if(!String.isEmpty(cfdaNumber)){
                List<Program__c> pgms = [SELECT Id FROM Program__c WHERE FederalProgramCFDA__c = :cfdaNumber LIMIT 1];
                if(!pgms.isempty()){
                    annObj.Program__c = pgms.get(0).Id;
                }
            }
            System.debug('***beforeannobj1'+annobj);
            //System.assert(1==2);
            system.debug('***beforeannobj1');
            annobj.ApplicationCreatedOutside__c = 'No';   
            annObj.LeadLastModifiedDate__c = objFOALead.LastUpdateDate__c;
            if(!pkgFound &&  isGrantsOpp){
                annObj.IsPackageComplete__c=false;
                annObj.MissingFormDescription__c=formNamesStr;
            }
            insert annobj;
        }
          return annobj.id; 
     } 


}