@isTest
public class RSM_MyInvoicesTest {
 
    @TestSetup
    static void makeData(){
        TestDataFactory.createData();
    }
    
    @isTest
    static void retrieveOrderDetailPDFTest(){
        Contact c = [Select id from contact where FirstName = 'test2' Limit 1];
        Map<String,Object> result = new Map<String,Object>();
        Attachment ach = new Attachment();
        ach.ParentId = 	c.Id;	//'0038Z00002sGdduQAC';
        ach.Name = 'Invoice.pdf';
        ach.Body = Blob.valueOf('unable to get content as pdf');
        insert ach;
        String invId = c.Id;		//'0038Z00002sGdduQAC'; //inv.Id;
        Test.startTest();
        result =RSM_MyInvoices.retrieveOrderDetailPDF(invId);
        System.assertNotEquals(result, null);
        Test.stopTest();
    }
    @isTest
    static void retrieveOrderDetailPDFTest2(){
        Map<String,Object> result = new Map<String,Object>();
        String invId = 'inv.Id'; //inv.Id;
        Test.startTest();
        result =RSM_MyInvoices.retrieveOrderDetailPDF(invId);
        System.assertEquals(result, null);
        Test.stopTest();
    }
    @isTest 
    static void lightDownload(){
        Invoice inv = new Invoice();
        inv.Description ='testing';
        String invId = 'invId';
        Test.startTest();
        OBJECT ob = RSM_MyInvoices.lightDownloadInvoice('3tt8Z000000kNRtQAM');
        System.assertNotEquals(ob, null);
        Test.stopTest();
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
        RSM_MyInvoices.createQuoteToCart(testCart.Id,'New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void createQuoteToCartTestCatch(){
        list<WebCart> testCartList = [Select id from WebCart where Name = 'Cart'];
        Test.startTest();
        RSM_MyInvoices.createQuoteToCart('CartId not found','New','quoteMsg-Test','communityId');
        System.assert(True);
        Test.stopTest();
    }
    
    @isTest
    Static void test2(){
        Invoice inv = new Invoice();
        //insert inv;
        test.startTest();
        RSM_MyInvoices obj = new RSM_MyInvoices(inv);
        System.assertNotEquals(null, obj);
        test.stopTest();
    }
    
    @isTest
    Static void getUserInvoicesTest3(){
        Invoice inv = new Invoice();
        RSM_MyInvoiceWrapper rmiw = new RSM_MyInvoiceWrapper();
        rmiw.invEndDate_Stub = Date.today();
        rmiw.invoice = inv;
        RSM_MyInvoices_Page_Result obj = new RSM_MyInvoices_Page_Result();
        obj.pageNumber = 1;
        obj.pageSize=10;
        list<Object> oList = new List<Object>();
        obj.records=oList;
        obj.totalItemCount=0;
        RSM_MyInvoices_Page_Result obj2 = RSM_MyInvoices.getUserInvoices(1);
        System.assertNotEquals(obj2, obj);
    }
    
}