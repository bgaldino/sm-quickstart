/*
* @author Tiago Welter
*/

@IsTest
public class B2BTestFactory {

    private static final String PRODUCT_TEST_NAME1 = 'Metal X';
    public static final String ACCOUNT_TEST_NAME = 'Test Name';
    public static final String ACCOUNT_TEST_PARTNER_NAME = 'Test Partner Account';

    public static Map<String, String> initialStorefrontSetup() {
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
            webStr.Name = 'Mkf Store';
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

            ProductCategory prod_category2 = new ProductCategory();
            prod_category2.Name = 'Marktest';
            prod_category2.IsNavigational = True;
            prod_category2.SortOrder = 4;
            prod_category2.ParentCategoryId = parent_category.Id;
            prod_category2.Description = 'Description';
            prod_category2.CatalogId = prodCatalog.Id;
            insert prod_category2; 
            
            ProductCategory prod_category3 = new ProductCategory();
            prod_category3.Name = 'Test printer';
            prod_category3.IsNavigational = True;
            prod_category3.SortOrder = 4;
            prod_category3.ParentCategoryId = parent_category.Id;
            prod_category3.Description = 'Description';
            prod_category3.CatalogId = prodCatalog.Id;
            insert prod_category3;             
            
            BuyerGroup buyGrp = addNewBuyerGroup('Test', true);
            // buyGrp.Name = B2BUtils.getRegistrationBuyerGroupName();

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
                
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            update standardPricebook;
            
            standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            
            System.assertEquals(true, standardPricebook.IsStandard);
            
            BuyerGroupPricebook buyerGrpPricebook = new BuyerGroupPricebook();
            buyerGrpPricebook.BuyerGroupId = buyGrp.Id;
            buyerGrpPricebook.Pricebook2Id = newPricebook.Id;
            buyerGrpPricebook.IsActive = true;
            insert buyerGrpPricebook;
            
            PricebookEntry pbe1 = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = proParentCertification.Id,
                UnitPrice = 1020,
                IsActive = true
            );
            insert pbe1;
            
            CommerceEntitlementProduct commerceEntProduct = new CommerceEntitlementProduct(
                PolicyId = commerceEntPolicy.Id,
                ProductId = proParentCertification.Id
            );
            insert commerceEntProduct;
            
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
                
            Account acc = new Account();
            acc.Name = ACCOUNT_TEST_NAME;
            acc.Type = 'Customer';
            acc.ShippingCountry = 'United States';
            acc.ShippingState = 'Alabama';
            acc.ShippingPostalCode = '12345';
            acc.BillingStreet  = 'Cambridge';
            acc.BillingCity   = 'Cambridge';
            acc.BillingCountry   = 'United States';
            insert acc;

            ContactPointAddress cpa = new ContactPointAddress();
            cpa.Name='Test CPA';
            cpa.AddressType='Billing';
            cpa.Street='TestStreet';
            cpa.City='TestCity';
            cpa.State='Alabama';
            cpa.Country='United States';
            cpa.PostalCode='10013';
            cpa.IsDefault=true;
            cpa.ParentId=acc.Id;        
            insert cpa;    

            Contact con = new Contact();
            con.FirstName = 'test';
            con.LastName = 'Contact';
            con.Email = 'test@test.com';
            con.AccountId = acc.Id;
            insert con;    
            
            BuyerAccount buyrAcc = new BuyerAccount();
            buyrAcc.Name = acc.Name;
            buyrAcc.BuyerId = acc.Id;
            buyrAcc.IsActive = true;
            insert buyrAcc;  
            
            BuyerGroupMember buyGrpMem = new BuyerGroupMember();
            buyGrpMem.BuyerId = acc.Id;
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

            WebCart cart = new WebCart(Name = B2BConstants.CART_CURRENT, WebStoreId = webStr.Id, AccountId = acc.Id , Status = B2BConstants.CART_ACTIVE, OwnerId = uu.Id);
            INSERT cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
            INSERT cartDeliveryGroup;
    
            List<CartItem>cartItems = new List<CartItem>();
            CartItem cart1 = new CartItem(
                                            CartId = cart.Id, 
                                            Sku = 'SKU_Test1', 
                                            SalesPrice = 10.00, 
                                            Quantity = 3.0, 
                                            Type = 'Product', 
                                            Name ='TestProduct', 
                                            CartDeliveryGroupId=cartDeliveryGroup.Id, 
                                            Product2Id = proParentCertification.Id);
    
