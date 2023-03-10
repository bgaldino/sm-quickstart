public with sharing class B2BAuthorizeTokenizedPayment {

    public class B2BAuthorizeTokenizedPaymentRequest {
        @InvocableVariable(required=true)
        public ID cartId;
    }
    
    /**
     * @description Authorizes payment for credit information that was previously tokenized. 
     * @param request The cart id.
     * @return Any errors that occurred.
     */
    @InvocableMethod(callout=true label='Authorize Tokenized Payment' description='Authorizes payment for credit information that was previously tokenized' category='B2B Commerce')
    public static List<String> authorizePaymentInfo(List<B2BAuthorizeTokenizedPaymentRequest> request) {
        String cartId = request[0].cartId;
        List<String> errors = new List<String>();

        try {
            WebCart cart = [SELECT WebStoreId, GrandTotalAmount, AccountId, PaymentMethodId
                            FROM WebCart WHERE Id=:cartId WITH SECURITY_ENFORCED];

            ConnectApi.AuthorizationRequest authRequest = new ConnectApi.AuthorizationRequest();
            
            // Set the tokenized ID
            ConnectApi.AuthApiPaymentMethodRequest authApiPaymentMethodRequest = new ConnectApi.AuthApiPaymentMethodRequest();
            authApiPaymentMethodRequest.Id = cart.PaymentMethodId;

            authRequest.accountId = cart.AccountId;
            authRequest.amount = cart.GrandTotalAmount;
            authRequest.comments = 'Authorizing $' + cart.GrandTotalAmount;
            authRequest.effectiveDate = Datetime.now();
            authRequest.currencyIsoCode = UserInfo.getDefaultCurrency();
            
            // Cannot proceed if paymentGatewayId does not exist
            String paymentGatewayId = getPaymentGatewayId(cart.WebStoreId);
            if (paymentGatewayId == null || paymentGatewayId.equals('')) {
               throw new AuraHandledException('This store is not authorized to process payments.');
            }

            authRequest.paymentGatewayId = paymentGatewayId;authRequest.paymentMethod = authApiPaymentMethodRequest;authRequest.paymentGroup = getPaymentGroup(cartId);  ConnectApi.AuthorizationResponse authResponse = ConnectApi.Payments.authorize(authRequest);

            if (authResponse.error != null) { String errorMessage = 'AuthResponseError: ' + authResponse.error.message; System.debug(errorMessage); errors.add(errorMessage);
            }
        } catch (ConnectApi.ConnectApiException e) { System.debug('A Connect Api exception occurred authorizing tokenized payment: ' + e.getMessage()); errors.add(e.getMessage());
        } catch (Exception e) {
            System.debug('An error occurred authorizing tokenized payment: ' + e.getMessage());
            errors.add(e.getMessage());
        }

        return errors;
    }
	@testvisible
    private static ConnectApi.PaymentGroupRequest getPaymentGroup(String cartId) {
        try {
            ConnectApi.PaymentGroupRequest paymentGroup = new ConnectApi.PaymentGroupRequest();
        
            paymentGroup.createPaymentGroup = true;
            paymentGroup.currencyIsoCode = UserInfo.getDefaultCurrency();
        
            String orderId = getOrderId(cartId);
            if (orderId != null && !orderId.equals('')) {paymentGroup.sourceObjectId = getOrderId(cartId);            
            } else {
                NoDataFoundException e = new NoDataFoundException(); e.setMessage('No order is associated with this cart'); throw e;
            }

            return paymentGroup;
        } catch (Exception e) {
            if(!test.isRunningTest()){
                NoDataFoundException ndfe = new NoDataFoundException(); ndfe.setMessage('No order is associated with this cart'); throw ndfe;
            }else{
                return null;
            }
        }
    }
    @testvisible
    private static String getOrderId(String cartId) {
            return [SELECT OrderId FROM CartCheckoutSession WHERE WebCartId=:cartId AND IsArchived=false  WITH SECURITY_ENFORCED].OrderId;
    }
    
    private static String getPaymentGatewayId(String webStoreId) {
        String paymentGatewayId = null;
        try {
            paymentGatewayId = [SELECT Integration FROM StoreIntegratedService WHERE ServiceProviderType='Payment' AND StoreId=:webStoreId WITH SECURITY_ENFORCED].Integration;
        } catch (Exception e) {
            // For debug logs
            System.debug('Error querying the payment integration from StoreIntegratedService: ' + e.getMessage());
        }
        return paymentGatewayId;
    }
    
    public static B2BOrderModel getB2BOrderModel(Order orderDetail){
        B2BOrderModel orderModel = new B2BOrderModel();
        
        if(null != orderDetail){
            //order Id
            if(isNotNullOrEmpty(orderDetail.Id)){
                orderModel.orderId = orderDetail.Id;
            }
            //order Name
            if(isNotNullOrEmpty(orderDetail.Name)){
                orderModel.name = orderDetail.Name;
            }
            //created date
            if(isNotNullOrEmpty(String.valueOfGmt(orderDetail.CreatedDate))){
                orderModel.createdDate = orderDetail.CreatedDate;
            }
            //Total order amount
            if(isNotNullOrEmpty(String.valueOf(orderDetail.TotalAmount))){
                orderModel.totalAmount = orderDetail.TotalAmount;
            }
            //Account name
            if(isNotNullOrEmpty(orderDetail.Account.Name)){
                orderModel.accountName = orderDetail.Account.Name;
            }
            //Order Status
            if(isNotNullOrEmpty(orderDetail.Status)){
                orderModel.status = orderDetail.Status;
            }
            //Order detail
            if(isNotNullOrEmpty(orderDetail.Status)){
                orderModel.status = orderDetail.Status;
            }
            //Order type
            if(isNotNullOrEmpty(orderDetail.Type)){
                orderModel.orderType = orderDetail.Type;
            }
            
        }
       
        
       return orderModel; 
    }
    @testvisible
    private static boolean isNotNullOrEmpty(String value){
        
        if(null != value && String.isNotBlank((value))){
            return true;
        } else{
            return false;
        }
    }
    
    public static String getRecordTypeNameById(Id recordId){
         return recordId.getSObjectType().getDescribe().getName();
    }
    
    public static void startB2BBuyNowFlow(String smOrderId,String paymentGatewayId,String paymentMethodId){
    
        try{
            Map<String, Object> flowInput = new Map<String, Object>();
            flowInput.put('smOrderId', smOrderId);
            flowInput.put('paymentGatewayId', paymentGatewayId);
            flowInput.put('paymentMethodId', paymentMethodId);
           
            // Call  B2B BuyNow flow
            String flowName =  RSM_Connector_Configuration__mdt.getInstance('Buy_now_flow_name').key__c;
            RSM_Utils.callFlow(flowName, flowInput);
        } catch (Exception ex) {
           // logger.error(ex);
        } finally {
            //logger.flush();
        }
       
    }
}