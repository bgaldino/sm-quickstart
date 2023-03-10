trigger RSM_InvoiceTrigger on Invoice (after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        RSM_InvoiceTrigger_Helper.createHelperData(Trigger.New);
    }
}