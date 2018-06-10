public with sharing class ProcessLogging {
    
    public ProcessLogging() {

    }

    public String InsertIntegrationHeader(String FileName, String Status){

        try{
            IntegrationHeader__c header = new IntegrationHeader__c();
            header.Filename__c = FileName;
            header.Status__c = Status;

            insert header;
//          InsertIntegrationDetail(header.Id);
            return header.Id;

        }
        catch(Exception e){
            System.debug('InsertIntegrationHeader---' + e.getMessage());
            return '';
        }

    }

    public void InsertIntegrationDetail(Id headerId, List<String> resp,Id regId){

        Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();
        String ipAddress;
        system.debug('mapHeaders--------------'+mapHeaders);
        if(mapHeaders != null){
            ipAddress = mapHeaders.get('True-Client-IP');
            if(ipAddress == null){
                ipAddress = mapHeaders.get('X-Salesforce-SIP');
            }
        }

        try{
            IntegrationDetail__c detail = new IntegrationDetail__c();
            detail.IntegrationHeader__c = headerId;
            detail.IP_Address__c = ipAddress;
            detail.Process_Start_Time__c = Date.valueOf(resp.get(6));
            detail.Process_End_Time__c = Date.valueOf(resp.get(7));
            detail.Process_Name__c = resp.get(3);
            System.debug('resp.get(2);----------------------------'+resp.get(2));
            detail.Process_Response__c = resp.get(2);
            detail.Process_API_URL__c = resp.get(0);
            detail.Agency_Name__c = resp.get(1);
            detail.Status__c = resp.get(4);
            detail.Process_Type__c = 'Get';
            detail.External_Registration__c = regId;
            detail.Type_of_Call__c = 'Outbound';
            detail.Synchronous__c = true;

            detail.City__c = 'City';
            detail.DetailRecord__c = 'Detail Record';
            detail.Log__c = 'Log';
            detail.NAICS_Code__c = 'NAICS Codec';
            detail.Postal_Code__c = '20148';
            detail.Process_Content_Type__c = 'Process Content Type';
            detail.PSC_Code__c = 'PSC Code';
            detail.RecordNumber__c = 100;
            detail.Socio_Status__c = 'Socio Status';
            detail.Synchronous__c = true;
            detail.Tracking_Number__c = 'Tracking Number';
            
            system.debug('detail object--------------------'+detail);
            insert detail;


        }
        catch(Exception e){
            System.debug('InsertIntegrationDetail---' + e.getMessage());
        }

        
    }
}