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
global with sharing class RSM_CreateIncoiceForCancellation {

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.ASSET_CANCELLATION);
    
    global class rsm_billingSechData {
        
        @InvocableVariable(required=true)
        public ID originalBillingId;
        @InvocableVariable(required=true)
        public ID cancelBillingId;
        @InvocableVariable(required=true)
        public Date nextBillingDates;

    }

    /**
     * This method is called when a cacnellation order is placed. Creates invoice with amount $0.
     * 
    **/
    @InvocableMethod(label='B2B Generate Invoice Cancel' description='B2B Generate Invoice Cancel' category='B2B Commerce')
    global static List<string> generateInvoice(List<rsm_billingSechData> requestData) {

        List<string> orderIds = new List<string>();
        Id originalBillingId = requestData[0].originalBillingId;
        Id cancelBillingId = requestData[0].cancelBillingId;
        string nextBillingDates = string.valueOf(requestData[0].nextBillingDates);
        Map<String,object> resultData = new Map<String,object>();

        try{
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if(Test.isRunningTest()){
            request.setHeader('Authorization', 'Bearer ');
        }else{
            request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken());
        }
        String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
        String cancelAssets = '/services/data/v55.0/commerce/invoicing/invoices/collection/actions/generate';
        request.setMethod('POST'); 
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        request.setEndpoint(baseUrl+cancelAssets);
        String requestBody = '{' +
            '"billingScheduleIds": [' + 
             '"' + originalBillingId + '","' + cancelBillingId + '"' + 
            '],' + 
            '"targetDate": "' + nextBillingDates.left(10) + '",'+ 
            '"invoiceDate":"' + nextBillingDates.left(10) + '",' + 
            '"action": "Posted"' + 
            '}';  

            request.setBody(requestBody);
            system.debug(requestBody + 'requestBody----');
            HttpResponse response = http.send(request);
            // Parse the JSON response
            resultData.put('response',response.getBody());
            System.debug('response: ' + response.getBody());
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
      
            }
            } catch(Exception e) {
                logger.error(e);
            } finally {
                logger.flush();
            }

            return orderIds;

    }
    


}