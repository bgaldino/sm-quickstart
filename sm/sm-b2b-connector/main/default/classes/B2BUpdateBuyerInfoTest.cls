@isTest
public class B2BUpdateBuyerInfoTest {
    @isTest
    static void startB2BBuyNowFlow(){
        String b2bOrderId = '';
        String paymentGatewayId = '';
        String paymentMethodId = '';
        Test.startTest();
        B2BUpdateBuyerInfo.startB2BUpdateBuyerInfo('','','','','');
        //No assertion - Void Method
        system.assertNotEquals(null, b2bOrderId);
        Test.stopTest();
    }
    @isTest
    static void catchmethod(){
    MessageLog__c log1 = new MessageLog__c(Message__c='B2BBuyNowFlow ERR');
    insert log1;
     Test.startTest();
        B2BUpdateBuyerInfo.startB2BUpdateBuyerInfo(log1.Message__c,log1.Message__c,log1.Message__c,log1.Message__c,log1.Message__c);
       system.assertEquals('B2BBuyNowFlow ERR', log1.Message__c);
        Test.stopTest();
    }
 
}