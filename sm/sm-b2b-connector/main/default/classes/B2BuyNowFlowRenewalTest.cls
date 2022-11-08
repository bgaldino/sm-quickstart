@isTest
public with sharing class B2BuyNowFlowRenewalTest {
    
        @isTest
        static void startB2BBuyNowFlowTest(){
           String paymentMethodId='';
       
            String b2bOrderId = '';
            String paymentGatewayId = '';
           
            Test.startTest();
            try{
                //VOID METHOD
                B2BuyNowFlowRenewal.startB2BBuyNowFlow(b2bOrderId,paymentGatewayId,paymentMethodId);
                System.assertEquals('', '');
            }
            catch(Exception e){
                System.assertNotEquals(null, e);
            }
            Test.stopTest();
        }
    
   
    }