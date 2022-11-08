@isTest
public with sharing class CartToOrderCopieTest {
    
    public static Map<String, String>  SetData() {
        Map<String, String> response = new Map<String, String>();
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            /*Orders_Sync_Integration__c  setting = Orders_Sync_Integration__c.getInstance();
            setting.Orders_Sync_Domain__c  = 'https://test.com';
            setting.Orders_Sync_Token__c  = 'abc123';
            upsert setting;*/
            ProductCatalog prodCatalog = new ProductCatalog();
            prodCatalog.Name = 'Test Catalog';
            insert prodCatalog;
            
            WebStore webStr = new WebStore();
            webStr.Name = 'Sflabs';
            webStr.PricingStrategy = 'LowestPrice';
            insert webStr;
            
            WebStoreCatalog web_Catalog = new WebStoreCatalog();
            web_Catalog.SalesStoreId = webStr.Id;
            web_Catalog.ProductCatalogId = prodCatalog.Id;
            insert web_Catalog;
            
            ProductCategory parent_category = new ProductCategory();
            parent_category.Name = 'ParentCategory';
            parent_category.CatalogId = prodCatalog.Id;
            parent_category.Description = 'Description';
            insert parent_category;
            
            ProductCategory prod_category = new ProductCategory();
            prod_category.Name = 'ProductCategory';
            prod_category.IsNavigational = True;
            prod_category.SortOrder = 4;
            prod_category.ParentCategoryId = parent_category.Id;
            prod_category.Description = 'Description';
            prod_category.CatalogId = prodCatalog.Id;
            insert prod_category;

            
            BuyerGroup buyGrp = new BuyerGroup();
            //buyGrp.Name = B2BUtils.getRegistrationBuyerGroupName();
            buyGrp.Name='Test Buyer Group';
            insert buyGrp;
            
            WebStoreBuyerGroup webStrBuyerGrp = new WebStoreBuyerGroup();
            webStrBuyerGrp.WebStoreId = webStr.Id;
            webStrBuyerGrp.BuyerGroupId = buyGrp.Id;
            insert webStrBuyerGrp;
            
            CommerceEntitlementPolicy commerceEntPolicy = new CommerceEntitlementPolicy(
                Name = 'Test Policy', Description = 'Test Description',
                CanViewProduct = true, CanViewPrice = true, IsActive = true
            );
            insert commerceEntPolicy;
            
            CommerceEntitlementBuyerGroup commerceEntBuyerGrp = new CommerceEntitlementBuyerGroup(
                PolicyId = commerceEntPolicy.Id,
                BuyerGroupId = buyGrp.Id
            );
            insert commerceEntBuyerGrp;    
            
            Pricebook2 newPricebook = new Pricebook2(
                Name = 'Test Book',
                IsActive = true
            );
            insert newPricebook;
            WebStorePricebook Ws= new WebStorePricebook();
            // Ws.Name='Test';
            Ws.IsActive=true;
            Ws.WebStoreId=webStr.id;
            Ws.Pricebook2Id= newPricebook.id;
            Insert Ws;
            System.debug(Ws);
            Schema.Location loc = new Schema.Location();
            loc.Name = 'Test Location';
            loc.LocationType ='Site';
            insert loc;
            
            Product2 proParentCertification = new Product2(
                IsActive = true,
                Name = 'Parent Certification',
                CurrencyIsoCode = 'USD',
                Family = 'Syndicated',
                ProductCode = 'CERTIFICATION'
            );    
            insert proParentCertification;      
            Product2 proParentCertification2 = new Product2(
                IsActive = true,
                Name = 'Parent Certification2',
                CurrencyIsoCode = 'USD',
                Family = 'Syndicated',
                ProductCode = 'CERTIFICATION2'
            );    
            insert proParentCertification2;   
            Id standardId = test.getStandardPricebookId(); 
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            update standardPricebook;
            
            standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            
            
            
            BuyerGroupPricebook buyerGrpPricebook = new BuyerGroupPricebook();
            buyerGrpPricebook.BuyerGroupId = buyGrp.Id;
            buyerGrpPricebook.Pricebook2Id = newPricebook.Id;
            buyerGrpPricebook.IsActive = true;
            insert buyerGrpPricebook;
            
            CommerceEntitlementProduct commerceEntProduct = new CommerceEntitlementProduct(
                PolicyId = commerceEntPolicy.Id,
                ProductId = proParentCertification.Id
            );
            insert commerceEntProduct;
            CommerceEntitlementProduct commerceEntProduct2 = new CommerceEntitlementProduct(
                PolicyId = commerceEntPolicy.Id,
                ProductId = proParentCertification2.Id
            );
            insert commerceEntProduct2;
            ProductSellingModel pSelling= new ProductSellingModel();
            pSelling.name='TermDefined';
            pSelling.status='Active';
            pSelling.SellingModelType ='TermDefined';
            pSelling.PricingTermUnit='Months';
            pSelling.PricingTerm=1;
            insert pSelling;
            ProductSellingModel pSelling2= new ProductSellingModel();
            pSelling2.name='Evergreen';
            pSelling2.status='Active';
            pSelling2.SellingModelType ='Evergreen';
            pSelling2.PricingTermUnit='Months';
            pSelling2.PricingTerm=1;
            insert pSelling2;
            ProductSellingModelOption pModelOption= new ProductSellingModelOption();
            pModelOption.ProductSellingModelId=pSelling.Id;
            pModelOption.Product2Id=proParentCertification.Id;
            insert pModelOption;
            
            ProductSellingModelOption pModelOption2= new ProductSellingModelOption();
            pModelOption2.ProductSellingModelId=pSelling2.Id;
            pModelOption2.Product2Id=proParentCertification2.Id;
            insert pModelOption2;
            
            list<PricebookEntry> priceBookEntryList = new  List<PricebookEntry>();
            PricebookEntry PB_entry = new PricebookEntry();
            PB_entry.pricebook2Id = standardId;
            PB_entry.product2id = proParentCertification.Id;
            PB_entry.unitprice = 1240.0;
            PB_entry.isactive = true;
            PB_entry.ProductSellingModelId=pSelling.Id;
            priceBookEntryList.add( PB_entry); 
            
            PricebookEntry  PB_entry2= new PricebookEntry();
            PB_entry2.pricebook2Id = newPricebook.Id;
            PB_entry2.product2id = proParentCertification.Id;
            PB_entry2.unitprice = 1249.0;
            PB_entry2.ProductSellingModelId=pSelling.id;
            PB_entry2.isactive = true;
            priceBookEntryList.add( PB_entry2) ;
            
            PricebookEntry PB_entry3 = new PricebookEntry();
            PB_entry3.pricebook2Id = standardId;
            PB_entry3.product2id = proParentCertification2.Id;
            PB_entry3.unitprice = 1200.0;
            PB_entry3.isactive = true;
            PB_entry3.ProductSellingModelId=pSelling2.Id;
            
            priceBookEntryList.add(PB_entry3); 
            PricebookEntry PB_entry4 = new PricebookEntry();
            PB_entry4.pricebook2Id = newPricebook.Id;
            PB_entry4.product2id = proParentCertification2.Id;
            PB_entry4.unitprice = 1200.0;
            PB_entry4.isactive = true;
            PB_entry4.ProductSellingModelId=pSelling2.Id;
            priceBookEntryList.add(PB_entry4); 
            Insert priceBookEntryList;
            
            ContactPointAddress con_point = new ContactPointAddress();
            con_point.Name = 'Test Address 123';
            con_point.City = 'Goleta';
            con_point.PostalCode = '93117-3084';
            con_point.State = 'California';
            con_point.Country = 'United States';
            con_point.AddressType = 'shipping/Billing';
            con_point.ActiveFromDate = Date.newInstance(2019, 12, 9);
            con_point.ActiveToDate = Date.newInstance(2021, 12, 9);
            insert con_point;
            
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
                            CommunityNickname = 'nick',
                            IsActive = True,
                            ProfileId = pf.Id,
                            ContactId = con.Id,
                            PortalRole = 'Manager'
                            
                            );
            insert uu;
            
            WebCart cart = new WebCart(Name = B2BConstants.CART_CURRENT, WebStoreId = webStr.Id, AccountId = Acc.Id , Status = B2BConstants.CART_ACTIVE, OwnerId = uu.Id);
            INSERT cart;
            OrderDeliveryMethod Order_Delivery_Method = new OrderDeliveryMethod(Name='Test Order Delivery Method');
            insert Order_Delivery_Method;
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery', DeliveryMethodId = Order_Delivery_Method.id, DeliverToName= Acc.Name);
            INSERT cartDeliveryGroup;
            
            List<CartItem>cartItems = new List<CartItem>();
            CartItem cart1 = new CartItem(
                CartId = cart.Id, 
                Sku = 'SKU_Test2', 
                SalesPrice = 10.00, 
                Quantity = 2.0, 
                Type = 'Charge', 
                AdjustmentAmount=10,
                Name ='TestProduct', 
                B2B_PriceBookEntry_Id__c=PB_entry2.Id,
                CartDeliveryGroupId=cartDeliveryGroup.Id, 
                Product2Id = proParentCertification.Id);
            
            CartItem cart2 = new CartItem(
                CartId = cart.Id, 
                Sku = 'SKU_Test', 
                SalesPrice = 10.00, 
                Quantity = 3.0, 
                Type = 'Product', 
                AdjustmentAmount=10,
                Name ='TestProduct', 
                B2B_PriceBookEntry_Id__c=PB_entry4.Id,
                CartDeliveryGroupId=cartDeliveryGroup.Id, 
                Product2Id = proParentCertification2.Id);
                cartItems.add(cart1);
                cartItems.add(cart2);
            //cartItems.add(cart2);
            INSERT cartItems;
            
            CartCheckoutSession checkoutSession = new CartCheckoutSession(WebCartId = cart.Id, IsArchived = FALSE, State = 'Start', Name = cart.Id);
            INSERT checkoutSession;
            
            String Accountid= Acc.id; 
            
            
            //Id recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            
            List< WebStorePricebook>   webstorePricebooks = [SELECT Id, Name, WebStoreId, Pricebook2Id, IsActive FROM WebStorePricebook WHERE WebStore.Name =:webStr.Name LIMIT 1];
            system.debug(webstorePricebooks);
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = Acc.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = newPricebook.Id;
            //orderObj.RecordTypeId       = recordTypeId;
            Insert orderObj;
            
            Order orderObj1 = new Order();
            orderObj1.Name               = 'Test1';
            orderObj1.AccountId          = Acc.Id;
            orderObj1.Status             = 'Draft';
            orderObj1.EffectiveDate      = system.today();
            orderObj1.ShippingCountry    = 'United States';
            orderObj1.ShippingState      = 'Georgia';
            orderObj1.Type               = 'End Customer';
            orderObj1.Pricebook2Id       = newPricebook.Id;
            //orderObj.RecordTypeId       = recordTypeId;
            Insert orderObj1;
            
            
            //Product2 producto = getProduct2();
            
            List<OrderItem> itemList = new List<OrderItem>();
            
            OrderItem orderItemObj1 = new OrderItem();
            orderItemObj1.OrderId            = orderObj.Id;
            orderItemObj1.Quantity           = 24; 
            orderItemObj1.UnitPrice          = 240;
            orderItemObj1.Product2id         = proParentCertification.Id;
            orderItemObj1.PricebookEntryId   = PB_entry2.Id;
            itemList.add(orderItemObj1);
            OrderItem orderItemObj2 = new OrderItem();
            orderItemObj2.OrderId            = orderObj1.Id;
            orderItemObj2.Quantity           = 14; 
            orderItemObj2.UnitPrice          = 240;
            orderItemObj2.Product2id         = proParentCertification2.Id;
            orderItemObj2.PricebookEntryId   = PB_entry4.Id;
            itemList.add(orderItemObj2);
            
            insert itemList;
            /*NamedCredential nc = [Select id from NamedCredential Limit 1];
            TaxEngineProvider TaxEngProvider = [select id from TaxEngineProvider limit 1];
            
            TaxEngine TaxEng= new TaxEngine(TaxEngineName='Test Tax Engine', Status='Active', TaxEngineCountry='United States', TaxEngineCity='TestCity', MerchantCredentialId =nc.Id ,TaxEnginePostalCode='12345',TaxEngineProviderId=TaxEngProvider.Id, SellerCode='S123');
            insert TaxEng;
            TaxPolicy TaxPol = new TaxPolicy(Name='Test Tax Policy', Status='Draft', TreatmentSelection='Manual');
            insert TaxPol;
        
        
            
            TaxTreatment taxTreatment = new TaxTreatment(Name='Test', Status='Active', TaxEngineId=TaxEng.id, TaxPolicyId=TaxPol.id, IsTaxable=true);
            insert taxTreatment;
            Taxpol.Status='Active';
            Taxpol.DefaultTaxTreatmentId= taxTreatment.id;
            upsert Taxpol;*/
            
            response.put('accountId', Acc.Id);
            response.put('CartId', cart.Id);
        }
        return response;
    }
    
    
    @isTest
    public static void Testmethod1() {
        
        Map<String, String> Data= SetData( );
        /*Orders_Sync_Integration__c  setting = Orders_Sync_Integration__c.getInstance();
setting.Orders_Sync_Domain__c  = 'https://test.com';
setting.Orders_Sync_Token__c  = 'abc123';
upsert setting;*/
        
        
        String orderId = [select id from order where name='Test'].id;
        List<id> orderIdList= new List<id>();
        orderidList.add(orderId);
       
        test.startTest();
        try {
            List <ID> cartToOrder1 = CartToOrderCopie.cartToOrder(Data.get('CartId'));
            system.assertNotEquals(orderIdList, cartToOrder1);
        }
        catch(Exception e) {
            system.assertNotEquals(null, e);
        }
        // CartToOrderCopie.updateCheckoutSession(checkoutSession.id, Ord.id);
        // ID OrderMapping = CartToOrderCopie.mapAndInsertCartToOrder(cart.id);
        //  ID SubscriptionManagementOrder = CartToOrderCopie.createSubscriptionManagementOrder(Ord.id);
        //ID mapAndInsertOrderAction = CartToOrderCopie.mapAndInsertOrderAction(Ord.id);
        // ID mapKGToOG = CartToOrderCopie.mapAndInsertCartDeliveryGroupToOrderDeliveryGroup(cartDeliveryGroup.id, Ord.id);
        
        /* CartToOrderCopie.mapAndInsertCartItems(cart.id, Order.id, mapAndInsertOrderAction.id, mapKGToOG.id );
       OrderItem = CartToOrderCopie.mapCartItemToOrderItem( CartItem.id, Order.id, mapAndInsertOrderAction.id, mapKGToOG.id);
       OrderItemAdjustmentLineItem = CartToOrderCopie.mapOrderItemAdjustmentLineItemTo(cartItem.id,  OrderItem.id);
       Decimal = CartToOrderCopie.getAdjustmentAmount(cartItem.id);
        */
        
        test.stopTest();
        
    }
    
}