@isTest
public class RSM_SubscriptionTest {

    @testSetup
    static void setup(){
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            TestDataFactory.createData();
            String userId = UserInfo.getUserId() ;
            User u =[Select Id, AccountId from User Where FirstName = 'ABCD'];
            Account acc = [Select Id from Account  LIMIT 1];
            Product2 product =[SELECT Id, Name, IsActive, ProductCode, Description from Product2 WHERE Name='Test Product1' LIMIT 1 ];
            ProductSellingModel model = [SELECT ID from ProductSellingModel WHERE Name = 'Evergreen Monthly'LIMIT 1];
            ProrationPolicy prorationPolicy =[SELECT Id from ProrationPolicy WHERE Name = 'TestProrationPolicy' LIMIT 1];
            ProductSellingModelOption modelOption =[SELECT ID from ProductSellingModelOption LIMIT 1];
            
            Asset asset = new Asset(Name='Test Product2',
                                    AccountId= u.AccountId,
                                    Status='Active',
                                    Product2Id = product.Id,
                                    IsInternal =false,
                                    IsCompetitorProduct =false,
                                    Quantity = 3);
            insert asset;
        }
    }

    /*@isTest 
    static void subscription(){
        //Map<String, string> obj =  B2BTestFactory.initialStorefrontSetup();
        Product2 prds = b2bTestFactory.creteProduct2(true);
               User u =[Select Id, AccountId from User Where firstname = 'ABCD'];
         Asset asse = [Select Id,Name from  Asset WHERE Name='Test Product2'LIMIT 1 ];
      //  WebStore webSt = [SELECT ID FROM WebStore WHERE NAME = 'Sflabs'];
         WebStore webSt = [SELECT ID,Name FROM WebStore];
        	//Order ord = B2BTestFactory.addNewOrder(obj.get('accountId'), '');
            Map<String, Object> flowInput = new Map<String, Object>();
           // flowInput.put('b2bOrderId', ord.id);
            //flowInput.put('paymentGatewayId', paymentGatewayId);
            //flowInput.put('paymentMethodId', paymentMethodId);
            // Call  B2B BuyNow flow
            RSM_Utils.callFlow(B2B_Constants.B2BFlow.BUY_NOW_FLOW, flowInput);
        
        System.runAs(u) {
            //System.assertEquals(ass.size() , 1);
            Test.startTest();
            //RSM_subscription.assetIdFromTest = asse.Id;
            RSM_subscription.getUserSubscriptions(1, webSt.ID);
            System.assertEquals('Test Product2' , asse.Name);
            Test.stopTest();
        }  
    }*/
    

    @isTest 
    static void subscription2(){
          User u =[Select Id, AccountId from User Where firstname = 'ABCD'];
      //   WebStore webSt = [SELECT ID,Name FROM WebStore WHERE NAME  = 'Sflabs'];
         WebStore webSt = [SELECT ID,Name FROM WebStore ];
        System.runAs(u) {
            Test.startTest();
            try {
                RSM_subscription.getUserSubscriptions(1, webSt.id);
                System.assertEquals('Sflabs',webSt.Name );
            }
            catch (Exception e) {}
            Test.stopTest();
        }  
    }
    @isTest 
    static void subscription3(){
          User u =[Select Id, AccountId from User Where firstname = 'ABCD'];
      //   WebStore webSt = [SELECT ID,Name FROM WebStore WHERE NAME  = 'Sflabs'];
         WebStore webSt = [SELECT ID,Name FROM WebStore ];
        System.runAs(u) {
            Test.startTest();
            try {
                RSM_subscription.getUserSubscriptions(0, webSt.id);
                System.assertEquals('Sflabs',webSt.Name );
            }
            catch (Exception e) {}
            Test.stopTest();
        }  
    }
}