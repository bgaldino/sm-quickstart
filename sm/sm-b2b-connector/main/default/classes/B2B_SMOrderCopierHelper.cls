public without sharing class B2B_SMOrderCopierHelper {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CHECKOUT_FLOW);

    public static void cloneSmOrderToCheckoutOrder(Set<Id> orderIds){
        try {
            for(Id orderId : orderIds){
                createNewCheckoutOrder(orderId);
            }
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
    }

    public static void createNewCheckoutOrder(Id orderId){
        try {
            Date todayDate = Date.today();
            Order subscriptionOrder = [SELECT id,Cart__c,AccountId,OwnerId,SalesStoreId,PoNumber,Pricebook2Id,
                                       CustomerAuthorizedById, CustomerAuthorizedDate,CompanyAuthorizedById,CompanyAuthorizedDate,
                                       BillToContactId,ShipToContactId,BillingEmailAddress,BillingPhoneNumber,BillingStreet, BillingCity,
                                       BillingState, BillingPostalCode,BillingCountry,BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity,
                                       ShippingState, ShippingPostalCode,ShippingCountry,ShippingLatitude, ShippingLongitude, EffectiveDate,OrderedDate, Status, smOrder__c,
                                       (SELECT Id, Type, TypeCode, Quantity, ListPrice, UnitPrice, 
                                       NetUnitPrice, OrderId,ProductSellingModelId, OrderActionId, 
                                       TaxTreatmentId, PricebookEntryId,EndDate, StartingPriceTotal, 
                                       StartingUnitPriceSource, ServiceDate, PeriodBoundary, BillingFrequency2, 
                                       PricingTermCount, ProductSellingModel.SellingModelType 
                                       FROM OrderItems 
                                       WHERE EndDate != :todayDate AND Quantity > 0 AND ProductSellingModel.SellingModelType != 'One-Time')
                                       FROM Order WHERE (Order.LastCloneDate__c <= LAST_MONTH OR Order.LastCloneDate__c = NULL) AND id =: orderId LIMIT 1];
            Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE DeliveryMethodId != null AND CartId = :subscriptionOrder.Cart__c][0].Id;
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
                                                          FROM CartDeliveryGroup WHERE Id = :cartDeliveryGroupId];
            CartDeliveryGroup cartDeliveryGroup = cartDeliveryGroups[0];
            Order orderCloneCopy = subscriptionOrder.clone(false,true);
                orderCloneCopy.Order_Type__c = 'B2B Order';
                orderCloneCopy.smOrder__c = subscriptionOrder.Id;
                orderCloneCopy.EffectiveDate = todayDate.addDays(1);
                orderCloneCopy.OrderedDate = todayDate.addDays(1);
                orderCloneCopy.LastCloneDate__c = todayDate;
                orderCloneCopy.Status = 'Draft';
            DMLManager.insertAsSystem(orderCloneCopy);
            subscriptionOrder.LastCloneDate__c = Date.today();
            DMLManager.updateAsUser(subscriptionOrder);

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
                        OrderId = orderCloneCopy.Id
            );
            DMLManager.insertAsUser(orderDeliveryGroup);

            Id orderActionId = mapAndInsertOrderAction(orderCloneCopy.id);

            List<OrderItem> orderItemsList = new List<OrderItem>();
            for(OrderItem items : subscriptionOrder.OrderItems){
                OrderItem itemCopy = items.clone(false,true);
                itemCopy.OrderId = orderCloneCopy.Id;
                itemCopy.ServiceDate = todayDate.addDays(1);
                itemCopy.OrderDeliveryGroupId = orderDeliveryGroup.Id;
                itemCopy.OrderActionId = orderActionId;
                itemCopy.UnitPrice = items.ListPrice;
                if(items.ProductSellingModel.SellingModelType == 'TermDefined') {
                    itemCopy.EndDate = System.today().addMonths(1);
                }
                orderItemsList.add(itemCopy);
            }
            DMLManager.insertAsSystem(orderItemsList);

            orderCloneCopy.Status = 'Activated';
            DMLManager.updateAsUser(orderCloneCopy);
            if(!Test.isRunningTest()){
                ConnectApi.OrderSummaryOutputRepresentation createdOrderSummary = createOrderSummary(orderCloneCopy.Id);   
            }
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
    }

    private static Date toDate(DateTime dt) {
        if (dt != null) {
            return Date.newinstance(dt.year(), dt.month(), dt.day());
        }
        
        return null;
    }

    private static Id mapAndInsertOrderAction(Id orderId) {
        try {
            OrderAction action = new OrderAction(OrderId = orderId, Type = 'New Sale');
            DMLManager.insertAsUser(action);
            return action.Id;
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        }
    }

    private static ConnectApi.OrderSummaryOutputRepresentation createOrderSummary(String orderId){
        try {
            Map<String,Object> result = new Map<String,Object>();
            ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId = orderId;
            osir.orderLifeCycleType = 'UNMANAGED';
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
            return osor;
        } catch (Exception ex) {
            logger.error(ex);
            return null;
        } finally {
            logger.flush();
        } 
    }
}