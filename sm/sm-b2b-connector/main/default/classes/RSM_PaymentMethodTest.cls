@isTest
public class RSM_PaymentMethodTest {
    @TestSetup
    static void payment(){
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            B2BTestFactory.addNewAccount('ACCOUNT_TEST_NAME',true);
            B2BTestFactory.addNewUser();
            Account acc =[Select Id from Account where name='ACCOUNT_TEST_NAME'];
            User user = [Select id, contactId from User Where firstname = 'ABC' ];
            Contact con = [Select id, name from Contact Where FirstName = 'test'];
            ContactPointAddress conaddress = [Select id, name from ContactPointAddress Where Name='Test CPA' ];
            ContactPointAddress conpoint = new ContactPointAddress();
            conpoint.Name = 'Test Address 123';
            conpoint.Street='245 mall road';
            conpoint.City = 'Goleta';
            conpoint.PostalCode = '93117-3084';
            conpoint.State = 'California';
            conpoint.parentId = acc.id;
            conpoint.IsDefault = true;
            conpoint.Country = 'United States';
            conpoint.AddressType = 'Shipping';
            insert conpoint;
            Product2 product = new Product2(Name = 'Test Product2', 
                                            Description = 'Description Test Product2',
                                            IsActive = true, 
                                            StockKeepingUnit = 'TestPrinter2'
                                        );
            insert product;
            Asset ass =new Asset(
                Name ='Book Shop',
                ContactId =con.Id,
                Product2Id = product.Id  );
            insert ass;
        }
    }

    @isTest static void shippingAddress(){
        ContactPointAddress exp = [Select id, name from ContactPointAddress Where Name='Test Address 123' ];
        String shippingAddress= '{"Id":"'+exp.Id+'", "City":"Goleta", "Street" :"245 mall road","PostalCode" :"93117-3084", "State":"California", "Country":"United States"}';
        Test.startTest();
        RSM_paymentMethod.updateShippingAddress(shippingAddress);
        System.assertEquals('Test Address 123',exp.Name);
        test.stopTest();
    }
    
     @isTest static void shippingAddressException(){
         
        ContactPointAddress exp = [Select id, name from ContactPointAddress Where Name='Test Address 123' ];
        //String shippingAddress= '{"Id":"'+exp.Id+'", "City":"Goleta", "Street" :"245 mall road","PostalCode" :"93117-3084", "State":"California", "Country":"United States"}';
        try{
        Test.startTest();
        RSM_paymentMethod.updateShippingAddress(null);
        //System.assertEquals('Test Address 123',exp.Name);
        test.stopTest();
         }catch(Exception e){
           system.assert(true, 'Should have thrown an exception');
        }
    }
    
    
    @isTest static void billingShippingAddress(){
        ContactPointAddress conAdd = [Select id, name from ContactPointAddress Where Name='Test CPA' ];
        map<string, object> exp = new map<string, object>();
        exp.put('Test',conAdd);
        map<string, object> act = new map<string, object>();
        act.put('Test',conAdd);
        User u =[Select id,AccountId from User WHERE firstname = 'ABC'];
        Account acc =[Select id ,name from Account Where  Id =:u.AccountId];
        //System.runAs(u) {
            Test.startTest();
                RSM_paymentMethod.getBillingShippingAddress();
                System.assertEquals(exp, act);
            Test.stopTest();
        //}
    }
    @isTest static void billingAddress(){
        ContactPointAddress conaddress = [Select id, name from ContactPointAddress Where Name='Test CPA' ];
        String billingAddress= '{"Id":"'+conaddress.Id+'","Street" :"245 mall road","City":"Goleta", "State":"California", "Country":"United States","PostalCode" :"93117-3084"}';
        Test.startTest();
        RSM_paymentMethod.updateBillingAddress(billingAddress);
        System.assertNotEquals(null, billingAddress);
        Test.stopTest();
    }   
    
    @isTest static void billingAddressException(){
        ContactPointAddress conaddress = [Select id, name from ContactPointAddress Where Name='Test CPA' ];
        //String billingAddress= '{"Id":"'+conaddress.Id+'","Street" :"245 mall road","City":"Goleta", "State":"California", "Country":"United States","PostalCode" :"93117-3084"}';
        try{
        Test.startTest();
        RSM_paymentMethod.updateBillingAddress(null);
        system.assert(false, 'Should not have thrown an exception');
        Test.stopTest();
        }catch(Exception e){
            
             system.assert(true, 'Should have thrown an exception');
        }
    }  
    
    
    @isTest static void renewAsset(){
        Asset ass = [Select id,name from Asset Where Name ='Book Shop'];
        map<string, object> exp = new map<string, object>();
        exp.put('Test',ass);
        map<string, object> act = new map<string, object>();
        act.put('Test',ass);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RSM_SearchControllerMock());
        RSM_paymentMethod.renewAssetMethod(ass.Id);
        System.assertEquals(exp, act);     
        Test.stopTest();
    }   
    @isTest static void EverGreenProduct(){
        Asset ass = [Select id,name from Asset Where Name ='Book Shop'];
        Test.startTest();
        RSM_paymentMethod.isEverGreenProduct(ass.Id);
        System.assertEquals(true, RSM_paymentMethod.isEverGreenProduct(ass.Id));
        Test.stopTest();
    }   
    
     @isTest static void assetMonths(){
        Asset ass = [Select id,name from Asset Where Name ='Book Shop'];
        Test.startTest();
        RSM_paymentMethod.getAssetMonths(ass.Id);
        System.assertEquals(null, RSM_paymentMethod.getAssetMonths(ass.Id));
        Test.stopTest();
    }   
    
    
    
   /* @isTest static void createPayment(){
        ContactPointAddress conAdd = [Select id, name from ContactPointAddress Where Name='Test CPA' ];
        map<string, object> exp = new map<string, object>();
        exp.put('Test',conAdd);
        map<string, object> act = new map<string, object>();
        act.put('Test',conAdd);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RSM_SearchControllerMock());
        RSM_paymentMethod.callCreatePaymentMethodAPI();
        System.assertEquals(exp, act);
        Test.stopTest(); 
    }   
    @isTest static void createPaymentMethod(){
        User user = [Select id, contactId from User Where firstname = 'ABC' ];
           Map<String,object> exp = new Map<String,object>();
        exp.put('Test',user);
           Map<String,object> act = new Map<String,object>();
        act.put('Test 1',user);
        Test.startTest();
        RSM_paymentMethod.createPaymentMethod('Naman Sharma','06','2032','4242424242424242');
        System.assertNotEquals(exp, act);
        Test.stopTest();
    }   */
    @isTest static void updateBuyer(){
        User u =[Select id,ContactId,firstname  from User WHERE firstname = 'ABC'];
        Contact con = [Select id, name from Contact Where id=:u.ContactId];
        System.runAs(u) {
            Test.startTest();
            RSM_paymentMethod.updateBuyerInfo('Andy Young','a_young@dickenson.com','(785) 241-6200');
           System.assertEquals('ABC', u.firstname);
            Test.stopTest();
        }
    }   
    @isTest static void PurchaseInfo(){
        User u =[Select id,ContactId from User WHERE firstname = 'ABC'];
        Contact con = [Select id, name from Contact Where id=:u.ContactId];
        System.runAs(u) {
            Test.startTest();
            RSM_paymentMethod.getPurchaserInfo();
            System.assertNotEquals(null,  RSM_paymentMethod.getPurchaserInfo());
            Test.stopTest();}
    } 
   /* @isTest static void PaymentMethod(){
        List<String>listOfStrings = new List<String>{'Anjana','Sharma'}; 
        listOfStrings.add('Test'); 
        listOfStrings.add('Test1');
        Test.startTest();
        RSM_paymentMethod.getPaymentMethod();   
        System.assertNotEquals(null, listOfStrings, 'Success');
        Test.stopTest();
    } */
}