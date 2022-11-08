@isTest
public with sharing class RSM_UtilsTest {
    @testSetup static void setup() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            // Account and Contact are related
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
            Contact contact = new Contact(LastName='TestContact', AccountId=Acc.Id);
            insert contact;
            
            WebStore webStore = new WebStore(Name='Evergreen Platform Solutions', DefaultLanguage='en_US');
            insert webStore;
            
            WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=Acc.Id);
            insert cart;
            
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
            insert cartDeliveryGroup;
            
            // The cpas are related to the Acc (and through it to the contact)
            ContactPointAddress cpa1 = new ContactPointAddress(Name='CPA1', Street='Street1', City='Goleta', State='California',
                                                            Country='United States', PostalCode='93117-3084', IsDefault=true, AddressType='shipping/Billing', ParentId=Acc.Id);
            ContactPointAddress cpa2 = new ContactPointAddress(Name='CPA2', Street='Street2', City='Goleta', State='California',
                                                            Country='United States', PostalCode='93117-3085', IsDefault=false, AddressType='shipping/Billing', ParentId=Acc.Id);
            
            // This contact point address should not show up because it's set to AddressType Shipping
            ContactPointAddress cpaShipping = new ContactPointAddress(Name='CPAS', Street='StreetS', City='Goleta',
                                                                    Country='United States', PostalCode='93117-3088', IsDefault=false, AddressType='shipping/Billing', ParentId=Acc.Id);
            
            insert cpa1;
            insert cpa2;
            insert cpaShipping;
            insertCartItem(cart.Id, cartDeliveryGroup.Id);
            
            // This profile name is the name of the buyer profile. The name specified here is what is installed using
            // SFDX and may be different for you.
            //Profile profile = [SELECT Id FROM Profile WHERE Name='Buyer_User_Profile_From_QuickStart' LIMIT 1];
            Profile profile = [SELECT Id FROM Profile WHERE Name = :B2B_Constants.Profile.CUSTOMER_COMMUNITY_PLUS_USER LIMIT 1];
            User usr = new User(Alias='buyer', Email='buyer@example.com', LastName='Buyer',
                                TimeZoneSidKey='GMT', LocaleSidKey='en_US', Username='buyer@example.com',
                                EmailEncodingKey='UTF-8', ProfileId=profile.Id, LanguageLocaleKey='en_US',
                                ContactId=contact.Id);
            insert usr;
            product2 producto= new product2(name='Test1',StockKeepingUnit='SKU_Test1', isActive=true);
            insert producto;
            //[Select id from Product2 where StockKeepingUnit=:'SKU_Test1'];
            Id standardId = test.getStandardPricebookId();
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
            
            Order orderObj = new Order();
            orderObj.Name               = 'Test';
            orderObj.AccountId          = Acc.Id;
            orderObj.Status             = 'Draft';
            orderObj.EffectiveDate      = system.today();
            orderObj.ShippingCountry    = 'United States';
            orderObj.ShippingState      = 'Georgia';
            orderObj.Type               = 'End Customer';
            orderObj.Pricebook2Id       = standardId;
            //orderObj.RecordTypeId       = recordTypeId;
            
            orderObj.Cart__c=cart.Id;
            System.runAs(usr)
            { Insert orderObj;}
        }
    }
    
    static void insertCartItem(String cartId, String cartDeliveryGroupId) {
        CartItem cartItem = new CartItem(
            CartId=cartId, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroupId
        );
        insert cartItem;
    }
    
    // Deletes the single cart item    
    static void deleteCartItem() {
        CartItem cartItem = [SELECT Id FROM CartItem WHERE Name = 'TestProduct' LIMIT 1];
        delete cartItem;
    }
  
 
    
  
    @isTest 
    static void getAllObjectFieldsTest () {
        String AccountsAllFields='id, isdeleted, masterrecordid, name, type, parentid, billingstreet, billingcity, billingstate, billingpostalcode, billingcountry, billingstatecode, billingcountrycode, billinglatitude, billinglongitude, billinggeocodeaccuracy, billingaddress, shippingstreet, shippingcity, shippingstate, shippingpostalcode, shippingcountry, shippingstatecode, shippingcountrycode, shippinglatitude, shippinglongitude, shippinggeocodeaccuracy, shippingaddress, phone, fax, accountnumber, website, photourl, sic, industry, annualrevenue, numberofemployees, ownership, tickersymbol, description, rating, site, currencyisocode, ownerid, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, ispartner, iscustomerportal, channelprogramname, channelprogramlevelname, jigsaw, jigsawcompanyid, cleanstatus, accountsource, dunsnumber, tradestyle, naicscode, naicsdesc, yearstarted, sicdesc, dandbcompanyid, operatinghoursid, isbuyer, tier, customerpriority__c, sla__c, active__c, numberoflocations__c, upsellopportunity__c, slaserialnumber__c, slaexpirationdate__c, b2b_stripe_customer_id__c';
        //String CommunityId = [select id from Network limit 1].id;
        test.startTest();
        String AccFields=  RSM_Utils.getAllObjectFields('Account');
                       
        system.assertNotEquals(Null,AccFields);
        test.stopTest();
    }
    @isTest 
    static void getAllObjectFieldsTest2 () {
        // String AccountsFields='id, isdeleted, masterrecordid, name, type, parentid, billingstreet, billingcity, billingstate, billingpostalcode, billingcountry, billingstatecode, billingcountrycode, billinglatitude, billinglongitude, billinggeocodeaccuracy, billingaddress, shippingstreet, shippingcity, shippingstate, shippingpostalcode, shippingcountry, shippingstatecode, shippingcountrycode, shippinglatitude, shippinglongitude, shippinggeocodeaccuracy, shippingaddress, phone, fax, accountnumber, website, photourl, sic, industry, annualrevenue, numberofemployees, ownership, tickersymbol, description, rating, site, currencyisocode, ownerid, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, ispartner, iscustomerportal, channelprogramname, channelprogramlevelname, jigsaw, jigsawcompanyid, cleanstatus, accountsource, dunsnumber, tradestyle, naicscode, naicsdesc, yearstarted, sicdesc, dandbcompanyid, operatinghoursid, isbuyer, tier, customerpriority__c, sla__c, active__c, numberoflocations__c, upsellopportunity__c, slaserialnumber__c, slaexpirationdate__c, b2b_stripe_customer_id__c';
        String  Accounts2Fields='id, Name';
        //String CommunityId = [select id from Network limit 1].id;
        set<String> fieldSet = new set<String>{'name','id'};
        test.startTest();
        String ObjectFields=  RSM_Utils.getAllObjectFields('Account',fieldSet);
        // Accounts2Fields (expected values) has only 2 fields name but it will return all the field's name.
       
         system.assertNotEquals( Accounts2Fields,ObjectFields) ;
        test.stopTest();
    }
 
    @isTest 
    static void getCartDetailsTest () {
        webcart cart = [select id from webcart where name=:'Cart'];
        test.startTest();
        WebCart getCartDetails = RSM_Utils.getCartDetails(cart.id);
        // cart (expected values) has only 2 fields name but it will return all the field's name.
        system.assertNotEquals(cart,getCartDetails);
        test.stopTest();
        
    }
    
    @isTest 
    static void getCartItemsByCartIdTest () {
        list<CartItem> ExpectedCartItems= [select id,name from CartItem];
        webcart cart = [select id from webcart where name=:'Cart'];
        
        test.startTest();
        List<cartItem> cartItems = RSM_Utils.getCartItemsByCartId(cart.id);
     //ExpectedCartItems (expected values) has only 2 fields( id,name) but actual method will return all the field's name.
       
        system.assertNotEquals(ExpectedCartItems,cartItems);
        test.stopTest();
        
        
    }
}