@isTest
public class B2B_CreateUserAccessTokenTest {
	@isTest
    public static void B2B_CreateUserAccessTokenTestMethod()
    {
        test.startTest();
        
      String res1 = B2B_CreateUserAccessToken.getAdminAccessToken();//getAccessToken();
        System.assertEquals('accessToken', res1);
        test.stopTest();
        
    }
    @isTest
    public static void B2B_CreateUserAccessTokenTestMethod2()
    {
        test.startTest();
        
      String res1 = B2B_CreateUserAccessToken.getAccessToken();
        System.assertEquals('accessToken', res1);
        test.stopTest();
        
    }
}