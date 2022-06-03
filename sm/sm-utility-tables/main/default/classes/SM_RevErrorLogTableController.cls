public with sharing class SM_RevErrorLogTableController {
  @AuraEnabled(cacheable=true)
  public static List<RevenueTransactionErrorLog> getErrorLogs() {
    try {
      return [
        SELECT
          Id,
          ErrorLogNumber,
          CreatedDate,
          PrimaryRecordId,
          PrimaryRecord.Name,
          RelatedRecordId,
          ErrorCode,
          ErrorMessage
        FROM RevenueTransactionErrorLog
        ORDER BY CreatedDate DESC
        LIMIT 200
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}