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

@RestResource(urlMapping='/B2B_BuyNowRestServiceRenewal/')
global with sharing class B2BuyNowFlowRenewal {

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.ASSET_RENEWAL);

        /**
         * Calls Subscription management renewal flow to create/Update the asset and Invoices.
         * 
        **/
        @HttpPost
        global static void startB2BBuyNowFlow(String b2bOrderId,String paymentGatewayId,String paymentMethodId){
        
            try{
                Map<String, Object> flowInput = new Map<String, Object>();
                flowInput.put('b2bOrderId', b2bOrderId);
                flowInput.put('paymentGatewayId', paymentGatewayId);
                flowInput.put('paymentMethodId', paymentMethodId);
                
                    Flow.Interview.SM_Renewal_Checkout intiateB2Bflow = new Flow.Interview.SM_Renewal_Checkout(flowInput);
                    intiateB2Bflow.start();
                } catch(Exception e) {
                    logger.error(e);
                    throw new AuraHandledException(e.getMessage());
                } finally {
                    logger.flush();
                }

        }
    }