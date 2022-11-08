@isTest
public with sharing class CommunityAuthControllerTest {
    public static Map<String, String>  SetData( ){
        
        Map<String, String> response = new Map<String, String>();
        
 
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND UserRoleId != null AND IsActive = true Limit 1];
        
        Account Acc = new Account();
        Acc.Name = 'ACCOUNT_TEST_NAME';
        Acc.Type = 'Customer';
        Acc.ShippingCountry = 'United States';
        Acc.ShippingState = 'Alabama';
        Acc.ShippingPostalCode = '12345';
        Acc.BillingStreet  = 'Cambridge';
        Acc.BillingCity   = 'Cambridge';
        Acc.BillingCountry   = 'United States';
        insert Acc;
        
        ContactPointAddress cpa = new ContactPointAddress();
        cpa.Name='Test CPA';
        cpa.AddressType='Billing';
        cpa.Street='TestStreet';
        cpa.City='TestCity';
        cpa.State='Alabama';
        cpa.Country='United States';
        cpa.PostalCode='10013';
        cpa.IsDefault=true;
        cpa.ParentId= Acc.id;        
        insert cpa;  
        ContactPointAddress cpa1 = new ContactPointAddress();
        cpa1.Name='Test CPA';
        cpa1.AddressType='Shipping';
        cpa1.Street='TestStreet';
        cpa1.City='TestCity';
        cpa1.State='Alabama';
        cpa1.Country='United States';
        cpa1.PostalCode='10013';
        cpa1.IsDefault=true;
        cpa1.ParentId= Acc.Id;        
        insert cpa1;    
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.Email = 'test@test.com';
        con.AccountId = Acc.Id;
        insert con;    
        
        BuyerAccount buyrAcc = new BuyerAccount();
        buyrAcc.Name = Acc.Name;
        buyrAcc.BuyerId = Acc.Id;
        buyrAcc.IsActive = true;
        insert buyrAcc;  
        BuyerGroup buyGrp = new BuyerGroup();
        //buyGrp.Name = B2BUtils.getRegistrationBuyerGroupName();
        buyGrp.Name='Test Buyer Group';
        insert buyGrp;
        BuyerGroupMember buyGrpMem = new BuyerGroupMember();
        buyGrpMem.BuyerId = Acc.Id;
        buyGrpMem.BuyerGroupId = buyGrp.Id;
        insert buyGrpMem;            
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = :B2BConstants.PROFILE_NAME LIMIT 1];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + RandomId;
        
        User uu = new User(firstname = 'ABC',
                           lastName = 'XYZ',
                           email = uniqueName + '@test' + orgId + '.org',
                           Username = uniqueName + '@test' + orgId + '.org',
                           EmailEncodingKey = 'ISO-8859-1',
                           Alias = uniqueName.substring(18, 23),
                           TimeZoneSidKey = 'America/Los_Angeles',
                           LocaleSidKey = 'en_US',
                           LanguageLocaleKey = 'en_US',
                           CommunityNickname = 'nickName',
                           IsActive = True,
                           ProfileId = pf.Id,
                           ContactId = con.Id,
                           PortalRole = 'Manager'
                          
                          );
        insert uu;
       
        System.debug(uu);
        string password='123$EE';
          String userId = Site.createPortalUser(uu, Acc.Id, password, true);
        response.put('accountId', Acc.Id);
        
       
        response.put('Ufirstname', uu.firstname);
         
        response.put('ulastName', uu.lastName);
      
        response.put('uUsername', uu.Username);
         
        response.put('Uemail', uu.email);
      
        response.put('uCommunityNickname', uu.CommunityNickname);
        
         system.debug(response);

        return response;
       
    }
   
    @isTest 
    public static void TestCommunityAuthController()
    {
        Map<String, String> Data= SetData( );
        system.debug('data'+ Data);
        string Password1='123$EE';
        test.startTest();
        string Str=  CommunityAuthController.registerUser(Data.get('Ufirstname'),
                                     Data.get('ulastName'),
                                     Data.get('uUsername'),
                                     Data.get('Uemail'),
                                     Data.get('uCommunityNickname'),
                                     Password1);
        System.assertEquals(null, Str); 
        test.stopTest();
    }
   
     @isTest
    public static void TestNegNickCommunityName()
    {
        try{ Map<String, String> Data= SetData( );
        system.debug('data'+ Data);
        string Password1='123$EE';
        test.startTest();
        string Str=  CommunityAuthController.registerUser(Data.get('Ufirstname'),
                                     Data.get('ulastName'),
                                     Data.get('uUsername'),
                                     Data.get('Uemail'),
                                     'Nic',
                                     Password1);
         test.stopTest();}
        Catch(Exception e){
            System.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
        
       
    }
    @isTest
    public static void TestNullNickCommunityName()
    {
        try{ Map<String, String> Data= SetData( );
            // Profile p = [Select Id from Profile WHERE Name = 'B2B Lightning Community Plus'];
            user usr=[select id from user where lastName = 'XYZ'];
       /*
        usr.FirstName = 'Test User';
        usr.LastName = 'Number One';
        usr.Email = 'testing222111@sesaco.com';
        usr.Username = 'testing222111@sesaco.com';
        usr.Alias = 'tester';
        //usr.ContactId = con.Id;
        usr.ProfileId = p.Id;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
*/
        System.runAs(usr){
            
             test.startTest();
            List<User> UserNicknameList = new List<user>();
              for(User usr1 : [Select Id, CommunityNickname From User Where CommunityNickname != null]){
                  usr1.CommunityNickname=null;
               UserNicknameList.add(usr1);
                 
            }
            update UserNicknameList;
        system.debug('data'+ Data);
        string Password1='123$EE';
       
        string Str=  CommunityAuthController.registerUser(Data.get('Ufirstname'),
                                     Data.get('ulastName'),
                                     Data.get('uUsername'),
                                     Data.get('Uemail'),
                                     'NickName',
                                     Password1);
            test.stopTest();}}
        Catch(Exception e){
            System.assertNotEquals('Attempt to de-reference a null object', e.getMessage());
        }
           
       
    }
    
     @isTest
    public static void TestElseCommunityPasswordNull()
    {
        try{ Map<String, String> Data= SetData( );
            // Profile p = [Select Id from Profile WHERE Name = 'B2B Lightning Community Plus'];
            user usr=[select id from user where lastName = 'XYZ'];
       /*
        usr.FirstName = 'Test User';
        usr.LastName = 'Number One';
        usr.Email = 'testing222111@sesaco.com';
        usr.Username = 'testing222111@sesaco.com';
        usr.Alias = 'tester';
        //usr.ContactId = con.Id;
        usr.ProfileId = p.Id;
        usr.TimeZoneSidKey    = 'America/Denver';
        usr.LocaleSidKey      = 'en_US';
        usr.EmailEncodingKey  = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        insert usr;
*/
        System.runAs(usr){
            
             test.startTest();
            List<User> UserNicknameList = new List<user>();
              for(User usr1 : [Select Id, CommunityNickname From User Where CommunityNickname != null]){
                  usr1.CommunityNickname=null;
               UserNicknameList.add(usr1);
                 
            }
            update UserNicknameList;
        system.debug('data'+ Data);
        string Password1=null;
       
        string Str=  CommunityAuthController.registerUser(Data.get('Ufirstname'),
                                     Data.get('ulastName'),
                                     Data.get('uUsername'),
                                     Data.get('Uemail'),
                                     'NickName',
                                     Password1);
            test.stopTest();}}
        Catch(Exception e){
            System.assertNotEquals('Attempt to de-reference a null object', e.getMessage());
        }
           
       
    }
    
    
     @isTest
    public static void TestExceptionRegUser()
    {
        try{ test.startTest();
            string Str1=  CommunityAuthController.registerUser(null,
                                                               null,
                                                               null,
                                                               null,
                                                               null,
                                                               null);
            test.stopTest();}
        Catch(Exception e){
            //System.assertEquals('Attempt to de-reference a null object', e.getMessage());
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
       
    }
     @isTest
    public static void TestNegIsEmailExist()
    {
        try{ test.startTest();
              Boolean isEmailExist1=  CommunityAuthController.isEmailExist('');
            test.stopTest();}
        Catch(Exception e){
            System.assertEquals('Attempt to de-reference a null object', e.getMessage());}
        
       
    }
    @isTest 
    public static void TestIsEmailExist()
    {
        Map<String, String> Data= SetData( );
        test.startTest();
        Boolean isEmailExist=  CommunityAuthController.isEmailExist(Data.get('uUsername') );
        System.assertEquals(true, isEmailExist); 
        test.stopTest();
    }
    
    
    @isTest
    public static void TestlogIn()
    {
        Map<String, String> Data= SetData( );
        test.startTest();
        string DoLogin=  CommunityAuthController.doLogin(Data.get('uUsername'), Data.get('uPassword'));
           System.assertEquals(null, DoLogin);                            
        test.stopTest();
    }
      @isTest
    public static void TestExceptionlogIn()
    {
        try{ test.startTest();
               string DoLogin=  CommunityAuthController.doLogin('',null);

            test.stopTest();}
        Catch(Exception e){
            System.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
        
       
    }
    

}