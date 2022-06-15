public with sharing class CPQ_RecordReset {

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

    // public static void deleteCongaQuoteDocuments(Set<Id> records) {
    //     SBQQ__Quote__c[] quotes = [SELECT Id FROM SBQQ__Quote__c WHERE Id IN :records];
        
    //     Set<String> documentIds = new Set<String>(); // must be a collection, not set - to use LIKE
    //     for (SBQQ__Quote__c q : quotes) {
    //         documentIds.add('%'+q.Id+'%');
    //     }

    //     List<String> arr = new List<String>();
    //     arr.addAll(documentIds);

    //     ContentDocument[] valuesToDelete = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr];
    //     try {
    //         Database.delete(valuesToDelete);
    //     } catch (DmlException e) {
    //         System.debug(e);
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // public static void deleteCongaInvoiceDocuments(Set<Id> records) {
    //     blng__Invoice__c[] invoices = [SELECT Id, Account_Name__c FROM blng__Invoice__c WHERE Id IN :records];
        
    //     Set<String> documentIds = new Set<String>(); // must be a collection, not set - to use LIKE
    //     for (blng__Invoice__c i : invoices) {
    //         documentIds.add('%'+i.Account_Name__c+'%');
    //     }

    //     List<String> arr = new List<String>();
    //     arr.addAll(documentIds);

    //     ContentDocument[] valuesToDelete = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr];
    //     try {
    //         Database.delete(valuesToDelete);
    //     } catch (DmlException e) {
    //         System.debug(e);
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // public static void deleteDocuSignQuoteDocuments(Set<Id> records) {
    //     //first delete .docx in Files that look like Quote Number: SmartBytes Quote_Q-29577
    //     SBQQ__Quote__c[] quotes = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id IN :records];
        
    //     Set<String> documentIds = new Set<String>(); // must be a collection, not set - to use LIKE
    //     for (SBQQ__Quote__c q : quotes) {
    //         documentIds.add('%'+q.Name+'%');
    //     }

    //     List<String> arr = new List<String>();
    //     arr.addAll(documentIds);

    //     ContentDocument[] valuesToDelete = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr];
    //     try {
    //         Database.delete(valuesToDelete);
    //     } catch (DmlException e) {
    //         System.debug(e);
    //         throw new AuraHandledException(e.getMessage());
    //     }

    //     //Next delete .pdf in Files that look like "Documents for your DocuSign Signature.pdf" - sent for signature
    //     Set<String> documentIds2 = new Set<String>(); // must be a collection, not set - to use LIKE
    //     documentIds2.add('%'+'Docusign Signature'+'%');

    //     List<String> arr2 = new List<String>();
    //     arr2.addAll(documentIds2);

    //     ContentDocument[] valuesToDelete2 = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr2];
    //     try {
    //         Database.delete(valuesToDelete2);
    //     } catch (DmlException e) {
    //         System.debug(e);
    //         throw new AuraHandledException(e.getMessage());
    //     }

    //     //Next delete DocuSign Envelope Object Records
    //     Set<String> quoteIds = new Set<String>();
    //     for (SBQQ__Quote__c q : quotes) {
    //         quoteIds.add(q.Id);
    //     }

    //     dfsle__Envelope__c[] valuesToDelete3 = [SELECT Id FROM dfsle__Envelope__c WHERE dfsle__SourceId__c IN :quoteIds];
    //     try {
    //         Database.delete(valuesToDelete3);
    //     } catch (DmlException e) {
    //         System.debug(e);
    //         throw new AuraHandledException(e.getMessage());
    //     }

    //     //finally delete docusign envelope status object records
    //     dfsle__EnvelopeStatus__c[] valuesToDelete4 = [SELECT Id FROM dfsle__EnvelopeStatus__c WHERE dfsle__SourceId__c IN :quoteIds];
    //     try {
    //         Database.delete(valuesToDelete4);
    //     } catch (DmlException e) {
    //         System.debug(e);
    //         throw new AuraHandledException(e.getMessage());
    //     }

    // }

    // public static void deleteDocuSignInvoiceDocuments(Set<Id> records) {
    //     //first delete .pdf in Files that look like Invoice Number: SmartBytes Invoice Document_INV-3914_2021-07-15
    //     blng__Invoice__c[] invoices = [SELECT Id, Name FROM blng__Invoice__c WHERE Id IN :records];
        
    //     Set<String> documentIds = new Set<String>(); // must be a collection, not set - to use LIKE
    //     for (blng__Invoice__c i : invoices) {
    //         documentIds.add('%'+i.Name+'%');
    //     }

    //     List<String> arr = new List<String>();
    //     arr.addAll(documentIds);

    //     ContentDocument[] valuesToDelete = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr];
    //     try {
    //         Database.delete(valuesToDelete);
    //     } catch (DmlException e) {
    //         System.debug(e);
    //         throw new AuraHandledException(e.getMessage());
    //     }

    //     //Next delete .pdf in Files that look like "SmartBytes Invoice Document" - sent for signature
    //     Set<String> documentIds2 = new Set<String>(); // must be a collection, not set - to use LIKE
    //     documentIds2.add('%'+'Invoice Document'+'%');

    //     List<String> arr2 = new List<String>();
    //     arr2.addAll(documentIds2);

    //     ContentDocument[] valuesToDelete2 = [SELECT Id FROM ContentDocument WHERE Title LIKE :arr2];
    //     try {
    //         Database.delete(valuesToDelete2);
    //     } catch (DmlException e) {
    //         System.debug(e);
    //         throw new AuraHandledException(e.getMessage());
    //     }

    // }

    public static void deleteOrders(Id accId) {

        Map<Id,Order> ordersToDelete = new Map<Id,Order>([SELECT Id, AccountId FROM Order WHERE AccountId = :accId]);
        if (ordersToDelete.isEmpty()) {
            return;
        }
        
        CPQ_RecordReset.deleteRecordJobs(ordersToDelete.keySet());

            for (Order o : ordersToDelete.values()) {
                o.SBQQ__Contracted__c = false;
            }
            Database.update(ordersToDelete.values());

            Map<Id,OrderItem> orderItems = new Map<Id,OrderItem>([SELECT Id FROM OrderItem WHERE OrderId IN :ordersToDelete.keyset()]);
            if (!orderItems.isEmpty()) {
                for (OrderItem oi : orderItems.values()) {
                    oi.SBQQ__Contracted__c = false;
                }

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
            CPQ_RecordReset.deleteRecordJobs(contractsToDeleteMap.keySet());
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

        CPQ_RecordReset.deleteProcessInputValues(quotesToDelete.keySet());
        CPQ_RecordReset.deleteRecordJobs(quotesToDelete.keySet());
        CPQ_RecordReset.deleteQuoteDocuments(quotesToDelete.keySet());

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


}