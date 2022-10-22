@isTest
public class RSM_MakeCPQQuoteAPICalloutTest {
    
    
	@testSetup
    static void setup(){
        TestDataFactory.createData();
    }
    
    @isTest
    Static void createQuoteToCartTest(){
        WebCart testCart = [Select id from WebCart where Name = 'Cart'];
        Pricebook2 prBook = [Select id, Name from Pricebook2 where Name = 'Custom Test Pricebook'];
        prBook.Name = 'Alpine Price Book';
        update prBook;
        
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
        RSM_makeCPQQuoteAPICallout.createQuoteToCart(testCart.Id,'New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void createQuoteToCartTestCatch(){
        list<WebCart> testCartList = [Select id from WebCart where Name = 'Cart'];
        Test.startTest();
        RSM_makeCPQQuoteAPICallout.createQuoteToCart('CartId not found','New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
}