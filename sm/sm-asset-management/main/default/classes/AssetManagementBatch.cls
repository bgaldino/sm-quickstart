public with sharing class AssetManagementBatch implements Database.Batchable<SObject>, Database.Stateful {

    final DateTime endDate = getUTCDateTime(System.now().addDays(5)); //End Date for the query
    Map<Id, Set<String>> needsToProcessAssetIds; //statefull attribute for the storing the Assets with Account
    final Integer RevCloudAPILimit = Integer.valueOf(System.Label.RevCloudAPILimit);

    public AssetManagementBatch () {
        needsToProcessAssetIds = new Map<Id, Set<String>>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query  = 'SELECT Id, Name, LifecycleStartDate, LifecycleEndDate, RenewalTerm, RenewalTermUnit, AccountId FROM Asset WHERE HasLifecycleManagement = TRUE and LifecycleEndDate =: endDate Order by AccountId';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> sObjectList) {
        Set<String> accountIds = new Set<String>();
        Map<Id, Set<String>> accountWithAssetIdsMap = new Map<Id, Set<String>>();
        Map<String, Integer> accountWithAssetLengthMap = new Map<String, Integer>();
        //Creating the Map to process the Renew and add the existing assets the map to compare them
        for(SObject sObj : SObjectList) {
            Asset a = (Asset)sObj;
            accountIds.add(a.AccountId);
            if(!accountWithAssetIdsMap.containsKey(a.accountId)){
                Set<String> assetIds = new Set<String>{a.Id};
                accountWithAssetIdsMap.put(a.AccountId, assetIds);
                checkAndAddAccount(a.accountId, accountWithAssetIdsMap);
            }
            else{
                accountWithAssetIdsMap.get(a.AccountId).add(a.Id);
            }
        }

        // AggregateResult is used to compare the Assets on the Account with the size
        // If the size does not match remove it from the map
        for(AggregateResult a : [SELECT AccountId, Count(Id) assets FROM Asset WHERE HasLifecycleManagement = TRUE AND LifecycleEndDate =: endDate and AccountId IN: accountIds  group by AccountId]){
            Integer assetsSize = Integer.valueOf(a.get('assets'));
            String accountId = String.valueOf(a.get('AccountId'));
            accountWithAssetLengthMap.put(accountId, assetsSize);
            if(accountWithAssetIdsMap.get(accountId).size() != assetsSize){
                needsToProcessAssetIds.put(accountId, accountWithAssetIdsMap.get(accountId));
                accountWithAssetIdsMap.remove(accountId);
            }
        }

        for(Id accountId : accountWithAssetIdsMap.keySet()){
            List<String> assetIds = new List<String>(accountWithAssetIdsMap.get(accountId));
            List<String> assetIdsToProcess = new List<String>();
            //Splitting the list if there is more than 100 elements
            for(String assetId : assetIds){
                assetIdsToProcess.add(assetId);
                assetIdsToProcess = runRenew(assetIdsToProcess);
            }
            //This is for the last set of assets If there is any
            if(!assetIdsToProcess.isEmpty()) {
                AssetManagementAPIs.renewAssetsAPI(assetIdsToProcess);
            }
        }
    }

    /**
     * Sending the email once process is completed
     */

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:bc.getJobId()];
          
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch ' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems +
       'with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private DateTime getUTCDateTime(DateTime dt){
        Datetime gmtDateTime = Datetime.newInstanceGmt(
            dt.year(),
            dt.month(),
            dt.day(),
            23,
            59,
            59
        );
        return gmtDateTime;
    }

    private void checkAndAddAccount(Id accountId,  Map<Id, Set<String>> accountWithAssetIdsMap){
        if(needsToProcessAssetIds.containsKey(accountId)){
            accountWithAssetIdsMap.get(accountId).addAll(needsToProcessAssetIds.get(accountId));
        }
    }

    /**
     * Check and size of the assetIdsToProcess and If the size is equal to the limit then run the Renew API
     */
    private List<String> runRenew(List<String> assetIdsToProcess) {
        if(assetIdsToProcess.size() == RevCloudAPILimit){
            AssetManagementAPIs.renewAssetsAPI(assetIdsToProcess);
            return new List<String>();
        }
        return assetIdsToProcess;
    }
}