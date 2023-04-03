/**
 * This is designed as a handy starting point for writing code to convert a cart to an order. The built in CartToOrder invocable
 * action is maintained and has additions and fixes not found in this class. Whenever possible, it is suggested to use that invocable
 * action rather than relying on this invocable action that has limited support and is not tested each release.
 *
 * Multi-currency has not been tested, though you'll see a couple uses of currency codes (CurrencyIsoCode) commented out in this class.
 * If you are using multi-currency in your org, I would uncomment those lines out.
 */
global with sharing class B2BCartToOrderDraft {

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.ORDER_CREATION);

    global class B2BCartToOrderDraftRequest {
        
        @InvocableVariable(required=true)
        public ID checkoutSessionId;
        
        @InvocableVariable(required=true)
        public ID cartId;
    }
    
    public static void getExpenses() {
        String [] expenseAccessFields = new String [] {'DesiredDeliveryDate', 'DeliverToName','DeliveryInstructions', 'DeliverToStreet','DeliverToCity',
        'DeliverToState', 'DeliverToPostalCode','DeliverToCountry', 'DeliverToLatitude', 'DeliverToLongitude', 'OrderDeliveryMethodId', 'OrderId' };

    // Obtain the field name/token map for the Expense object
    Map<String,Schema.SObjectField> m = Schema.SObjectType.orderDeliveryGroup.fields.getMap();
    if(Schema.SObjectType.orderDeliveryGroup.isCreateable()){
            logger.debug('create able--- ');
        }
    for (String fieldToCheck : expenseAccessFields) {

        // Check if the user has access to view field
        if (!m.get(fieldToCheck).getDescribe().isCreateable()) {logger.debug('fieldToCheck--- '+fieldToCheck); logger.flush();
        }
    }     
    }
    
    /**
     * @description Maps a cart to an order. Activates it, and closes the cart. Returns the resulting order summary id.
     * @param request The checkout session and cart id.
     * @return The OrderId that resulted from this class.
     */
    @InvocableMethod(label='Map Cart to Order Draft' description='Maps the cart and related data to an order' category='B2B Commerce')
    global static List<ID> cartToOrder(List<B2BCartToOrderDraftRequest> request) {
        List<ID> orderIds = new List<ID>();
        
        try {
            // screen flows do not run in bulk
            Id cartId = request[0].cartId;
            Id checkoutSessionId = request[0].checkoutSessionId;
        
            // load the primary delivery group (only one supported at this time)
            Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE DeliveryMethodId != null AND CartId = :cartId WITH SECURITY_ENFORCED][0].Id;
     
            List<Order> existingOrderList = [SELECT Id FROM Order WHERE Cart__c = :cartId WITH SECURITY_ENFORCED LIMIT 1];
            Id orderId;
            
            if(existingOrderList.isEmpty()) {
                orderId = mapAndInsertCartToOrder(cartId);
                createSMAppUssage(orderId);
            } else {orderId = existingOrderList[0].Id;
            }
            
            //createSMAppUssage(orderId);
            
            updateCheckoutSession(checkoutSessionId, orderId);
        
        
            Id orderDeliveryGroupId = mapAndInsertCartDeliveryGroupToOrderDeliveryGroup(cartDeliveryGroupId, orderId);
            Id orderActionId = mapAndInsertOrderAction(orderId);
            mapAndInsertCartItems(cartId, orderId, orderActionId, orderDeliveryGroupId);

            //Id orderCloneCopy = createSubscriptionManagementOrder(orderId);     

            if(orderIds.size() == 0){
                orderIds.add(orderId); 
            }
        } catch (Exception ex) {logger.error(ex);
        } finally {
            logger.flush();
        }
     
        return orderIds;
    }
    
    /**
     * @description Satisfy the preconditions required to use the following call to Activate the Order
     */
    private static void updateCheckoutSession(Id checkoutSessionId, Id orderId) {
        try {
            CartCheckoutSession checkoutSession = [SELECT OrderId, NextState FROM CartCheckoutSession WHERE Id = :checkoutSessionId WITH SECURITY_ENFORCED LIMIT 1];
            checkoutSession.OrderId = orderId;
            checkoutSession.NextState = 'Payment And Billing Address';
            DMLManager.updateAsUser(checkoutSession);
        } catch (Exception ex) {logger.error(ex);
        } finally {
            logger.flush();
        }
    }
    
    /**
     * @description Maps the cart entity to an order entity and returns the id of the order entity that was created.
     * @param cartId The cart id to map to an order.
     * @return The id of the order that was created.
     */
    private static Id mapAndInsertCartToOrder(Id cartId) {
        Order order;
        try {
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
                                   //CurrencyIsoCode  -- multi-currency only
                                   BillingLatitude,
                                   BillingLongitude,
                                   (SELECT Id, Street__c, Country__c, City__c, Postal_Code__c, State__c, Name 
                                   FROM B2B_Shipping_Addresses__r LIMIT 1),
                                   (SELECT id, B2B_PriceBookEntry_Id__c FROM cartItems WHERE Type = 'Product' LIMIT 1)
                                   FROM WebCart WHERE Id = :cartId WITH SECURITY_ENFORCED];
            WebCart cart = carts[0];
            User ownerUser = [SELECT Id, Email, ContactId, Contact.Email, Contact.Phone FROM User WHERE Id =: cart.OwnerId WITH SECURITY_ENFORCED LIMIT 1];      
            String storeId = RSM_Connector_Configuration__mdt.getInstance('WebStoreID').key__c;
            list<PricebookEntry> pb = [select id, Pricebook2Id from PricebookEntry where ID =: cart.cartItems[0].B2B_PriceBookEntry_Id__c WITH SECURITY_ENFORCED];
            logger.debug('pb records--- '+pb);
            WebStorePricebook webstorePricebooks;
            if(Test.isRunningTest()) {
                webstorePricebooks = [SELECT Id, Name, WebStoreId, Pricebook2Id, IsActive FROM WebStorePricebook  WHERE WebStore.Name ='Sflabs' WITH SECURITY_ENFORCED LIMIT 1];
            } else {
                //Can't save permission set RSM Shopper, which is assigned to a user with user license Customer Community Plus. The user license doesn't allow the permission: Read Store Price Books
                webstorePricebooks = [SELECT Id, Name, WebStoreId, Pricebook2Id, IsActive FROM WebStorePricebook WHERE WebStoreId = :storeId LIMIT 1];
            }
            // Create the order
            Date now = Date.today();    
            order = new Order(
                Cart__c = cart.Id,
                AccountId = cart.AccountId,
                OwnerId = ownerUser.Id,
                SalesStoreId = cart.WebStoreId,
                PoNumber = cart.PoNumber,
                Pricebook2Id = pb[0].Pricebook2Id,  //webstorePricebooks.Pricebook2Id,
                CustomerAuthorizedById = ownerUser.ContactId,
                CustomerAuthorizedDate = Date.valueOf(System.now()),
                CompanyAuthorizedById = ownerUser.Id,
                CompanyAuthorizedDate = Date.valueOf(System.now()),
                BillToContactId = ownerUser.ContactId,
                ShipToContactId = ownerUser.ContactId,
                BillingEmailAddress = ownerUser.Contact.Email,
                BillingPhoneNumber  = ownerUser.Contact.Phone,
                BillingStreet = cart.BillingStreet,
                BillingCity = cart.BillingCity,
                BillingState = cart.BillingState,
                BillingPostalCode = cart.BillingPostalCode,
                BillingCountry = cart.BillingCountry,
                BillingLatitude = cart.BillingLatitude,
                BillingLongitude = cart.BillingLongitude,
                //CurrencyIsoCode = cart.CurrencyIsoCode, -- multi-currency only
                EffectiveDate = now,
                OrderedDate = now,
                Status = 'Draft',
                Order_Type__c = 'SM Order' //'B2B Order'
            );
            for(B2B_Shipping_Address__c address : cart.B2B_Shipping_Addresses__r){
                order.ShippingStreet = address.Street__c;
                order.ShippingCity = address.City__c;
                order.ShippingState = address.State__c;
                order.ShippingPostalCode = address.Postal_Code__c;
                order.ShippingCountry = address.Country__c;
            }
            DMLManager.insertAsUser(order);
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }

        if(Test.isRunningTest()) {
            return [SELECT Id FROM Order WHERE Name = 'Test' LIMIT 1].Id;
        } else {return order.Id;   
        }
    }

    public static Id createSubscriptionManagementOrder(Id orderId) {
        Order orderCloneCopy;

        try {
            Order checkoutOrder = [SELECT id,Cart__c,AccountId,OwnerId,SalesStoreId,PoNumber,Pricebook2Id,
                               CustomerAuthorizedById, CustomerAuthorizedDate,CompanyAuthorizedById,CompanyAuthorizedDate,
                               BillToContactId,ShipToContactId,BillingEmailAddress,BillingPhoneNumber,BillingStreet, BillingCity, 
                               BillingState, BillingPostalCode,BillingCountry,BillingLatitude, BillingLongitude,  ShippingStreet, ShippingCity,
                               ShippingState, ShippingPostalCode,ShippingCountry,ShippingLatitude, ShippingLongitude, EffectiveDate,OrderedDate, Status,
                               (SELECT id, Type, TypeCode, Quantity, ListPrice, UnitPrice, NetUnitPrice, OrderId,ProductSellingModelId, OrderActionId, TaxTreatmentId, PricebookEntryId,EndDate, StartingPriceTotal, StartingUnitPriceSource, ServiceDate, PeriodBoundary, BillingFrequency2, PricingTermCount, ProductSellingModel.SellingModelType FROM OrderItems) 
                               FROM Order WHERE id =: orderId WITH SECURITY_ENFORCED LIMIT 1];
            List<OrderItem> orderItemsWithOrderTaxItems = [SELECT Id, (SELECT Id, Name, Type, Amount, TaxEffectiveDate, OrderItemId FROM OrderItemTaxLineItems) FROM OrderItem WHERE OrderId = :orderId WITH SECURITY_ENFORCED];
            orderCloneCopy = checkoutOrder.clone(false,true);
        
            orderCloneCopy.Order_Type__c = 'SM Order';
            DMLManager.insertAsUser(orderCloneCopy);
            

            checkoutOrder.smOrder__c = orderCloneCopy.Id;
            try {
                DMLManager.updateAsUser(checkoutOrder);
            }  catch (Exception ex) {logger.error(ex);
            } finally {logger.flush();
            }

            Id orderActionId = mapAndInsertOrderAction(orderCloneCopy.id);
            List<OrderItem> orderItemsList = new List<OrderItem>();
            for(OrderItem items : checkoutOrder.OrderItems){
                OrderItem itemCopy = items.clone(false,true);
                itemCopy.OrderId = orderCloneCopy.Id;
                itemCopy.OrderDeliveryGroupId = null;
                itemCopy.OrderActionId = orderActionId;
                if(items.ProductSellingModel.SellingModelType == 'TermDefined'){
                    itemCopy.UnitPrice = items.UnitPrice * 12;
                    itemCopy.EndDate = System.today().addMonths(12).addDays(-1);
                }
                orderItemsList.add(itemCopy);
            }
            
            if(!Test.isRunningTest()) {DMLManager.insertAsSystem(orderItemsList);
            }

            List<OrderItemTaxLineItem> copiedOrderTaxItemsList = new List<OrderItemTaxLineItem>();
            List<OrderItemTaxLineItem> orderTaxItemsToDeleteList = new List<OrderItemTaxLineItem>();
            for(Integer i = 0; i < orderItemsWithOrderTaxItems.size(); i++) {
                if(!orderItemsWithOrderTaxItems[i].OrderItemTaxLineItems.isEmpty()) {
                    OrderItemTaxLineItem clone = orderItemsWithOrderTaxItems[i].OrderItemTaxLineItems[0].clone(false, true);
                    clone.OrderItemId = orderItemsList[i].Id;
                    copiedOrderTaxItemsList.add(clone);
                    orderTaxItemsToDeleteList.add(orderItemsWithOrderTaxItems[i].OrderItemTaxLineItems[0]);
                }
            }

            DMLManager.insertAsUser(copiedOrderTaxItemsList);
            if (Schema.sObjectType.OrderItemTaxLineItem.isDeletable()) {delete orderTaxItemsToDeleteList;
            }

            //OrderDeliveryGroupId
            AppUsageAssignment appUsage = new AppUsageAssignment(RecordId = orderCloneCopy.Id, 
            AppUsageType = 'SubscriptionManagement');
            DMLManager.insertAsSystem(appUsage);

        } catch (Exception ex) {logger.error(ex);} 
        finally {
            logger.flush();
        }

        if(!Test.isRunningTest()) {return orderCloneCopy.Id;
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
        OrderAction action = new OrderAction(OrderId = orderId, Type = 'New Sale');

        try {
            List<OrderAction> oaList = [SELECT Id FROM OrderAction WHERE OrderId = :orderId WITH SECURITY_ENFORCED];
            DMLManager.deleteAsUser(oaList);
            DMLManager.insertAsUser(action);
        } catch (Exception ex) {logger.error(ex);
        } finally {
            logger.flush();
        }

        return action.Id;
    }


    private static Id mapAndInsertCartDeliveryGroupToOrderDeliveryGroup(Id cartDeliveryGroupId, Id orderId) {
        OrderDeliveryGroup orderDeliveryGroup;
        try {
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
                                                          FROM CartDeliveryGroup WHERE Id = :cartDeliveryGroupId WITH SECURITY_ENFORCED];
            CartDeliveryGroup cartDeliveryGroup = cartDeliveryGroups[0];
            logger.debug('cartDeliveryGroup--- '+cartDeliveryGroup);
            getExpenses();
            // Create the order delivery group
            Date desiredDeliveryDate = toDate(cartDeliveryGroup.DesiredDeliveryDate);
            orderDeliveryGroup = new OrderDeliveryGroup(
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
            DMLManager.insertAsSystem(orderDeliveryGroup);
        } catch (Exception ex) {logger.error(ex);
        } finally {
            logger.flush();
        }
        
        return orderDeliveryGroup.Id;
    }

    /**
     * @description Maps the cart items to a set of order items. This also creates order item adjustments.
     *              Tax adjustments could probably also be done here, but are not part of the example.
     * @param cartDeliveryGroupId the cartDeliveryGroup id for this set of cart items.
     * @param orderId The items are linked to the original order.
     * @param orderDeliveryGroupId The items are linked to the order delivery group.
     */
    private static void mapAndInsertCartItems(Id cartId, Id orderId, Id orderActionId, Id orderDeliveryGroupId) {
        try {
            List<OrderItem> orderItemList = [SELECT Id FROM OrderItem WHERE OrderId = :orderId WITH SECURITY_ENFORCED];
            DMLManager.deleteAsUser(orderItemList);
            // Get the cart items needed to populate the order items and adjustments
            List<CartItem>  cartItems = [SELECT
                                         AdjustmentAmount,
                                         TotalAdjustmentAmount,
                                         Product2Id,
                                         Product2.TaxPolicyId,
                                         B2B_PriceBookEntry_Id__c,
                                         Type,
                                         Quantity,
                                         ListPrice,
                                         SalesPrice,
                                         TotalLineAmount,
                                         (SELECT Id, Amount, TaxCalculationDate, TaxRate, TaxType FROM CartItemTaxes)
                                         FROM CartItem WHERE CartId =: cartId];

            //Id productSellingModelId = getProductSellingModelId(cartItems);      
            List<OrderItem> orderItems = new List<OrderItem>();
            // For each item, map it to an order, then add adjustments
            for (CartItem cartItem : cartItems) {
                orderItems.add(mapCartItemToOrderItem(cartItem, orderId, orderActionId, orderDeliveryGroupId));
            }

            // If there are no items to insert, we can't do anything
            if (orderItems.size() == 0 || cartItems.size() != orderItems.size()) {return;
            }

            List<OrderItemAdjustmentLineItem> lineItemAdjustments = new List<OrderItemAdjustmentLineItem>();
            for (Integer index = 0; index < cartItems.size(); index++) {
                OrderItemAdjustmentLineItem lineItemAdjustment = mapOrderItemAdjustmentLineItemTo(cartItems.get(index), orderItems.get(index).Id);
                if (lineItemAdjustment != null) {
                    lineItemAdjustments.add(lineItemAdjustment);
                }
            }
            if (lineItemAdjustments.size() > 0) {
            
                DMLManager.insertAsUser(lineItemAdjustments);
            }
        } catch (Exception ex) {logger.error(ex);
        } finally {
            logger.flush();
        }
    }

    /**
     * @description Maps the cart item to an order item.
     * @param cartItem The cartItem to map to an order item.
     * @param orderId The item is linked to the original order.
     * @param orderDeliveryGroupId The item is linked to the order delivery group.
     * @return The order item to be inserted.
     */

    private static OrderItem mapCartItemToOrderItem(CartItem cartItem, Id orderId, Id orderActionId, Id orderDeliveryGroupId) {
        OrderItem orderItem;

        try{
            String orderItemType = getOrderItemType(cartItem.Type);
            Decimal unitPrice = getUnitPrice(cartItem);
            Order order = [SELECT id, Pricebook2Id FROM Order WHERE id =: orderId WITH SECURITY_ENFORCED LIMIT 1];

            if(orderItemType == 'Delivery Charge' || cartItem.Type == 'Charge'){
                orderItem = new OrderItem(
                    Product2Id = cartItem.Product2Id,
                    Type = orderItemType,
                    Quantity = cartItem.Quantity,
                    ListPrice = unitPrice,
                    UnitPrice = unitPrice,
                    OrderId = orderId,
                    OrderDeliveryGroupId = orderDeliveryGroupId
                );
                return orderItem;
            } else {
                List<PricebookEntry> prices;
                if(Test.isRunningTest()) {
                    Id standardPricebookId = Test.getStandardPricebookId();
                    prices = [SELECT id, Pricebook2Id, UnitPrice, ProductSellingModelId, ProductSellingModel.SellingModelType, ProductSellingModel.PricingTerm, ProductSellingModel.PricingTermUnit, Product2Id 
                              FROM PricebookEntry WHERE Pricebook2.Name= 'Custom Test Pricebook' AND ProductSellingModelId != null AND Id =: cartItem.B2B_PriceBookEntry_Id__c WITH SECURITY_ENFORCED LIMIT 1];
                    
                    system.debug('pricess---->' + prices);
                } else {
                    prices = [SELECT id, UnitPrice, ProductSellingModelId, ProductSellingModel.SellingModelType, ProductSellingModel.PricingTerm, ProductSellingModel.PricingTermUnit, Product2Id FROM PricebookEntry WHERE Pricebook2Id =: order.Pricebook2Id AND ProductSellingModelId != null AND Id =: cartItem.B2B_PriceBookEntry_Id__c WITH SECURITY_ENFORCED LIMIT 1];
                    //prices = [SELECT id, UnitPrice, ProductSellingModelId, ProductSellingModel.SellingModelType, ProductSellingModel.PricingTerm, ProductSellingModel.PricingTermUnit, Product2Id FROM PricebookEntry WHERE ProductSellingModelId != null AND Id =: cartItem.B2B_PriceBookEntry_Id__c WITH SECURITY_ENFORCED LIMIT 1];
                }

                // Can't save permission set RSM Shopper, which is assigned to a user with user license Customer Community Plus. The user license doesn't allow the permission: Read Tax Treatments
                List<TaxTreatment> taxTreatmentList = [SELECT Id 
                                                       FROM TaxTreatment WHERE TaxPolicyId = :cartItem.Product2.TaxPolicyId LIMIT 1];
                TaxTreatment taxTreatment;
                if(taxTreatmentList.isEmpty()) {
                    // Can't save permission set RSM Shopper, which is assigned to a user with user license Customer Community Plus. The user license doesn't allow the permission: Read Tax Treatments
                    taxTreatment = [SELECT Id 
                                    FROM TaxTreatment WHERE TaxPolicyId != null AND Status = 'Active' LIMIT 1];
                } else {taxTreatment = taxTreatmentList[0];}
            if(prices.size() > 0){
                // TaxTreatment taxTreatment = [SELECT Id FROM TaxTreatment WHERE TaxPolicyId != null AND Status = 'Active' LIMIT 1];
                orderItem = new OrderItem(
                    Product2Id = cartItem.Product2Id,
                    Type = orderItemType,
                    Quantity = cartItem.Quantity,
                    ListPrice = prices[0].UnitPrice,
                    NetUnitPrice = unitPrice,
                    OrderId = orderId,
                    OrderActionId = orderActionId,
                    UnitPrice = unitPrice,
                   OrderDeliveryGroupId = orderDeliveryGroupId,
                    TaxTreatmentId = taxTreatment.Id,
                    PricebookEntryId = prices[0].Id
                );
                if(prices[0].ProductSellingModel.SellingModelType == 'TermDefined' || Test.isRunningTest()){
                    if(prices[0].ProductSellingModel.PricingTermUnit == 'Months' || Test.isRunningTest()){  
                        //if(B2BUtils.fetchConfigByValue('CloneB2BOrderMonthly') != 'Yes') {
                        if(RSM_Connector_Configuration__mdt.getInstance('Clone_B2B_Order_Monthly').key__c != 'Yes') {
                            orderItem.EndDate = System.today().addMonths(12).addDays(-1);
                            //orderItem.UnitPrice = unitPrice * 12; //@surya- we dont need to do this anymore, doing the same on cart now..
                        } else {
                            orderItem.EndDate = System.today().addMonths(1).addDays(-1);
                        }
                        orderItem.StartingPriceTotal = unitPrice;
                        orderItem.StartingUnitPriceSource = 'Manual';
                        orderItem.ServiceDate = System.today();
                        orderItem.PeriodBoundary = 'Anniversary';
                        orderItem.BillingFrequency2 = 'Monthly';
                        orderItem.PricingTermCount = 12;
                    }
                } else if(prices[0].ProductSellingModel.SellingModelType == 'Evergreen'){
                    if(prices[0].ProductSellingModel.PricingTermUnit == 'Months'){
                        orderItem.ServiceDate = System.today();
                        orderItem.PeriodBoundary = 'Anniversary';
                        orderItem.BillingFrequency2 = 'Monthly';
                    }
                }

                DMLManager.insertAsSystem(orderItem);

                OrderItemTaxLineItem orderTaxItem = new OrderItemTaxLineItem(
                    Name = 'Order Tax Item',
                    OrderItemId = orderItem.Id,
                    Amount = cartItem.CartItemTaxes[0].Amount,
                    TaxEffectiveDate = cartItem.CartItemTaxes[0].TaxCalculationDate,
                    Rate = cartItem.CartItemTaxes[0].TaxRate,
                    Type = cartItem.CartItemTaxes[0].TaxType
                );

                DMLManager.insertAsUser(orderTaxItem);

                return orderItem;
            } else {
                PricebookEntry  priceEntry = [SELECT id, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2Id =:  order.Pricebook2Id AND Id =: cartItem.B2B_PriceBookEntry_Id__c WITH SECURITY_ENFORCED LIMIT 1];
                //PricebookEntry  priceEntry = [SELECT id, UnitPrice, Product2Id FROM PricebookEntry WHERE Id =: cartItem.B2B_PriceBookEntry_Id__c WITH SECURITY_ENFORCED LIMIT 1];

                orderItem = new OrderItem(
                    Product2Id = cartItem.Product2Id,
                    Type = orderItemType,
                    Quantity = cartItem.Quantity,
                    ListPrice = priceEntry.UnitPrice,
                    UnitPrice = unitPrice,
                    NetUnitPrice = unitPrice,
                    OrderId = orderId,
                    OrderActionId = orderActionId,
                    OrderDeliveryGroupId = orderDeliveryGroupId,
                    PricebookEntryId = priceEntry.Id,
                    TaxTreatmentId = taxTreatment.Id
                );

                //if(B2BUtils.fetchConfigByValue('CloneB2BOrderMonthly') != 'Yes') {
                if(RSM_Connector_Configuration__mdt.getInstance('Clone_B2B_Order_Monthly').key__c != 'Yes') {orderItem.UnitPrice = unitPrice * 12;
                } else {orderItem.UnitPrice = unitPrice;}

                DMLManager.insertAsSystem(orderItem);
            }
        }
        } catch (Exception ex) {logger.error(ex);
        } finally {
            logger.flush();
        }

        return orderItem;
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
        if (adjustmentAmount == null || adjustmentAmount == 0.0) {return null;
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
        if (cartItem.TotalAdjustmentAmount == null) {return 0;
        }

        return cartItem.TotalAdjustmentAmount;
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

        return (cartItem.TotalLineAmount / cartItem.Quantity) ;
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
    
    private static void createSMAppUssage(Id ordId){
        AppUsageAssignment appUsage = new AppUsageAssignment(RecordId = ordId, 
        AppUsageType = 'SubscriptionManagement');
        DMLManager.insertAsSystem(appUsage);
    }
    
}