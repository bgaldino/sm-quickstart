/**
 * @description       : 
 * @author            : Prabhat Kumar
 * @group             : 
 * @last modified on  : 05-20-2022
 * @last modified by  : Prabhat Kumar
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-20-2022   Prabhat Kumar  Initial Version
**/

public without sharing class RSM_RestApiCalls {

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.REST_CALLOUT);
    public static String httpCallOut(Map<String,String> request){
        String response;
    try{
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader(B2B_SetupConstants.AUTHORIZATIONTITLE, request.get(B2B_SetupConstants.AUTHORIZATION));
        req.setEndpoint(request.get(B2B_SetupConstants.ENDPOINT));
        req.setMethod(request.get(B2B_SetupConstants.METHOD));
        req.setHeader(B2B_SetupConstants.CONTENTTYPE,request.get(B2B_SetupConstants.CONTENT));
        req.setBody(request.get(B2B_SetupConstants.BODY));
        HttpResponse res = h.send(req);
        response = res.getBody();
        if (res.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
            res.getStatusCode() + ' ' + res.getStatus());
        } else {
            System.debug(res);                
                    
        }  
        System.debug('response--restapi-'+response);

        } catch(Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
        }
        return response;
    }
}