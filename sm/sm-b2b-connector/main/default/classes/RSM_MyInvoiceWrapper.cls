public with sharing class RSM_MyInvoiceWrapper {
    @AuraEnabled 
    public Invoice invoice { get; set; }
    
    @AuraEnabled 
    public Date invEndDate_Stub { get; set; }
    
    //@AuraEnabled 
    //public String invoiceId { get; set; }

}