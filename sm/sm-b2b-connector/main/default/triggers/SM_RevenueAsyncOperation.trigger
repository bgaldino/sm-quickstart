trigger SM_RevenueAsyncOperation on RevenueAsyncOperation (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        Map<Id, RevenueAsyncOperation> newMap = Trigger.newMap;
        Map<Id, RevenueAsyncOperation> oldMap = Trigger.oldMap;
        Map<Id, RevenueAsyncOperation> raoMap = new Map<Id, RevenueAsyncOperation>();
        Map<Id, RevenueTransactionErrorLog> raoVsErrorMap = new Map<Id, RevenueTransactionErrorLog>();
        Set<Id> raoList = new Set<Id>();
        for (RevenueAsyncOperation rao : Trigger.new) {
            //when status is updated
            if (newMap.get(rao.Id).Status != oldMap.get(rao.Id).Status) {
                if (newMap.get(rao.Id).Status == 'CompletedWithFailures' || newMap.get(rao.Id).Status == 'Failure' || newMap.get(rao.Id).Status == 'Completed') {
                    raoList.add(rao.Id);
                    raoMap.put(rao.Id, rao);
                }
            }
        }

        List<RevenueTransactionErrorLog> errorLogs = [SELECT Id, ErrorLogNumber, CreatedDate, CreatedById, PrimaryRecordId, PrimaryRecord.Name, RelatedRecordId, ErrorCode, ErrorMessage, Category, RevenueAsyncOperationId FROM RevenueTransactionErrorLog WHERE RevenueAsyncOperationId = :raoList];
        for (RevenueTransactionErrorLog error : errorLogs) {
            if (error.Category == 'InitiateCancel' || error.Category == 'InitiateRenewal') {
                raoVsErrorMap.put(error.RevenueAsyncOperationId, error);
            }
        }

        for (RevenueAsyncOperation rao : raoMap.values()) {
            //asset cancellation
            if (rao.JobType == 'PearCancelAssets') {
                //asset cancellation failure
                if (raoVsErrorMap.containsKey(rao.Id)) {
                    SM_RevenueAsyncOperationHelper.sendCancelAssetFailureEmail(rao, raoVsErrorMap.get(rao.Id));
                }
                //asset cancellation success is not needed as email notification is already sent to customer.
            }
            //asset renewal
            if (rao.JobType == 'PearRenewAssets') {
                //asset renewal failure
                if (raoVsErrorMap.containsKey(rao.Id)) {
                    SM_RevenueAsyncOperationHelper.sendRenewAssetFailureEmail(rao, raoVsErrorMap.get(rao.Id));
                }
            }
        }
    }
}