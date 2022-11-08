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
}