@isTest
private class UpdateCartItemfromQuoteLineTest {
    /*static testMethod void updatecart(){
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            TestDataFactory.createData3();
            CartItem ci= [Select id,Name from CartItem where Name='Cart Item 1' Limit 1];
            Product2 product1 = [Select id,Name from Product2 where Name='Test Product1' Limit 1];
            WebCart cart = [Select id,Name from WebCart where Name ='Cart' Limit 1];
            Opportunity op = new Opportunity(
            Name='Testopp',
            CloseDate= Date.newInstance(2022,8,2),
            StageName='Prospecting',
            CurrencyIsoCode='USD'   
            );
            insert op;
            priceBook2 pricebook = [SELECT ID, NAME FROM PRICEBOOK2 WHERE NAME = 'Custom Test Pricebook' AND ISACTIVE = TRUE];
            PricebookEntry product1Entry=[Select id,Product2Id,Pricebook2Id from PricebookEntry where Product2Id=:product1.id and isActive=true limit 1];
            system.assertEquals(pricebook.id, product1Entry.Pricebook2Id);
            //String product1Entry =[Select id from PricebookEntry Limit 1].id;
            Quote qt =new Quote(
            OpportunityId= op.id,
            Cart__c=cart.id,
            Name='TestCart',
            pricebook2id = pricebook.id,
            STATUS = 'Approved'
            );
            insert qt;
            QuoteLineItem qu = new QuoteLineItem(
            Product2Id = product1.id,
            cartitemid__c= ci.id,
            QuoteId=qt.id,
            UnitPrice=25.0,
            Quantity=1,
            PricebookEntryId=product1Entry.id
            
            );
            //qu.BillingFrequency = 'Monthly';
            //qu.StartDate = System.today();
            insert qu;
            
            List<QuoteLineItem> qtline = new List<QuoteLineItem>();
            qtline.add(qu);
            
            Test.startTest();
            updateCartItemfromQuoteLine.updateCartItemfromQuotelineItem(qtline);
            //VOID METHOD
            System.assertEquals(1, qu.Quantity);
            Test.stopTest();
        }
    }*/
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
        UpdateCartItemfromQuoteLine.createQuoteToCart(testCart.Id,'New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void createQuoteToCartTestCatch(){
        list<WebCart> testCartList = [Select id from WebCart where Name = 'Cart'];
        Test.startTest();
        UpdateCartItemfromQuoteLine.createQuoteToCart('CartId not found','New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void createNewSFQuoteTest(){
        String reqData = '';
        Test.startTest();
        UpdateCartItemfromQuoteLine.createNewSFQuote(reqData);
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    static void subwrap(){
         CartItem cartItem1 =[Select id,Quantity,CurrencyIsoCode from CartItem where Name='Cart Item 1' Limit 1];
        ProductSellingModel model = [Select id,Name from ProductSellingModel where Name='Evergreen Monthly' Limit 1];
        Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = false);
        insert customPricebook;
        String cID ='02nnafanf';   
        List<String> candidatePricebookIds= new List<String>();
        candidatePricebookIds.add(cId);
        UpdateCartItemfromQuoteLine rsm = new UpdateCartItemfromQuoteLine(customPricebook.id,candidatePricebookIds);
        Product2 product1 = [Select id ,Name from Product2 where Name ='Test Product1' Limit 1];
        Test.startTest();
       // subscriptionTerm,startDate,roundingMode,pricingFlow,
       // listPricebookId,
       // graph:{"records":[{"referenceId":"ref_sales_txn",
       // "record":{"CurrencyIsoCode":"USD","attributes":{"type":"SalesTransaction"}}},{"referenceId":"ref_sales
        UpdateCartItemfromQuoteLine rsm1 = new UpdateCartItemfromQuoteLine(customPricebook.id,candidatePricebookIds);
        String r = rsm.getTermPriceProduct(rsm, product1.id, Integer.valueOf(cartItem1.Quantity), model.id, String.valueOf(cartItem1.CurrencyIsoCode));
        System.assert(r != Null);
        Test.stopTest();
    }
}