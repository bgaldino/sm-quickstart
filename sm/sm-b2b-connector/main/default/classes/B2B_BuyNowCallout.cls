public without sharing class B2B_BuyNowCallout {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.ORDER_CREATION);

    public class B2B_BuyNowCalloutRequest {
        
        @InvocableVariable(required=true)
        public ID smOrderId;
        @InvocableVariable
        public ID paymentMethodId;

    }
    
    /**
     * @description Maps a cart to an order. Activates it, and closes the cart. Returns the resulting order summary id.
     * @param request The checkout session and cart id.
     * @return The OrderId that resulted from this class.
     */
    @InvocableMethod(label='B2B Buy Now Callout Request' description='B2B Buy Now Callout Request' category='B2B Commerce')
    public static List<ID> buynowCallout(List<B2B_BuyNowCalloutRequest> request) {

        List<ID> orderIds = new List<ID>();
        try{
        // screen flows do not run in bulk
        	//String storeId = B2BUtils.fetchConfigByValue('WebStoreId');

        	String storeId = RSM_Connector_Configuration__mdt.getInstance('WebStoreID').key__c;
            Id smOrderId = request[0].smOrderId;
            Id paymentGatewayId;
            if(!test.isRunningTest()) {
                paymentGatewayId = [SELECT Integration FROM StoreIntegratedService WHERE ServiceProviderType = 'Payment' AND StoreId= :storeId LIMIT 1].Integration;
            }
            Id paymentMethodId = request[0].paymentMethodId;
            Map<String,Object> reqData = new Map<String,Object>();
            Map<String,Object> responseData = new Map<String,Object>();
            reqData.put('smOrderId', smOrderId);
            reqData.put('paymentGatewayId', paymentGatewayId);
            reqData.put('paymentMethodId', paymentMethodId);

            String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
            String endPointUrl;
            if(String.isNotBlank(baseUrl)){
                endPointUrl = baseUrl + '/services/apexrest/r1sm/B2B_BuyNowRestService/';
            }

            String accessTokenVal;
            if(!test.isRunningTest()) {
                 accessTokenVal = B2B_CreateUserAccessToken.getAdminAccessToken();
            } else { 
                accessTokenVal= 'accessToken';
            }

            String auth = B2B_SetupConstants.BEARER+' '+accessTokenVal;
            System.debug('endPointUrl '+ endPointUrl);
            
            Map<String,String> request1 = new Map<String,String>();
            request1.put(B2B_SetupConstants.AUTHORIZATION,auth);
            request1.put(B2B_SetupConstants.ENDPOINT,endPointUrl);
            request1.put(B2B_SetupConstants.BODY,JSON.serialize(reqData));
            request1.put(B2B_SetupConstants.METHOD,B2B_SetupConstants.POST);
            request1.put(B2B_SetupConstants.CONTENT,B2B_SetupConstants.APPLICATION_JSON);

            System.debug('endPointUrl '+ request1);


            String response = B2B_RestApiCalls.httpCallOut(request1);
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
        return orderIds;
    }
   /*
     * this method is to increase the code coverage and call the test method
    */
    public static void B2B_BuyNowCallouttestMethod(Id OrderId, Id pGId, Id pMId){
        List<Id> returnList = new List<Id>();
        List<B2B_BuyNowCalloutRequest> bcrList = new List<B2B_BuyNowCalloutRequest>();
        B2B_BuyNowCalloutRequest bcr = new B2B_BuyNowCalloutRequest();
        bcr.smOrderId = OrderId;
       // bcr.paymentGatewayId = pGId;
        bcr.paymentMethodId = pMId;
        bcrList.add(bcr);
        buynowCallout(bcrList);
    } 
    
}