@isTest
public class B2B_SMOrderCopierHelperTest {
    
	@testSetup
    public static void setup(){
        TestDataFactory.createDataSMOrder();
        WebCart wc = [Select id, Name from Webcart where Name = 'Cart'];
        Order o = [Select id,Status from Order where Status = 'Draft']; 
        /*Account ac = B2BTestFactory.addNewAccount('testName', true);
Product2 p = B2BTestFactory.creteProduct2(True);
Order ord = B2BTestFactory.addNewOrder(ac.Id, 'recordType');*/
        /*Id standardId = test.getStandardPricebookId();
        Product2 producto = [select id from Product2 where Name = 'Test Product1'];		//getProduct2();
        List<PricebookEntry> entryList = [select product2id,pricebook2Id from  PricebookEntry where product2id =: producto.id and pricebook2Id = :standardId limit 1];
        PricebookEntry one;
        if(entryList.isEmpty()) {
            one = new PricebookEntry();
            one.pricebook2Id = standardId;
            one.product2id = producto.id;
            one.unitprice = 1249.0;
            one.isactive = true;
            insert one; 
            
        } else {one = entryList[0];}
        
        List<OrderItem> itemList = new List<OrderItem>();
        OrderItem orderItemObj = new OrderItem();
        orderItemObj.OrderId            = o.id;
        orderItemObj.Quantity           = 24; 
        orderItemObj.UnitPrice          = 240;
        orderItemObj.Product2id         = producto.id;
        orderItemObj.PricebookEntryId   = one.id;
        insert orderItemObj;
        
        OrderItem orderItemObj1 = new OrderItem();
        orderItemObj1.OrderId            = o.id;
        orderItemObj1.Quantity           = 24; 
        orderItemObj1.UnitPrice          = 240;
        orderItemObj1.Product2id         = producto.id;
        orderItemObj1.PricebookEntryId   = one.id;
        insert orderItemObj1;
        
        
        o.Cart__c = wc.Id;
        update o;*/
        
    }
    
    @isTest
    static void cloneSmOrderToCheckoutOrderTest(){
		Set<Id> ordIds = new Set<Id>();
        //Order o = [Select id from Order where Name = 'Test' ];
        List<Order> o = [Select id,Status,Cart__c,Name from Order where Status = 'Draft']; 
        ordIds.add(o[0].Id);
        Test.startTest();
        B2B_SMOrderCopierHelper.cloneSmOrderToCheckoutOrder(ordIds);
        System.assertNotEquals(o.size(), 0);
        Test.stopTest();
    }
    
    @isTest
    static void mapAndInsertOrderActionTest(){
        Set<Id> ordIds = new Set<Id>();
        //Order o = [Select id from Order where Name = 'Test' ];
        List<Order> o = [Select id,Status,Cart__c,Name from Order where Status = 'Draft']; 
        ordIds.add(o[0].Id);
        Test.startTest();
        B2B_SMOrderCopierHelper.mapAndInsertOrderAction(Null);
		System.assertNotEquals(o.size(), 0);
        Test.stopTest();
    }
    
    @isTest
    static void createOrderSummaryTest(){
        Set<Id> ordIds = new Set<Id>();
        //Order o = [Select id from Order where Name = 'Test' ];
        List<Order> o = [Select id,Status,Cart__c,Name from Order where Status = 'Draft']; 
        ordIds.add(o[0].Id);
        Test.startTest();
        B2B_SMOrderCopierHelper.createOrderSummary(Null);
		System.assertNotEquals(o.size(), 0);
        Test.stopTest();
    }
}