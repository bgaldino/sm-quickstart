@isTest
public class TestDataFactory {
    public static void createDataSMOrder() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account account = new Account(Name = 'Test Account', 
                                          CurrencyIsoCode = 'USD'
                                         );
            insert account;
            
            String networkId = Network.getNetworkId();
            
            ContactPointAddress contactPointAddress = new ContactPointAddress(
                Name = 'Europe Address',
                ParentId = account.Id,
                AddressType = 'Billing',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Ciney',
                PostalCode = '5590',
                Country = 'Belgium',
                CountryCode = 'BE'
            );
            insert contactPointAddress;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId,
                                                          IsActive = true);
            
            Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = true);
            insert customPricebook;
            
            WebStore webStore = new WebStore(Name = 'Sflabs', 
                                             SupportedLanguages = 'en_US', 
                                             DefaultLanguage = 'en_US',
                                             StrikethroughPricebookId = pricebookId
                                            );
            insert webStore;    
            
            WebStorePricebook webStorePricebook = new WebStorePricebook(WebStoreId = webStore.Id, Pricebook2Id = customPricebook.Id, IsActive = true);
            insert webStorePricebook;
            
            Order order = new Order(Name = 'Test Order ', Status = 'Draft', EffectiveDate = system.today(), EndDate = system.today() + 365, AccountId = account.id, Pricebook2Id = pricebookId);
            insert order;
            
            WebCart cart = new WebCart(Name = 'Cart', 
                                       WebStoreId = webStore.Id, 
                                       AccountId = account.Id, 
                                       CurrencyIsoCode = 'USD',
                                       PoNumber = '6794',
                                       BillingStreet = 'Street',
                                       BillingCity = 'New York',
                                       BillingState = 'New York',
                                       BillingPostalCode = '34562',
                                       BillingCountry = 'United States',
                                       BillingLatitude = 40.730610,
                                       BillingLongitude = -73.935242
                                      );
            insert cart;
            B2B_Shipping_Address__c shippingAddress = new B2B_Shipping_Address__c(Cart__c = cart.Id,
                                                                                  Street__c = 'Street', 
                                                                                  Country__c = 'United States', 
                                                                                  City__c = 'New York', 
                                                                                  Postal_Code__c = '34562', 
                                                                                  State__c = 'New York', 
                                                                                  Name = 'Test'
                                                                                 );
            insert shippingAddress;
            CartCheckoutSession checkoutSession1 = new CartCheckoutSession (
                Name = 'Checkout Session 1',
                CurrencyIsoCode = cart.CurrencyIsoCode,
                WebCartId = cart.Id,
                State = 'Shipping',
                NextState = '',
                IsProcessing = false,
                IsArchived = false,
                IsError = false
            );
            insert checkoutSession1;
            
            ProrationPolicy prorationPolicy = new ProrationPolicy(RemainderStrategy = 'AddToFirst',
                                                                  ProrationPolicyType = 'StandardTimePeriods',
                                                                  Name = 'TestProrationPolicy');
            insert prorationPolicy;
            
            ProductSellingModel model = new ProductSellingModel(PricingTerm = 1,
                                                                PricingTermUnit = 'Months',
                                                                Name = 'Evergreen Monthly',
                                                                SellingModelType = 'Evergreen',
                                                                Status = 'Active'
                                                               );
            insert model;
            
            Product2 product1 = new Product2(Name = 'Test Product1', 
                                             Description = 'Description Test Product1',
                                             IsActive = true, 
                                             StockKeepingUnit = 'TestPrinter1'
                                            );
            insert product1;
            
            
            ProductSellingModelOption modelOption = new ProductSellingModelOption(
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                ProrationPolicyId = prorationPolicy.Id
            );
            insert modelOption;
            
            PricebookEntry product1Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 300.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1Entry;
            
            OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod(Name = 'Test Delivery Method', 
                                                                                  ProductId = product1.id);
            insert testOrderDeliveryMethod;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                CurrencyIsoCode = 'USD',
                DeliverToCountryCode = 'US',
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'TEst',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;
            
            Product2 product2 = new Product2(Name = 'Test Product2', 
                                             Description = 'Description Test Product2',
                                             IsActive = true, 
                                             StockKeepingUnit = 'TestPrinter2'
                                            );
            insert product2;
            PricebookEntry product2Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product2.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product2Entry;
            
            Product2 product3 = new Product2(Name = 'Test Product Add on', 
                                             Description = 'Add on product',
                                             IsActive = true, 
                                             StockKeepingUnit = 'TestPrinter3'
                                            );
            insert product3;
            Related_Product__c relatedProduct1 =  new Related_Product__c(Product__c = product1.Id, 
                                                                         Sequence__c = 1, 
                                                                         Related_Product__c = product2.Id,
                                                                         Related_Product_Relation_Type__c = 'Related', 
                                                                         Related_Product_Type__c = 'CrossSell', 
                                                                         Enabled__c = true
                                                                        );
            insert relatedProduct1;
            Related_Product__c relatedProductAddOn =  new Related_Product__c(Product__c = product1.Id, 
                                                                             Sequence__c = 1, 
                                                                             Related_Product__c = product3.Id,
                                                                             Related_Product_Relation_Type__c = 'Related', 
                                                                             Related_Product_Type__c = 'Accessories', 
                                                                             Enabled__c = true
                                                                            );
            insert relatedProductAddOn;
            
            CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = product1.StockKeepingUnit,
                Name = 'Cart Item 1',
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Quantity = 2.0,
                Product2Id = product1.Id,
                CurrencyIsoCode = 'USD',
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                B2B_PriceBookEntry_Id__c = product1Entry.Id, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0
            );
            insert cartItem1;
            
            CartTax tax = new CartTax( 
                Amount = 100,
                CartItemId = cartItem1.Id,
                Name = 'Cart Tax',
                TaxCalculationDate = Date.today(),
                TaxRate = 10,
                TaxType = 'Estimated'
            );
            insert tax;
        }
    }
    
    public static void createData() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account account = new Account(
                
                Name = 'Test Account', 
                CurrencyIsoCode = 'USD'
            );
            insert account;
            
            Contact con = new Contact();
            con.FirstName = 'test2';
            con.LastName = 'contact2';
            con.Email = 'test2@test.com';
            con.AccountId = account.Id;
            insert con;    
            
            BuyerAccount buyrAcc = new BuyerAccount();
            buyrAcc.Name = account.Name;
            buyrAcc.BuyerId = account.Id;
            buyrAcc.IsActive = true;
            insert buyrAcc;  
            BuyerGroup buyGrp =  new BuyerGroup(name='Test buyer Group');
            // buyGrp.Name = B2BUtils.getRegistrationBuyerGroupName();
            insert buyGrp;
            
            
            
            
            BuyerGroupMember buyGrpMem = new BuyerGroupMember();
            buyGrpMem.BuyerId = account.Id;
            buyGrpMem.BuyerGroupId = buyGrp.Id;
            insert buyGrpMem;            
            
            Profile pf = [SELECT Id FROM Profile WHERE Name = :B2BConstants.PROFILE_NAME LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            User uu = new User(firstname = 'ABCD',
                               lastName = 'Test',
                               email = uniqueName + '@test2' + orgId + '.org',
                               Username = uniqueName + '@test2' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick2',
                               IsActive = True,
                               ProfileId = pf.Id,
                               ContactId = con.Id,
                               PortalRole = 'Manager'
                              );
            insert uu;
            
            
            
            
            //String networkId = Network.getNetworkId();
            String networkId='0DM8c000000sxg1';
            ContactPointAddress contactPointAddress = new ContactPointAddress(
                Name = 'Europe Address',
                ParentId = account.Id,
                AddressType = 'Billing',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Ciney',
                PostalCode = '5590',
                Country = 'Belgium',
                CountryCode = 'BE'
            );
            insert contactPointAddress;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true
            );
            
            Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = true);
            insert customPricebook;
            
            WebStore webStore = new WebStore(
                Name = 'Sflabs', 
                SupportedLanguages = 'en_US', 
                DefaultLanguage = 'en_US',
                StrikethroughPricebookId = pricebookId
            );
            insert webStore;    
            
            WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
            webStrBuyerGrp.WebStoreId = webStore.Id;
            webStrBuyerGrp.BuyerGroupId = buyGrp.Id;
            insert webStrBuyerGrp;
            WebStorePricebook webStorePricebook = new WebStorePricebook(WebStoreId = webStore.Id, Pricebook2Id = customPricebook.Id, IsActive = true);
            insert webStorePricebook;
            
            Order order = new Order(Name = 'Test Order ', Status = 'Draft', EffectiveDate = system.today(), EndDate = system.today() + 365, AccountId = account.id, Pricebook2Id = pricebookId);
            insert order;
            
            WebCart cart = new WebCart(
                Name = 'Cart', 
                WebStoreId = webStore.Id, 
                AccountId = account.Id, 
                CurrencyIsoCode = 'USD',
                PoNumber = '6794',
                BillingStreet = 'Street',
                BillingCity = 'New York',
                BillingState = 'New York',
                BillingPostalCode = '34562',
                BillingCountry = 'United States',
                BillingLatitude = 40.730610,
                BillingLongitude = -73.935242,
                jobId__c=null
            );
            insert cart;
            
            B2B_Shipping_Address__c shippingAddress = new B2B_Shipping_Address__c(
                Cart__c = cart.Id,
                Street__c = 'Street', 
                Country__c = 'United States', 
                City__c = 'New York', 
                Postal_Code__c = '34562', 
                State__c = 'New York', 
                Name = 'Test'
            );
            insert shippingAddress;
            
            CartCheckoutSession checkoutSession1 = new CartCheckoutSession (
                Name = 'Checkout Session 1',
                CurrencyIsoCode = cart.CurrencyIsoCode,
                WebCartId = cart.Id,
                State = 'Shipping',
                NextState = '',
                IsProcessing = false,
                IsArchived = false,
                IsError = false
            );
            insert checkoutSession1;
            
            ProrationPolicy prorationPolicy = new ProrationPolicy(
                RemainderStrategy = 'AddToFirst',
                ProrationPolicyType = 'StandardTimePeriods',
                Name = 'TestProrationPolicy'
            );
            insert prorationPolicy;
            
            ProductSellingModel model = new ProductSellingModel(
                PricingTerm = 1,
                PricingTermUnit = 'Months',
                Name = 'Evergreen Monthly',
                SellingModelType = 'Evergreen',
                Status = 'Active'
            );
            insert model;
            
            ProductCatalog catalog1 = new ProductCatalog(
                Name = 'Test Catalog 1'
            );
            insert catalog1;
            
            ProductCategory category1 = new ProductCategory(
                Name = 'Test Category 1',
                CatalogId = catalog1.Id
            );
            insert category1;
            
            Product2 product1 = new Product2(
                Name = 'Test Product1', 
                Description = 'Description Test Product1',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter1'
                
            );
            insert product1;
            
            ProductSellingModelOption modelOption = new ProductSellingModelOption(
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                ProrationPolicyId = prorationPolicy.Id
            );
            insert modelOption;
            
            PricebookEntry product1Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 300.0,
                IsActive = false,
                UseStandardPrice = false
            );
            insert product1Entry;
            
            OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod(
                Name = 'Test Delivery Method', 
                ProductId = product1.id
            );
            insert testOrderDeliveryMethod;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                CurrencyIsoCode = 'USD',
                DeliverToCountryCode = 'US',
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'TEst',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;
            
            Product2 product2 = new Product2(
                Name = 'Test Product2', 
                Description = 'Description Test Product2',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter2'
            );
            insert product2;
            
            PricebookEntry product1CustomEntry = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1CustomEntry;
            
            Product2 product3 = new Product2(
                Name = 'Test Product Add on', 
                Description = 'Add on product',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter3'
            );
            insert product3;
            
            ProductCategoryProduct pcp1 = new ProductCategoryProduct(
                ProductCategoryId = category1.Id,
                ProductId = product2.Id
            );
            insert pcp1;
            
            ProductCategoryProduct pcp2 = new ProductCategoryProduct(
                ProductCategoryId = category1.Id,
                ProductId = product3.Id
            );
            insert pcp2;
            
            Related_Product__c relatedProduct1 =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product2.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'CrossSell', 
                Enabled__c = true
            );
            insert relatedProduct1;
            
            Related_Product__c relatedProductAddOn =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product3.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'Accessories', 
                Enabled__c = true
            );
            insert relatedProductAddOn;
            
            CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = product1.StockKeepingUnit,
                Name = 'Cart Item 1',
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Quantity = 2.0,
                Product2Id = product1.Id,
                CurrencyIsoCode = 'USD',
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                B2B_PriceBookEntry_Id__c = product1CustomEntry.Id, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0
            );
            insert cartItem1;
            Asset asset =new Asset(
                Name ='Book Shop',
                AccountId= account.Id,
                ContactId =con.Id,
                Product2Id = product1.Id
            );
            insert asset;    
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = account.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = customPricebook.Id;
            //orderObj.RecordTypeId       = recordTypeId;
            Insert orderObj;
        }
    }
    
    public static void createData2() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account account = new Account(
                
                Name = 'Test Account', 
                CurrencyIsoCode = 'USD'
            );
            insert account;
            
            Contact con = new Contact();
            con.FirstName = 'test2';
            con.LastName = 'contact2';
            con.Email = 'test2@test.com';
            con.AccountId = account.Id;
            insert con;    
            
            BuyerAccount buyrAcc = new BuyerAccount();
            buyrAcc.Name = account.Name;
            buyrAcc.BuyerId = account.Id;
            buyrAcc.IsActive = true;
            insert buyrAcc;  
            BuyerGroup buyGrp =  new BuyerGroup(name='Test buyer Group');
            // buyGrp.Name = B2BUtils.getRegistrationBuyerGroupName();
            insert buyGrp;
            
            
            
            
            BuyerGroupMember buyGrpMem = new BuyerGroupMember();
            buyGrpMem.BuyerId = account.Id;
            buyGrpMem.BuyerGroupId = buyGrp.Id;
            insert buyGrpMem;            
            
            Profile pf = [SELECT Id FROM Profile WHERE Name = :B2BConstants.PROFILE_NAME LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            User uu = new User(firstname = 'ABC',
                               lastName = 'Test',
                               email = uniqueName + '@test2' + orgId + '.org',
                               Username = uniqueName + '@test2' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick2',
                               IsActive = True,
                               ProfileId = pf.Id,
                               ContactId = con.Id,
                               PortalRole = 'Manager'
                              );
            insert uu;
            
            
            
            
            String networkId = Network.getNetworkId();
            
            ContactPointAddress contactPointAddress = new ContactPointAddress(
                Name = 'Europe Address',
                ParentId = account.Id,
                AddressType = 'Billing',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Ciney',
                PostalCode = '5590',
                Country = 'Belgium',
                CountryCode = 'BE'
            );
            insert contactPointAddress;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = false
            );
            
            Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = false);
            insert customPricebook;
            
            WebStore webStore = new WebStore(
                Name = 'Sflabs', 
                SupportedLanguages = 'en_US', 
                DefaultLanguage = 'en_US',
                StrikethroughPricebookId = pricebookId
            );
            insert webStore;    
            
            WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
            webStrBuyerGrp.WebStoreId = webStore.Id;
            webStrBuyerGrp.BuyerGroupId = buyGrp.Id;
            insert webStrBuyerGrp;
            WebStorePricebook webStorePricebook = new WebStorePricebook(WebStoreId = webStore.Id, Pricebook2Id = customPricebook.Id, IsActive = true);
            insert webStorePricebook;
            
            WebCart cart = new WebCart(
                Name = 'Cart', 
                WebStoreId = webStore.Id, 
                AccountId = account.Id, 
                CurrencyIsoCode = 'USD',
                PoNumber = '6794',
                BillingStreet = 'Street',
                BillingCity = 'New York',
                BillingState = 'New York',
                BillingPostalCode = '34562',
                BillingCountry = 'United States',
                BillingLatitude = 40.730610,
                BillingLongitude = -73.935242,
                jobId__c=null
            );
            insert cart;
            
            B2B_Shipping_Address__c shippingAddress = new B2B_Shipping_Address__c(
                Cart__c = cart.Id,
                Street__c = 'Street', 
                Country__c = 'United States', 
                City__c = 'New York', 
                Postal_Code__c = '34562', 
                State__c = 'New York', 
                Name = 'Test'
            );
            insert shippingAddress;
            
            CartCheckoutSession checkoutSession1 = new CartCheckoutSession (
                Name = 'Checkout Session 1',
                CurrencyIsoCode = cart.CurrencyIsoCode,
                WebCartId = cart.Id,
                State = 'Shipping',
                NextState = '',
                IsProcessing = false,
                IsArchived = false,
                IsError = false
            );
            insert checkoutSession1;
            
            ProrationPolicy prorationPolicy = new ProrationPolicy(
                RemainderStrategy = 'AddToFirst',
                ProrationPolicyType = 'StandardTimePeriods',
                Name = 'TestProrationPolicy'
            );
            insert prorationPolicy;
            
            ProductSellingModel model = new ProductSellingModel(
                PricingTerm = 1,
                PricingTermUnit = 'Months',
                Name = 'Evergreen Monthly',
                SellingModelType = 'Evergreen',
                Status = 'Active'
            );
            insert model;
            
            Product2 product1 = new Product2(
                Name = 'Test Product1', 
                Description = 'Description Test Product1',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter1'
                
            );
            insert product1;
            
            ProductSellingModelOption modelOption = new ProductSellingModelOption(
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                ProrationPolicyId = prorationPolicy.Id
            );
            insert modelOption;
            
            PricebookEntry product1Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 300.0,
                IsActive = false,
                UseStandardPrice = false
            );
            insert product1Entry;
            
            OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod(
                Name = 'Test Delivery Method', 
                ProductId = product1.id
            );
            insert testOrderDeliveryMethod;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                CurrencyIsoCode = 'USD',
                DeliverToCountryCode = 'US',
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'TEst',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;
            
            Product2 product2 = new Product2(
                Name = 'Test Product2', 
                Description = 'Description Test Product2',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter2'
            );
            insert product2;
            
            PricebookEntry product1CustomEntry = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1CustomEntry;
            
            Product2 product3 = new Product2(
                Name = 'Test Product Add on', 
                Description = 'Add on product',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter3'
            );
            insert product3;
            
            Related_Product__c relatedProduct1 =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product2.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'CrossSell', 
                Enabled__c = true
            );
            insert relatedProduct1;
            
            Related_Product__c relatedProductAddOn =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product3.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'Accessories', 
                Enabled__c = true
            );
            insert relatedProductAddOn;
            
            CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = product1.StockKeepingUnit,
                Name = 'Cart Item 1',
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Quantity = 2.0,
                Product2Id = product1.Id,
                CurrencyIsoCode = 'USD',
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                B2B_PriceBookEntry_Id__c = product1CustomEntry.Id, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0
            );
            insert cartItem1;
            Asset asset =new Asset(
                Name ='Book Shop',
                AccountId= account.Id,
                ContactId =con.Id,
                Product2Id = product1.Id
            );
            insert asset;
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = account.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = customPricebook.Id;
            //orderObj.RecordTypeId       = recordTypeId;
            Insert orderObj;
        }
    }
    
    public static void createTaxEngine() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            TaxTreatment defaultTaxTreatment = new TaxTreatment (
                Name = 'No Tax Treatment',
                Status = 'Active'
            );
            insert defaultTaxTreatment;
            
            TaxPolicy policy = new TaxPolicy(
                Name = 'No Tax', 
                TreatmentSelection = 'LegalEntity', 
                DefaultTaxTreatmentId = defaultTaxTreatment.Id,
                Status = 'Draft');
            insert policy;
            
            defaultTaxTreatment.TaxPolicyId = policy.Id;
            update defaultTaxTreatment;
            
            policy.Status = 'Active';
            update policy;
            
            /*NamedCredential cred = [SELECT id FROM NamedCredential LIMIT 1];
TaxEngineProvider provider = [SELECT id FROM TaxEngineProvider LIMIT 1];
TaxEngine engine = new TaxEngine(
MerchantCredentialId = cred.id, 
Status = 'Active',
SellerCode = '67892',
TaxEngineName = 'Test Engine',
TaxEngineProviderId = provider.Id,
TaxEngineCountry = 'United States',
TaxEngineCity = 'New York', 
TaxEngineState ='New York', 
TaxEngineStreet ='Street',
TaxEnginePostalCode ='34562' 
);
insert engine;

TaxTreatment taxTreatment = new TaxTreatment (
TaxEngineId = engine.Id,
TaxPolicyId = policy.Id,
Name = 'Test Tax Treatment',
IsTaxable = true,
Status = 'Active'
);
insert taxTreatment;*/
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            
            Pricebook2 customPricebook = new Pricebook2(
                Name = 'Custom Price Book',
                IsActive = true
            );
            insert customPricebook;
            
            ProrationPolicy prorationPolicy2 = new ProrationPolicy(
                RemainderStrategy = 'AddToFirst',
                ProrationPolicyType = 'StandardTimePeriods',
                Name = 'Term ProrationPolicy'
            );
            insert prorationPolicy2;
            
            ProductSellingModel termModel = new ProductSellingModel(
                PricingTerm = 1,
                PricingTermUnit = 'Months',
                Name = 'Annual Monthly',
                SellingModelType = 'TermDefined',
                Status = 'Active'
            );
            insert termModel;
            
            Product2 productTerm = new Product2(
                Name = 'Term Product1', 
                Description = 'Term DEfined Test Product1',
                IsActive = true, 
                StockKeepingUnit = 'TermPrinter'
            );
            insert productTerm;
            
            ProductSellingModelOption modelOption2 = new ProductSellingModelOption(
                Product2Id = productTerm.Id,
                ProductSellingModelId = termModel.Id,
                ProrationPolicyId = prorationPolicy2.Id
            );
            insert modelOption2;
            
            PricebookEntry product2Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = productTerm.Id,
                ProductSellingModelId = termModel.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product2Entry;  
            
            PricebookEntry product2CustomEntry = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = productTerm.Id,
                ProductSellingModelId = termModel.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product2CustomEntry;
        }
    }
    
    public static void createData3() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account account = new Account(
                
                Name = 'Test Account', 
                CurrencyIsoCode = 'USD'
            );
            insert account;
            
            Contact con = new Contact();
            con.FirstName = 'test2';
            con.LastName = 'contact2';
            con.Email = 'test2@test.com';
            con.AccountId = account.Id;
            insert con;    
            
            BuyerAccount buyrAcc = new BuyerAccount();
            buyrAcc.Name = account.Name;
            buyrAcc.BuyerId = account.Id;
            buyrAcc.IsActive = true;
            insert buyrAcc;  
            BuyerGroup buyGrp =  new BuyerGroup(name='Test buyer Group');
            // buyGrp.Name = B2BUtils.getRegistrationBuyerGroupName();
            insert buyGrp;
            
            
            
            
            BuyerGroupMember buyGrpMem = new BuyerGroupMember();
            buyGrpMem.BuyerId = account.Id;
            buyGrpMem.BuyerGroupId = buyGrp.Id;
            insert buyGrpMem;            
            
            Profile pf = [SELECT Id FROM Profile WHERE Name = :B2BConstants.PROFILE_NAME LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            User uu = new User(firstname = 'ABCD',
                               lastName = 'Test',
                               email = uniqueName + '@test2' + orgId + '.org',
                               Username = uniqueName + '@test2' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick2',
                               IsActive = True,
                               ProfileId = pf.Id,
                               ContactId = con.Id,
                               PortalRole = 'Manager'
                              );
            insert uu;
            
            
            
            
            //String networkId = Network.getNetworkId();
            String networkId='0DM8c000000sxg1';
            ContactPointAddress contactPointAddress = new ContactPointAddress(
                Name = 'Europe Address',
                ParentId = account.Id,
                AddressType = 'Billing',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Ciney',
                PostalCode = '5590',
                Country = 'Belgium',
                CountryCode = 'BE'
            );
            insert contactPointAddress;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true
            );
            
            Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = true);
            insert customPricebook;
            
            WebStore webStore = new WebStore(
                Name = 'Sflabs', 
                SupportedLanguages = 'en_US', 
                DefaultLanguage = 'en_US',
                StrikethroughPricebookId = pricebookId
            );
            insert webStore;    
            
            WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
            webStrBuyerGrp.WebStoreId = webStore.Id;
            webStrBuyerGrp.BuyerGroupId = buyGrp.Id;
            insert webStrBuyerGrp;
            WebStorePricebook webStorePricebook = new WebStorePricebook(WebStoreId = webStore.Id, Pricebook2Id = customPricebook.Id, IsActive = true);
            insert webStorePricebook;
            
            Order order = new Order(Name = 'Test Order ', Status = 'Draft', EffectiveDate = system.today(), EndDate = system.today() + 365, AccountId = account.id, Pricebook2Id = pricebookId);
            insert order;
            
            WebCart cart = new WebCart(
                Name = 'Cart', 
                WebStoreId = webStore.Id, 
                AccountId = account.Id, 
                CurrencyIsoCode = 'USD',
                PoNumber = '6794',
                BillingStreet = 'Street',
                BillingCity = 'New York',
                BillingState = 'New York',
                BillingPostalCode = '34562',
                BillingCountry = 'United States',
                BillingLatitude = 40.730610,
                BillingLongitude = -73.935242,
                jobId__c=null
            );
            insert cart;
            
            B2B_Shipping_Address__c shippingAddress = new B2B_Shipping_Address__c(
                Cart__c = cart.Id,
                Street__c = 'Street', 
                Country__c = 'United States', 
                City__c = 'New York', 
                Postal_Code__c = '34562', 
                State__c = 'New York', 
                Name = 'Test'
            );
            insert shippingAddress;
            
            CartCheckoutSession checkoutSession1 = new CartCheckoutSession (
                Name = 'Checkout Session 1',
                CurrencyIsoCode = cart.CurrencyIsoCode,
                WebCartId = cart.Id,
                State = 'Shipping',
                NextState = '',
                IsProcessing = false,
                IsArchived = false,
                IsError = false
            );
            insert checkoutSession1;
            
            ProrationPolicy prorationPolicy = new ProrationPolicy(
                RemainderStrategy = 'AddToFirst',
                ProrationPolicyType = 'StandardTimePeriods',
                Name = 'TestProrationPolicy'
            );
            insert prorationPolicy;
            
            ProductSellingModel model = new ProductSellingModel(
                //PricingTerm = 1,
                //PricingTermUnit = 'Months',
                Name = 'One-Time',
                SellingModelType = 'OneTime',
                Status = 'Active'
            );
            insert model;
            
            Product2 product1 = new Product2(
                Name = 'Test Product1', 
                Description = 'Description Test Product1',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter1'
                
            );
            insert product1;
            
            ProductSellingModelOption modelOption = new ProductSellingModelOption(
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id
                //ProrationPolicyId = prorationPolicy.Id
            );
            insert modelOption;
            
            PricebookEntry product1Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 300.0,
                IsActive = false,
                UseStandardPrice = false
            );
            insert product1Entry;
            
            OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod(
                Name = 'Test Delivery Method', 
                ProductId = product1.id
            );
            insert testOrderDeliveryMethod;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                CurrencyIsoCode = 'USD',
                DeliverToCountryCode = 'US',
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'TEst',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;
            
            Product2 product2 = new Product2(
                Name = 'Test Product2', 
                Description = 'Description Test Product2',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter2'
            );
            insert product2;
            
            PricebookEntry product1CustomEntry = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1CustomEntry;
            
            Product2 product3 = new Product2(
                Name = 'Test Product Add on', 
                Description = 'Add on product',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter3'
            );
            insert product3;
            
            Related_Product__c relatedProduct1 =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product2.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'CrossSell', 
                Enabled__c = true
            );
            insert relatedProduct1;
            
            Related_Product__c relatedProductAddOn =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product3.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'Accessories', 
                Enabled__c = true
            );
            insert relatedProductAddOn;
            
            CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = product1.StockKeepingUnit,
                Name = 'Cart Item 1',
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Quantity = 2.0,
                Product2Id = product1.Id,
                CurrencyIsoCode = 'USD',
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                B2B_PriceBookEntry_Id__c = product1CustomEntry.Id, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0
            );
            insert cartItem1;
            Asset asset =new Asset(
                Name ='Book Shop',
                AccountId= account.Id,
                ContactId =con.Id,
                Product2Id = product1.Id
            );
            insert asset;    
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = account.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = customPricebook.Id;
            //orderObj.RecordTypeId       = recordTypeId;
            Insert orderObj;
        }
    }
    
    public static void createTestData() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account account = new Account(
                Name = 'Sample Account', 
                CurrencyIsoCode = 'USD'
            );
            insert account;
            
            Contact con = new Contact();
            con.FirstName = 'Sample';
            con.LastName = 'Contact';
            con.Email = 'sample@test.com';
            con.AccountId = account.Id;
            insert con;    
            
            BuyerAccount buyrAcc = new BuyerAccount();
            buyrAcc.Name = account.Name;
            buyrAcc.BuyerId = account.Id;
            buyrAcc.IsActive = true;
            insert buyrAcc;
            
            BuyerGroup buyGrp =  new BuyerGroup(name='Sample buyer Group');
            insert buyGrp;
            
            BuyerGroupMember buyGrpMem = new BuyerGroupMember();
            buyGrpMem.BuyerId = account.Id;
            buyGrpMem.BuyerGroupId = buyGrp.Id;
            insert buyGrpMem;            
            
            Profile pf = [SELECT Id FROM Profile WHERE Name = :B2BConstants.PROFILE_NAME LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            User uu = new User(
                firstname = 'Sample',
                lastName = 'User',
                email = uniqueName + '@test2' + orgId + '.org',
                Username = uniqueName + '@test2' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                CommunityNickname = 'snick2',
                IsActive = True,
                ProfileId = pf.Id,
                ContactId = con.Id,
                PortalRole = 'Manager'
            );
            insert uu;
            
            ContactPointAddress contactPointAddress = new ContactPointAddress(
                Name = 'Sample Europe Address',
                ParentId = account.Id,
                AddressType = 'Billing',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Ciney',
                PostalCode = '5590',
                Country = 'Belgium',
                CountryCode = 'BE'
            );
            insert contactPointAddress;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true
            );
            
            Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Sample Pricebook', IsActive = true);
            insert customPricebook;
            
            WebStore webStore = [Select Id from WebStore where Name = 'Sflabs'];
            if(null == webStore) {
                webStore = new WebStore(
                    Name = 'Sflabs', 
                    SupportedLanguages = 'en_US', 
                    DefaultLanguage = 'en_US',
                    StrikethroughPricebookId = pricebookId
                );
                insert webStore;
            } 
            
            WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
            webStrBuyerGrp.WebStoreId = webStore.Id;
            webStrBuyerGrp.BuyerGroupId = buyGrp.Id;
            insert webStrBuyerGrp;
            WebStorePricebook webStorePricebook = new WebStorePricebook(WebStoreId = webStore.Id, Pricebook2Id = customPricebook.Id, IsActive = true);
            insert webStorePricebook;
            
            Order order = new Order(Name = 'Sample Order ', Status = 'Draft', EffectiveDate = system.today(), EndDate = system.today() + 365, AccountId = account.id, Pricebook2Id = pricebookId);
            insert order;
            
            WebCart cart = new WebCart(
                Name = 'Sample Cart', 
                WebStoreId = webStore.Id, 
                AccountId = account.Id, 
                CurrencyIsoCode = 'USD',
                PoNumber = '6794',
                BillingStreet = 'Street',
                BillingCity = 'New York',
                BillingState = 'New York',
                BillingPostalCode = '34562',
                BillingCountry = 'United States',
                BillingLatitude = 40.730610,
                BillingLongitude = -73.935242,
                jobId__c=null
            );
            insert cart;
            
            B2B_Shipping_Address__c shippingAddress = new B2B_Shipping_Address__c(
                Cart__c = cart.Id,
                Street__c = 'Street', 
                Country__c = 'United States', 
                City__c = 'New York', 
                Postal_Code__c = '34562', 
                State__c = 'New York', 
                Name = 'Sample Shipping Address'
            );
            insert shippingAddress;
            
            CartCheckoutSession checkoutSession1 = new CartCheckoutSession (
                Name = 'Sample Checkout Session',
                CurrencyIsoCode = cart.CurrencyIsoCode,
                WebCartId = cart.Id,
                State = 'Shipping',
                NextState = '',
                IsProcessing = false,
                IsArchived = false,
                IsError = false
            );
            insert checkoutSession1;
            
            ProrationPolicy prorationPolicy = new ProrationPolicy(
                RemainderStrategy = 'AddToFirst',
                ProrationPolicyType = 'StandardTimePeriods',
                Name = 'SampleProrationPolicy'
            );
            insert prorationPolicy;
            
            ProductSellingModel model = [Select Id from ProductSellingModel where SellingModelType =  'Evergreen'];
            if(null == model) {
                model = new ProductSellingModel(
                    PricingTerm = 1,
                    PricingTermUnit = 'Months',
                    Name = 'Sample Evergreen Monthly',
                    SellingModelType = 'Evergreen',
                    Status = 'Active'
                );
                insert model;
            }
            
            ProductCatalog catalog1 = new ProductCatalog(
                Name = 'Sample Catalog'
            );
            insert catalog1;
            
            ProductCategory category1 = new ProductCategory(
                Name = 'Sample Category',
                CatalogId = catalog1.Id
            );
            insert category1;
            
            Product2 product1 = new Product2(
                Name = 'Sample Product 1', 
                Description = 'Description Test Product1',
                IsActive = true, 
                StockKeepingUnit = 'SamplePrinter1'
            );
            insert product1;
            
            ProductSellingModelOption modelOption = new ProductSellingModelOption(
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                ProrationPolicyId = prorationPolicy.Id
            );
            insert modelOption;
            
            PricebookEntry product1Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 300.0,
                IsActive = false,
                UseStandardPrice = false
            );
            insert product1Entry;
            
            OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod(
                Name = 'Sample Delivery Method', 
                ProductId = product1.id
            );
            insert testOrderDeliveryMethod;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Sample Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                CurrencyIsoCode = 'USD',
                DeliverToCountryCode = 'US',
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'TEst',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;
            
            Product2 product2 = new Product2(
                Name = 'Sample Product 2', 
                Description = 'Description Test Product2',
                IsActive = true, 
                StockKeepingUnit = 'SamplePrinter2'
            );
            insert product2;
            
            PricebookEntry product1CustomEntry = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1CustomEntry;
            
            Product2 product3 = new Product2(
                Name = 'Sample Product Add on', 
                Description = 'Add on product',
                IsActive = true, 
                StockKeepingUnit = 'SamplePrinter3'
            );
            insert product3;
            
            ProductCategoryProduct pcp1 = new ProductCategoryProduct(
                ProductCategoryId = category1.Id,
                ProductId = product2.Id
            );
            insert pcp1;
            
            ProductCategoryProduct pcp2 = new ProductCategoryProduct(
                ProductCategoryId = category1.Id,
                ProductId = product3.Id
            );
            insert pcp2;
            
            Related_Product__c relatedProduct1 =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product2.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'CrossSell', 
                Enabled__c = true
            );
            insert relatedProduct1;
            
            Related_Product__c relatedProductAddOn =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product3.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'Accessories', 
                Enabled__c = true
            );
            insert relatedProductAddOn;
            
            CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = product1.StockKeepingUnit,
                Name = 'Sample Cart Item 1',
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Quantity = 2.0,
                Product2Id = product1.Id,
                CurrencyIsoCode = 'USD',
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                B2B_PriceBookEntry_Id__c = product1CustomEntry.Id, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0
            );
            insert cartItem1;
            Asset asset =new Asset(
                Name ='Sample Book Shop',
                AccountId= account.Id,
                ContactId =con.Id,
                Product2Id = product1.Id
            );
            insert asset;   
            
            Order orderObj = new Order();
            orderObj.Name               = 'Sample Test Order';
            orderObj.AccountId          = account.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = customPricebook.Id;
            //orderObj.RecordTypeId       = recordTypeId;
            Insert orderObj;
        }
    }
    
    public static void createTestData2() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account account = new Account(
                
                Name = 'Test Account', 
                CurrencyIsoCode = 'USD'
            );
            insert account;
            
            Contact con = new Contact();
            con.FirstName = 'test2';
            con.LastName = 'contact2';
            con.Email = 'test2@test.com';
            con.AccountId = account.Id;
            insert con;    
            
            BuyerAccount buyrAcc = new BuyerAccount();
            buyrAcc.Name = account.Name;
            buyrAcc.BuyerId = account.Id;
            buyrAcc.IsActive = true;
            insert buyrAcc;  
            BuyerGroup buyGrp =  new BuyerGroup(name='Test buyer Group');
            // buyGrp.Name = B2BUtils.getRegistrationBuyerGroupName();
            insert buyGrp;
            
            
            
            
            BuyerGroupMember buyGrpMem = new BuyerGroupMember();
            buyGrpMem.BuyerId = account.Id;
            buyGrpMem.BuyerGroupId = buyGrp.Id;
            insert buyGrpMem;            
            
            Profile pf = [SELECT Id FROM Profile WHERE Name = :B2BConstants.PROFILE_NAME LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            User uu = new User(firstname = 'ABC',
                               lastName = 'Test',
                               email = uniqueName + '@test2' + orgId + '.org',
                               Username = uniqueName + '@test2' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick2',
                               IsActive = True,
                               ProfileId = pf.Id,
                               ContactId = con.Id,
                               PortalRole = 'Manager'
                              );
            insert uu;
            
            
            
            
            String networkId = Network.getNetworkId();
            
            ContactPointAddress contactPointAddress = new ContactPointAddress(
                Name = 'Europe Address',
                ParentId = account.Id,
                AddressType = 'Billing',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Ciney',
                PostalCode = '5590',
                Country = 'Belgium',
                CountryCode = 'BE'
            );
            insert contactPointAddress;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = false
            );
            
            Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = false);
            insert customPricebook;
            
            WebStore webStore = new WebStore(
                Name = 'Sflabs', 
                SupportedLanguages = 'en_US', 
                DefaultLanguage = 'en_US',
                StrikethroughPricebookId = pricebookId
            );
            insert webStore;    
            
            //updates. start//
            StoreIntegratedService service = new StoreIntegratedService();
            service.ServiceProviderType='Payment';
            service.StoreId= webStore.Id;
            service.Integration='0b08Z0000004IHPQA2';
            insert service;
            //end here.//
            
            WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
            webStrBuyerGrp.WebStoreId = webStore.Id;
            webStrBuyerGrp.BuyerGroupId = buyGrp.Id;
            insert webStrBuyerGrp;
            WebStorePricebook webStorePricebook = new WebStorePricebook(WebStoreId = webStore.Id, Pricebook2Id = customPricebook.Id, IsActive = true);
            insert webStorePricebook;
            
            WebCart cart = new WebCart(
                Name = 'Cart', 
                WebStoreId = webStore.Id, 
                AccountId = account.Id, 
                CurrencyIsoCode = 'USD',
                PoNumber = '6794',
                BillingStreet = 'Street',
                BillingCity = 'New York',
                BillingState = 'New York',
                BillingPostalCode = '34562',
                BillingCountry = 'United States',
                BillingLatitude = 40.730610,
                BillingLongitude = -73.935242,
                jobId__c=null
            );
            insert cart;
            
            B2B_Shipping_Address__c shippingAddress = new B2B_Shipping_Address__c(
                Cart__c = cart.Id,
                Street__c = 'Street', 
                Country__c = 'United States', 
                City__c = 'New York', 
                Postal_Code__c = '34562', 
                State__c = 'New York', 
                Name = 'Test'
            );
            insert shippingAddress;
            
            CartCheckoutSession checkoutSession1 = new CartCheckoutSession (
                Name = 'Checkout Session 1',
                CurrencyIsoCode = cart.CurrencyIsoCode,
                WebCartId = cart.Id,
                State = 'Shipping',
                NextState = '',
                IsProcessing = false,
                IsArchived = false,
                IsError = false
            );
            insert checkoutSession1;
            
            ProrationPolicy prorationPolicy = new ProrationPolicy(
                RemainderStrategy = 'AddToFirst',
                ProrationPolicyType = 'StandardTimePeriods',
                Name = 'TestProrationPolicy'
            );
            insert prorationPolicy;
            
            ProductSellingModel model = new ProductSellingModel(
                PricingTerm = 1,
                PricingTermUnit = 'Months',
                Name = 'Evergreen Monthly',
                SellingModelType = 'Evergreen',
                Status = 'Active'
            );
            insert model;
            
            Product2 product1 = new Product2(
                Name = 'Test Product1', 
                Description = 'Description Test Product1',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter1'
                
            );
            insert product1;
            
            ProductSellingModelOption modelOption = new ProductSellingModelOption(
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                ProrationPolicyId = prorationPolicy.Id
            );
            insert modelOption;
            
            PricebookEntry product1Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 300.0,
                IsActive = false,
                UseStandardPrice = false
            );
            insert product1Entry;
            
            OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod(
                Name = 'Test Delivery Method', 
                ProductId = product1.id
            );
            insert testOrderDeliveryMethod;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                CurrencyIsoCode = 'USD',
                DeliverToCountryCode = 'US',
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'TEst',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;
            
            Product2 product2 = new Product2(
                Name = 'Test Product2', 
                Description = 'Description Test Product2',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter2'
            );
            insert product2;
            
            PricebookEntry product1CustomEntry = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1CustomEntry;
            
            Product2 product3 = new Product2(
                Name = 'Test Product Add on', 
                Description = 'Add on product',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter3'
            );
            insert product3;
            
            Related_Product__c relatedProduct1 =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product2.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'CrossSell', 
                Enabled__c = true
            );
            insert relatedProduct1;
            
            Related_Product__c relatedProductAddOn =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product3.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'Accessories', 
                Enabled__c = true
            );
            insert relatedProductAddOn;
            
            CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = product1.StockKeepingUnit,
                Name = 'Cart Item 1',
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Quantity = 2.0,
                Product2Id = product1.Id,
                CurrencyIsoCode = 'USD',
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                B2B_PriceBookEntry_Id__c = product1CustomEntry.Id, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0
            );
            insert cartItem1;
            Asset asset =new Asset(
                Name ='Book Shop',
                AccountId= account.Id,
                ContactId =con.Id,
                Product2Id = product1.Id
            );
            insert asset;
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = account.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = customPricebook.Id;
            //orderObj.RecordTypeId       = recordTypeId;
            Insert orderObj;
        }
    }
    
    public static void createData4() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account account = new Account(
                
                Name = 'Test Account', 
                CurrencyIsoCode = 'USD'
            );
            insert account;
            
            Contact con = new Contact();
            con.FirstName = 'test2';
            con.LastName = 'contact2';
            con.Email = 'test2@test.com';
            con.AccountId = account.Id;
            insert con;    
            
            BuyerAccount buyrAcc = new BuyerAccount();
            buyrAcc.Name = account.Name;
            buyrAcc.BuyerId = account.Id;
            buyrAcc.IsActive = true;
            insert buyrAcc;  
            BuyerGroup buyGrp =  new BuyerGroup(name='Test buyer Group');
            // buyGrp.Name = B2BUtils.getRegistrationBuyerGroupName();
            insert buyGrp;
            
            
            
            
            BuyerGroupMember buyGrpMem = new BuyerGroupMember();
            buyGrpMem.BuyerId = account.Id;
            buyGrpMem.BuyerGroupId = buyGrp.Id;
            insert buyGrpMem;            
            
            Profile pf = [SELECT Id FROM Profile WHERE Name = :B2BConstants.PROFILE_NAME LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            User uu = new User(firstname = 'ABCD',
                               lastName = 'Test',
                               email = uniqueName + '@test2' + orgId + '.org',
                               Username = uniqueName + '@test2' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick2',
                               IsActive = True,
                               ProfileId = pf.Id,
                               ContactId = con.Id,
                               PortalRole = 'Manager'
                              );
            insert uu;
            
            
            
            
            //String networkId = Network.getNetworkId();
            String networkId='0DM8c000000sxg1';
            ContactPointAddress contactPointAddress = new ContactPointAddress(
                Name = 'Europe Address',
                ParentId = account.Id,
                AddressType = 'Billing',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Ciney',
                PostalCode = '5590',
                Country = 'Belgium',
                CountryCode = 'BE'
            );
            insert contactPointAddress;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = pricebookId,
                IsActive = true
            );
            
            Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = true);
            insert customPricebook;
            
            WebStore webStore = new WebStore(
                Name = 'Sflabs', 
                SupportedLanguages = 'en_US', 
                DefaultLanguage = 'en_US',
                StrikethroughPricebookId = pricebookId
            );
            insert webStore;    
            
            WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
            webStrBuyerGrp.WebStoreId = webStore.Id;
            webStrBuyerGrp.BuyerGroupId = buyGrp.Id;
            insert webStrBuyerGrp;
            WebStorePricebook webStorePricebook = new WebStorePricebook(WebStoreId = webStore.Id, Pricebook2Id = customPricebook.Id, IsActive = true);
            insert webStorePricebook;
            
            Order order = new Order(Name = 'Test Order ', Status = 'Draft', EffectiveDate = system.today(), EndDate = system.today() + 365, AccountId = account.id, Pricebook2Id = pricebookId);
            insert order;
            
            WebCart cart = new WebCart(
                Name = 'Cart', 
                WebStoreId = webStore.Id, 
                AccountId = account.Id, 
                CurrencyIsoCode = 'USD',
                PoNumber = '6794',
                BillingStreet = 'Street',
                BillingCity = 'New York',
                BillingState = 'New York',
                BillingPostalCode = '34562',
                BillingCountry = 'United States',
                BillingLatitude = 40.730610,
                BillingLongitude = -73.935242,
                jobId__c=null
            );
            insert cart;
            
            B2B_Shipping_Address__c shippingAddress = new B2B_Shipping_Address__c(
                Cart__c = cart.Id,
                Street__c = 'Street', 
                Country__c = 'United States', 
                City__c = 'New York', 
                Postal_Code__c = '34562', 
                State__c = 'New York', 
                Name = 'Test'
            );
            insert shippingAddress;
            
            CartCheckoutSession checkoutSession1 = new CartCheckoutSession (
                Name = 'Checkout Session 1',
                CurrencyIsoCode = cart.CurrencyIsoCode,
                WebCartId = cart.Id,
                State = 'Shipping',
                NextState = '',
                IsProcessing = false,
                IsArchived = false,
                IsError = false
            );
            insert checkoutSession1;
            
            ProrationPolicy prorationPolicy = new ProrationPolicy(
                RemainderStrategy = 'AddToFirst',
                ProrationPolicyType = 'StandardTimePeriods',
                Name = 'TestProrationPolicy'
            );
            insert prorationPolicy;
            
            ProductSellingModel model = new ProductSellingModel(
                PricingTerm = 1,
                PricingTermUnit = 'Months',
                Name = 'Evergreen Monthly',
                SellingModelType = 'Evergreen',
                Status = 'Active'
            );
            insert model;
            
            ProductCatalog catalog1 = new ProductCatalog(
                Name = 'Test Catalog 1'
            );
            insert catalog1;
            
            ProductCategory category1 = new ProductCategory(
                Name = 'Test Category 1',
                CatalogId = catalog1.Id
            );
            insert category1;
            
            Product2 product1 = new Product2(
                Name = 'Test Product1', 
                Description = 'Description Test Product1',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter1'
                
            );
            insert product1;
            
            ProductSellingModelOption modelOption = new ProductSellingModelOption(
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                ProrationPolicyId = prorationPolicy.Id
            );
            insert modelOption;
            
            PricebookEntry product1Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 300.0,
                IsActive = false,
                UseStandardPrice = false
            );
            insert product1Entry;
            
            OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod(
                Name = 'Test Delivery Method', 
                ProductId = product1.id
            );
            insert testOrderDeliveryMethod;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                CurrencyIsoCode = 'USD',
                DeliverToCountryCode = 'US',
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'TEst',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;
            
            Product2 product2 = new Product2(
                Name = 'Test Product2', 
                Description = 'Description Test Product2',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter2'
            );
            insert product2;
            
            PricebookEntry product1CustomEntry = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1CustomEntry;
            
            Product2 product3 = new Product2(
                Name = 'Test Product Add on', 
                Description = 'Add on product',
                IsActive = true, 
                StockKeepingUnit = 'TestPrinter3'
            );
            insert product3;
            
            ProductCategoryProduct pcp1 = new ProductCategoryProduct(
                ProductCategoryId = category1.Id,
                ProductId = product2.Id
            );
            insert pcp1;
            
            ProductCategoryProduct pcp2 = new ProductCategoryProduct(
                ProductCategoryId = category1.Id,
                ProductId = product3.Id
            );
            insert pcp2;
            
            Related_Product__c relatedProduct1 =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product2.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'CrossSell', 
                Enabled__c = true
            );
            insert relatedProduct1;
            
            Related_Product__c relatedProductAddOn =  new Related_Product__c(
                Product__c = product1.Id, 
                Sequence__c = 1, 
                Related_Product__c = product3.Id,
                Related_Product_Relation_Type__c = 'Related', 
                Related_Product_Type__c = 'Accessories', 
                Enabled__c = true
            );
            insert relatedProductAddOn;
            
            CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = product1.StockKeepingUnit,
                Name = 'Cart Item 1',
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Quantity = 2.0,
                Product2Id = product1.Id,
                CurrencyIsoCode = 'USD',
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                B2B_PriceBookEntry_Id__c = product1CustomEntry.Id, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0,
                TotalPriceAfterAllAdjustments = 20.0
            );
            insert cartItem1;
            Asset asset =new Asset(
                Name ='Book Shop',
                AccountId= account.Id,
                ContactId =con.Id,
                Product2Id = product1.Id
            );
            insert asset;    
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = account.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = customPricebook.Id;
            //orderObj.RecordTypeId       = recordTypeId;
            Insert orderObj;
        }
    }
    
    
    public static void createDataSMOrder2() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account account = new Account(Name = 'Test Account', 
                                          CurrencyIsoCode = 'USD'
                                         );
            insert account;
            
            String networkId = Network.getNetworkId();
            
            ContactPointAddress contactPointAddress = new ContactPointAddress(
                Name = 'Europe Address',
                ParentId = account.Id,
                AddressType = 'Billing',
                Street = 'Lodewijk De Raetlaan 295',
                City = 'Ciney',
                PostalCode = '5590',
                Country = 'Belgium',
                CountryCode = 'BE'
            );
            insert contactPointAddress;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId,
                                                          IsActive = true);
            
            Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Test Pricebook', IsActive = true);
            insert customPricebook;
            
            WebStore webStore = new WebStore(Name = 'Sflabs', 
                                             SupportedLanguages = 'en_US', 
                                             DefaultLanguage = 'en_US',
                                             StrikethroughPricebookId = pricebookId
                                            );
            insert webStore;    
            
            WebStorePricebook webStorePricebook = new WebStorePricebook(WebStoreId = webStore.Id, Pricebook2Id = customPricebook.Id, IsActive = true);
            insert webStorePricebook;
            
            WebCart cart = new WebCart(Name = 'Cart', 
                                       WebStoreId = webStore.Id, 
                                       AccountId = account.Id, 
                                       CurrencyIsoCode = 'USD',
                                       PoNumber = '6794',
                                       BillingStreet = 'Street',
                                       BillingCity = 'New York',
                                       BillingState = 'New York',
                                       BillingPostalCode = '34562',
                                       BillingCountry = 'United States',
                                       BillingLatitude = 40.730610,
                                       BillingLongitude = -73.935242
                                      );
            insert cart;
            
            
            
            B2B_Shipping_Address__c shippingAddress = new B2B_Shipping_Address__c(Cart__c = cart.Id,
                                                                                  Street__c = 'Street', 
                                                                                  Country__c = 'United States', 
                                                                                  City__c = 'New York', 
                                                                                  Postal_Code__c = '34562', 
                                                                                  State__c = 'New York', 
                                                                                  Name = 'Test'
                                                                                 );
            insert shippingAddress;
            CartCheckoutSession checkoutSession1 = new CartCheckoutSession (
                Name = 'Checkout Session 1',
                CurrencyIsoCode = cart.CurrencyIsoCode,
                WebCartId = cart.Id,
                State = 'Shipping',
                NextState = '',
                IsProcessing = false,
                IsArchived = false,
                IsError = false
            );
            insert checkoutSession1;
            
            ProrationPolicy prorationPolicy = new ProrationPolicy(RemainderStrategy = 'AddToFirst',
                                                                  ProrationPolicyType = 'StandardTimePeriods',
                                                                  Name = 'TestProrationPolicy');
            insert prorationPolicy;
            
            ProductSellingModel model = new ProductSellingModel(PricingTerm = 1,
                                                                PricingTermUnit = 'Months',
                                                                Name = 'Evergreen Monthly',
                                                                SellingModelType = 'Evergreen',
                                                                Status = 'Active'
                                                               );
            insert model;
            
            Product2 product1 = new Product2(Name = 'Test Product1', 
                                             Description = 'Description Test Product1',
                                             IsActive = true, 
                                             StockKeepingUnit = 'TestPrinter1'
                                            );
            insert product1;
            
            
            ProductSellingModelOption modelOption = new ProductSellingModelOption(
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                ProrationPolicyId = prorationPolicy.Id
            );
            insert modelOption;
            
            PricebookEntry product1Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product1.Id,
                ProductSellingModelId = model.Id,
                UnitPrice = 300.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product1Entry;
            
            OrderDeliveryMethod testOrderDeliveryMethod = new OrderDeliveryMethod(Name = 'Test Delivery Method', 
                                                                                  ProductId = product1.id);
            insert testOrderDeliveryMethod;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
                CartId = cart.Id,
                Name = 'Default Delivery 1',
                DeliveryMethodId = testOrderDeliveryMethod.Id,
                CurrencyIsoCode = 'USD',
                DeliverToCountryCode = 'US',
                DesiredDeliveryDate = System.Now(),
                DeliverToName = 'TEst',
                ShippingInstructions = 'instr',
                DeliverToStreet = cart.BillingStreet,
                DeliverToCity = cart.BillingCity,
                DeliverToState = cart.BillingState,
                DeliverToPostalCode = cart.BillingPostalCode,
                DeliverToCountry = cart.BillingCountry,
                DeliverToLatitude = cart.BillingLatitude,
                DeliverToLongitude = cart.BillingLongitude
            );
            insert cartDeliveryGroup;
            
            Product2 product2 = new Product2(Name = 'Test Product2', 
                                             Description = 'Description Test Product2',
                                             IsActive = true, 
                                             StockKeepingUnit = 'TestPrinter2'
                                            );
            insert product2;
            PricebookEntry product2Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = product2.Id,
                UnitPrice = 500.0,
                IsActive = true,
                UseStandardPrice = false
            );
            insert product2Entry;
            
            Product2 product3 = new Product2(Name = 'Test Product Add on', 
                                             Description = 'Add on product',
                                             IsActive = true, 
                                             StockKeepingUnit = 'TestPrinter3'
                                            );
            insert product3;
            Related_Product__c relatedProduct1 =  new Related_Product__c(Product__c = product1.Id, 
                                                                         Sequence__c = 1, 
                                                                         Related_Product__c = product2.Id,
                                                                         Related_Product_Relation_Type__c = 'Related', 
                                                                         Related_Product_Type__c = 'CrossSell', 
                                                                         Enabled__c = true
                                                                        );
            insert relatedProduct1;
            Related_Product__c relatedProductAddOn =  new Related_Product__c(Product__c = product1.Id, 
                                                                             Sequence__c = 1, 
                                                                             Related_Product__c = product3.Id,
                                                                             Related_Product_Relation_Type__c = 'Related', 
                                                                             Related_Product_Type__c = 'Accessories', 
                                                                             Enabled__c = true
                                                                            );
            insert relatedProductAddOn;
            
            CartItem cartItem1 = new CartItem(
                CartId = cart.Id,
                Type = 'Product',
                Sku = product1.StockKeepingUnit,
                Name = 'Cart Item 1',
                CartDeliveryGroupId = cartDeliveryGroup.Id,
                Quantity = 2.0,
                Product2Id = product1.Id,
                CurrencyIsoCode = 'USD',
                TotalPrice = 20.00,
                UnitAdjustedPrice = 20.00,
                AdjustmentAmount = 10.0, 
                B2B_PriceBookEntry_Id__c = product1Entry.Id, 
                ListPrice = 10.0, 
                SalesPrice = 10.0, 
                TotalLineAmount = 20.0
            );
            insert cartItem1;
            
            CartTax tax = new CartTax( 
                Amount = 100,
                CartItemId = cartItem1.Id,
                Name = 'Cart Tax',
                TaxCalculationDate = Date.today(),
                TaxRate = 10,
                TaxType = 'Estimated'
            );
            insert tax;
            
            Order order = new Order(Name = 'Test Order ', Status = 'Draft', Cart__c = cart.Id, EffectiveDate = system.today(), EndDate = system.today() + 365, AccountId = account.id, Pricebook2Id = standardPricebook.Id, Order_Type__c = 'SM Order');
            insert order;
            
            /*OrderItem oi = new OrderItem(OrderId = order.id, UnitPrice = 100, Quantity = 1, Product2Id = product1.Id);
            insert oi;
            
            OrderItemTaxLineItem oit = new OrderItemTaxLineItem(Name = 'Name', OrderItemId =oi.Id, Type = 'Actual', TaxEffectiveDate = System.today(), Amount = 10);
            insert oit;*/
        }
    }
    
}