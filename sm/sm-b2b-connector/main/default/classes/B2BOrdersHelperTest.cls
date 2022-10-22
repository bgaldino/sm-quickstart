@isTest
private class B2BOrdersHelperTest {
    
    static testMethod void b2borders(){
        
        TestDataFactory.createData();
        B2BOrderModel result = new B2BOrderModel();
        Account acc= [select id,Name from Account where Name ='Test Account'LIMIT 1];
        Order o = new Order(
            Name='Test Order',
            AccountId=acc.id,
            Status='Draft',
            EffectiveDate=Date.newInstance(2022, 12, 9), 
            Type='None'
        );
        insert o;
        B2BOrderModel expect =new B2BOrderModel();
        expect.accountName  =null;
        expect.createdDate=null;
        expect.name='Test Order';
        expect.namedPlace=null;
        expect.orderDeliveryMethod=null;
        expect.orderEstimatedDuty=null;
        expect.orderEstimatedShipping=null;
        expect.orderId=o.id;
        expect.orderNumber=null;
        expect.orderSubtotal=null;
        expect.orderTotal=null;
        expect.orderType='None';
        expect.orderedDate=null;
        expect.paymentMethod=null;
        expect.promoCodes=null;
        expect.promoCodesAdded=null;
        expect.shipmentType=null;
        expect.status='Draft';
        expect.totalAmount=null;
        Test.startTest();
        result=B2BOrdersHelper.getB2BOrderModel(o); 
        System.assertNotEquals(expect, result);
        Test.stopTest();  
    }
}