global with sharing class AWSDownload extends GNT.FlexTableActionHandler {

    global override Map<String, Object> clickHandler() {
        Map<String, Object> resultMap = new Map<String, Object>();
    	AWS_Keys__c awsKeySet =  AWS_Keys__c.getInstance('govgrantsassets');

        List<FileBatch__c> appList = new List<FileBatch__c>([SELECT Id, ExternalFileName__c, FileName__c FROM FileBatch__c WHERE Id IN :selectedRecordIds]);


        String filename = EncodingUtil.urlEncode(appList[0].FileName__c, 'UTF-8');
 
        String BucketName=awsKeySet.Bucket_Name__c;
        String AccessKey= awsKeySet.AWS_AccessKey_Id__c;
        String SecretKey=awsKeySet.AWS_Secret_Key__c;
        String awsUrl = awsKeySet.AWS_URL__c;
        
        Datetime now = DateTime.now();
        Datetime expireson = now.AddSeconds(60); // Lifespan of the link
        Long Lexpires = expireson.getTime()/1000;
        
        String stringtosign = 'GET\n\n\n'+Lexpires+'\n/'+BucketName+'/'+filename;
        System.debug('redirectToS3Key stringstosign: ' + stringtosign);
        
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(SecretKey));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(stringtosign),blob.valueof(SecretKey)); 
        String signed= EncodingUtil.base64Encode(mac);     
        String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
        String url = awsUrl + '/' + BucketName + '/'+filename+'?AWSAccessKeyId='+AccessKey+
                              '&Expires='+Lexpires+'&Signature='+signed;

        resultMap.put('PageReference',url);
       // resultMap.put('PageReference','http://www.oracle.com/technetwork/developer-tools/apex/overview/apex41-new-features-487382.ppt');





        resultMap.put('Message', 'Successfully moved the application to review. '+appList.size()); 
        return resultMap;
    }




}