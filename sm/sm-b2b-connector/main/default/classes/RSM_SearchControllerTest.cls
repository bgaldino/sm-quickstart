@isTest
public class RSM_SearchControllerTest {
    @TestSetup static void method(){
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account Acc = B2BTestFactory.addNewAccount('TestAccount', True);
            WebStore WebStore =B2BTestFactory.addNewWebStore();
            User u= B2BTestFactory.addNewUser();
            Product2 proParentCertification = new Product2(
                IsActive = true,
                Name = 'Parent Certification',
                CurrencyIsoCode = 'USD',
                Family = 'Syndicated',
                ProductCode = 'CERTIFICATION'
            );    
            insert proParentCertification;
        }
    }

    @isTest static void search(){
        String networkId = Network.getNetworkId();
        String productToSearch = [SELECT Id FROM Product2 Where  Name = 'Parent Certification' LIMIT 1].Id;
        Account Acc = [Select Id from Account Where Name ='TestAccount'];
        String CommunityId =Network.getNetworkId();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RSM_SearchControllerMock());
        RSM_SearchController.productSearch(networkId,productToSearch,Acc.Id);
        System.assertEquals(CommunityId, networkId);
        Test.stopTest();
        
    }
}