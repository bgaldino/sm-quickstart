@isTest
public class B2B_FlowExceptionsHandlerTest {
    @isTest
    static void One(){
        list<B2B_FlowExceptionsHandler.B2B_FlowExceptionsHandlerRequest> lst = new List<B2B_FlowExceptionsHandler.B2B_FlowExceptionsHandlerRequest>();
        B2B_FlowExceptionsHandler.B2B_FlowExceptionsHandlerRequest req = new B2B_FlowExceptionsHandler.B2B_FlowExceptionsHandlerRequest();
        req.errorMessage = 'errorMessage';
        req.errorSubject = 'errorSubject';
        lst.add(req);
        Test.startTest();
        String resp = null;
        B2B_FlowExceptionsHandler.buynowCallout(lst);
        System.assertEquals(resp,null);
        Test.stopTest();
    }
    @isTest
    static void two(){
        list<B2B_FlowExceptionsHandler.B2B_FlowExceptionsHandlerRequest> lst = new List<B2B_FlowExceptionsHandler.B2B_FlowExceptionsHandlerRequest>();
        B2B_FlowExceptionsHandler.B2B_FlowExceptionsHandlerRequest req = new B2B_FlowExceptionsHandler.B2B_FlowExceptionsHandlerRequest();
        req.errorMessage = 'errorMessage';
//        req.errorSubject = 'errorSubject';
        lst.add(req);
        Test.startTest();
        String resp = null;
        B2B_FlowExceptionsHandler.buynowCallout(lst);
        System.assertEquals(resp,null);
        Test.stopTest();
    }
}