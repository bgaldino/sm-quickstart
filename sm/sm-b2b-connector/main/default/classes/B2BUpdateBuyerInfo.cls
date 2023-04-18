@RestResource(urlMapping='/B2B_updateBuyerInfo/')
global with sharing class B2BUpdateBuyerInfo {
    private static final DCM_Logger logger = DCM_Logger.getImmediateInstance('BuyerInfo');
 
    @HttpPost
    global static void startB2BUpdateBuyerInfo(String firstName, String lastName, string contactId, string email, string phoneNumber){
        System.debug('firstName: ' + firstName + '; lastName: ' + lastName + '; contactId: ' + contactId + '; email: ' + email + '; phoneNumber: ' + phoneNumber);
        logger.debug('firstName: ' + firstName + '; lastName: ' + lastName + '; contactId: ' + contactId + '; email: ' + email + '; phoneNumber: ' + phoneNumber);
        try{
            Map<String, Object> flowInput = new Map<String, Object>();
            flowInput.put('contactId', contactId);
            flowInput.put('email', email);
            flowInput.put('firstname', firstName);
            flowInput.put('lastname', lastName);
            flowInput.put('phone', phoneNumber);
            // Call  B2B BuyNow flow
            String flowName = RSM_Connector_Configuration__mdt.getInstance('Update_Buyer_Info').key__c;       //'SM_Update_buyer_info';
            //Flow.Interview dynamicInterview = Flow.Interview.createInterview(flowName, flowInput);
            //dynamicInterview.start();
            RSM_Utils.callFlow(B2B_SetupConstants.NAMESPACE,flowName, flowInput);
        } catch (Exception ex) {
            System.debug('exception-- '+ex);
            logger.error(ex);
        } finally {
            logger.flush();
        }
       
    }
    /*
    @HttpPost
    global static void startB2BUpdateBuyerInfo(){
        String req = RestContext.request.requestBody.toString();
        try{
            Map<String, Object> flowInput = new Map<String, Object>();
            flowInput.put('contactId', conId);
            flowInput.put('email', mail);
            flowInput.put('firstname', fname);
            flowInput.put('lastname', lname);
            flowInput.put('phone', phoneNumber);
           
            // Call  B2B BuyNow flow
            String flowName =  'SM_Update_buyer_info';
            Flow.Interview dynamicInterview = Flow.Interview.createInterview(flowName, flowInput);
            dynamicInterview.start();
        } catch (Exception ex) {
        System.debug('exception-- '+ex);
            //logger.error(ex);
        } finally {
            //logger.flush();
        }
       
    }*/
    

 }