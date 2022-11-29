@isTest
private with sharing class SM_RevErrorLogTableControllerTest {
  private static final DCM_Logger LOGGER = DCM_Logger.getInstance();

  @IsTest
  static void getErrorLogsEmpty() {
    List<RevenueTransactionErrorLog> rtel = SM_RevErrorLogTableController.getErrorLogs();
    System.assert(rtel.isEmpty() == true, 'No RevenueTransactionErrorLogs');
  }
}
