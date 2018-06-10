@isTest

    global class MockHttpResponseGenerator implements HttpCalloutMock {
      

        global HTTPResponse respond(HTTPRequest req) {

            System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());

            System.assertEquals('GET', req.getMethod());

            HttpResponse res = new HttpResponse();

            res.setHeader('Content-Type', 'application/json');

            res.setBody('{"foo":"bar"}');

            res.setStatusCode(200);

            return res;

        }

    }