@isTest
private with sharing class SM_RevErrorLogTableControllerTest {

    @IsTest
    static void getErrorLogsEmpty(){
        List<RevenueTransactionErrorLog> rtel = SM_RevErrorLogTableController.getErrorLogs();
        System.assert(rtel.isEmpty() == true, 'No RevenueTransactionErrorLogs');
    }
}
