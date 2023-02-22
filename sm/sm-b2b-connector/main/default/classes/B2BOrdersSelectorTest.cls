@isTest 
public class B2BOrdersSelectorTest {

    static  Map<String,Object> dataMap;

    static void setupData(){
        Account acc = B2BTestFactory.addNewAccount(B2BTestFactory.ACCOUNT_TEST_NAME,true);
        B2BTestFactory.creteProduct2(true);
        Order orderObj = B2BTestFactory.addNewOrder(acc.Id,null);
        dataMap = new Map<String,Object>();
        dataMap.put(B2BConstants.ORDER, orderObj);
    }

    @isTest
    static void getOrderDetailsTest() {
        setupData();
        Order expectedOrder = (Order)dataMap.get(B2BConstants.ORDER);
        Test.startTest();
        Order returnOrder = B2BOrdersSelector.getOrderDetails(expectedOrder.Id);
        Test.stopTest();
        Assert.areEqual(expectedOrder.Id,returnOrder.Id,'Expected Order and return order should be same.');

    }

    @isTest
    static void getOrderByStatusTest() {
        setupData();
        Order expectedOrder = (Order)dataMap.get(B2BConstants.ORDER);
        Test.startTest();
        Map<String, Object> mapParam = new Map<String, Object>{
            'limit' => 10,
            'offset' => 0,
            'selectedStatus' => '',
            'filterText' => 'NO ORDER FOUND'
        };
        List<Order> returnOrders = B2BOrdersSelector.getOrderByStatus(mapParam);
        Test.stopTest();
        Assert.areEqual(0,returnOrders.size(),'Expected zero order return as status is blank.');

    }

    @isTest
    static void getCountDataTest() {
        setupData();
        Order expectedOrder = (Order)dataMap.get(B2BConstants.ORDER);
        Test.startTest();
        Map<String, Object> mapParam = new Map<String, Object>{
            'limit' => 10,
            'offset' => 0,
            'selectedStatus' => '',
            'filterText' => 'NO ORDER FOUND'
        };
        Integer returnOrderCount = B2BOrdersSelector.getCountData(mapParam);
        Test.stopTest();
        Assert.areEqual(0,returnOrderCount,'Expected zero order return as status is blank.');

    }

    @isTest
    static void getAccountIdTest() {
        Test.startTest();
        String accountId = B2BOrdersSelector.getAccountId(UserInfo.getUserId());
        Test.stopTest();
        Assert.areEqual(true,String.isBlank(accountId),'Expected blank accountId as Context is of admin User.');

    }
}