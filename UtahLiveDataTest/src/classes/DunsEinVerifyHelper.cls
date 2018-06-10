global with sharing class DunsEinVerifyHelper extends GNT.DynamicLayoutActionRedirect{
    
    
    global override PageReference whenClicked(){ 
        //Savepoint sp = Database.setSavepoint();
         Id recordId = layoutHolder.getPrimarySObject().Id;
         
         boolean flag=false;
         UserRegistration__c uReg = [Select Id, Name, PrimaryRepPrefix__c, PrimaryRepFirstName__c, PrimaryRepLastName__c, PrimaryRepAddress1__c, 
                                     PrimaryRepAddress2__c, PrimaryRepCity__c, PrimaryRepState__c, PrimaryRepZipCode__c, PrimaryRepCountry__c, 
                                     PrimaryRepPhone__c, PrimaryRepTitle__c, PrimaryRepEmail__c, SecondaryRepPrefix__c, SecondaryRepFirstName__c, 
                                     SecondaryRepLastName__c, SecondaryRepAddress1__c, SecondaryRepAddress2__c, SecondaryRepCity__c, SecondaryRepState__c,                                      
                                     SecondaryRepZipCode__c, SecondaryRepCountry__c, SecondaryRepPhone__c, SecondaryRepTitle__c, SecondaryRepEmail__c, 
                                     Status__c, Organization__c, EINText__c, OrganizationTypeSInglePicklist__c, OrganizationTypeOther__c, OrgnizationPhoneNumber__c,
                                     OrganizationFax__c, Website__c, DCSupplySchedule__c, FedralGSASchedule__c, DUNS__c, DUNSExpirationDate__c, OrganizationFiscalYearStartDate__c,
                                     OrganizationFiscalYearEndDate__c, OrganizationDescription__c,OrganizationStreetAddress__c, OrganizationCityAddress__c,
                                     County__c, OrganizationState__c, OrganizationZipCode__c, OrganizationsCountry__c, UserRole__c, isApplicant__c, IsReviewer__c, Comments__c, 
                                     ExternalVerificationLog__c,RecordType.Name,Sams__c from UserRegistration__c where id = :recordId];
        try{
            /*ExternalInterfaceCtrl obj = new ExternalInterfaceCtrl();
            String token = obj.fetchToken();
            //String response = obj.checkDUNS(uReg.DUNS__c, token);
            if(obj.checkEIN(uReg.EINText__c)){
               flag = true; 
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'EIN does not exists in SAM')); 
            }
            if(response == null){
                flag=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DUNs does not exists in SAM'));
            }*/
            //comment flag=true when it goes live
            //uReg.Status__c='Verified';
            //uReg.ExternalVerificationLog__c=validate(uReg);
            //Added logic to call WebService only when RecordType equals to 'Applicant'
            System.debug('>>>>Rec'+uReg.RecordType.Name);
            if(uReg.RecordType.Name == 'Applicant'){
                String wsResponse = validate(uReg);
                System.Debug('wsResponse--'+ wsResponse);
                if(wsResponse.contains('Exception')){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DUNs does not exists in SAM'));
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-88149')));
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-25251')));
                }  
                    
                uReg.Status__c='Verified';
                uReg.ExternalVerificationLog__c= wsResponse.abbreviate(131072);
                
                
            }
            else
            {
                System.Debug('uReg.Status__c'+uReg.Status__c);  
                uReg.Status__c='Verified';
            }
            update uReg;
            //TaskCreationHandler.createApprovalProcessTasks(uReg.Id, 'Review User Registration', uReg.Name, 'UserRegistrationApprover', System.TODAY() + 7,  true);    
            
                        
        }catch(Exception e){
            //Database.rollback(sp);
            //System.Debug('UserRegistrationHelper whenClicked...'+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage())); 
        }   
        PageReference pageRef= new PageReference('/apex/InternalUserRegistrationView?id='+recordId);
        pageRef.setRedirect(true);
        return pageRef; 
        //return null;      
    }
    
    private String cleanEIN(String ein) {
        if( ein!=null && ein.length() != 9 && !ein.contains('-') ){
            return 'Invalid';
        }else if(ein.length()==10 && ein.contains('-')){ //Already in correct format
            return ein;
        }
        return ein.substring(0,2) + '-' + ein.substring(2,9);
    }
    
    private String cleanDUNS(String dunsNo) {
        if(dunsNo.length() != 9)
            return 'Invalid';
        return dunsNo;
    }
    
    private String validate(UserRegistration__c uReg){
        String result;
        String token;
        String ein='Invalid';
        String duns = 'Invalid';
        String dbresponse = '';
        Map<String,boolean> externalInterfaceMap=new Map<String,boolean>();
        
        try{
            List<ExternalInterfaces__c> mcs = ExternalInterfaces__c.getall().values();
            for(ExternalInterfaces__c i:mcs){
                system.debug('printing all ext interfaces-----------------------------:'+i.Name);
                externalInterfaceMap.put(i.Name,i.isEnabled__c);
            }

            ExternalInterfaceCtrl obj = new ExternalInterfaceCtrl();
            Map<String, List<String>> calloutResponse = new Map<String, List<String>>();
            String samResponseStr='';
            Map<String,String> samResponse=null;
            if(uReg.DUNS__c!=null && uReg.DUNS__c.length()>0){
                duns=cleanDUNS(uReg.DUNS__c);
            }
            if(uReg.EINText__c!=null && uReg.EINText__c.length()>0){
                ein=cleanEIN(uReg.EINText__c);
            }
            system.debug('-------------------After duns ein formating------------------------'+duns+'\n'+ein);
            
             //DUNS Verification
             if(externalInterfaceMap.containsKey('SAM.Gov Entity Validation') && externalInterfaceMap.get('SAM.Gov Entity Validation')){
                if(duns!= 'Invalid'){
                    system.debug('-------------------inside duns sam entity validation------------------------');
                    samResponse=obj.checkWithSAM(duns,null);
                }
                else if(ein!= 'Invalid'){
                    system.debug('-------------------inside ein sam entity validation------------------------');
                    samResponse=obj.checkWithSAM(null,ein);
                }
                //SAM.Gov webservice callout response  ---Added by Sirisha duriseti 
                result='SAMGov Response:';
                
                if(samResponse!=null){
                    for(String s:samResponse.keySet()){
                        result+=s+':'+samResponse.get(s)+'\r\n';
                        samResponseStr+=s+':'+samResponse.get(s)+'\r\n';
                    }
                }
               
                System.debug('samResponse------------------------'+samResponse);
             }

                       
            //check DUNS - Dun and Bradstreet
            if(externalInterfaceMap.containsKey('Dun and Bradstreet Verification') && externalInterfaceMap.get('Dun and Bradstreet Verification')&& uReg.DUNS__c!=null && uReg.DUNS__c.length()==9){
                system.debug('In D&B---------------------------------------------------');
                token = obj.fetchToken();
                system.debug('token----------------------'+token);
                if(duns!= 'Invalid'){
                    calloutResponse=obj.checkDUNS(duns, token,calloutResponse);
                }
                System.debug('duns------------------------'+calloutResponse);
            }
            //Check EPLS
            if(externalInterfaceMap.containsKey('SAM.GOV EPLS Verification') && externalInterfaceMap.get('SAM.GOV EPLS Verification') && uReg.Sams__c!=null){
                calloutResponse=obj.checkEPLS(uReg.Sams__c,calloutResponse);
                System.debug('epls------------------------'+calloutResponse);
            }
            //Check FPDS
            
            if(externalInterfaceMap.containsKey('FPDS') && externalInterfaceMap.get('FPDS') && uReg.DUNS__c!=null && uReg.DUNS__c.length()==9){
                if(duns!= 'Invalid'){
                    calloutResponse=obj.FPDSSearch(duns,calloutResponse);
                }
                System.debug('fpds------------------------'+calloutResponse);
            }
            
             //EIN Verification
            if(externalInterfaceMap.containsKey('GuideStar:Non Profit Verification') && externalInterfaceMap.get('GuideStar:Non Profit Verification') && uReg.EINText__c!=null){
                if(ein!= 'Invalid'){
                    calloutResponse = obj.checkEIN(ein,calloutResponse);
                }
                System.debug('ein------------------------'+calloutResponse );
            }
            
            //Insert Integration Header and Detail records
            ProcessLogging header = new ProcessLogging();
            String headerId = header.InsertIntegrationHeader('User Registration', '');

            for(String s: calloutResponse.KeySet()){
                System.debug('calloutResponse ------------' + s);
                if(s!=null){
                    List<String> reqresp = calloutResponse.get(s);
                    for(String str:reqresp){
                        dbresponse+=str;
                    }
                    header.InsertIntegrationDetail(headerId,reqresp,uReg.Id);
                }
            }
             result+= 'Interfaces Response:' + dbresponse +  '\r\n';
             System.debug('result------------------------'+result);
             
            //Added by Sirisha Duriseti 
            //ProcessLogging header = new ProcessLogging();
            //String headerId = header.InsertIntegrationHeader('User Registration', '');
            if(samResponse!=null){
                IntegrationDetail__c detail = new IntegrationDetail__c();
                detail.IntegrationHeader__c = headerId ;
                //detail.IP_Address__c = ipAddress;
                //detail.Process_Start_Time__c = Date.valueOf(resp.get(6));
                //detail.Process_End_Time__c = Date.valueOf(resp.get(7));
                detail.DataRetrievalTime__c=samResponse.get('dataRetrievalTime');
                detail.Process_Name__c = 'SAM.Gov Entity Validation';
                detail.Process_Response__c = samResponseStr;
                detail.Process_Content_Type__c = 'XML';
                detail.Agency_Name__c = 'SAM.Gov';
                if(samResponse.containsKey('REQUEST FAILED')){
                    detail.Status__c = 'FAILED';
                }else{
                    detail.Status__c = 'SUCCESS';//(samResponse.get('transactionStatus').contains('01')?  'Success':samResponse.get('transactionMessage'));
                }
                detail.Process_Type__c = 'Get';
                detail.External_Registration__c = uReg.id;
                detail.Type_of_Call__c = 'HTTP Callout';
                detail.Synchronous__c = true;
                
                insert detail;
                
                System.debug('inserted detail---------------------------'+detail);
             }
            
            
            
        }catch(Exception ex){
            return 'Exception:'+ex.getMessage();
        }
        return result;
    }
}