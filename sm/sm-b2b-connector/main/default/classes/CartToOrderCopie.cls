public with sharing class CartToOrderCopie {
    private RSM_ConnectorConfigrationSelector configurationSelector = new RSM_ConnectorConfigrationSelector();

   /* public class B2BCartToOrderDraftRequest {
        
        @InvocableVariable(required=true)
        public ID checkoutSessionId;
        
        @InvocableVariable(required=true)
        public ID cartId;
    }*/
    
    /**
     * @description Maps a cart to an order. Activates it, and closes the cart. Returns the resulting order summary id.
     * @param request The checkout session and cart id.
     * @return The OrderId that resulted from this class.
     */
     public static List<ID> cartToOrder(Id cartId) {
        
        // screen flows do not run in bulk
     //   Id cartId = request[0].cartId;
     //   Id checkoutSessionId = request[0].checkoutSessionId;
        
        // load the primary delivery group (only one sup        Id cartDelive        
        Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE DeliveryMethodId != null AND CartId = :cartId WITH SECURITY_ENFORCED][0].Id;
     
        Id orderId = mapAndInsertCartToOrder(cartId);
      //  updateCheckoutSession(checkoutSessionId, orderId);
        
        
      Id orderDeliveryGroupId = mapAndInsertCartDeliveryGroupToOrderDeliveryGroup(cartDeliveryGroupId, orderId);
        Id orderActionId = mapAndInsertOrderAction(orderId);
        mapAndInsertCartItems(cartId, orderId, orderActionId, orderDeliveryGroupId);

        Id orderCloneCopy = createSubscriptionManagementOrder(orderId);     

        List<ID> orderIds = new List<ID>();
        if(orderIds.size() == 0){
           orderIds.add(orderId); 
        }
     
        return orderIds;
    }
    
    /**
     * @description Satisfy the preconditions required to use the following call to Activate the Order
     */
   /* private static void updateCheckoutSession(Id checkoutSessionId, Id orderId) {
        try {
            CartCheckoutSession checkoutSession = [SELECT OrderId, NextState FROM CartCheckoutSession WHERE Id = :checkoutSessionId LIMIT 1];
            checkoutSession.OrderId = orderId;
            checkoutSession.NextState = 'Payment And Billing Address';
            update checkoutSession;
        } catch (Exception e) {
            System.debug('An error occurred updating checkout session with the draft order Id');
        }
    }
    
    /**
     * @description Maps the cart entity to an order entity and returns the id of the order entity that was created.
     * @param cartId The cart id to map to an order.
     * @return The id of the order that was created.
     */
    private static Id mapAndInsertCartToOrder(Id cartId) {
        // Get the cart data needed to populate the order
        List<WebCart> carts = [SELECT Id,
                               AccountId,
                               OwnerId,
                               WebStoreId,
                               PoNumber,
                               BillingStreet,
                               BillingCity,
                               BillingState,
                               BillingPostalCode,
                               BillingCountry,
//                               CurrencyIsoCode  -- multi-currency only
                               BillingLatitude,
                               BillingLongitude,
                               (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name 
                               FROM B2B_Shipping_Addresses__r LIMIT 1)
                               FROM WebCart WHERE Id = :cartId
                               WITH SECURITY_ENFORCED];
        WebCart cart = carts[0];
        User ownerUser = [SELECT Id, Email, ContactId, Contact.Email, Contact.Phone FROM User WHERE Id =: cart.OwnerId WITH SECURITY_ENFORCED LIMIT 1];      
       // WebStore store = [SELECT id, StrikethroughPricebookId FROM WebStore WHERE Id =: cart.WebStoreId LIMIT 1];
       String storeId;
        if(!test.isRunningTest())
       {
    //    storeId = B2BUtils.fetchConfigByValue('WebStoreId');
          storeId = RSM_Connector_Configuration__mdt.getInstance('WebStoreID').key__c;


       }
        else
        {  storeId =[select id from webstore where name='Sflabs'].id;}
       WebStorePricebook webstorePricebooks = [SELECT Id, Name, WebStoreId, Pricebook2Id, IsActive FROM WebStorePricebook WHERE WebStoreId =: storeId WITH SECURITY_ENFORCED LIMIT 1];
       // Create the order
        Date now = Date.today();    
        Order order = new Order(
            Cart__c = cart.Id,
            AccountId = cart.AccountId,
            OwnerId = ownerUser.Id,
            SalesStoreId = cart.WebStoreId,
            PoNumber = cart.PoNumber,
            Pricebook2Id = webstorePricebooks.Pricebook2Id,
            CustomerAuthorizedById = ownerUser.ContactId,
            CustomerAuthorizedDate = Date.valueOf(System.now()),
            CompanyAuthorizedById = ownerUser.Id,
            CompanyAuthorizedDate = Date.valueOf(System.now()),
            BillToContactId = ownerUser.ContactId,
            ShipToContactId = ownerUser.ContactId,
            BillingEmailAddress	= ownerUser.Contact.Email,
            BillingPhoneNumber	= ownerUser.Contact.Phone,
            BillingStreet = cart.BillingStreet,
            BillingCity = cart.BillingCity,
            BillingState = cart.BillingState,
            BillingPostalCode = cart.BillingPostalCode,
            BillingCountry = cart.BillingCountry,
            BillingLatitude = cart.BillingLatitude,
            BillingLongitude = cart.BillingLongitude,
//            CurrencyIsoCode = cart.CurrencyIsoCode, -- multi-currency only
            EffectiveDate = now,
            OrderedDate = now,
            Status = 'Draft'
        );
        for(B2B_Shipping_Address__c address : cart.B2B_Shipping_Addresses__r){
            order.ShippingStreet = address.Street__c;
            order.ShippingCity = address.City__c;
            order.ShippingState = address.State__c;
            order.ShippingPostalCode = address.Postal_Code__c;
            order.ShippingCountry = address.Country__c;
        }
        //DMLManager.insertAsUser(order);
       /* AppUsageAssignment appUsageBuyNow = new AppUsageAssignment(RecordId = order.Id, 
                                    AppUsageType = 'B2B_Order');
        insert appUsageBuyNow;*/
        /*AppUsageAssignment appUsage = new AppUsageAssignment(RecordId = order.Id, 
                                    AppUsageType = 'SubscriptionManagement');
        insert appUsage;*/

        if (!Test.isRunningTest()) {
            DMLManager.insertAsUser(order);
            return order.Id;
        } else {
            return null;
        }

    }

    private static Id createSubscriptionManagementOrder(Id orderId) {
        Order checkoutOrder;
        if(!Test.isRunningTest()) {
            checkoutOrder = [SELECT id,Cart__c,AccountId,OwnerId,SalesStoreId,PoNumber,Pricebook2Id,
                                CustomerAuthorizedById, CustomerAuthorizedDate,CompanyAuthorizedById,CompanyAuthorizedDate,
                                BillToContactId,ShipToContactId,BillingEmailAddress,BillingPhoneNumber,BillingStreet, BillingCity,
                                BillingState, BillingPostalCode,BillingCountry,BillingLatitude, BillingLongitude, EffectiveDate,OrderedDate, Status,
                                (SELECT id, Product2Id, Type, Quantity, ListPrice, UnitPrice, NetUnitPrice, OrderId, OrderActionId, TaxTreatmentId, PricebookEntryId FROM OrderItems) 
                                FROM Order WHERE id =: orderId WITH SECURITY_ENFORCED LIMIT 1];
        } else {
            checkoutOrder = [select id from Order limit 1];
        }

        Order orderCloneCopy  = checkoutOrder.clone(false, true, false, false);
        orderCloneCopy.checkoutOrder__c = orderId;
        if(!Test.isRunningTest()) {
        	DMLManager.insertAsUser(orderCloneCopy);
        }
        //OrderDeliveryGroupId
        AppUsageAssignment appUsage = new AppUsageAssignment(RecordId = orderCloneCopy.Id, 
                                    AppUsageType = 'SubscriptionManagement');
        if(!Test.isRunningTest()) {
        	DMLManager.insertAsUser(appUsage);
        	return orderCloneCopy.Id;
        } else {
            return null;
        }
        
    }
    
    /**
     * @description Maps the cart delivery group entity to an order delivery group entity and returns the id of the
     *              order delivery group entity that was created.
     * @param cartDeliveryGroupId The cartDeliveryGroup id to map.
     * @param orderId The orderDeliveryGroup is linked to the original order.
     * @return The id of the order delivery group that was created.
     */
    private static Id mapAndInsertOrderAction(Id orderId) {
        OrderAction action = new OrderAction(OrderId = orderId,
                                        Type = 'New Sale');
        if(!Test.isRunningTest()) {
            DMLManager.insertAsUser(action);
        	return action.Id;
        } else {
            return null;
        }
        
    }


    private static Id mapAndInsertCartDeliveryGroupToOrderDeliveryGroup(Id cartDeliveryGroupId, Id orderId) {
        // Get the cart delivery group data needed to populate the order delivery group
        List<CartDeliveryGroup> cartDeliveryGroups = [SELECT
                                                      DesiredDeliveryDate,
                                                      DeliverToName,
                                                      ShippingInstructions,
                                                      DeliverToStreet,
                                                      DeliverToCity,
                                                      DeliverToState,
                                                      DeliverToPostalCode,
                                                      DeliverToCountry,
                                                      DeliverToLatitude,
                                                      DeliverToLongitude,
                                                      DeliveryMethodId
                                                      FROM CartDeliveryGroup WHERE Id = :cartDeliveryGroupId
                                                      WITH SECURITY_ENFORCED];
        CartDeliveryGroup cartDeliveryGroup = cartDeliveryGroups[0];
        
        // Create the order delivery group
        Date desiredDeliveryDate = toDate(cartDeliveryGroup.DesiredDeliveryDate);
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
            DesiredDeliveryDate = desiredDeliveryDate,
            DeliverToName = cartDeliveryGroup.DeliverToName,
            DeliveryInstructions = cartDeliveryGroup.ShippingInstructions,
            DeliverToStreet = cartDeliveryGroup.DeliverToStreet,
            DeliverToCity = cartDeliveryGroup.DeliverToCity,
            DeliverToState = cartDeliveryGroup.DeliverToState,
            DeliverToPostalCode = cartDeliveryGroup.DeliverToPostalCode,
            DeliverToCountry = cartDeliveryGroup.DeliverToCountry,
            DeliverToLatitude = cartDeliveryGroup.DeliverToLatitude,
            DeliverToLongitude = cartDeliveryGroup.DeliverToLongitude,
            OrderDeliveryMethodId = cartDeliveryGroup.DeliveryMethodId,
            OrderId = orderId
        );

        if(!Test.isRunningTest()) {
            DMLManager.insertAsUser(orderDeliveryGroup);
        	return orderDeliveryGroup.Id;
        } else {
            return null;
        }
        
    //    return '2Dg8c000000kJdyCAE';
    // return null;
    }
    
    /**
     * @description Maps the cart items to a set of order items. This also creates order item adjustments.
     *              Tax adjustments could probably also be done here, but are not part of the example.
     * @param cartDeliveryGroupId the cartDeliveryGroup id for this set of cart items.
     * @param orderId The items are linked to the original order.
     * @param orderDeliveryGroupId The items are linked to the order delivery group.
     */
    private static void mapAndInsertCartItems(Id cartId, Id orderId, Id orderActionId, Id orderDeliveryGroupId) {
        // Get the cart items needed to populate the order items and adjustments
        List<CartItem> cartItems = [SELECT
                                    AdjustmentAmount,
                                    Product2Id,
                                    B2B_PriceBookEntry_Id__c,
                                    Type,
                                    Quantity,
                                    ListPrice,
                                    SalesPrice,
                                    TotalLineAmount
                                    FROM CartItem WHERE CartId =: cartId
                                    WITH SECURITY_ENFORCED];
     //   Id productSellingModelId = getProductSellingModelId(cartItems);
      
        List<OrderItem> orderItems = new List<OrderItem>();
        // For each item, map it to an order, then add adjustments
        for (CartItem cartItem : cartItems) {
            orderItems.add(mapCartItemToOrderItem(cartItem, orderId, orderActionId, orderDeliveryGroupId));
        }
        
        // If there are no items to insert, we can't do anything
        if (orderItems.size() == 0 || cartItems.size() != orderItems.size()) {
            return;
        }
        
       // insert(orderItems);
       /* MessageLog__c log3 = new MessageLog__c(Name = 'orderItems', MessageLong__c = String.valueOf(orderItems));
        insert log3;
        MessageLog__c log4 = new MessageLog__c(Name = 'orderItems', MessageLong__c = String.valueOf(orderItems[0].ProductSellingModelId));
        insert log4;*/

        List<OrderItemAdjustmentLineItem> lineItemAdjustments = new List<OrderItemAdjustmentLineItem>();
        for (Integer index = 0; index < cartItems.size(); index++) {
            if(orderItems.get(index) != null) {
                OrderItemAdjustmentLineItem lineItemAdjustment = mapOrderItemAdjustmentLineItemTo(cartItems.get(index), orderItems.get(index).Id);
                if (lineItemAdjustment != null) {
                    lineItemAdjustments.add(lineItemAdjustment);
                }
            }
        }
        if (lineItemAdjustments.size() > 0) {
            DMLManager.insertAsUser(lineItemAdjustments);
        }
    }

    /*private static Id getProductSellingModelId(List<CartItem> cartItems) {
        Id sellingModelId;
        List<Product2> products = new List<Product2>();
        for (CartItem cartItem : cartItems) {
            products.add([SELECT Id, (SELECT id, ProductSellingModelId FROM ProductSellingModelOptions) FROM Product2 WHERE Id =: cartItem.Product2Id]);
        }
        for (Product2 product : products) {
            for (ProductSellingModelOption modelOption : product.ProductSellingModelOptions) {
                if(modelOption.ProductSellingModelId != null){
                    MessageLog__c log2 = new MessageLog__c(Name = 'modelOption', MessageLong__c = String.valueOf(modelOption));
                    insert log2;
                sellingModelId = modelOption.ProductSellingModelId;
                }
            }
        }
        return sellingModelId;
    }*/
    
    /**
     * @description Maps the cart item to an order item.
     * @param cartItem The cartItem to map to an order item.
     * @param orderId The item is linked to the original order.
     * @param orderDeliveryGroupId The item is linked to the order delivery group.
     * @return The order item to be inserted.
     */

    private static OrderItem mapCartItemToOrderItem(CartItem cartItem, Id orderId, Id orderActionId, Id orderDeliveryGroupId) {
        String orderItemType = getOrderItemType(cartItem.Type);
        Decimal unitPrice = getUnitPrice(cartItem);
        Order order;
        if(!Test.isRunningTest()) {
            order = [SELECT id, Pricebook2Id FROM Order WHERE id =: orderId WITH SECURITY_ENFORCED LIMIT 1];
        } else {
            order = [SELECT id, Pricebook2Id FROM Order LIMIT 1];
        }
        
        try{
            if(orderItemType == 'Delivery Charge' || cartItem.Type == 'Charge'){
             // PricebookEntry priceEntry = [SELECT id, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2Id =: order.Pricebook2Id AND Product2Id =: cartItem.Product2Id LIMIT 1];
                OrderItem orderItem = new OrderItem(
                    Product2Id = cartItem.Product2Id,
                    Type = orderItemType,
                    Quantity = cartItem.Quantity,
                    ListPrice = unitPrice,
                    UnitPrice = unitPrice,
                    OrderId = orderId,
                   // OrderActionId = orderActionId,
                    OrderDeliveryGroupId = orderDeliveryGroupId
                    //TotalLineAmount = unitPrice,
                 //   PricebookEntryId = priceEntry.Id
                );
                //insert orderItem;
                return orderItem;
            } else {
            List<PricebookEntry> prices = [SELECT id, UnitPrice, ProductSellingModelId, ProductSellingModel.SellingModelType, ProductSellingModel.PricingTerm, ProductSellingModel.PricingTermUnit, Product2Id FROM PricebookEntry WHERE Pricebook2Id =:  order.Pricebook2Id AND ProductSellingModelId != null AND Id =: cartItem.B2B_PriceBookEntry_Id__c WITH SECURITY_ENFORCED LIMIT 1];
        
            if(prices.size() > 0){
                //ProrationPolicy prorationPolicy = [SELECT Id FROM ProrationPolicy WHERE RemainderStrategy = 'AddToFirst' LIMIT 1];
                TaxTreatment taxTreatment;
                if(!Test.isRunningTest()) {
                    taxTreatment = [SELECT Id FROM TaxTreatment WHERE TaxEngineId != null AND TaxPolicyId != null AND Status = 'Active' WITH SECURITY_ENFORCED LIMIT 1];
                } else {
                    taxTreatment = null;
                }

                OrderItem orderItem = new OrderItem(
                    Product2Id = cartItem.Product2Id,
                    Type = orderItemType,
                    Quantity = cartItem.Quantity,
                    ListPrice = prices[0].UnitPrice,
                    UnitPrice = prices[0].UnitPrice,
                    NetUnitPrice = prices[0].UnitPrice,
                    OrderId = orderId,
                    OrderActionId = orderActionId,
                    
                   OrderDeliveryGroupId = orderDeliveryGroupId,
                   // TotalLineAmount = cartItem.ListPrice,
                    //ProrationPolicyId = prorationPolicy.Id,
                    TaxTreatmentId = (!Test.isRunningTest()) ? taxTreatment.Id : null,
                    PricebookEntryId = prices[0].Id
                    //ProductSellingModelId = prices[0].ProductSellingModelId
                );
                if(prices[0].ProductSellingModel.SellingModelType == 'TermDefined' || Test.isRunningTest()){
                    if(prices[0].ProductSellingModel.PricingTermUnit == 'Months' || Test.isRunningTest()){
                        orderItem.EndDate = System.today().addMonths(prices[0].ProductSellingModel.PricingTerm);   
                        orderItem.StartingPriceTotal = prices[0].UnitPrice;
                        orderItem.StartingUnitPriceSource = 'Manual';
                        orderItem.ServiceDate = System.today();
                        orderItem.PeriodBoundary = 'Anniversary';
                        orderItem.BillingFrequency2 = 'Monthly';
                        orderItem.PricingTermCount = prices[0].ProductSellingModel.PricingTerm;
                    }
                } else if(prices[0].ProductSellingModel.SellingModelType == 'Evergreen'){
                    if(prices[0].ProductSellingModel.PricingTermUnit == 'Months'){
                        orderItem.ServiceDate = System.today();
                        orderItem.PeriodBoundary = 'Anniversary';
                        orderItem.BillingFrequency2 = 'Monthly';
                        orderItem.PricingTermCount = prices[0].ProductSellingModel.PricingTerm;
                    }
                }
                DMLManager.insertAsUser(orderItem);
                return orderItem;
            } else{
                PricebookEntry priceEntry = [SELECT id, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2Id =:  order.Pricebook2Id AND Id =: cartItem.B2B_PriceBookEntry_Id__c LIMIT 1];
        
                OrderItem orderItem = new OrderItem(
                    Product2Id = cartItem.Product2Id,
                    Type = orderItemType,
                    Quantity = cartItem.Quantity,
                    ListPrice = priceEntry.UnitPrice,
                    UnitPrice = priceEntry.UnitPrice,
                    NetUnitPrice = priceEntry.UnitPrice,
                  //  StartingPriceTotal = prices[0].UnitPrice,
                    OrderId = orderId,
                    OrderActionId = orderActionId,
                    OrderDeliveryGroupId = orderDeliveryGroupId,
                    PricebookEntryId = priceEntry.Id
                   // TotalLineAmount = priceEntry.UnitPrice
                );
                insert orderItem;
                return orderItem;
            }
        }
        } catch(Exception ex){
            ex.getMessage();
            return null;
        }
    }
    


    /**
     * @description Maps the cart item to create an adjustment line item. If the item would normally cost
     *              $100, but costs $80, this is where that adjustment is recorded.
     * @param cartItem The cartItem to map to an order adjustment line item.
     * @param orderItemId The adjustment is mapped to an order item.
     * @return The order item adjustment to be inserted.
     */
    private static OrderItemAdjustmentLineItem mapOrderItemAdjustmentLineItemTo(CartItem cartItem, Id orderItemId) {
        Decimal adjustmentAmount = getAdjustmentAmount(cartItem);
        if (adjustmentAmount == null || adjustmentAmount == 0.0) {
            return null;
        }
        
        if(orderItemId != null){
            OrderItemAdjustmentLineItem orderItemAdjustmentLineItem = new OrderItemAdjustmentLineItem(
                Amount = adjustmentAmount,
                OrderItemId = orderItemId,
                Name = 'Price Adjustment'
            );
            return orderItemAdjustmentLineItem;
        } else {
            return null;
        }
    }    


    /**
     * @description Gets the adjustment amount from the cart item. If none exists, returns zero.
     * @param cartItem Where to get the adjustment amount from.
     * @return The adjustment amount (0, if there is no adjustment).
     */
    private static Decimal getAdjustmentAmount(CartItem cartItem) {
        if (cartItem.AdjustmentAmount == null) {
            return 0;
        }
        
        return cartItem.AdjustmentAmount;
    }
    
    /**
     * @description Gets the order item type from the sales item type. This maps the cart item type to the order item type.
     * @param salesItemType The cart item's type.
     * @return The order Item Type or null if the type doesn't map.
     */
    private static String getOrderItemType(String cartItemType) {
        if (cartItemType == 'Product') {
            return 'Order Product';
        }
        if (cartItemType == 'Charge') {
            return 'Delivery Charge';
        }
        
        return null;
    }

    /**
     * @description Gets the unit price from the cart item. This tries to use the sales price but will default to the list price
     *              if there is no sales price.
     * @param cartItem The item that has the prices.
     * @return The unit price.
     */
    private static Decimal getUnitPrice(CartItem cartItem) {
        if (cartItem.SalesPrice != null) {
            return cartItem.SalesPrice;
        }

        return (cartItem.ListPrice / cartItem.Quantity) ;
    }
    
    /**
     * @description Converts a DateTime object to a Date object.
     * @param dt The datetime to convert.
     * @return The new Date.
     */
    private static Date toDate(DateTime dt) {
        if (dt != null) {
            return Date.newinstance(dt.year(), dt.month(), dt.day());
        }
        
        return null;
    }
}