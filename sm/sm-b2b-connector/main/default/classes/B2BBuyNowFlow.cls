/**
 * @description       : 
 * @author            : Raja Patnaik
 * @group             : 
 * @last modified on  : 03-03-2022
 * @last modified by  : Raja Patnaik
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   03-03-2023   Raja Patnaik  Initial Version
**/
@RestResource(urlMapping='/B2B_BuyNowRestService/')
global class B2BBuyNowFlow {
 
    @HttpPost
    global static void startB2BBuyNowFlow(String smOrderId,String paymentGatewayId,String paymentMethodId){
    
        try{
            Map<String, Object> flowInput = new Map<String, Object>();
            flowInput.put('smOrderId', smOrderId);
            flowInput.put('paymentGatewayId', paymentGatewayId);
            flowInput.put('paymentMethodId', paymentMethodId);
           
                Flow.Interview.Cybersecurity_SM_CheckOut intiateB2Bflow = new Flow.Interview.Cybersecurity_SM_CheckOut(flowInput);
                intiateB2Bflow.start();
            
          
        }
        catch(Exception ex){
            System.debug('ex ' +ex);
            MessageLog__c log1 = new MessageLog__c(Message__c = 'B2BBuyNowFlow ERR', MessageLong__c = ex.getMessage() + ' || ' + ex.getStackTraceString());
            insert log1;
        } 
       
    }
    
 
 }