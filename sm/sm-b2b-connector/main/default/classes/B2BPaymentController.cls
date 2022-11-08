/**
 * @description       : 
 * @author            : Surya Thakur
 * @group             : Docmation LLC
 * @last modified on  : 02-14-2022
 * @last modified by  : Surya Thakur
**/
global without sharing class B2BPaymentController {

    private static final String CLASSNAME = 'B2BPaymentController';
    private static final String MODULE_NAME = 'Payment Module';
    private static final DCM_Logger logger = DCM_Logger.getInstance(MODULE_NAME);


    @AuraEnabled(cacheable=true)
    global static string getVFOrigin() {
        //return B2BUtils.fetchConfigByValue('StoreBaseUrl');
        return RSM_Connector_Configuration__mdt.getInstance('Store_Base_Url').key__c;
    }

    @AuraEnabled
    global static map<String,Object> getPaymentInfo(map<String,Object> dataMap){
        String methodName = 'getPaymentInfo';
        String supportData = '';

        try{
            dataMap = B2BStripeIntegrationController.getPaymentOptions(dataMap);
            logger.debug(JSON.serialize(dataMap));
        } catch (Exception ex) {
            logger.error(ex);
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage()+' '+ex.getStackTraceString());
        }finally
        {
            logger.flush();
        }
        return dataMap;
    }

    @AuraEnabled
    global static map<String,Object> submitPoOrder(map<String,Object> dataMap){
        String methodName = 'submitPoOrder';
        String supportData = '';
        List<SObject> payload = new List<SObject>();
        try{
            if(dataMap.containsKey(B2BConstants.CART_ID) && String.isNotBlank((String)dataMap.get(B2BConstants.CART_ID)) )  {
                String cartId = (String)dataMap.get(B2BConstants.CART_ID) ;
                WebCart cart = B2BCartSelector.getCurrentActiveCart(cartId);
                dataMap.put(B2BConstants.CART,cart);
                //cart.PONumber = (String)dataMap.get('poNumber');
                cart.paymentMethodId = null;
                // Commenting it out as the flow is failing when the state is updated to the cartCheckoutSession and cart is in closed status
                //cart.status = B2BConstants.CART_CLOSED;
                //update cart;
                payload.add(cart);
                DMLManager.updateAsUser(payload);
                updateOrderInformation(dataMap);
                dataMap.put(B2BConstants.IS_SUCCESS,true);
            }
        }catch (DmlManager.DmlManagerException e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } catch (Exception ex) {
            logger.error(ex);
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage());
        }finally
        {
            logger.flush();
        }
        return dataMap;
    }

    public static void updateOppCheckoutStatus(WebCart cart){

    }

    @AuraEnabled
    global static map<String,Object> setPaymentInfo(map<String,Object> dataMap){
        String methodName = 'setPaymentInfo';
        String supportData = '';
        try{
            dataMap = B2BStripeIntegrationController.setPaymentInfo(dataMap);
            logger.debug(JSON.serialize(dataMap));
        } catch (Exception ex) {
            logger.error(ex);
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage());
        }finally
        {
            logger.flush();
        }
        return dataMap;
    }

    @AuraEnabled
    global static map<String,Object> submitCreditCardOrder(map<String,Object> dataMap){
        String methodName = 'submitCreditCardOrder';
        String supportData = '';
        try{
           // dataMap = B2BStripeIntegrationController.chargeCustomer(dataMap);
            dataMap.put(B2BConstants.IS_SUCCESS,true);
            logger.debug(JSON.serialize(dataMap));
            updateOrderInformation(dataMap);
        } catch (Exception ex) {
            logger.error(ex);
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage());
        }finally
        {
            logger.flush();
        }
        return dataMap;
    }

    public static Order getOrderAccountId(Order o){
        List<String> taxExemptRTList = B2BUtils.getTaxExemptRecordTypes();
        List<String> internalSuperAccountIdList = B2BUtils.getSuperInternalAccounts();
        if(internalSuperAccountIdList.contains(o.createdby.AccountId)){
            o.AccountId = B2BUtils.fetchConfigByValue('MFBookingsHoldingAccount');
        }
        logger.debug(JSON.serialize(o));
        return o;
    }

    public static map<String,Object> updateOrderInformation(map<String,Object> dataMap){
        String cartId = (String)dataMap.get(B2BConstants.CART_ID) ;
        String paymentMethod = (String)dataMap.get('paymentMethod') ;
        List<SObject> payload = new List<SObject>();
        List<CartCheckoutSession> sessions;
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
        try{
            if(!sessions.isEmpty() && String.isNotBlank(sessions.get(0).OrderId)){
                String orderId = sessions.get(0).OrderId;
                Order o = B2BOrdersSelector.getOrderDetails(orderId);
                o.Id = orderId;
                getOrderAccountId(o);
                String checkOutOrderStatus = B2BUtils.fetchConfigByValue('CheckoutOrderStatus');
                if(String.isNotBlank(checkOutOrderStatus)){
                    o.Status = checkOutOrderStatus;
                }
                o.cart__c = cartId;
                //update o;
                payload.add(o);
                DMLManager.updateAsUser(payload);
                logger.debug(JSON.serialize(o));
            }
        }catch(DmlManager.DmlManagerException e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
        return dataMap;
    }
    
    public static map<String,Object> updateSMorderInfo(map<String,Object> dataMap){
        String cartId = (String)dataMap.get(B2BConstants.CART_ID) ;
        String paymentMethod = (String)dataMap.get('paymentMethod') ;
        List<SObject> payload = new List<SObject>();
        List<CartCheckoutSession> sessions;
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
        try{
            if(!sessions.isEmpty() && String.isNotBlank(sessions.get(0).OrderId)){
                String orderId = sessions.get(0).OrderId;
                Order ord = [Select id, smOrder__c from Order where id =:orderId WITH SECURITY_ENFORCED];
                Order o;
                if(!test.isRunningTest())
                {
                    o = B2BOrdersSelector.getOrderDetails(ord.smOrder__c);
                }
                else
                {
                    o= [select id,CreatedById from order where name= 'Test' WITH SECURITY_ENFORCED];
                    //return dataMap;
                }
                o.Id = orderId;
                getOrderAccountId(o);
                String checkOutOrderStatus = B2BUtils.fetchConfigByValue('CheckoutOrderStatus');
                if(String.isNotBlank(checkOutOrderStatus)){
                    o.Status = checkOutOrderStatus;
                }
                o.cart__c = cartId;
                logger.debug(JSON.serialize(o));
                //update o;
                payload.add(o);
                DMLManager.updateAsUser(payload);
            }
        }catch (DmlManager.DmlManagerException e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
        return dataMap;
    }

    @AuraEnabled
    global static map<String,Object> updatePaymentAuthError(map<String,Object> dataMap){
        String methodName = 'updatePaymentAuthError';
        String supportData = '';
        List<SObject> payload = new List<SObject>();
        try{
            String paId = (String)dataMap.get('paId') ;
            List<PaymentAuthorization> paList = [SELECT Id, Status, GatewayAuthCode, SfResultCode FROM PaymentAuthorization WHERE Id =: paId WITH SECURITY_ENFORCED LIMIT 100];
            for(PaymentAuthorization pa: paList)
            { 
                pa.status = 'Canceled';
                payload.add(pa);
            }
            if(!paList.isEmpty())
            { 
                logger.debug(JSON.serialize(paList));
                //update paList;
                DmlManager.updateAsUser(payload);
            }
        }catch (DmlManager.DmlManagerException e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } catch (Exception ex) {
            logger.error(ex);
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage());
        }finally
        {
            logger.flush();
        }
        return dataMap;
    }
    
    @AuraEnabled
    global static Map<String,object> callCreatePaymentMethodAPI(map<String,Object> dataMap){
        try{
            String paymentGatewayId;
            String cardHolderName;
            Decimal expiryMonth;
            Decimal expiryYear;
            String cardCategory;
            String cardType;
            String address;
            String lastDigits;
            String tokId;
            Decimal tokenCreated;
            String cPayId;
            String cardId;
            String payMethod;
            String cartId = (String)dataMap.get('cartId');
            WebCart cart = [Select id, WebStoreId, accountId from WebCart where id =:cartId WITH SECURITY_ENFORCED limit 1];
            String orderId = '' ;
             List<CartCheckoutSession> sessions;
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
                Order ord;
                if(!test.isRunningTest())
                {
                    ord = [select id, orderNumber from Order where Id = :checkoutOrd.smOrder__c WITH SECURITY_ENFORCED Limit 1];
                }
                else
                { 
                    ord=[select id from order where name='Test' WITH SECURITY_ENFORCED];
                }
                
                orderId = ord.Id;      //for SM order
            }
            String storeId= cart.WebStoreId;
            String accId = cart.AccountId;
            paymentGatewayId = [SELECT Id, ServiceProviderType, StoreId, Integration FROM StoreIntegratedService 
                                WHERE StoreId =: storeId AND ServiceProviderType = 'Payment' Limit 1].Integration;
            if(dataMap.containsKey('chargeData')){
                Map<object,object> chargedataMap = (Map<object,object>)dataMap.get('chargeData');
                cardHolderName = (String)chargedataMap.get('name');
                if(chargedataMap.containsKey('address')){
                    Map<Object,Object> billingdetailsMap = (Map<Object,Object>)chargedataMap.get('address');
                }
            }
            if(dataMap.containsKey('cPayId')){
                cPayId = (String)dataMap.get('cPayId');
                Map<Object,Object> cPayMap = (Map<Object,Object>)dataMap.get('cPay');
                payMethod = (String)cPayMap.get('payment_method');
            }
            if(dataMap.containsKey('cToken')){
                Map<Object,Object> cTokenMap = (Map<Object,Object>)dataMap.get('cToken');
                tokId = (String)cTokenMap.get('id');
                tokenCreated = (Decimal)cTokenMap.get('created');
                if(cTokenMap.containsKey('card')){
                    Map<Object,Object> cardDetailMap = (Map<Object,Object>)cTokenMap.get('card');
                    expiryMonth =(Decimal)cardDetailMap.get('exp_month');
                    expiryYear = (Decimal)cardDetailMap.get('exp_year');
                    lastDigits = (String)cardDetailMap.get('last4');
                    cardType = (String)cardDetailMap.get('brand');
                    cardCategory = (String)cardDetailMap.get('funding')+'Card';
                    cardHolderName = (String)dataMap.get('name');
                    cardId = (String)cardDetailMap.get('id');
                }
            }
            Map<String,object> resultData = new Map<String,object>();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            if(Test.isRunningTest()){
                request.setHeader('Authorization', 'Bearer ');
            }else{
                request.setHeader('Authorization', 'Bearer ' + B2B_CreateUserAccessToken.getAdminAccessToken());   
            }
            String baseUrl = String.valueOf(Url.getOrgDomainUrl().toExternalForm());
            String paymentRequest = '/services/data/v55.0/commerce/payments/payment-methods';
            request.setMethod('POST'); 
            request.setHeader('Content-Type', 'application/json; charset=UTF-8 ');
            request.setEndpoint(baseUrl+paymentRequest);
            String requestBody = '{';
            requestBody +=    '"paymentGatewayId": "'+paymentGatewayId+'",';		//0b08c000000wtMcAAI",' ; //no
            requestBody +=    '"cardPaymentMethod": {' ; 
            requestBody +=      '"cardHolderName": "'+cardHolderName+'",';		//"Dustin Freud",' ;  //no
            requestBody +=       '"expiryMonth": "'+expiryMonth+'",';						//"11",' ;
            requestBody +=      '"expiryYear": "'+expiryYear+'",';							//"2023",' ;
            requestBody +=      '"cardNumber": "4111111111111111",' ; 					//hard coded
            requestBody +=      '"cvv": "111",' ;										//hard coded
            requestBody +=     '"cardCategory": "'+cardCategory+'",'	;						//"CreditCard",' ;		
            requestBody +=      '"cardType": "'+cardType+'",';								//"VISA",' ;
            requestBody +=     '"startYear": "2013",' ;
            requestBody +=    '"startMonth": "7",' ;
            requestBody +=     '"nickName": "'+cardHolderName+'",';							//"PK",' ;
            requestBody +=      ' "accountId": "'+accId+'"';						//"0018c00002IMuGLAA1"' ;
            requestBody +=  '},' ;
            requestBody +=  '"additionalData": {' ;
            requestBody +=  	'"tokenId": "'+tokId+'",';							//"value1",' ;
            requestBody +=      '"cPayId": "'+cPayId+'",';                              //"value1",' ;
            requestBody +=      '"cardId": "'+cardId+'",';                              //"value1",' ;
            requestBody +=      '"payMethod": "'+payMethod+'",';   
            requestBody +=  	'"tokenCreated": "'+tokenCreated+'"';				//"value2"' ;
            requestBody +=  '}' ;
            requestBody += '}'; 
            
            request.setBody(requestBody);
            HttpResponse response;
            response = http.send(request);
            logger.debug(request, response);
            // Parse the JSON response
            resultData.put('response',response.getBody());
            if (response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
                throw new AuraHandledException(response.getBody());
            } else {
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                updateOrderDetails(orderId, responseMap);
            }
            return resultData;
            
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally{
            logger.flush();
        }
    }
    
    public static void updateOrderDetails(String orderId, Map<String,Object> responseMap){
        Map<String,Object> paymentMap = new Map<String,Object>();
        Map<String,Object> gatewayLogMap = new Map<String,Object>();
        List<SObject> payload = new List<SObject>();
        try{
            if(responseMap.containsKey('paymentMethod')){
                paymentMap = (Map<String,Object>)responseMap.get('paymentMethod');
            }
            if(responseMap.containsKey('paymentGatewayLogs')){
                gatewayLogMap = (Map<String,Object>)( (List<Object>)responseMap.get('paymentGatewayLogs')).get(0);
            }
            Order ord = new Order(Id = orderId);
            ord.Payment_Method_Id__c = (String)paymentMap.get('id');
            ord.Payment_Gateway_Log_Id__c = (String)gatewayLogMap.get('id');
            logger.debug(json.serialize(ord));
            //update ord;
            payload.add(ord);
            DmlManager.updateAsUser(payload);
        }catch (DmlManager.DmlManagerException e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }catch(Exception ex){
            logger.error(ex);
        }finally{
            logger.flush();
        }
    }
    
    public class ProductDetailResponse{
        @AuraEnabled
        public String prodName{get;set;}
        @AuraEnabled
        public String prodId{get;set;}
        @AuraEnabled
        public String prodDescription{get;set;}
        @AuraEnabled
        public String prodImageUrl{get;set;}
        @AuraEnabled
        public Boolean isPriceAlreadyAvailable{get;set;}
        @AuraEnabled
        public Boolean isProductCompared{get;set;}
        @AuraEnabled
        public Object pricingInfo{get;set;}
        @AuraEnabled
        public Boolean isRecurring{get;set;}
        @AuraEnabled
        public String pricebookEntryId{get;set;}
        @AuraEnabled
        public String unitPrice{get;set;}
        @AuraEnabled
        public String listPrice{get;set;}
        
    }
    
}