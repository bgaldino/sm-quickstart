@isTest
private class RSM_RequestForQuoteTest {
    
    @isTest
    static void QuoteTest(){
        Map<String,Object> result = new Map<String,Object>();
        Map<String,Object> expect = new Map<String,Object>();
        expect.put('isSuccess',true);
        TestDataFactory.createData();
        
        String cartType='New';
        String quoteMsg='This is the new Quote';
        //String communtiyId=[Select id from Network limit 1].id;
         WebCart testCart = [Select id from WebCart where Name = 'Cart'];
        String cartId=testCart.id;
        /*Pricebook2 prBook = [Select id, Name from Pricebook2 where Name = 'Custom Test Pricebook'];
        prBook.Name = 'Alpine Price Book';
        update prBook;*/
        
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
        result = RSM_requestForQuote.requestForAQuotes(cartId,cartType,quoteMsg,null);
        System.assertEquals(expect, result);
        Test.stopTest();
    }
}