            CartItem cart2 = new CartItem(
                                            CartId = cart.Id, 
                                            Sku = 'SKU_Test1', 
                                            SalesPrice = 10.00, 
                                            Quantity = 3.0, 
                                            Type = 'Product', 
                                            Name ='TestProduct', 
                                            CartDeliveryGroupId = cartDeliveryGroup.Id, 
                                            Product2Id = proParentCertification.Id);
            cartItems.add(cart1);
            cartItems.add(cart2);
            INSERT cartItems;
    
            CartCheckoutSession checkoutSession = new CartCheckoutSession(WebCartId = cart.Id, IsArchived = FALSE, State = 'Start', Name = cart.Id);
            INSERT checkoutSession;

            response.put('userId', uu.Id);
            response.put('accountId', acc.Id);
            response.put('contactId', con.Id);
            response.put('accountId', acc.Id);
            response.put('Cartid',cart.id);
            
            
            response.put('productId', proParentCertification.Id);
            response.put('webStoreName', webStr.Name);
            response.put('webStoreId', webStr.Id);
            response.put('productCategoryId',prod_category.Id);
            response.put('webCatalogId',web_Catalog.Id);
            response.put('pricebookEntryId', pbe1.Id);
            response.put('pricebookId', standardPricebook.Id);
        }
        return response;
    }

    public static User addNewUser() {
        User uu;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Account acc = addNewAccount(ACCOUNT_TEST_NAME,true);
            BuyerAccount baObjs = addNewBuyerAccount(acc,true);

            ContactPointAddress cpa = new ContactPointAddress();
            cpa.Name='Test CPA';
            cpa.AddressType='Billing';
            cpa.Street='TestStreet';
            cpa.City='TestCity';
            cpa.State='Alabama';
            cpa.Country='United States';
            cpa.PostalCode='10013';
            cpa.IsDefault=true;
            cpa.ParentId=acc.Id;       
            insert cpa;    

            Contact con = new Contact();
            con.FirstName = 'test';
            con.LastName = 'Contact';
            con.Email = 'test@test.com';
            con.AccountId = acc.Id;
            insert con;    

            Profile pf = [SELECT Id FROM Profile WHERE Name = :B2BConstants.PROFILE_NAME LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            uu = new User(firstname = 'ABC',
                            lastName = 'XYZ',
                            email = uniqueName + '@test' + orgId + '.org',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            CommunityNickname = string.valueOf(math.random()).substring(0,6),
                            IsActive = True,
                            ProfileId = pf.Id,
                            ContactId = con.Id,
                            PortalRole = 'Manager'
                            );
            insert uu;
        }
        return uu;
    }
   
    public static BuyerGroup addNewBuyerGroup(String name,Boolean isInsert) {
        BuyerGroup buyGrp;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            buyGrp = new BuyerGroup();
            buyGrp.Name = String.isNotBlank(name) ? name : 'JAN22PROMO';
            if(isInsert) { insert buyGrp;}
        }
        return buyGrp;
    }

    public static BuyerAccount addNewBuyerAccount(Account actObj, Boolean isInsert) {
        BuyerAccount buyerAccount;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            buyerAccount = new BuyerAccount();
            buyerAccount.BuyerId = actObj.Id;
            buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
            buyerAccount.IsActive = true;
            if(isInsert) { insert buyerAccount;}
        
           
        }
        return buyerAccount;
    }

    public static Account addNewAccount(String accName, Boolean isInsert) {
        Account acc;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            acc = new Account();
            acc.Name = accName;
            acc.Type = 'Customer';
            acc.ShippingCountry = 'United States';
            acc.ShippingState = 'Alabama';
            acc.ShippingPostalCode = '12345';
            acc.BillingStreet  = 'Cambridge';
            acc.BillingCity   = 'Cambridge';
            acc.BillingCountry = 'United States';
            if(isInsert) { insert acc;}
        }
        return acc;
    }

    public static Order addNewOrder(String accountId, String recordType) {
        Order orderObj;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            /*Orders_Sync_Integration__c  setting = Orders_Sync_Integration__c.getInstance();
            setting.Orders_Sync_Domain__c  = 'https://test.com';
            setting.Orders_Sync_Token__c  = 'abc123';
            upsert setting;*/
            
            Id standardId = test.getStandardPricebookId();
            //Id recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();

            orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = accountId;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = standardId;
            //orderObj.RecordTypeId       = recordTypeId;
            Insert orderObj;

            /*   Product2 productoIns =new Product2();
            productoIns.Name='test1';
            productoIns.Product_Category__c = '3D Printer & Hardware';
            productoIns.productCode='1234';
            productoIns.isActive = true;
            insert productoIns;    */

            Product2 producto = getProduct2();
            List<PricebookEntry> entryList = [select product2id,pricebook2Id from  PricebookEntry where product2id =: producto.id and pricebook2Id = :standardId limit 1];
            PricebookEntry one;
            if(entryList.isEmpty()) {
                one = new PricebookEntry();
                one.pricebook2Id = standardId;
                one.product2id = producto.id;
                one.unitprice = 1249.0;
                one.isactive = true;
                insert one; 

            } else {one = entryList[0];}
                
            List<OrderItem> itemList = new List<OrderItem>();
            OrderItem orderItemObj = new OrderItem();
            orderItemObj.OrderId            = orderObj.id;
            orderItemObj.Quantity           = 24; 
            orderItemObj.UnitPrice          = 240;
            orderItemObj.Product2id         = producto.id;
            orderItemObj.PricebookEntryId   = one.id;
            insert orderItemObj;
            
            OrderItem orderItemObj1 = new OrderItem();
            orderItemObj1.OrderId            = orderObj.id;
            orderItemObj1.Quantity           = 24; 
            orderItemObj1.UnitPrice          = 240;
            orderItemObj1.Product2id         = producto.id;
            orderItemObj1.PricebookEntryId   = one.id;
            insert orderItemObj1;
        }
        return orderObj;
    }

    public static WebStore addNewWebStore() {
        WebStore webStr;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            webStr = new WebStore();
            webStr.Name = B2BConstants.STOREFRONT;
            webStr.PricingStrategy = 'LowestPrice';
            insert webStr;
            
            /*NamedCredential nc = [Select id from NamedCredential Limit 1];
            
            PaymentGatewayProvider pgp = [select id from PaymentGatewayProvider LIMIT 1];
            
            PaymentGateway pg = new PaymentGateway();
            pg.PaymentGatewayName = 'Test Gateway';
            pg.Status = 'Active';
            pg.PaymentGatewayProviderId = pgp.id;
            pg.MerchantCredentialId = nc.id;
            insert pg;
            
            StoreIntegratedService sis = new StoreIntegratedService();
            sis.StoreId = webStr.Id;
            sis.Integration = pg.Id;
            sis.ServiceProviderType='Payment';
            insert sis;*/
        }
        return webStr;
    }    

    public static WebCart addNewCart(String wstoreId, String accountId, String userId) {
        WebCart cart;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Id standardId = test.getStandardPricebookId();

            cart = new WebCart(CurrencyISOCode='USD',Name = B2BConstants.CART_CURRENT, WebStoreId = wstoreId, AccountId = accountId, Status = B2BConstants.CART_ACTIVE, OwnerId = userId);
            insert cart;

            ContactPointAddress cttObj = [SELECT Id, Name FROM ContactPointAddress WHERE ParentId = :accountId LIMIT 1];
            
            update cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
            insert cartDeliveryGroup;

            Product2 producto = creteProduct2(true);
            
            PricebookEntry one = new PricebookEntry();
            one.pricebook2Id = standardId;
            one.product2id = producto.id;
            one.unitprice = 1249.0;
            one.isactive = true;
            insert one;

            List<CartItem>cartItems = new List<CartItem>();
            CartItem cart1 = new CartItem(
                                            CartId = cart.Id, 
                                            Sku = 'SKU_Test1', 
                                            SalesPrice = 10.00, 
                                            Quantity = 3.0, 
                                            Type = 'Product', 
                                            Name ='TestProduct', 
                                            CartDeliveryGroupId=cartDeliveryGroup.Id, 
                                            Product2Id = producto.Id);

            cartItems.add(cart1);
            //  insert cartItems;

            CartItem cart2 = new CartItem(
                CartId = cart.Id, 
                Sku = 'SKU_Test2', 
                SalesPrice = 10.00, 
                Quantity = 3.0, 
                Type = 'Charge', 
                Name ='TestProduct2', 
                CartDeliveryGroupId=cartDeliveryGroup.Id, 
                Product2Id = producto.Id);

                cartItems.add(cart2);
                insert cartItems;
        }
        return cart;
    }

    public static WebCart getCurrentWebCart() {      
        String query = ' SELECT ' + B2BCartSelector.getQueryFieldString() + ' FROM WebCart LIMIT 1 ';
        List<WebCart> webCartList = Database.query(query);
        WebCart cart = webCartList.get(0);
        return cart; 
    }   

    public static User getUser() {      
        return [SELECT Id, Email, UserName, AccountId,Account.Name,Account.B2B_Stripe_Customer_ID__c, ContactId FROM User WHERE firstname = 'ABC' LIMIT 1]; 
    }   

    public static List<Account> getAccountList() {      
        return [SELECT Id,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Name FROM Account WHERE Name = :ACCOUNT_TEST_NAME LIMIT 1]; 
    }  

    public static WebStore getWebStore() {      
        return [SELECT Id FROM WebStore WHERE Name = :B2BConstants.STOREFRONT LIMIT 1];
    }

    public static BuyerGroup getBuyerGroup() {      
        return [SELECT Id, Name FROM BuyerGroup LIMIT 1];
    }  
    
    public static Opportunity createOpportunity(String oppName,String stageName,Date closedDate,Boolean isInsert){
        Opportunity opp;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Contact cn = new Contact(LastName= 'test contact'); insert cn;
            opp = new Opportunity();
            opp.name = oppName;
            opp.stageName = stageName;
            opp.closeDate = closedDate;
            
            if(isInsert) insert opp;
            
        }
        return opp;
    }

    public static CartDeliveryGroup createCartDeliveryGroup(WebCart cart, Boolean isInsert) {
        CartDeliveryGroup cartDeliveryGroup;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {   
            cartDeliveryGroup = createCartDeliveryGroup(cart);
            if(isInsert) {insert cartDeliveryGroup;}
            
        }
        return CartDeliveryGroup;
    }

    public static CartDeliveryGroup getCartDeliveryGroup() {      
        return [SELECT Id, Name FROM CartDeliveryGroup LIMIT 1];
    }

    public static CartDeliveryGroupMethod createCartDeliveryGroupMethod(Id cartId, Id deliveryId, Id orderDeliveryMethod,Boolean isInsert) {      
        CartDeliveryGroupMethod cdbObj;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            cdbObj = new CartDeliveryGroupMethod();
            cdbObj.WebCartId            = cartId;
            cdbObj.Name                 = 'CDG NAME';
            cdbObj.CartDeliveryGroupId  = deliveryId;
            cdbObj.ShippingFee          = 13;
            cdbObj.DeliveryMethodId     = orderDeliveryMethod;   
            if(isInsert) { insert cdbObj;}
        
            
        }
        return cdbObj;
    }   

    public static CartDeliveryGroupMethod getCartDeliveryGroupMethod() {      
        return [SELECT Id, Name FROM CartDeliveryGroupMethod LIMIT 1];
    }

    public static OrderDeliveryMethod createOrderDeliveryMethod(String productId,Boolean isInsert) {
        OrderDeliveryMethod cdbObj;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {  
            cdbObj = new OrderDeliveryMethod();
            cdbObj.Name                 = 'NAME';
            cdbObj.ProductId            = productId;
            cdbObj.IsActive             = true;
            if(isInsert) {
                insert cdbObj;
            }
            
        }
        return cdbObj;
    } 

    public static OrderDeliveryMethod getOrderDeliveryMethod() {      
        return [SELECT Id, Name FROM OrderDeliveryMethod LIMIT 1];
    }

    public static Product2 creteProduct2(Boolean isInsert) {   
        Product2 producto;  
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            //insert duty product
            Product2 productoDutye =new Product2();
            //productoDutye.Name                = B2BUtils.getDefaultDutyProductName();
            productoDutye.Name                = PRODUCT_TEST_NAME1;
            productoDutye.productCode         = 'DUTY';
            productoDutye.isActive            = true;
            productoDutye.StockKeepingUnit ='D-001';
            insert productoDutye;        
            
            producto =new Product2();
            producto.Name                = PRODUCT_TEST_NAME1;
            producto.productCode         = '1234';
            producto.isActive            = true;
            if(isInsert) {
                insert producto;        
            }
            
        }
        return producto;
    } 

    public static Product2 getProduct2() {      
        return [SELECT Id, Name FROM Product2 WHERE Name = :PRODUCT_TEST_NAME1 LIMIT 1];
    }

    public static Contact createContact(String lastName,Boolean isInsert) {
        Contact conIns;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
          conIns = new Contact();
          conIns.lastName = lastName;
          if(isInsert){insert conIns;}
          
        }
        return conIns;
    }    

    public static User createCommunityUser(String fname, String lname,String contactId,Boolean isInsert) {
        User uu;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            Integer randomNo = Math.round((Math.random() * (900000) + 100000));
            UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'Sales_Ops' Limit 1];

            Profile pf = [SELECT Id FROM Profile WHERE Name = :B2BConstants.PROFILE_NAME LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            uu = new User(firstname = fname,
                            lastName = lname,
                            email = uniqueName + '@test' + orgId + '.org',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            CommunityNickname = string.valueOf(math.random()).substring(0,6),
                            IsActive = True,
                            ProfileId = pf.Id,
                            ContactId = contactId,
                            PortalRole = 'Manager',
                            UserRoleId = userRole.Id

                            );
        
            if(isInsert) { insert uu;}
        }
        return uu;
    }

    public static CartItem getCartItem(String cartId) {      
        return [SELECT Id FROM CartItem WHERE CartId = :cartId LIMIT 1];
    }

    public static Order getOrder() {      
        return [SELECT Id FROM Order LIMIT 1];
    }    

    public static Contact creteNewContact(String emailStr, String lastNameStr, String accountId,Boolean isInsert) {
        Contact con;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {    
            con = new Contact();
            con.FirstName = 'test';
            con.LastName = lastNameStr;
            con.Email = emailStr;
            con.AccountId = accountId;
            if(isInsert) { insert con;}
        }
        return con;
    }

    public static Account addNewPartnerAccount(String accName, Boolean isInsert) {
        Account acc;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            acc = new Account();
            acc.Name = accName;
            acc.Type = 'Reseller';
            acc.ShippingCountry = 'United States';
            acc.ShippingState = 'Alabama';
            acc.ShippingPostalCode = '12345';
            acc.BillingStreet  = 'Cambridge';
            acc.BillingCity   = 'Cambridge';
            acc.BillingCountry = 'United States';        
            //acc.RecordTypeId = B2BUtils.getRecordTypeId('Account',B2BConstants.REC_TYPE_ACCOUNT_RESELLER);
            if(isInsert) { insert acc;}       
            
        }
        return acc;
    }

    /*public static B2B_Shipment__c createOrderShippment(String orderId) {
        B2B_Shipment__c shipment = new B2B_Shipment__c();
        shipment.Shipment_Ext_Id__c     = '1234567890';
        shipment.Order__c               = orderId;
        shipment.Tracking_Number__c     = '123456789';
        shipment.Tracking_URL__c        = 'www.test.com/123456789';
        shipment.Shipping_Method__c     = 'Post'; 
        shipment.Shipping_Carriers__c   = 'Fedex';
        shipment.Ship_Date__c           = null;
        shipment.Status__c              = 'In Transit';
        shipment.Description__c         = 'AAAAAA';
        shipment.Ship_To_Name__c        = 'Test';
        shipment.Ship_To_CompanyName__c = 'Test';
        shipment.Ship_To_Street__c      = 'Test Street';
        shipment.Ship_To_City__c        = 'TestCity';
        shipment.Ship_To_State__c       = 'Alabama';
        shipment.Ship_To_Country__c     = 'United States';
        shipment.Ship_To_PostalCode__c  = '10013';
        insert shipment;

        OrderItem prod = [SELECT Id FROM OrderItem WHERE Orderid = :orderId LIMIT 1];

        B2B_Shipment_Item__c itemShip = new B2B_Shipment_Item__c();
        itemShip.B2B_Shipment__c = shipment.Id;
        itemShip.Quantity__c = 10;
        itemShip.Printer_ID__c = '101010;102555';
        itemShip.Order_Product__c = prod.Id;
        insert itemShip;      
        return shipment;
    }    */

    public static CartDeliveryGroup createCartDeliveryGroup(WebCart cart){
        CartDeliveryGroup cartDeliveryGroup;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
        }
        return cartDeliveryGroup;
    }

    public static CartCheckoutSession getCurrentWebCartSession() {       
        Id webCartId = getCurrentWebCart().Id;
        return [SELECT Name, Id, OrderId FROM CartCheckoutSession WHERE WebCartId = :webCartId LIMIT 1];        
    } 

    public static CartCheckoutSession createCartCheckOutSession(WebCart cart){
        CartCheckoutSession checkoutSession;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            checkoutSession = new CartCheckoutSession(WebCartId = cart.Id, IsArchived = FALSE, State = 'Start', Name = cart.Id);
            insert checkoutSession;
        }
        return checkoutSession;
    }    


    public static ConnectApi.CartItem getConnectApiCartItem(){
        ConnectApi.CartItem obj;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            obj = new ConnectApi.CartItem();
        }
        return obj;
    }


    public static  List<ConnectApi.BatchResult> getConnectApiBatchResult(){
        List<ConnectApi.BatchResult> objList;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            objList = new  List<ConnectApi.BatchResult>();
        }
        return objList;
    }
    /*public static B2BRecommendedProduct__c createRecommendedProduct(String parentProductId,String productId, Boolean isInsert) {
        B2BRecommendedProduct__c ins = new B2BRecommendedProduct__c();
        ins.Active__c = true;
        ins.RecommendedProduct__c = productId;
        ins.Product__c = parentProductId;
        ins.Sequence__c = 1;
        if(isInsert) {
            insert ins;
        }
        return ins;
    }*/


    public static  ConnectApi.PricingResult getConnectApiProductPrices(){
        ConnectApi.PricingResult obj;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            obj = new  ConnectApi.PricingResult();
            List<ConnectApi.PricingResultLineItem> prltList = new List<ConnectApi.PricingResultLineItem>();
            for(Product2 p :[SELECT Id FROM Product2]){
                ConnectApi.PricingResultLineItem cp = new ConnectApi.PricingResultLineItem();
                cp.success = true;
                cp.unitPrice = '33';
                cp.productId = p.Id ;
                cp.listPrice = '110';
                prltList.add(cp);
            }
        
            obj.pricingLineItemResults = prltList;
            obj.success = true ;
        }
        return obj;
    }

    public static ConnectApi.ManagedContentVersionCollection getManagedContentVersionCollection(){
        ConnectApi.ManagedContentVersionCollection obj;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            obj = new  ConnectApi.ManagedContentVersionCollection();
            Map<String, ConnectApi.ManagedContentNodeValue> mcMap = new Map<String, ConnectApi.ManagedContentNodeValue>();
            ConnectApi.ManagedContentTextNodeValue mct = new ConnectApi.ManagedContentTextNodeValue();
            mct.value = 'test';
            mcMap.put('thumbUrl',mct );
            mcMap.put('source',mct );
            ConnectApi.ManagedContentVersion mcv = new ConnectApi.ManagedContentVersion();
            mcv.title = 'test';
            mcv.contentNodes = mcMap;
            List<ConnectApi.ManagedContentVersion> contentVersions = new List<ConnectApi.ManagedContentVersion>{mcv};
            obj.items = contentVersions;
        }
        return obj;
    }

    public static  ConnectApi.CartSummary getConnectApiCartSummary(){
        ConnectApi.CartSummary obj;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            WebCart cartObj = B2BTestFactory.getCurrentWebCart();
            obj = new  ConnectApi.CartSummary();
            obj.cartId =cartObj.Id  ;
        }
        return obj;
    }

    public static CartItemPriceAdjustment createCartAdjustment(Webcart cart,Boolean isInsert) {
        CartItemPriceAdjustment obj;
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            BuyerGroup buGroup = [SELECT Id, Name FROM BuyerGroup LIMIT 1];
            Promotion prom = new Promotion();
            prom.Name = buGroup.Name;
            prom.StartDateTime = system.now();
            prom.IsActive = true;
            insert prom;
            
            WebCartAdjustmentGroup inn = new WebCartAdjustmentGroup();
            inn.AdjustmentSource = 'System';
            inn.AdjustmentTargetType = 'Item';
            inn.AdjustmentType = 'AdjustmentAmount';
            inn.AdjustmentValue = 100;
            inn.cartId = cart.id;
            inn.CurrencyIsoCode = 'USD';
            inn.PriceAdjustmentCauseId = prom.id;
            inn.Name = 'coupon100off';
            inn.TotalAmount = 100;
            insert inn;
            String itemId = cart.cartItems[0].id; 
            
            obj = new CartItemPriceAdjustment() ;
            obj.Name = 'coupon100off';
            obj.AdjustmentTargetType = 'Item';
            obj.AdjustmentSource = 'System';
            obj.AdjustmentType = 'AdjustmentAmount';
            obj.PriceAdjustmentCauseId = prom.id;
            obj.CurrencyIsoCode = 'USD';
            obj.CartItemId = itemId;
            obj.TotalAmount = 100;
            obj.AdjustmentValue = 100;
            insert obj;
        }
        return obj;
    }


}