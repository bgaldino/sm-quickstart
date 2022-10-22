/**
 * @description       : 
 * @author            : Abhishek Walia
 * @group             : Docmation LLC
 * @last modified on  : 07-05-2022
 * @last modified by  : Surya
**/
public without sharing class B2BStripeIntegrationController {
    
    private static final String MODULE_NAME = 'Payment Module';
    private static final DCM_Logger logger = DCM_Logger.getInstance(MODULE_NAME);
    
    public static B2B_Payment_Gateway_Setting__mdt getStripeConfiguration(){
	
        B2B_Payment_Gateway_Setting__mdt paymentConfigration;
        try{
            String AccountId = [SELECT AccountId,Account.currencyIsoCode FROM User WHERE Id=:userInfo.getUserId() WITH SECURITY_ENFORCED].AccountId;
            User u = [SELECT AccountId,Account.currencyIsoCode FROM USER where Id=:userInfo.getUserId() WITH SECURITY_ENFORCED limit 1 ];
            if(U != null){
                List<B2B_Payment_Gateway_Setting__mdt> paymentConfigrationList = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Api_Key__c, Country__c, EndPoint_URL__c, Entity_Name__c, Public_Key__c, Stripe_Account_Name__c, User_Locale__c, WebStore__c, Currency__c FROM B2B_Payment_Gateway_Setting__mdt WHERE Currency__c=:u.Account.currencyIsoCode LIMIT 1];
                if(!paymentConfigrationList.isEmpty()){
                    paymentConfigration = paymentConfigrationList.get(0);
                }
            }
            logger.debug(JSON.serialize(paymentConfigration));
            return paymentConfigration;
        }catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
        return paymentConfigration;
    }

    public static Map<String,Object> chargeCustomer(Map<String,Object> dataMap){
        Boolean isSuccess = false;
        String message = '';
        String cartId = (String)dataMap.get(B2BConstants.CART_ID) ;
        WebCart cart = B2BCartSelector.getCurrentActiveCart(cartId);
        String currencyCode = cart.currencyISOCode;
        Decimal amount  = cart.GrandTotalAmount ;  
        Integer intAmount = Integer.valueOf(amount*100);
        B2B_Payment_Gateway_Setting__mdt stripeConfig = getStripeConfiguration() ;
		if(stripeConfig == Null){
            stripeConfig = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Api_Key__c, Country__c, EndPoint_URL__c, Entity_Name__c, Public_Key__c, 
                            Stripe_Account_Name__c, User_Locale__c, WebStore__c, Currency__c FROM B2B_Payment_Gateway_Setting__mdt where MasterLabel = 'MF USD' 
                            WITH SECURITY_ENFORCED];
        }
        try{
            if( B2BUtils.fetchConfigByValue('StripePaymentType') == 'charge'){
                Map<String, String> params = new Map<String, String>();
                String customerUrl = stripeConfig.EndPoint_URL__c+'payment_intents/'+(String)dataMap.get('cPayId')+'/capture';
                String apiKey =  stripeConfig.Api_Key__c;
                Blob headerValue = Blob.valueOf(apiKey + ':');
                String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
                HttpResponse response = stripeRestAPICall(customerUrl,authorizationHeader,B2BStripeAdapter.urlEncodedParams(params),'POST');
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                logger.debug(JSON.serialize(responseMap));
                if(responseMap.containsKey('charges')){
                    Map<String,Object> chargeMap = (Map<String,Object>)responseMap.get('charges');
                    if(chargeMap.containsKey('data')){
                        Map<String,Object> chargeDataMap = (Map<String,Object>)( (List<Object>)chargeMap.get('data')).get(0);
                        dataMap.put('chargeData', (Object)chargeDataMap.get('billing_details'));
                        dataMap.put('chargeId', (String)chargeDataMap.get('id'));
                        dataMap.put(B2BConstants.IS_SUCCESS,true);
                    }
                }else{
                    if(responseMap.containsKey('error')){
                        Map<String,Object> errMap = (Map<String,Object>)responseMap.get('error');
                        if(errMap.containsKey('payment_intent')){
                            Map<String,Object> piResponseMap = (Map<String,Object>)errMap.get('payment_intent');
                            if(piResponseMap.containsKey('charges')){
                                Map<String,Object> chargeMap = (Map<String,Object>)piResponseMap.get('charges');
                                if(chargeMap.containsKey('data')){
                                    Map<String,Object> chargeDataMap = (Map<String,Object>)( (List<Object>)chargeMap.get('data')).get(0);
                                    dataMap.put('chargeId', (String)chargeDataMap.get('id'));
                                    dataMap.put(B2BConstants.IS_SUCCESS,true);
                                }
                            }
                        }else{
                            dataMap.put(B2BConstants.IS_SUCCESS,false);
                        }
                    }else{
                        
                    }
                }
            }else{
                dataMap.put('chargeId', (String)dataMap.get('cPayId'));
                dataMap.put(B2BConstants.IS_SUCCESS,true);
            }
        }catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
        
        return dataMap;

    }




    public static Map<String,Object> getPaymentOptions(Map<String,Object> dataMap){
        Boolean isSuccess = false;
        String message = '';
        try{
            if(dataMap.containsKey(B2BConstants.CART_ID) && String.isNotBlank((String)dataMap.get(B2BConstants.CART_ID)) )  {
                String cartId = (String)dataMap.get(B2BConstants.CART_ID) ;
                WebCart cart = B2BCartSelector.getCurrentActiveCart(cartId);
                dataMap.put(B2BConstants.CART,cart);
                List<String> internalAccountIdList = B2BUtils.getInternalAccounts();
                List<String> taxExemptRTList = B2BUtils.getTaxExemptRecordTypes();
                Boolean hidePurchaseOrder = false;
                Boolean hideCreditCard = false;
                Decimal maxCartTotal = B2BUtils.maxOnlinePurchaseAmount(cart.CurrencyISOCode);
                String userType = '';
                if(internalAccountIdList.contains(cart.AccountId)){
                    userType = 'Internal';
                    List<String> internalSuperAccountIdList = B2BUtils.getSuperInternalAccounts();
                    hideCreditCard = internalSuperAccountIdList.contains(cart.AccountId) ? false : true;
                    hidePurchaseOrder = false;
                }else{
                    userType = 'End Customer';
                }
                if(!hideCreditCard){
                    B2B_Payment_Gateway_Setting__mdt stripeConfig = getStripeConfiguration() ;
                    if(stripeConfig!=null){
                        hideCreditCard = false;
                        dataMap.put('stripConfig',stripeConfig);
                        //dataMap.put('iframeUrl',B2BUtils.fetchConfigByValue('StoreUrl')+'/apex/B2BStripePay?pKey='+stripeConfig.public_Key__c);
                        dataMap.put('iframeUrl',B2BUtils.fetchConfigByValue('StoreUrl')+'/apex/B2BStripePay');
                        String stripeCustomerId = getStripeCustomerId(stripeConfig);
                        dataMap.put('stripeCustomerId',stripeCustomerId);
                    }
                }
                Boolean canPay = hideCreditCard && hidePurchaseOrder ? false : true;
                dataMap.put('userType',userType);
                dataMap.put('canPay',canPay);
                dataMap.put('hideCreditCard',hideCreditCard);
                dataMap.put('hidePurchaseOrder',hidePurchaseOrder);
                isSuccess = true;
            }
            dataMap.put(B2BConstants.IS_SUCCESS,isSuccess);
            dataMap.put(B2BConstants.MESSAGE,message);
            logger.debug(JSON.serialize(dataMap));
            return dataMap;
        }catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
        dataMap.put(B2BConstants.IS_SUCCESS,isSuccess);
        dataMap.put(B2BConstants.MESSAGE,message);
        logger.debug(JSON.serialize(dataMap));
        logger.flush();
        return dataMap;
    }

    public static string getStripeCustomerId(B2B_Payment_Gateway_Setting__mdt stripeConfig){
        String stripeCustomerId;
        List<SObject> payload = new List<SObject>();
        User user ;
        try{
            List<User> userList = [SELECT AccountId, Account.Name,Account.B2B_Stripe_Customer_ID__c 
                                   FROM User WHERE Id=:userInfo.getUserId() AND AccountId != null WITH SECURITY_ENFORCED LIMIT 1];
            if(Test.isRunningTest()){
                user = B2BTestFactory.getUser();
            }else{
                user = userList.get(0);
            }
            if(user != null ){
                stripeCustomerId = user.Account.B2B_Stripe_Customer_ID__c;
                if(String.isBlank(stripeCustomerId)){
                    HttpRequest http = new HttpRequest();
                    String customerUrl = stripeConfig.EndPoint_URL__c+'customers';
                    String apiKey =  stripeConfig.Api_Key__c;
                    String stripeAccountName = user.Account.Name;
                    Blob headerValue = Blob.valueOf(apiKey + ':');
                    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
                    String body = 'name='+stripeAccountName;
                    HttpResponse resp = new HttpResponse();
                    
                    resp = stripeRestAPICall(customerUrl,authorizationHeader,body,'POST');
                    logger.debug(http, resp);
                    string response = resp.getBody();
                    
                    B2BStripeModel stripeCustomerResponse = parseTokenResponse(response);
                    
                    Account customerAccount = new Account(Id = user.AccountId);
                    customerAccount.B2B_Stripe_Customer_ID__c = stripeCustomerResponse.CustomerId;
                    //update customerAccount;
                    payload.add(customerAccount);
                    DmlManager.updateAsUser(payload);
                    stripeCustomerId = stripeCustomerResponse.CustomerId;
                }
                logger.debug(JSON.serialize(stripeCustomerId));
                return stripeCustomerId; 
            } 
        }catch (DmlManager.DmlManagerException e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }catch(Exception ex){
            logger.error(ex);
        }Finally{
            logger.flush();
        }
        return stripeCustomerId; 
    }

    public static HttpResponse stripeRestAPICall(String stripeEndpoint, String authorizationHeader,String requestBody,String method )
    {
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            req.setEndpoint(stripeEndpoint);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setMethod(method);
            req.setBody(requestBody);
            req.setTimeout(40000);
            /*if(Test.isRunningTest()){
                HTTPResponse res = new HTTPResponse();
                //res.setBody('{"success":"true"}');
                res.setBody('{"charges":{"data":"Delivery Method 1"}}');
                res.setStatus('Success');
                res.setStatusCode(200);
                return res;
            }else{*/
                logger.debug(req,http.send(req));
                return http.send(req);
           //}
        }catch(Exception e){
            logger.error(e);
        }finally{
            logger.flush();
        }
        return null;
    }

    public static B2BStripeModel parseTokenResponse(String responseBody){    
        B2BStripeModel sModel   = new B2BStripeModel();
        
        JSONParser parser = JSON.createParser(responseBody);
        boolean isSrcValue = false;
        try{
            while(parser.nextToken() != null){
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    if(parser.getText() == 'id'){
                        parser.nexttoken();
                        sModel.id= parser.getText();
                    }
                    
                    if(parser.getText() == 'object' && !(isSrcValue)){
                        isSrcValue = true;
                        parser.nexttoken();
                        sModel.transactionObject= parser.getText();
                        if (sModel.transactionObject == 'charge'){
                            sModel.stripeTransactionToken = sModel.id;
                        } else if (sModel.transactionObject == 'customer') {
                            sModel.CustomerId = sModel.id;
                        }
                    }
                    
                    if(parser.getText() == 'amount'){
                        parser.nexttoken();
                        sModel.chargeAmount = decimal.valueOf(parser.getText());
                    }
                    
                    if(parser.getText() =='currency'){
                        parser.nexttoken();
                        sModel.currencyCode=parser.getText();
                    }
                    if(parser.getText() =='type'){
                        parser.nexttoken();
                        sModel.type= parser.getText();
                    }
                    
                    if(parser.getText() == 'source'){
                        isSrcValue = true;
                        while(parser.nextToken() != null){
                            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                if (parser.getText() == 'last4'){
                                    parser.nexttoken();
                                    sModel.cardLastFourDigit= parser.getText();
                                }
                                
                                if (parser.getText() == 'exp_month'){
                                    parser.nexttoken();
                                    sModel.cardExpiryMonth = parser.getText();
                                }
                                
                                if (parser.getText() == 'exp_year'){
                                    parser.nexttoken();
                                    sModel.cardExpiryYear = parser.getText();
                                }
                                
                                if (parser.getText() == 'country'){
                                    parser.nexttoken();
                                    sModel.country = parser.getText();
                                }
                                
                                if (parser.getText() == 'brand'){
                                    parser.nexttoken();
                                    sModel.brand= parser.getText();
                                }
                                
                            }
                        }
                    }
                    else
                        if(parser.getText() == 'data'){
                            while(parser.nextToken() != null){
                                if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                                    if (parser.getText() == 'last4'){
                                        parser.nexttoken();
                                        sModel.cardLastFourDigit= parser.getText();
                                    }
                                    
                                    if (parser.getText() == 'exp_month'){
                                        parser.nexttoken();
                                        sModel.cardExpiryMonth= parser.getText();
                                    }
                                    
                                    if (parser.getText() == 'exp_year'){
                                        parser.nexttoken();
                                        sModel.cardExpiryYear= parser.getText();
                                    }
                                    
                                    if (parser.getText() == 'country'){
                                        parser.nexttoken();
                                        sModel.country= parser.getText();
                                    }
                                    
                                    if (parser.getText() == 'brand'){
                                        parser.nexttoken();
                                        sModel.brand= parser.getText();
                                    }
                                }
                            }
                        }
                    else
                        if(parser.getText() == 'Error'){
                            while(parser.nextToken() != null){
                                if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                                    if (parser.getText() == 'message'){
                                        parser.nexttoken();
                                        sModel.stripeChargeProcessError= parser.getText();
                                    }
                                    
                                }
                            }
                        }
                }
                
            }
            logger.debug(JSON.serialize(sModel));
            return sModel;
        }catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
        return sModel;
    }
    
    public static Map<String, String> setPaymentInfo(Map<String,Object> dataMap) {
        String stripeCustomerId = (String)dataMap.get('stripeCustomerId');
        String cartId = (String)dataMap.get(B2BConstants.CART_ID) ;
        String orderId = '' ;
        List<CartCheckoutSession> sessions;
        try {
            if(!test.isRunningTest())
            {
                sessions= B2BUtils.getActiveCheckoutSessions(cartId);
            }
            else
            {
                sessions=[ SELECT
                          Id,
                          OrderId
                          FROM CartCheckoutSession
                          WHERE Name='Cart' WITH SECURITY_ENFORCED];
            }
            if(!sessions.isEmpty()){
                Order checkoutOrd = [select id, orderNumber, smOrder__c from Order where Id =: sessions.get(0).OrderId WITH SECURITY_ENFORCED Limit 1];
                Order ord = [select id, orderNumber from Order where Id = :checkoutOrd.smOrder__c WITH SECURITY_ENFORCED Limit 1];
                orderId = ord.Id;      //for SM order
            }
            Map<String, String> PaymentResultInfo = new Map<String, String>();
            Map<String, Object> selectedBillingAddress = new Map<String, Object>();
            Map<String, Object> paymentInfo = new Map<String, Object>();
            ConnectApi.AuthorizationRequest authRequest = new ConnectApi.AuthorizationRequest();
            WebCart cart = B2BCartSelector.getCurrentActiveCart(cartId);
            
            authRequest.amount = cart.GrandTotalAmount;
            authRequest.accountId = cart.AccountId;
            authRequest.effectiveDate = Datetime.now();
            authRequest.currencyIsoCode = cart.currencyIsoCode;
            String paymentGatewayId = getPaymentGatewayId(cart.WebStoreId);
            if (paymentGatewayId == null || paymentGatewayId.equals('')) {
                logger.error('paymentGatewayId == Null');
                throw new AuraHandledException('This store is not authorized to process payments.');
            }
            authRequest.paymentGatewayId = paymentGatewayId;
            authRequest.paymentMethod = getPaymentMethod(cart);
            authRequest.paymentGroup = getPaymentGroup(cart,orderId);
            authRequest.additionalData = new Map<String, String>{'stripeCustomerId' => stripeCustomerId ,'cartId' => cartId ,'orderId'=>orderId};
                if(!Test.isRunningTest()){
                    ConnectApi.AuthorizationResponse authResponse = ConnectApi.Payments.authorize(authRequest);
                    ConnectApi.AuthorizationGatewayResponse authGatewayRes = authResponse.gatewayResponse;
                    if (authResponse.error != null) {
                        logger.error(authResponse.error.message);
                        throw new AuraHandledException('AuthResponseError: ' + authResponse.error.message);
                    }
                    if(authGatewayRes !=null){
                        logger.debug(JSON.serialize(authGatewayRes));
                        PaymentResultInfo.put('PI_Secret',authGatewayRes.gatewayResultCodeDescription);
                    }
                    if(authResponse.paymentAuthorization !=null){
                        ConnectApi.PaymentAuthorizationResponse paymentAuthResp = authResponse.paymentAuthorization;
                        PaymentResultInfo.put('PA_Id',paymentAuthResp.id);
                        logger.debug(JSON.serialize(paymentAuthResp));
                    }
                    dataMap.put(B2BConstants.IS_SUCCESS,true);
                    dataMap.put(B2BConstants.CART_ID,cartId);
                    dataMap.put(B2BConstants.ORDER_ID,orderId);
                }
            logger.debug(JSON.serialize(PaymentResultInfo));
            return PaymentResultInfo;
        } catch(ConnectApi.ConnectApiException e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException('Message: ' + e.getMessage() + ' --- ' + 'Type: ' + e.getTypeName() + '----' + ' _STACK_: ' + e.getStackTraceString());
        }finally{
            logger.flush();
        }
    }

    private static String getPaymentGatewayId(String webStoreId) {
        return [SELECT Integration FROM StoreIntegratedService WHERE ServiceProviderType='Payment' AND StoreId=:webStoreId].Integration;
    
    }
    @testVisible
    private static ConnectApi.PaymentGroupRequest getPaymentGroup(WebCart cart,String orderId) {
        ConnectApi.PaymentGroupRequest paymentGroup = new ConnectApi.PaymentGroupRequest();
        paymentGroup.createPaymentGroup = true;
        paymentGroup.currencyIsoCode = cart.currencyIsoCode;
        paymentGroup.sourceObjectId = orderId;            
        return paymentGroup;
    }
    @testVisible
    private static ConnectApi.AuthApiPaymentMethodRequest getPaymentMethod(WebCart cart) {
    
        
        ConnectApi.AuthApiPaymentMethodRequest authApiMethod = new ConnectApi.AuthApiPaymentMethodRequest();
        
        ConnectApi.CardPaymentMethodRequest paymentMethod = new ConnectApi.CardPaymentMethodRequest();
        
        //ConnectApi.CardPaymentMethodRequest paymentMethod = (ConnectApi.CardPaymentMethodRequest)[SELECT AccountId, CardCategory, CardBin, CardHolderFirstName, CardHolderLastName, CardHolderName, CardLastFour, CardPaymentMethodNumber, CardType, CardTypeCategory, CompanyName, DisplayCardNumber, ExpiryMonth, ExpiryYear, Email, Id, InputCardNumber, PaymentMethodAddress, StartMonth, StartYear FROM CardPaymentMethod where id ='03O8c000000ws40EAA' ];
        
        paymentMethod.accountId = cart.AccountId;
        paymentMethod.cardCategory = ConnectApi.CardCategory.CreditCard;
        paymentMethod.cardHolderFirstName = 'Test user';
        paymentMethod.cardHolderLastName = 'Test user';
        paymentMethod.email = 'cardHolder@yopmail.com';
        paymentMethod.cardHolderName = 'Test user';
        paymentMethod.cardNumber = '4242424242424242';//Dummy Card Number value to bypass required field
        paymentMethod.cardType = 'Visa';//Dummy Card Type value to bypass required field
        paymentMethod.cvv = '123';//Dummy Card CVV value to bypass required field
        paymentMethod.expiryMonth = 12;//Dummy Card Expiry Month value to bypass required field
        paymentMethod.expiryYear = 2030;    //Dummy Card Expiry Year value to bypass required field    
        authApiMethod.cardPaymentMethod = paymentMethod;
       
        // Pass address from the Payment Form
        ConnectApi.AddressRequest address = new ConnectApi.AddressRequest();
        address.street = '164 Indusco Ct.';//cart.Bill_To__r.Street;
        address.city = 'Troy';//cart.Bill_To__r.City;
        address.state = 'Washington';//cart.Bill_To__r.State;
        address.country = 'United States';//cart.Bill_To__r.Country;
        address.postalCode = '48083';//cart.Bill_To__r.PostalCode;
        
        authApiMethod.address = address;
        authApiMethod.saveForFuture = false;
        //authApiMethod.id = '03O8c000000ws40EAA'; //paymentMethod.Id; // PaymentMethod record ID.
        return authApiMethod;
    }
}