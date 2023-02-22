public class B2B_RestApiCalls {

    private static final DCM_Logger logger = DCM_Logger.getImmediateInstance('API Call');

    
    public static String httpCallOut(Map<String,String> request){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader(B2B_SetupConstants.AUTHORIZATIONTITLE, request.get(B2B_SetupConstants.AUTHORIZATION));
        req.setEndpoint(request.get(B2B_SetupConstants.ENDPOINT));
        req.setMethod(request.get(B2B_SetupConstants.METHOD));
        req.setHeader(B2B_SetupConstants.CONTENTTYPE,request.get(B2B_SetupConstants.CONTENT));
        req.setBody(request.get(B2B_SetupConstants.BODY));
        req.setTimeout(120000);
        HttpResponse res = h.send(req);
        String response = res.getBody();
        System.debug('response--restapi-'+response);
        logger.debug('response--restapi-'+response);
        return response;
    }
  
}