@isTest
public class B2B_HomeFeaturedProductTest {
  
   public static testMethod void one(){
        List<Product2> prList = new List<Product2>();
        Product2 p = new Product2(
        Feature1__c='One',
        Feature2__c='Two',
        Feature3__c='Three',
        Feature4__c='Four',
        Feature5__c='Five',
        Name='Product1',
        ProductCode='P11',
        CurrencyIsoCode='USD',
        StockKeepingUnit='SKU01',
        Family='None',
        description='Product is Nice',
        isActive=true,
        Is_Featured_Product__c =true
        
        );
        prList.add(p);
        insert prList;
       List<B2B_HomeFeaturedProduct.ProductWrapper> pro = new List<B2B_HomeFeaturedProduct.ProductWrapper>();
       List<Product2> pro1 =[Select Id, Feature1__c, Feature3__c,Feature4__c, Feature5__c, Feature2__c,Name, ProductCode,CurrencyIsoCode, StockKeepingUnit, Family, Description from Product2 where Name='Product1' limit 1];
       Test.startTest();
       pro = B2B_HomeFeaturedProduct.getFeaturedProducts();
       System.assertEquals(pro1.size(), pro.size());
       Test.stopTest(); 
    }
    @isTest
    static void Firstexceptiontesting(){
        List<B2B_HomeFeaturedProduct.ProductWrapper> actual = new List<B2B_HomeFeaturedProduct.ProductWrapper>();
        List<B2B_HomeFeaturedProduct.ProductWrapper> expected = new List<B2B_HomeFeaturedProduct.ProductWrapper>();
        Test.startTest();
        actual=B2B_HomeFeaturedProduct.getFeaturedProducts();
        System.assertEquals(expected, actual);
        Test.stopTest();
    }
     @isTest 
    static void two(){
        List<Product2> prList = new List<Product2>();
        Product2 p = new Product2(
        Feature1__c='One',
        Feature2__c='Two',
        Feature3__c='Three',
        Feature4__c='Four',
        Feature5__c='Five',
        Name='Product1',
        ProductCode='P11',
        CurrencyIsoCode='USD',
        StockKeepingUnit='SKU01',
        Family='None',
        description='Product is Nice',
        isActive=true,
        Is_Featured_Product__c =true
        
        );
        prList.add(p);
        insert prList;
        ProductSellingModel psm = new ProductSellingModel(
        Name='PSM',
        PricingTerm=1,
        PricingTermUnit='Months',
        SellingModelType ='Evergreen',
        Status='Active'
        );
        insert psm; 
        ProrationPolicy prorationPolicy2 = new ProrationPolicy(RemainderStrategy = 'AddToFirst',
                                                               ProrationPolicyType = 'StandardTimePeriods',
                                                               Name = 'Term ProrationPolicy');
        insert prorationPolicy2;
        ProductSellingModelOption modelOption = new ProductSellingModelOption(
            Product2Id = p.Id,
            ProductSellingModelId = psm.Id,
            ProrationPolicyId = prorationPolicy2.Id
        );
        
        insert modelOption;
        Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = false);
        insert customPricebook;
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId,
                                                      IsActive = false);
        PricebookEntry pe = new PricebookEntry(
        UnitPrice=45,
        ProductSellingModelId=psm.Id,
        Product2Id=p.Id,
        IsActive = true,
        Pricebook2Id=standardPricebook.Id
        );
       insert pe;
        Decimal result;
        Decimal expected = 45.00;
        B2B_HomeFeaturedProduct.ProductDetailResponse onbj = new B2B_HomeFeaturedProduct.ProductDetailResponse();
        onbj.prodImageUrl = 'prodImageUrl';
        onbj.isPriceAlreadyAvailable = true;
        onbj.isProductCompared = false;
        onbj.pricingInfo = String.valueOf('abs');
        onbj.isRecurring = true;
        onbj.prodName = 'prodName';
        onbj.prodId = 'prodId';
        onbj.prodDescription = 'prodDescription';
        onbj.pricebookEntryId = 'pricebookEntryId';
        onbj.unitPrice = 'unitPrice';
        onbj.listPrice = 'listPrice';
        Test.startTest();
        result=B2B_HomeFeaturedProduct.getProductPrice(p.id);
        System.assertEquals(expected, result);
        Test.stopTest();  
    }
}