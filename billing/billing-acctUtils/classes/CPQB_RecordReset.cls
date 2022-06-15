public with sharing class CPQB_RecordReset {

    // public static void delObjects(String targetObject, String lookupField, Id matchId) {
    //     String dbQuery = 'SELECT Id,' + lookupField + ' FROM ' + targetObject + ' WHERE ' + lookupField + ' = :matchId'; 
    //     SObject[] sObjsToDelete = Database.query(dbQuery);
    //     try {
    //         Database.delete(sObjsToDelete);
    //     } catch (DmlException e) {
    //         System.debug(e);
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    public static void delRevenueTransactions(Id accId) {
        blng__RevenueTransaction__c [] RvTrnsToDelete = [SELECT Id, blng__Account__c  FROM blng__RevenueTransaction__c  WHERE blng__Account__c = :accId];
        try {
            Database.delete(RvTrnsToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void delTransactionJournalEntryLines(Id accId) {
        Transaction_Journal_Entry_Line__c [] tjelToDelete = [SELECT Id, Account__c FROM Transaction_Journal_Entry_Line__c  WHERE Account__c = :accId];
        try {
            Database.delete(tjelToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void delTransactionJournalEntries(Id accId) {
        Transaction_Journal_Entry__c [] tjelToDelete = [SELECT Id, Account__c FROM Transaction_Journal_Entry__c  WHERE Account__c = :accId];
        try {
            Database.delete(tjelToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }  
    
    
    public static Boolean disableBillingTriggers(Boolean triggersDisabled) {
        blng__BillingConfig__c triggerConfig = [SELECT Id, Name, blng__BooleanValue__c FROM blng__BillingConfig__c WHERE Name = 'DISABLE_TRIGGERS'];
        triggerConfig.blng__BooleanValue__c = triggersDisabled;
        SObject so = (SObject)triggerConfig;
        Database.SaveResult sr = Database.updateImmediate(so);
        if (sr.isSuccess()) {
            String msg = triggersDisabled ? 'disabled': 'enabled';
            System.debug('Successfully '+ msg +' Billing Triggers');
            return true;
        } else {
            for (Database.Error err : sr.getErrors()) {
                System.debug('The following error has occurred.');
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            throw new AuraHandledException(err.getMessage());
            }
            return false;
        }
    }

    public static void deleteDiscScheds(Id accId) {
        SBQQ__DiscountSchedule__c[] dsToDelete = [SELECT Id, SBQQ__Account__c FROM SBQQ__DiscountSchedule__c WHERE SBQQ__Account__c = :accId];
        try {
            Database.delete(dsToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteProcessInputValues(Set<Id> quotes) {
        SBQQ__ProcessInputValue__c[] valuesToDelete = [SELECT Id, SBQQ__QuoteId__c FROM SBQQ__ProcessInputValue__c WHERE SBQQ__QuoteId__c IN :quotes];
        try {
            Database.delete(valuesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteRecordJobs(Set<Id> records) {
        SBQQ__RecordJob__c[] valuesToDelete = [SELECT Id FROM SBQQ__RecordJob__c WHERE RecordIdShort__c IN :records];
        try {
            Database.delete(valuesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteQuoteDocuments(Set<Id> records) { // native CPQ Document Generation

        SBQQ__QuoteDocument__c[] quoteDocuments = [SELECT Id, SBQQ__DocumentId__c FROM SBQQ__QuoteDocument__c WHERE SBQQ__Quote__c IN :records];

        Set<Id> documentIds = new Set<Id>();
        for (SBQQ__QuoteDocument__c qD : quoteDocuments) {
            documentIds.add(qD.SBQQ__DocumentId__c);
        }

        Document[] valuesToDelete = [SELECT Id FROM Document WHERE Id IN :documentIds];

        try {
            Database.delete(valuesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteCongaQuoteDocuments(Set<Id> records) {
        SBQQ__Quote__c[] quotes = [SELECT Id FROM SBQQ__Quote__c WHERE Id IN :records];
        
        Set<String> documentIds = new Set<String>(); // must be a collection, not set - to use LIKE
        for (SBQQ__Quote__c q : quotes) {
            documentIds.add('%'+q.Id+'%');
        }

        List<String> arr = new List<String>();
        arr.addAll(documentIds);

        ContentDocument[] valuesToDelete = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr];
        try {
            Database.delete(valuesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteCongaInvoiceDocuments(Set<Id> records) {
        blng__Invoice__c[] invoices = [SELECT Id, Account_Name__c FROM blng__Invoice__c WHERE Id IN :records];
        
        Set<String> documentIds = new Set<String>(); // must be a collection, not set - to use LIKE
        for (blng__Invoice__c i : invoices) {
            documentIds.add('%'+i.Account_Name__c+'%');
        }

        List<String> arr = new List<String>();
        arr.addAll(documentIds);

        ContentDocument[] valuesToDelete = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr];
        try {
            Database.delete(valuesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteDocuSignQuoteDocuments(Set<Id> records) {
        //first delete .docx in Files that look like Quote Number: SmartBytes Quote_Q-29577
        SBQQ__Quote__c[] quotes = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id IN :records];
        
        Set<String> documentIds = new Set<String>(); // must be a collection, not set - to use LIKE
        for (SBQQ__Quote__c q : quotes) {
            documentIds.add('%'+q.Name+'%');
        }

        List<String> arr = new List<String>();
        arr.addAll(documentIds);

        ContentDocument[] valuesToDelete = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr];
        try {
            Database.delete(valuesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }

        //Next delete .pdf in Files that look like "Documents for your DocuSign Signature.pdf" - sent for signature
        Set<String> documentIds2 = new Set<String>(); // must be a collection, not set - to use LIKE
        documentIds2.add('%'+'Docusign Signature'+'%');

        List<String> arr2 = new List<String>();
        arr2.addAll(documentIds2);

        ContentDocument[] valuesToDelete2 = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr2];
        try {
            Database.delete(valuesToDelete2);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }

        //Next delete DocuSign Envelope Object Records
        Set<String> quoteIds = new Set<String>();
        for (SBQQ__Quote__c q : quotes) {
            quoteIds.add(q.Id);
        }

        dfsle__Envelope__c[] valuesToDelete3 = [SELECT Id FROM dfsle__Envelope__c WHERE dfsle__SourceId__c IN :quoteIds];
        try {
            Database.delete(valuesToDelete3);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }

        //finally delete docusign envelope status object records
        dfsle__EnvelopeStatus__c[] valuesToDelete4 = [SELECT Id FROM dfsle__EnvelopeStatus__c WHERE dfsle__SourceId__c IN :quoteIds];
        try {
            Database.delete(valuesToDelete4);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }

    }

    public static void deleteDocuSignInvoiceDocuments(Set<Id> records) {
        //first delete .pdf in Files that look like Invoice Number: SmartBytes Invoice Document_INV-3914_2021-07-15
        blng__Invoice__c[] invoices = [SELECT Id, Name FROM blng__Invoice__c WHERE Id IN :records];
        
        Set<String> documentIds = new Set<String>(); // must be a collection, not set - to use LIKE
        for (blng__Invoice__c i : invoices) {
            documentIds.add('%'+i.Name+'%');
        }

        List<String> arr = new List<String>();
        arr.addAll(documentIds);

        ContentDocument[] valuesToDelete = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr];
        try {
            Database.delete(valuesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }

        //Next delete .pdf in Files that look like "SmartBytes Invoice Document" - sent for signature
        Set<String> documentIds2 = new Set<String>(); // must be a collection, not set - to use LIKE
        documentIds2.add('%'+'Invoice Document'+'%');

        List<String> arr2 = new List<String>();
        arr2.addAll(documentIds2);

        ContentDocument[] valuesToDelete2 = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr2];
        try {
            Database.delete(valuesToDelete2);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }

    }

    public static void deleteOrders(Id accId) {
        blng__BillingSchedule__c[] BS = [SELECT Id, blng__OrderProduct__r.Order.AccountId FROM blng__BillingSchedule__c WHERE blng__OrderProduct__r.Order.AccountId = :accId];
        try {
            Database.delete(BS);
        } catch (DmlException e) {
             System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }

        Map<Id,Order> ordersToDelete = new Map<Id,Order>([SELECT Id, AccountId FROM Order WHERE AccountId = :accId]);
        if (ordersToDelete.isEmpty()) {
            return;
        }
        
        CPQB_RecordReset.deleteRecordJobs(ordersToDelete.keySet());

            for (Order o : ordersToDelete.values()) {
                o.SBQQ__Contracted__c = false;
            }
            Database.update(ordersToDelete.values());

            Map<Id,OrderItem> orderItems = new Map<Id,OrderItem>([SELECT Id FROM OrderItem WHERE OrderId IN :ordersToDelete.keyset()]);
            if (!orderItems.isEmpty()) {
                for (OrderItem oi : orderItems.values()) {
                    oi.SBQQ__Contracted__c = false;
                }

                CPQB_RecordReset.deleteOIRevenueSchedules(orderItems.keySet());
                CPQB_RecordReset.deleteUsages(orderItems.keySet());
                CPQB_RecordReset.deleteUsageSummaries(orderItems.keySet());
                CPQB_RecordReset.deleteOrderConsumption(orderItems.keySet());
                Database.update(orderItems.values());
            }
            for (Order o : ordersToDelete.values()) {
                o.Status = 'Draft';
                o.SBQQ__Contracted__c = false;
            }

            try {
                Database.update(ordersToDelete.values());
                Database.delete(ordersToDelete.values());
            } catch (DmlException e) {
                System.debug(e);
                throw new AuraHandledException(e.getMessage());
            }

    }

    

    // Delete Opps
    public static void deleteOpportunities(Id accId) {
        Opportunity[] opportinitiesToDelete = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :accId];
        try {
            Database.delete(opportinitiesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Delete Assets
    public static void deleteAssets(Id accId) {
        Asset[] assetsToDelete = [SELECT Id, AccountId FROM Asset WHERE AccountId = :accId];
        try {
            Database.delete(assetsToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Delete Subs
    public static void deleteSubscriptions(Id accId) {
        SBQQ__Subscription__c[] subscriptionsToDelete = [SELECT Id, SBQQ__Account__r.Id FROM SBQQ__Subscription__c WHERE SBQQ__Account__r.Id = :accId];
        try {
            Database.delete(subscriptionsToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteContracts(Id accId) {
        Map<Id,Contract> contractsToDeleteMap = new Map<Id,Contract>([SELECT Id, AccountId FROM Contract WHERE AccountId = :accId]);
        
        Contract[] contractsToDelete = [SELECT Id, SBQQ__RenewalOpportunity__c, AccountId FROM Contract WHERE AccountId = :accId];
        
        if(!contractsToDeleteMap.isEmpty()){
            CPQB_RecordReset.deleteRecordJobs(contractsToDeleteMap.keySet());
        }

        if (!contractsToDelete.isEmpty()) {
            for (Contract c : contractsToDelete) {
                c.SBQQ__RenewalOpportunity__c = null;
            }
            try {
                Database.update(contractsToDelete);
                Database.delete(contractsToDelete);
            } catch (DmlException e) {
                System.debug(e);
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    public static void deleteQuotes(Id accId) {
        Map<Id,SBQQ__Quote__c> quotesToDelete = new Map<Id,SBQQ__Quote__c>([SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Account__r.Id = :accId]);
        if (quotesToDelete.isEmpty()) {
            return;
        }

        CPQB_RecordReset.deleteProcessInputValues(quotesToDelete.keySet());
        CPQB_RecordReset.deleteRecordJobs(quotesToDelete.keySet());
        CPQB_RecordReset.deleteQuoteDocuments(quotesToDelete.keySet());
        CPQB_RecordReset.deleteCongaQuoteDocuments(quotesToDelete.keySet());
        CPQB_RecordReset.deleteDocuSignQuoteDocuments(quotesToDelete.keySet());

        try {
            Database.delete(quotesToDelete.values());
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }


    public static void deleteContractedPrices(Id accId) {
        SBQQ__ContractedPrice__c[] cpToDelete = [SELECT Id FROM SBQQ__ContractedPrice__c WHERE SBQQ__Account__c = :accId];
        try {
            Database.delete(cpToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteOrderConsumption(Set<Id> orderItemIds) {
        SBQQ__OrderItemConsumptionSchedule__c[] ocToDelete = [SELECT Id FROM SBQQ__OrderItemConsumptionSchedule__c WHERE SBQQ__OrderItem__c IN :orderItemIds];
        try {
            Database.delete(ocToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
   
    /**
     * blng Object reset
     * 
     * 
     * 
     * 
     * 
     */

     public static void deletePaymentTransactions(Id accId) {
        blng__PaymentTransaction__c[] trxToDelete = [SELECT 
                                                        Id, 
                                                        blng__Account__c 
                                                    FROM blng__PaymentTransaction__c 
                                                    WHERE blng__Account__c = :accId];
        try {
            Database.delete(trxToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteCreditNotes(Id accId) {
        blng__CreditNote__c[] creditNotesToDelete = [SELECT 
                                                        Id, 
                                                        blng__Account__c 
                                                    FROM blng__CreditNote__c 
                                                    WHERE blng__Account__c = :accId];
        try {
            Database.delete(creditNotesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteDebitNotes(Id accId) {
        blng__DebitNote__c[] debitNotesToDelete = [SELECT 
                                                        Id, 
                                                        blng__Account__c 
                                                    FROM blng__DebitNote__c 
                                                    WHERE blng__Account__c = :accId];
        try {
            Database.delete(debitNotesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deletePayments(Id accId) {
        blng__Payment__c[] payments = [SELECT 
                                            Id, 
                                            blng__Account__c 
                                        FROM blng__Payment__c 
                                        WHERE blng__Account__c = :accId];
        try {
            Database.delete(payments);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteRefunds(Id accId) {
        blng__Refund__c[] refunds = [SELECT 
                                        Id, 
                                        blng__Account__c 
                                    FROM blng__Refund__c 
                                    WHERE blng__Account__c = :accId];
        try {
            Database.delete(refunds);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteAccountBalanceSnapshots(Id accId) {
        blng__AccountBalanceSnapshot__c[] snapshots = [SELECT 
                                        Name, 
                                        blng__Account__c, 
                                        blng__SnapshotDate__c 
                                    FROM blng__AccountBalanceSnapshot__c 
                                    WHERE (blng__Account__c = :accId AND blng__SnapshotDate__c < LAST_N_DAYS:3)];
        try {
            Database.delete(snapshots);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteInvoices(Id accId) {
        blng__Invoice__c[] invoicesToDelete = [SELECT 
                                                    Id, 
                                                    blng__InvoiceStatus__c, 
                                                    blng__Account__r.Id 
                                                FROM blng__Invoice__c 
                                                WHERE blng__Account__r.Id = :accId];

        //deleteCongaInvoiceDocuments
        Map<Id, blng__Invoice__c> invoicesToDelete2 = new Map<Id, blng__Invoice__c>([SELECT Id, Name, blng__Account__r.Id, Account_Name__c FROM blng__Invoice__c WHERE blng__Account__r.Id = :accId]);
        CPQB_RecordReset.deleteCongaInvoiceDocuments(invoicesToDelete2.keySet());
            
        //deleteDocuSignInvoiceDocuments
        CPQB_RecordReset.deleteDocuSignInvoiceDocuments(invoicesToDelete2.keySet());
        
        if (!invoicesToDelete.isEmpty()) {
            Set<Id> invoiceIds = new Set<Id>();
            blng__Invoice__c[] invoicesToUpdate = new List<blng__Invoice__c>();

            for (blng__Invoice__c invoice : invoicesToDelete) {
                invoiceIds.add(invoice.Id);
                blng.InvoiceAPI.creditInvoice(invoice.Id, 'Cancel and Re-bill');
                invoicesToUpdate.add(invoice);
            }
            if (!invoicesToUpdate.isEmpty()) {
                Database.update(invoicesToUpdate);
            }

            Map<Id, blng__InvoiceLine__c> invoiceLines = new Map<Id, blng__InvoiceLine__c>([SELECT Id, blng__Invoice__c FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN :invoiceIds]);
            if (!invoiceLines.isEmpty()) {
                CPQB_RecordReset.deleteILRevenueSchedules(invoiceLines.keySet());
            }
            Database.delete(invoicesToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteInvoices(): ' + Limits.getQueries());


    }

    public static void deleteUsages(Set<Id> orderItemIds) {
        blng__Usage__c[] usagesToDelete = [SELECT Id, blng__OrderProduct__c FROM blng__Usage__c WHERE blng__OrderProduct__c IN :orderItemIds];
        try {
            Database.delete(usagesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteUsageSummaries(Set<Id> orderItemIds) {
        blng__UsageSummary__c[] usageSummariesToDelete = [SELECT Id, blng__OrderProduct__c FROM blng__UsageSummary__c WHERE blng__OrderProduct__c IN :orderItemIds];
        try {
            Database.delete(usageSummariesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteOIRevenueSchedules(Set<Id> orderItemIds) {
        blng__RevenueSchedule__c[] revenueSchedulesToDelete = [SELECT Id, blng__OrderProduct__c FROM blng__RevenueSchedule__c WHERE blng__OrderProduct__c IN :orderItemIds];
        try {
            Database.delete(revenueSchedulesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteILRevenueSchedules(Set<Id> invLineIds) {
        blng__RevenueSchedule__c[] revenueSchedulesToDelete = [SELECT Id FROM blng__RevenueSchedule__c WHERE blng__InvoiceLine__c IN :invLineIds];
        try {
            Database.delete(revenueSchedulesToDelete);
        } catch (DmlException e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}