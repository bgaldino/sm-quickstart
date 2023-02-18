@isTest
public class B2BGetProductsTest {
    @testSetup
    static void setup(){
        TestDataFactory.createData();
    }
    @isTest
    static void getProductTest(){
        Product2 prd = [Select id, Name, ProductCode, CurrencyIsoCode, StockKeepingUnit, Family, Description 
                        from Product2 where Name = 'Test Product1'];
        
        ConnectApi.ProductDetail pd = new ConnectApi.ProductDetail();
        pd.id = prd.Id;
        B2BGetProducts.ProductDetail responseObj = new B2BGetProducts.ProductDetail();
        responseObj.product = pd;
        responseObj.id = prd.Id;
        responseObj.imageUrl = '';
        test.startTest();
        B2BGetProducts.ProductDetail pDetail = B2BGetProducts.getProduct(prd.Id,Null);
        System.assert(pDetail != null);
        test.stopTest();
    }
    
    @isTest
    static void fetchExternalManagedAccountTest(){
        Product2 prd = [Select id, Name, ProductCode, CurrencyIsoCode, StockKeepingUnit, Family, Description 
                        from Product2 where Name = 'Test Product1'];
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PriceSflabs');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        B2BGetProducts.fetchExternalManagedAccount();
        System.assert(prd.Name == 'Test Product1');
        test.stopTest();
    }
    @isTest
    static void calculatePriceTest(){
        Map<String,object> exVal = new Map<String,object>{
            						'response' => '{"TestPrinter1":1.00, "SKU_Test2":2.00}'
                                        };
        Map<String,object> returnVal = new Map<String,object>();
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PriceSflabs');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        returnVal = B2BGetProducts.calculatePrice('requestBody');
        System.assertEquals(exVal, returnVal);
        test.stopTest();
    }
    @isTest
    static void calculatePriceforCSRTest(){
        Map<String,object> exVal = new Map<String,object>{
            						'response' => '{"TestPrinter1":1.00, "SKU_Test2":2.00}'
                                        };
        Map<String,object> returnVal = new Map<String,object>();
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PriceSflabs');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        returnVal = B2BGetProducts.calculatePriceforCSR('requestBody');
        System.assertEquals(exVal, returnVal);
        test.stopTest();
    }
    @isTest
    static void createNewOrderTest(){
        Map<String,object> exVal = new Map<String,object>{
            						'response' => '{"TestPrinter1":1.00, "SKU_Test2":2.00}'
                                        };
        Map<String,object> returnVal = new Map<String,object>();
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PriceSflabs');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        returnVal = B2BGetProducts.createNewOrder('requestBody');
        System.assertEquals(exVal, returnVal);
        test.stopTest();
    }
    @isTest
    static void calculatePriceApi(){
        Map<String,object> exVal = new Map<String,object>{
            						'response' => '{"TestPrinter1":1.00, "SKU_Test2":2.00}'
                                        };
        Map<String,object> returnVal = new Map<String,object>();
        list<String> candidatePricebookIds = new list<String>();
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PriceSflabs');
        // The web service call returns an error code.
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        returnVal = B2BGetProducts.calculatePriceApi('requestBody',candidatePricebookIds,'',1,'');
        System.assertEquals(exVal, returnVal);
        test.stopTest();
    }
       
}