@isTest
public class DaoServiceTest {
    @TestSetup static void service() {
         
         Account acc = new Account();
            acc.Name = 'ACCOUNT_TEST_NAME';
            acc.Type = 'Customer';
            acc.ShippingCountry = 'United States';
            acc.ShippingState = 'Alabama';
            acc.ShippingPostalCode = '12345';
            acc.BillingStreet  = 'Cambridge';
            acc.BillingCity   = 'Cambridge';
            acc.BillingCountry   = 'United States';
            insert acc;
              Schema.sObjectType t = Account.sObjectType;// Returns token for the account object
              Schema.DescribeSObjectResult D = Account.sObjectType.getDescribe();
    }
@isTest
    static void method1() {    
        List<String> fieldList = new List<String>();
        fieldList.add('Name');
        fieldList.add('id');
        Account acc =[Select Id from Account LIMIT 1];
        Schema.sObjectType sotype = Account.sObjectType; 
             Test.startTest();
        DaoService.getSobjectById( acc.Id,fieldList,sotype);
        System.assertNotEquals(null, acc);
        Test.stopTest();
               }
    
    }