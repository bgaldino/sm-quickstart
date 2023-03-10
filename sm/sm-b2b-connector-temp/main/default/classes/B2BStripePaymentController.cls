/**
 * @description       : 
 * @author            : Abhishek Walia
 * @group             : Docmation LLC
 * @last modified on  : 02-14-2022
 * @last modified by  : Abhishek Walia
**/
public without sharing class B2BStripePaymentController {

    private static final String CLASSNAME = 'B2BStripePaymentController';
    private static final String MODULE_NAME = 'Payment Module';


    @AuraEnabled(cacheable=true)
    public static string getVFOrigin() {
        return B2BUtils.fetchConfigByValue('StoreBaseUrl');
    }

    @AuraEnabled
    public static map<String,Object> getPaymentInfo(map<String,Object> dataMap){
        String methodName = 'getPaymentInfo';
        String supportData = '';
        try{
            dataMap = B2BStripeIntegrationController.getPaymentOptions(dataMap);
        } catch (Exception ex) {
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage()+' '+ex.getStackTraceString());
            //B2BExceptionLogs.Log(ex, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            //B2BUtils.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }

    @AuraEnabled
    public static map<String,Object> submitPoOrder(map<String,Object> dataMap){
        String methodName = 'submitPoOrder';
        String supportData = '';
        try{
            if(dataMap.containsKey(B2BConstants.CART_ID) && String.isNotBlank((String)dataMap.get(B2BConstants.CART_ID)) )  {
                String cartId = (String)dataMap.get(B2BConstants.CART_ID) ;
                WebCart cart = B2BCartSelector.getCurrentActiveCart(cartId);
                dataMap.put(B2BConstants.CART,cart);
                cart.PONumber = (String)dataMap.get('poNumber');
                cart.paymentMethodId = null;
                // Commenting it out as the flow is failing when the state is updated to the cartCheckoutSession and cart is in closed status
                //cart.status = B2BConstants.CART_CLOSED;
                update cart;
                updateOppCheckoutStatus(cart);
                updateOrderInformation(dataMap);
                dataMap.put(B2BConstants.IS_SUCCESS,true);
            }
        } catch (Exception ex) {
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage());
            //B2BExceptionLogs.Log(ex, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            //B2BUtils.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }

    public static void updateOppCheckoutStatus(WebCart cart){
        /*if(String.isNotBlank(cart.Partner_Opportunity__c)){
            Opportunity opp = new Opportunity();
            opp.Id = cart.Partner_Opportunity__c;
            opp.Checkout_Status__c = 'Checkout Completed';
            update opp;
        }*/
    }

    @AuraEnabled
    public static map<String,Object> setPaymentInfo(map<String,Object> dataMap){
        String methodName = 'setPaymentInfo';
        String supportData = '';
        try{
            dataMap = B2BStripeIntegrationController.setPaymentInfo(dataMap);
        } catch (Exception ex) {
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage());
            //B2BExceptionLogs.Log(ex, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            //B2BUtils.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }

    @AuraEnabled
    public static map<String,Object> submitCreditCardOrder(map<String,Object> dataMap){
        String methodName = 'submitCreditCardOrder';
        String supportData = '';
        try{
            dataMap = B2BStripeIntegrationController.chargeCustomer(dataMap);
            updateOrderInformation(dataMap);
        } catch (Exception ex) {
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage());
            //B2BExceptionLogs.Log(ex, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            //B2BUtils.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }

    public static Order getOrderAccountId(Order o){
        List<String> taxExemptRTList = B2BUtils.getTaxExemptRecordTypes();
        List<String> internalSuperAccountIdList = B2BUtils.getSuperInternalAccounts();
        if(internalSuperAccountIdList.contains(o.createdby.AccountId)){
            o.AccountId = B2BUtils.fetchConfigByValue('MFBookingsHoldingAccount');
        }/*else if(taxExemptRTList.contains(o.Account.Recordtype.name) ){
            if(String.isNotBlank(o.OpportunityId)){
                o.AccountId = o.Opportunity.AccountId;
            }else if(o.Type =='End Customer'){
                o.AccountId = B2BUtils.fetchConfigByValue('MFBookingsHoldingAccount');
            }
        }*/
        return o;
    }

    public static map<String,Object> updateOrderInformation(map<String,Object> dataMap){
        String cartId = (String)dataMap.get(B2BConstants.CART_ID) ;
        String paymentMethod = (String)dataMap.get('paymentMethod') ;
        List<CartCheckoutSession> sessions = B2BUtils.getActiveCheckoutSessions(cartId);
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
                //o.Accepted_Terms__c = true;
                //o.B2B_IP_Address__c = B2BUtils.getIpAddress() ;
                //o.B2B_Term_Acceptance_TimeStamp__c = Datetime.Now();
                //o.End_Customer_PO_Number__c = dataMap.containsKey('endCustomerPONumber') ? (String)dataMap.get('endCustomerPONumber') : ''  ;
                if(paymentMethod == 'PO'){
                    o.PoNumber =  (String)dataMap.get('poNumber')   ;
                    //o.Payment_Method__c =  'Purchase Order' ;
                }else{
                    //o.Stripe_Transaction_ID__c =  (String)dataMap.get('chargeId')   ;
                    //o.Payment_Method__c = 'Credit Card (Stripe)' ;
                }
                update o;
            }
        return dataMap;
    }

    @AuraEnabled
    public static map<String,Object> updatePaymentAuthError(map<String,Object> dataMap){
        String methodName = 'updatePaymentAuthError';
        String supportData = '';
        try{
            String paId = (String)dataMap.get('paId') ;
            List<PaymentAuthorization> paList = [SELECT Id, Status, GatewayAuthCode, SfResultCode FROM PaymentAuthorization WHERE Id =: paId LIMIT 100];
            for(PaymentAuthorization pa: paList){ pa.status = 'Canceled';
            }
            if(!paList.isEmpty()){ update paList;
            }
        } catch (Exception ex) {
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS,false);
            dataMap.put(B2BConstants.MESSAGE,ex.getMessage());
            //B2BExceptionLogs.Log(ex, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            //B2BUtils.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }
}