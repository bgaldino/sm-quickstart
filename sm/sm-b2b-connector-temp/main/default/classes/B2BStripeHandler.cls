/**
* @description       : 
* @author            : Abhishek Walia
* @group             : Docmation LLC
* @last modified on  : 01-23-2022
* @last modified by  : Abhishek Walia
**/
public with sharing class B2BStripeHandler {
    public string lexOrigin {get{ 
        return B2BUtils.fetchConfigByValue('StoreBaseUrl');
    } set;}
   
    public string pKeyUrl {get{ 
            return getPublicKey();
    } set;}
    
    @RemoteAction
    public static Map<String, String> submitOrderTest(Map<String,Object> dataMap) {
        Map<String, String> result = new Map<String, String>();
        try{
			result = B2BStripeIntegrationController.setPaymentInfo(dataMap);
           //result = B2BStripeIntegrationController.chargeCustomer(dataMap);
        }catch(Exception e){
            
        }
        return result;
    }
    
    @AuraEnabled
    public static Map<String, String> submitOrderTestAura(Map<String,Object> dataMap) {
        Map<String, String> result = new Map<String, String>();
        try{
			result = B2BStripeIntegrationController.setPaymentInfo(dataMap);
           //result = B2BStripeIntegrationController.chargeCustomer(dataMap);
        }catch(Exception e){
            
        }
        return result;
    }
    
    public static String getPublicKey(){
        B2B_Payment_Gateway_Setting__mdt stripeConfig = B2BStripeIntegrationController.getStripeConfiguration() ;
        if(stripeConfig!=null){
            return stripeConfig.public_Key__c;
        }
        return null;
    }
    
    
}