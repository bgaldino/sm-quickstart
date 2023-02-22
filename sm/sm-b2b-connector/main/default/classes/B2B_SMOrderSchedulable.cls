global class B2B_SMOrderSchedulable implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.CHECKOUT_FLOW);

        Set<Id> orderIdsState = new Set<Id>();
       
        global Database.QueryLocator start(Database.BatchableContext bc){
            try {
                String query = 'SELECT Id, NextBillingDate, ReferenceEntityId FROM BillingSchedule WHERE NextBillingDate = TOMORROW AND CancellationDate = null';
                if(!Test.isRunningTest()) {
                  query += ' WITH SECURITY_ENFORCED';
                }

                return Database.getQueryLocator(query);
            } catch (Exception ex) {
                logger.error(ex);
                return null;
            } finally {
                logger.flush();
            }
        }
    
        global void execute(Database.BatchableContext bc, List<BillingSchedule> scope){
            try{ 
                Set<Id> orderIds = new Set<Id>();

                for(BillingSchedule billingIterator : scope){
                    if(!orderIdsState.contains(billingIterator.ReferenceEntityId)) {
                        orderIds.add(billingIterator.ReferenceEntityId);
                        orderIdsState.add(billingIterator.ReferenceEntityId);
                    }
                    
                }
                if(!orderIds.isEmpty()) {
                    B2B_SMOrderCopierHelper.cloneSmOrderToCheckoutOrder(orderIds);
                }
            } catch (Exception ex) {
                logger.error(ex);
            } finally {
                logger.flush();
            }
        }

        global void execute(SchedulableContext sc){
            try {
                //if(B2BUtils.fetchConfigByValue('CloneB2BOrderMonthly') == 'Yes') {
                if(RSM_Connector_Configuration__mdt.getInstance('Clone_B2B_Order_Monthly').key__c == 'Yes') {
                    Database.executeBatch(new B2B_SMOrderSchedulable(), 10);
                }else{
                    throw new CalloutException('test');
                }
            } catch (Exception ex) {
                logger.error(ex);
            } finally {
                logger.flush();
            }
        }
    
        global void finish(Database.BatchableContext bc){
          
        }
    }