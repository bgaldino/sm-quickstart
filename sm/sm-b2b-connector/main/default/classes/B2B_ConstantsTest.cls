@isTest
public class B2B_ConstantsTest {

    @isTest
    public static void PermissionSetTest(){
        Test.startTest();
        B2B_Constants ob = new B2B_Constants();
        test.stopTest();
    }
    
    @isTest
    public static void PermissionSetTest2(){
        Test.startTest();
        B2B_Constants.PermissionSet p = B2B_Constants.PermissionSet;
        test.stopTest();
    }
    
    @isTest
    public static void B2BFlowTest(){
        Test.startTest();
        B2B_Constants.B2BFlow p = B2B_Constants.B2BFlow;
        test.stopTest();
    }
    
    @isTest
    public static void SObjectTypeTest(){
        Test.startTest();
        B2B_Constants.SObjectType p = B2B_Constants.SObjectType;
        test.stopTest();
    }
}