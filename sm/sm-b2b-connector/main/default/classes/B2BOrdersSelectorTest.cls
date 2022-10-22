@isTest 
public class B2BOrdersSelectorTest {
    @TestSetup   static void method1(){
        B2BTestFactory.addNewUser();
        List<String> statusList =  new List<string>();
        statusList.add('Draft');
        statusList.add('Active');
        TestDataFactory.createData();
        Account a =[Select id from Account WHERE  Name = 'Test Account' LIMIT 1];
        Product2 p =[Select id from Product2 LIMIT 1];
        Order orderTest = new Order(Name = 'Test Order',
                                    Status = 'Draft',
                                    EffectiveDate = system.today(),
                                    EndDate = system.today() + 4,
                                    CurrencyIsoCode = 'USD',
                                    AccountId = a.id);
        insert orderTest;
        OrderItem testOrderItem = new OrderItem(OrderId = orderTest.id,
                                                Quantity = 24,
                                                UnitPrice = 240,
                                                ListPrice = 240,
                                                Product2Id = p.id);
        insert testOrderItem;
    }
    @isTest static void DefaultField(){
        Set<String> mySet = new Set<String>();
        mySet.add('Test');
        mySet.add('Test1');
        Test.startTest();
        B2BOrdersSelector.getDefaultFields();
        System.assert(mySet.contains('Test'));
        Test.stopTest();
    }
    @isTest static void AllField(){
        Set<String> retSet = new Set<String>();
        retSet.add('Test');
        retSet.add('Test1');
        Test.startTest();
        B2BOrdersSelector.getAllFields();
        System.assert(retSet.contains('Test1'));
        Test.stopTest();
    }
    @isTest static void QueryField(){
        String exp ='Selected';
        Test.startTest();
        B2BOrdersSelector.getQueryFieldString();
        System.assertNotEquals(exp,   B2BOrdersSelector.getQueryFieldString());
        Test.stopTest();
    }
    @isTest static void Querywhere(){
        String uId = UserInfo.getUserId();
        Account ac =[Select id from Account WHERE  Name = 'Test Account'];
        User u =[Select id,AccountId,userType from User WHERE Id=:uId];
        String accId = u.AccountId;
        Order o = [Select Id from Order WHERE Name = 'Test Order' LIMIT 1];
        Map<String, Order> map1 = new Map<String, Order>();
        map1.put('statusList',o);
         map1.put('myOrderOnly',o);
          map1.put('filterText',o);
          Test.startTest();
        B2BOrdersSelector.getQueryWhere(map1);
        System.assertEquals(accId, u.AccountId);
        Test.stopTest();
    }
    @isTest static void OrderByStatus(){
        User u =[Select id,AccountId from User WHERE firstname ='ABC'];
        Account ac =[Select id from Account WHERE Id =:u.AccountId];
        Order o = [Select Id from Order WHERE Name ='Test Order' LIMIT 1];
        Map<String, Object> map1 = new Map<String, Object>();
        map1.put('selectedStatus',o.Id);
        map1.put('limit',1);
        map1.put('offset',0);
         Order[] order = new List<Order>(); 
        order.add( new Order(
            Name='Pens',
            Description='Red pens'));
        order.add( new Order(
            Name='Notebooks',
            Description='Cool notebooks'));
        System.runAs(u) {
            Test.startTest();
            B2BOrdersSelector.getOrderByStatus(map1);
            System.assertEquals('Notebooks', order[1].Name);
            System.assertEquals('Pens', order[0].Name);
            Test.stopTest();
        }
    }
    @isTest static void CountData(){
        Integer exp= 1;
        Order ord =[Select Id,name from Order LIMIT 1];
        User u =[Select id,AccountId,userType from User WHERE firstname = 'ABC'];
        Account ac =[Select id from Account WHERE Id =:u.AccountId];
        Order order = [Select Id from Order where Name = 'Test Order'LIMIT 1];
        Map<String, Object> map1 = new Map<String, Object>();
        map1.put('selectedStatus',order.id);
        map1.put('limit',1);
        map1.put('offset',0);
        System.runAs(u) {
            Test.startTest();
            B2BOrdersSelector.getCountData(map1);
            System.assertNotEquals(ord, order);
               Test.stopTest();
        }
    }
    @isTest static void AccountId(){
        String accountId = null;
        Account ac =[Select id from Account WHERE  Name = 'Test Account'];
        User u =[Select id from User WHERE firstname = 'ABC'];
        Test.startTest();
        B2BOrdersSelector.getAccountId(u.Id);
        System.assertEquals(null, accountId);
        Test.stopTest();
    }
    @isTest static void OrderId(){
        Order o =[Select id ,Name from Order where Name='Test Order' LIMIT 1];
        List<OrderSummary> currentos = new List<OrderSummary>();
        Test.startTest();
        B2BOrdersSelector.getOrderDetails(o.Id);
        System.assertNotEquals(null, o.id);
        Test.stopTest();
    }
    @isTest static void RecordTypeName(){
        Order o =[Select id ,Name from Order where Name='Test Order' LIMIT 1];
        List<OrderSummary> currentos = new List<OrderSummary>();
        Test.startTest();
        B2BOrdersHelper.getRecordTypeNameById(o.Id);
         System.assertNotEquals(null, o.id);
        Test.stopTest();
    }
}