/**
 * Created by scheck on 2019-05-08.
 */

public with sharing class CPQB_ConsumptionUploaderCTRL {
/**
* Create a new Usage Record
*/
    @AuraEnabled
    public static Id createRecord(blng__Usage__c usageRecord) {
        System.debug('CreateCandidateRecord::createRecord::usageRecord' + usageRecord);
        try {
            if (usageRecord != null) {
                Database.insert(usageRecord);
            }
            return usageRecord.Id;

        } catch (DmlException e) {
            System.debug('An Error Occurred: ');
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * Pull up all related product orders for picklist
    *
    */
    @AuraEnabled
    public static List<OrderItem> getUsageOrderItems(String orderId) {
        List<OrderItem> usageOrderItems = new List<OrderItem>([
                SELECT
                        Id,
                        OrderItemNumber,
                        Order.Id,
                        Order.Account.Name,
                        Order.Account.AccountNumber,
                        Product2Id,
                        Product2.Name
                FROM OrderItem
                WHERE SBQQ__ChargeType__c = 'Usage'
                AND Order.Id = :orderId]);

        System.debug('---- Usage Order Items:');
        System.debug(usageOrderItems);

        List<OrderItem> consumptionOrderItems = new List<OrderItem>([
                SELECT
                        Id,
                        OrderItemNumber,
                        Order.Id,
                        Order.Account.Name,
                        Order.Account.AccountNumber,
                        Product2Id,
                        Product2.Name
                FROM OrderItem
                WHERE Id IN (SELECT
                        SBQQ__OrderItem__c
                FROM SBQQ__OrderItemConsumptionSchedule__c)
                AND Order.Id = :orderId]);

        System.debug('---- Consumption Order Items:');
        System.debug(consumptionOrderItems);
        usageOrderItems.addAll(consumptionOrderItems);

        System.debug('---- Combined Order Items:');
        System.debug(usageOrderItems);
        return usageOrderItems;
    }


    @AuraEnabled
    public static Map<String, List<SBQQ__OrderItemConsumptionSchedule__c>> getOIConsumptionSchedules(String orderId) {
        // Order Items that have consumption schedules
        Map<Id, OrderItem> orderItems = new Map<Id, OrderItem>([
                SELECT
                        Id,
                        OrderItemNumber,
                        Order.Id,
                        Order.Account.Name,
                        Order.Account.AccountNumber,
                        Product2Id,
                        Product2.Name,
                (SELECT
                        Id,
                        Name,
                        SBQQ__MatchingAttribute__c,
                        SBQQ__UnitOfMeasure__c
                FROM SBQQ__OrderItems__r)
                FROM OrderItem
                WHERE Id IN (SELECT
                        SBQQ__OrderItem__c
                FROM SBQQ__OrderItemConsumptionSchedule__c)
                AND Order.Id = :orderId]);

        Map<String, List<SBQQ__OrderItemConsumptionSchedule__c>> orderItemConsumptionSchedulesByStrings = new Map<String, List<SBQQ__OrderItemConsumptionSchedule__c>>();

        for(OrderItem oi : orderItems.values()) {
            List<SBQQ__OrderItemConsumptionSchedule__c> theseOICS = new List<SBQQ__OrderItemConsumptionSchedule__c>();
            theseOICS.addAll(oi.SBQQ__OrderItems__r);
            orderItemConsumptionSchedulesByStrings.put(oi.OrderItemNumber, theseOICS);
        }
        return orderItemConsumptionSchedulesByStrings;

    }
}