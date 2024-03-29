@RestResource(urlMapping='/B2B_BuyNowRestService/')
global with sharing class B2BBuyNowFlow {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CHECKOUT_FLOW);
 
    @HttpPost
    global static void startB2BBuyNowFlow(String smOrderId,String paymentGatewayId,String paymentMethodId){
    
        try{
            logger.debug('inside startB2BBuyNowFlow- '+smOrderId);
            Map<String, Object> flowInput = new Map<String, Object>();
            flowInput.put('smOrderId', smOrderId);
            flowInput.put('paymentGatewayId', paymentGatewayId);
            flowInput.put('paymentMethodId', paymentMethodId);
           
            // Call  B2B BuyNow flow
            logger.debug('inside startB2BBuyNowFlow- '+smOrderId);
            String flowName =  RSM_Connector_Configuration__mdt.getInstance('Buy_now_flow_name').key__c;
            RSM_Utils.callFlow(flowName, flowInput);
            logger.debug('inside startB2BBuyNowFlow flowName- '+flowName);
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
       
    }
    

 }