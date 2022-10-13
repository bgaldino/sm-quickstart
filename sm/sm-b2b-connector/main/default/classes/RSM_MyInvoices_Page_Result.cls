global with sharing class RSM_MyInvoices_Page_Result {
   
    @AuraEnabled
    global Integer pageSize { get; set; }

    @AuraEnabled
    global Integer pageNumber { get; set; }

    @AuraEnabled
    global Integer totalItemCount { get; set; }

    @AuraEnabled
    global Object[] records { get; set; }

    
}