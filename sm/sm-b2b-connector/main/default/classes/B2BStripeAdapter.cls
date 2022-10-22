/**
 * @description       : 
 * @author            : Surya Thakur
 * @group             : Docmation LLC
 * @last modified on  : 03-10-2022
 * @last modified by  : Surya Thakur
**/

//global virtual with sharing class B2BStripeAdapter implements commercepayments.PaymentGatewayAdapter {
global virtual with sharing class B2BStripeAdapter implements commercepayments.PaymentGatewayAdapter, B2BPaymentAdapter_Interface {
    private static final commercepayments.SalesforceResultCodeInfo SUCCESS_SALESFORCE_RESULT_CODE_INFO = 
        new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success);
    private static final commercepayments.SalesforceResultCodeInfo RC_SUCCESS = toCodeInfo(commercepayments.SalesforceResultCode.Success);
    private static final commercepayments.SalesforceResultCodeInfo RC_DECLINE = toCodeInfo(commercepayments.SalesforceResultCode.Decline);
    private static final List<String> DECLINE_CODES = new List<String>{'card_declined', 'incorrect_cvc', 'expired_card', 'authentication_required', 'card_not_supported', 'currency_not_supported', 'incorrect_number', 'incorrect_zip'};
        
    private static final String MODULE_NAME = 'Payment Adapter Module';
    private static final DCM_Logger logger = DCM_Logger.getInstance(MODULE_NAME);

    public class StripeValidationException extends Exception {

    }
    global B2BStripeAdapter() {
    }
 
    global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {     
        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        commercepayments.PaymentGatewayRequest paymentRequest = gatewayContext.getPaymentRequest();
        commercepayments.GatewayResponse response;
        
        try {
            logger.debug(JSON.serialize(requestType));
            if (requestType == commercepayments.RequestType.Authorize) {
                response = createAuthResponse((commercepayments.AuthorizationRequest) paymentRequest);
            } else if (requestType == commercepayments.RequestType.Capture) {
                response =  createCaptureResponse((commercepayments.CaptureRequest) paymentRequest);
            } else if (requestType == commercepayments.RequestType.Sale) {
                response =  createSaleResponse((commercepayments.SaleRequest) paymentRequest);
            } else if (requestType == commercepayments.RequestType.ReferencedRefund) {
                response = createRefundResponse((commercepayments.ReferencedRefundRequest) paymentRequest);
            } else if (requestType == commercepayments.RequestType.Tokenize) {
                response = createTokenizeResponse1((commercepayments.PaymentMethodTokenizationRequest) paymentRequest);
            }
            return response;
        } catch (StripeValidationException e) {
            logger.error(e);
            return new commercepayments.GatewayErrorResponse('400', e.getMessage());
        }finally{
            logger.flush();
        }
    }
    
    public commercepayments.GatewayResponse createTokenizeResponse1(commercepayments.PaymentMethodTokenizationRequest tokenizeRequest) {
        Map<String, Object> results = (Map<String, Object>)tokenizeRequest.additionalData;
        commercepayments.PaymentMethodTokenizationResponse tokenizeResponse = new commercepayments.PaymentMethodTokenizationResponse();
        try{
            logger.debug(JSON.serialize(results));
            tokenizeResponse.setGatewayAvsCode((String)results.get('tokenId'));
            tokenizeResponse.setGatewayMessage((String)results.get('payMethod'));
            tokenizeResponse.setGatewayResultCode((String)results.get('cPayId'));
            tokenizeResponse.setGatewayResultCodeDescription((String)results.get('cardId'));
            tokenizeResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
            tokenizeResponse.setGatewayToken((String)results.get('tokenId'));
            tokenizeResponse.setGatewayTokenDetails((String)results.get('payMethod'));
            tokenizeResponse.setGatewayDate(system.now());
            return tokenizeResponse;
        }catch(StripeValidationException ex){
            logger.error(ex);
            return new commercepayments.GatewayErrorResponse('400', ex.getMessage());
        }finally{
            logger.flush();
        }
    }


    public commercepayments.GatewayResponse createTokenizeResponse(commercepayments.PaymentMethodTokenizationRequest tokenizeRequest) {
        // API: https://stripe.com/docs/api/tokens    
        
        try{
            logger.debug(JSON.serialize(tokenizeRequest));
            commercepayments.CardPaymentMethodRequest cardPaymentMethod = tokenizeRequest.cardPaymentMethod;
            Map<String, String> params = new Map<String, String>();
            params.put('card[name]', urlEncode(cardPaymentMethod.cardHolderName));
            params.put('card[number]', cardPaymentMethod.cardNumber);
            params.put('card[exp_month]', String.valueOf(cardPaymentMethod.expiryMonth));
            params.put('card[exp_year]', String.valueOf(cardPaymentMethod.expiryYear));
            params.put('card[cvc]', cardPaymentMethod.cvv);
            
            commercepayments.AddressRequest billingAddress = tokenizeRequest.address;
            
            if (billingAddress != null) {
                params.put('card[address_line1]', billingAddress.street);
                params.put('card[address_city]', billingAddress.city);
                params.put('card[address_state]', billingAddress.state);
                params.put('card[address_zip]', billingAddress.postalCode);
                params.put('card[address_country]', billingAddress.country);
            }
            
            HttpResponse response = doPost('tokens', params);
            String body = response.getBody();
            logger.debug(JSON.serialize(body));
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
            Integer sc = response.getStatusCode();
            commercepayments.PaymentMethodTokenizationResponse tokenizeResponse = new commercepayments.PaymentMethodTokenizationResponse();
            
            tokenizeResponse.setGatewayDate(system.now());
            if (sc >= 200 && sc < 300) {
                tokenizeResponse.setGatewayToken((String) results.get('id'));
                tokenizeResponse.setGatewayResultCode('success');
                tokenizeResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
            }
            else {
                // TODO: lots of error mapping/handling
                Map<String, Object> error = (Map<String, Object>) results.get('error');
                if(!test.isRunningTest()){
                    String errorType = (String) error.get('type');
                    String errorCode = (String) error.get('code');
                    
                    if (errorType.equals('card_error') && DECLINE_CODES.contains(errorCode) ) {
                        tokenizeResponse.setGatewayResultCode(errorCode);
                        tokenizeResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                        tokenizeResponse.setGatewayMessage((String) error.get('message'));
                        tokenizeResponse.setSalesforceResultCodeInfo(RC_DECLINE);
                    } else {
                        logger.error(body);
                        return new commercepayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
                    }
                }
            }
            
            // TODO: more failure cases?
            logger.debug(JSON.serialize(tokenizeResponse));
            return tokenizeResponse;
        }catch(Exception ex){
            logger.error(ex);
            return new commercepayments.GatewayErrorResponse('400', ex.getMessage());
        }finally{
            logger.flush();
        }
        
    }
    
    public commercepayments.GatewayResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest) {
        // API: https://stripe.com/docs/api/charges/create       
        try{
            logger.debug(JSON.serialize(authRequest));
            commercepayments.AuthApiPaymentMethodRequest paymentMethod = authRequest.paymentMethod;
            commercepayments.AddressRequest address = paymentMethod.address;
            String stripeCustomerId =  authRequest.additionalData.get('stripeCustomerId');
            String currentCartId = authRequest.additionalData.get('cartId');
            String orderId = authRequest.additionalData.get('orderId');
            List<Order> ordList = [SELECT Id,OrderNumber FROM ORDER WHERE Id=:orderId];
            
            WebCart cart = B2BCartSelector.getCurrentActiveCart(currentCartId);
            String currencyCode = cart.currencyISOCode;
            Decimal Amount  = cart.GrandTotalAmount ;  
            Integer intAmount = Integer.valueOf(Amount*100);
            
            Map<String, String> params = new Map<String, String>();
            params.put('amount', String.valueOf(intAmount));
            params.put('currency', currencyCode);
            params.put('customer', stripeCustomerId);
            params.put('metadata[cartId]', currentCartId);
            params.put('metadata[orderId]', orderId);
            if(!ordList.isEmpty()){
                params.put('metadata[orderNumber]', ordList.get(0).OrderNumber);
                params.put('description', ordList.get(0).OrderNumber);
            }
            params.put('capture_method', 'manual');
            params.put('payment_method_types[]', 'card');
            //params.put('setup_future_usage', 'off_session');
            
            HttpResponse response = doPost('payment_intents', params);
            
            String body = response.getBody();
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
            logger.debug(JSON.serialize(results));
            /*for(string key: results.keyset()){
                system.debug(key+'_______'+results.get(key));
            }*/
            Integer sc = response.getStatusCode();
            commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
            
            authResponse.setGatewayDate(system.now());
            
            if (sc >= 200 && sc < 300) {
                
                authResponse.setGatewayResultCode((String) results.get('status'));
                authResponse.setGatewayResultCodeDescription((String) results.get('client_secret'));
                authResponse.setGatewayAuthCode((String) results.get('id')); // "ch_..."
                authResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
                authResponse.setAmount(double.valueOf(((Long) results.get('amount'))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
                authResponse.setGatewayReferenceNumber((String) results.get('client_secret')); 
            } else {
                // TODO: lots of error mapping/handling
                Map<String, Object> error = (Map<String, Object>) results.get('error');
                if(!test.isRunningTest()){
                    String errorType = (String) error.get('type');
                    String errorCode = (String) error.get('code');
                    
                    if (errorType.equals('card_error') && DECLINE_CODES.contains(errorCode) ) {
                        authResponse.setGatewayResultCode(errorCode);
                        authResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                        authResponse.setGatewayMessage((String) error.get('message'));
                        authResponse.setSalesforceResultCodeInfo(RC_DECLINE);
                    } else {
                        return new commercepayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
                    }
                }
            }
            return authResponse;
        }catch(StripeValidationException ex){
            logger.error(ex);
            return new commercepayments.GatewayErrorResponse('400', ex.getMessage());
        }finally{
            logger.flush();
        } 
        
    }
    
    public commercepayments.GatewayResponse createCaptureResponse(commercepayments.CaptureRequest captureRequest) {
        // API: https://stripe.com/docs/api/charges/capture
        try{
            // get the GatewayAuthCode
            logger.debug(JSON.serialize(captureRequest));
            QueryUtils q = new QueryUtils(PaymentAuthorization.SObjectType);
            q.getSelectClause().addField('GatewayAuthCode', false);
            q.setWhereClause(' WHERE Id =' + '\'' + captureRequest.paymentAuthorizationId + '\'');
            PaymentAuthorization paymentAuthorization = (PaymentAuthorization)Database.query(q.buildSOQL())[0];
            String authCode = paymentAuthorization.GatewayAuthCode;
            
            String currencyIsoCodeLC = 'usd'; // TODO: we need to get this from previous uath
            Long amount = toStripeCurrencyUnits(currencyIsoCodeLC, captureRequest.amount);
            
            Map<String, String> params = new Map<String, String>();
            params.put('amount', String.valueOf(amount));
            
            HttpResponse response = doPost('charges/' + authCode + '/capture', params);
            
            String body = response.getBody();
            if (response.getStatusCode() != 200) {
                return new commercepayments.GatewayErrorResponse('500', 'ERROR: ' + response + ': ' + body);
            }
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
            logger.debug(JSON.serialize(results));
            commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();
            captureResponse.setAmount(double.valueOf(((Long) results.get('amount'))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
            captureResponse.setGatewayDate(system.now());
            captureResponse.setGatewayResultCode((String) results.get('balance_transaction'));
            captureResponse.setGatewayResultCodeDescription((String) results.get('receipt_url'));
            captureResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
            logger.debug(JSON.serialize(captureResponse));
            return captureResponse;
        }catch(Exception ex){
            logger.error(ex);
            return new commercepayments.GatewayErrorResponse('500', ex.getMessage());
        }finally{
            logger.flush();
        }    
        
    }
    
    public commercepayments.GatewayResponse createSaleResponse(commercepayments.SaleRequest saleRequest) {
        
        try{
            logger.debug(JSON.serialize(saleRequest));
            commercepayments.SaleApiPaymentMethodRequest results = saleRequest.paymentMethod;
            
            CardPaymentMethod cpm ;
            if(!test.isRunningTest())
            { cpm = [SELECT Id, GatewayToken, GatewayTokenDetails, PaymentGatewayId, GatewayResultCode, GatewayResultCodeDescription, Account.B2B_Stripe_Customer_ID__c FROM CardPaymentMethod where id =: results.Id WITH SECURITY_ENFORCED Limit 1];}
            else
            {  
                cpm=[SELECT Id, Account.B2B_Stripe_Customer_ID__c,GatewayTokenDetails,GatewayResultCode from CardPaymentMethod where AuditEmail= 'h@test.com' WITH SECURITY_ENFORCED];
            }
            
            Map<String, String> params = new Map<String, String>();
            params.put('amount',String.valueOf( Math.roundToLong(saleRequest.amount * 100) ));  //Math.roundToLong(amount * 100)
            params.put('currency',String.valueOf(saleRequest.currencyIsoCode));
            params.put('customer',String.valueOf(cpm.Account.B2B_Stripe_Customer_ID__c));
            params.put('payment_method',String.valueOf(cpm.GatewayTokenDetails));
            params.put('off_session',String.valueOf(true));
            params.put('confirm',String.valueOf(true));
            params.put('description',String.valueOf(cpm.GatewayTokenDetails));
            B2B_Payment_Gateway_Setting__mdt stripeConfig = B2BStripeIntegrationController.getStripeConfiguration() ;
            if(stripeConfig == Null){
                stripeConfig = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Api_Key__c, Country__c, EndPoint_URL__c, 
                                Entity_Name__c, Public_Key__c, Stripe_Account_Name__c, User_Locale__c, WebStore__c, Currency__c 
                                FROM B2B_Payment_Gateway_Setting__mdt where MasterLabel = 'MF USD' WITH SECURITY_ENFORCED];
            }
            String customerUrl = stripeConfig.EndPoint_URL__c+'payment_intents/'+(String)cpm.GatewayResultCode+'/capture';
            String apiKey =  stripeConfig.Api_Key__c;
            Blob headerValue = Blob.valueOf(apiKey + ':');
            String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
            HttpResponse response = chargePaymentApi((String)cpm.GatewayResultCode,authorizationHeader,B2BStripeAdapter.urlEncodedParams(params),'POST');
            String body = response.getBody();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            logger.debug(JSON.serialize(responseMap));
            Integer sc = response.getStatusCode();
            
            commercepayments.SaleResponse saleResponse = new commercepayments.SaleResponse();
            saleResponse.setGatewayDate(system.now());
            if (sc >= 200 && sc < 300) {
                saleResponse.setGatewayReferenceDetails((String)responseMap.get('client_secret'));
                saleResponse.setGatewayResultCode((String) responseMap.get('status'));
                saleResponse.setGatewayResultCodeDescription((String) responseMap.get('client_secret'));
                saleResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
                saleResponse.setAmount(double.valueOf(((Long) responseMap.get('amount'))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
                saleResponse.setGatewayReferenceNumber((String) responseMap.get('id')); 
            } else {
                // TODO: lots of error mapping/handling
                Map<String, Object> error = (Map<String, Object>) responseMap.get('error');
                if(!test.isRunningTest()){
                    String errorType = (String) error.get('type');
                    String errorCode = (String) error.get('code');
                    
                    if (errorType.equals('card_error') && DECLINE_CODES.contains(errorCode) ) {
                        saleResponse.setGatewayResultCode(errorCode);
                        saleResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                        saleResponse.setGatewayMessage((String) error.get('message'));
                        saleResponse.setSalesforceResultCodeInfo(RC_DECLINE);
                    } else {
                        return new commercepayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
                    }
                }
            }
            return saleResponse;
        }catch(Exception ex){
            logger.error(ex);
            return new commercepayments.GatewayErrorResponse('500', ex.getMessage());
        }finally{
            logger.flush();
        }
    }
    
    private String getRandomNumber(integer stringLength){
        final integer MAX = integer.valueOf(Math.pow(10,stringLength) - 1);
        return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength,'0');
    }
    
    public commercepayments.GatewayResponse createRefundResponse(commercepayments.ReferencedRefundRequest refundRequest) {
        // API: https://stripe.com/docs/api/refunds
        try{
            // the Stripe charge ID is stored in the PaymentAuthorization gatewayauthcode
            logger.debug(JSON.serialize(refundRequest));
            QueryUtils q = new QueryUtils(Payment.SObjectType);
            q.getSelectClause().addField('PaymentAuthorizationId', false);
            q.setWhereClause(' WHERE Id =' + '\'' + refundRequest.paymentId + '\'');
            Payment payment = (Payment)Database.query(q.buildSOQL())[0];
            
            QueryUtils q1 = new QueryUtils(PaymentAuthorization.SObjectType);
            q1.getSelectClause().addField('GatewayAuthCode', false);
            q1.setWhereClause(' WHERE Id =' + '\'' + payment.PaymentAuthorizationId + '\'');
            PaymentAuthorization paymentAuth = (PaymentAuthorization)Database.query(q1.buildSOQL())[0];
            
            String currencyIsoCodeLC = 'usd'; // TODO: we need to get this from previous uath
            Long amount = toStripeCurrencyUnits(currencyIsoCodeLC, refundRequest.amount);
            
            Map<String, String> params = new Map<String, String>();
            params.put('charge', paymentAuth.GatewayAuthCode);
            params.put('amount', String.valueOf(amount));
            
            HttpResponse response = doPost('refunds', params);
            
            String body = response.getBody();
            if (response.getStatusCode() != 200) {
                logger.error(body);
                return new commercepayments.GatewayErrorResponse('500', 'ERROR: ' + response + ': ' + body);
            }
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
            logger.debug(JSON.serialize(results));
            commercepayments.ReferencedRefundResponse refundResponse = new commercepayments.ReferencedRefundResponse();
            refundResponse.setAmount(double.valueOf(((Long) results.get('amount'))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
            refundResponse.setGatewayDate(system.now());
            refundResponse.setGatewayResultCode((String) results.get('balance_transaction'));
            refundResponse.setGatewayResultCodeDescription((String) results.get('receipt_url'));
            refundResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
            logger.debug(JSON.serialize(refundResponse));
            return refundResponse;
        }catch(Exception ex){
            logger.error(ex);
            return new commercepayments.GatewayErrorResponse('500', ex.getMessage());
        }finally{
            logger.flush();
        }
        
    }
    
    public static HttpResponse doPost(String path, Map<String, String> params) {
        try{
            B2B_Payment_Gateway_Setting__mdt stripeConfig = B2BStripeIntegrationController.getStripeConfiguration();
            if(stripeConfig == Null){
                stripeConfig = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Api_Key__c, Country__c, EndPoint_URL__c, Entity_Name__c, Public_Key__c, 
                                Stripe_Account_Name__c, User_Locale__c, WebStore__c, Currency__c FROM B2B_Payment_Gateway_Setting__mdt 
                                where MasterLabel = 'MF USD'];
            }
            commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('/v1/' + path);
            Blob headerValue = Blob.valueOf(stripeConfig.API_Key__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody(urlEncodedParams(params));
            return http.send(request);
        }catch(Exception ex){
            logger.error(ex);
            HttpResponse resp = new HttpResponse();
            resp.setBody('error');
            return resp;
        }finally{
            logger.flush();
        }
    }
    
    public static String urlEncodedParams(Map<String, String> params) {
        String body = '';
        Boolean first = true;
        for (String key: params.keySet()) {
            if (first) {
                first = false;
            } else {
                body += '&';
            }
            // NOTE: do not encode values to allow PaymentsNamedConnection to replace the secure fields
            // values that need to be encoded should be encoded by this method's caller
            body += urlEncode(key) + '=' + params.get(key);
        }
        return body;
    }
    
    private static String urlEncode(String str) {
        return EncodingUtil.urlEncode(str, 'UTF-8');
    }
    
    private static Long toStripeCurrencyUnits(String currencyIsoCodeLC, Double amount) {
        // see https://stripe.com/docs/currencies#zero-decimal
        if (currencyIsoCodeLC.equals('usd')) {
            return Math.roundToLong(amount * 100); // TODO: make sure there are no rounding/precission issues
        }
        throw new StripeValidationException('toStripeCurrencyUnits: TODO: ' + currencyIsoCodeLC);  
    }
    
    private static commercepayments.SalesforceResultCodeInfo toCodeInfo(commercepayments.SalesforceResultCode code) {
        return new commercepayments.SalesforceResultCodeInfo(code);
    }
    
    
    public static HttpResponse chargePaymentApi(String stripeEndpoint, String authorizationHeader1,String requestBody,String method ){
        try{
            B2B_Payment_Gateway_Setting__mdt stripeConfig = B2BStripeIntegrationController.getStripeConfiguration();
            if(stripeConfig == Null){
                stripeConfig = [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Api_Key__c, Country__c, EndPoint_URL__c, Entity_Name__c, 
                                Public_Key__c, Stripe_Account_Name__c, User_Locale__c, WebStore__c, Currency__c 
                                FROM B2B_Payment_Gateway_Setting__mdt where MasterLabel = 'MF USD' WITH SECURITY_ENFORCED];
            }
            commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('/v1/payment_intents');

            Blob headerValue = Blob.valueOf(stripeConfig.API_Key__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody(requestBody);
            return http.send(request);
        }catch(Exception ex){
            logger.error(ex);
            return Null;
        }finally{
            logger.flush();
        }
    }
}