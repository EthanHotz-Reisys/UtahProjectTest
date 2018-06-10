public class POC_FB {
	public void uploadToAmazonS3 (Attachment attach) {
        String filename = attach.Name;
        String attachmentBody = EncodingUtil.base64Encode(attach.Body);
        String formattedDateString = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String bucketname = 'govgrantsassets';//you can write the bucket name where files should be uploaded
         
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setEndpoint('https://s3.amazonaws.com/' + bucketname + '/' + filename);
        req.setHeader('Host', 's3.amazonaws.com');
        req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
        req.setHeader('Content-Type', attach.ContentType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('ACL', 'public-read');
        req.setHeader('Content-Encoding', 'base64');
        req.setHeader('Date', formattedDateString);
        req.setBodyAsBlob(attach.Body);
        String key = 'AKIAIJSHF4H7HQZB5QCQ';
        String secret = '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';
        String stringToSign = 'PUT\n\n' + attach.ContentType + '\n' + formattedDateString + '\n' + '/' + bucketname + '/' + filename;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueOf(stringToSign), blob.valueof(secret));
        String signed = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signed;
        req.setHeader('Authorization', authHeader);
        Http http = new Http();
 		try {
            //Execute web service call
            HTTPResponse res = http.send(req);
            System.debug('RESPONSE STRING: ' + res.toString());
            System.debug('RESPONSE STATUS: '+res.getStatus());
            System.debug('STATUS_CODE: '+res.getStatusCode());
 
        } catch(System.CalloutException e) {
            system.debug('AWS Service Callout Exception: ' + e.getMessage());
        }
	}
}