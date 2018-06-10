/**
* @author: Sarat Mahavratayajula. 2016-08-03
*/
@isTest
global class MockUSPSAddressInformationCtrlResponse implements HttpCalloutMock {
	
	global HttpResponse respond(HttpRequest request) {
		String bdy = '<CityStateLookupResponse USERID=\'Some ID 1\'><ZipCode ID="0"><Zip5>\'12345\'</Zip5></ZipCode>'+
		'<Address1>\'SomeAddress1\'</Address1><Address2>\'SomeAddress2\'</Address2>'+
		'<City>\'Some City\'</City><State>\'Some State\'</State><Zip4>\'Some Zip 4\'</Zip4><Error>\'Some Error\'</Error>'+
		'<Number>\'Some Number\'</Number><Description>\'Some Description\'</Description></CityStateLookupResponse>';
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(bdy);
		res.setStatusCode(200);
		return res;
	}
	
}