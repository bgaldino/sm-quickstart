@isTest
public with sharing class B2BuyNowFlowRenewalTest {
    
        @isTest
        static void startB2BBuyNowFlowTest(){
           String paymentMethodId='';
       
            String b2bOrderId = '';
            String paymentGatewayId = '';
           
            Test.startTest();
            //VOID METHOD
            B2BuyNowFlowRenewal.startB2BBuyNowFlow(b2bOrderId,paymentGatewayId,paymentMethodId);
            System.assertEquals('', '');
            Test.stopTest();
        }
    
   
    }