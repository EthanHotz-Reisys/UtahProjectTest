public with sharing class SubmitApplication {

	public String SubmitApplicationToGrants(String appId) {

		String intUrl = 'http://submitapplicationtogrants.herokuapp.com/submit?appreference=';
		try{
			HttpRequest req = new HttpRequest();
			req.setMethod('GET');
			String url = (intUrl + appId);
			System.debug('url>>>>>>>>>>>>' + url);
			req.setEndpoint(url);
			req.setTimeout(60000);
				
			HTTPResponse httpRes = new Http().send(req);
			Integer statusCode = httpRes.getStatusCode();
			String res = httpRes.getBody();
				
			System.debug('Status>>>>>>>>>>>>' + statusCode);
			System.debug('getBody>>>>>>>>>>>>' + res);
				
			if(statusCode != 200){
				//throw new IntegrationException('Status is ' + statusCode + '. Response:' + res);
			}
		}
		catch(Exception e){
        	String msg = 'Error in comminicating to Grants.gov. Please contact System administrator: ' + e;
        	System.debug(msg);
		}
		return null;
	}

}