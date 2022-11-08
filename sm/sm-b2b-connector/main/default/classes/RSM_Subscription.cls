/**
 * @description       : Class is called from Manage Subscription page under Account Information.                      in the Store. 
 * @author            : Prabhat Kumar
 * @group             : 
 * @last modified on  : 09-09-2022
 * @last modified by  : Prabhat Kumar
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-20-2022   Prabhat Kumar  Initial Version
**/

global without sharing class RSM_Subscription {

    private final static Integer PAGE_SIZE = 12;
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.MANAGE_SUBSCRIPTION);
    @AuraEnabled
    global static RSM_Subscriptions_Page_Result getUserSubscriptions(Integer pageNumber, string communityId) {
        RSM_Subscriptions_Page_Result result = new RSM_Subscriptions_Page_Result();
        try {

            Integer pageSize    = PAGE_SIZE; //define how many records are shown per page
            Integer offset      = (pageNumber - 1) * pageSize; //search when the page is located
            
            List<RSM_SubscriptionsWrapper> response = new List<RSM_SubscriptionsWrapper>();        
            String userId = UserInfo.getUserId() ;
            List<User> uList = [SELECT Id,AccountId, contactId FROM USER WHERE Id=:userId AND AccountId != null WITH SECURITY_ENFORCED];
            Map<string, string> assetTypeMap = new Map<string, string>();

    
            List<Asset> allAssets = new List<Asset>();
            
            
            if(!uList.isEmpty()){
                Set<Id> productIdsList =  new Set<Id>();
                Set<Id> assetIdsList =  new Set<Id>();
                // List<Webstore> lstWebstore = new list<Webstore>();
                List<NetworkMember> memberNetwork = new list<NetworkMember>();
                List<Asset> assetList = new List<Asset>([SELECT Id, Payment_Method__c,  LifecycleStartDate, LifecycleEndDate, account.Name, TotalLifecycleAmount, Status, Product2Id, CreatedDate, Product2.IsActive, Product2.Name, Product2.Description
                                             FROM Asset 
                                             WHERE AccountId = :uList.get(0).AccountId 
                                             AND contactId =: uList.get(0).contactId
                                             AND Product2Id != null 
                                             AND Product2.IsActive = true 
                                           
                                             AND IsDeleted = false 
                                             AND IsInternal = false 
                                              //  AND CurrentQuantity > 0 
                                              AND IsCompetitorProduct = false WITH SECURITY_ENFORCED order by createdDate desc]); 
    
                allAssets = [SELECT Id
                                    FROM Asset 
                                    WHERE AccountId = :uList.get(0).AccountId 
                                    AND Product2Id != null 
                                    AND Product2.IsActive = true 
                                    
                                    AND IsDeleted = false 
                                    AND IsInternal = false 
                                    AND CurrentQuantity > 0 
                                    AND IsCompetitorProduct = false AND ID in (SELECT ReferenceEntityId from BillingScheduleGroup) WITH SECURITY_ENFORCED];
    
                for(Asset a : assetList ){
                    productIdsList.add(a.Product2Id);
                    assetIdsList.add(a.Id);
                }
                
    
                if(productIdsList.size() > 0){
                    Map<String, String> productImageUrlsByProductIds = B2BGetProducts.getProdImages(productIdsList, communityId);
    
                    List<Product2> products =  [SELECT Id, Name, IsActive, ProductCode, CurrencyIsoCode, StockKeepingUnit, Family, Description, 
                                                (SELECT Id, ProductSellingModel.Name from ProductSellingModelOptions) 
                                                FROM Product2 WHERE Id IN :productIdsList];
    
                    Map<String, Product2> productsMap = new Map<String, Product2>();
                    for(Product2 product :products ){
                        productsMap.put(product.Id, product);
                    }
    
                    List<AssetStatePeriod> assetsPeriods =  [SELECT Id, EndDate, StartDate, Quantity, AssetId FROM AssetStatePeriod WHERE AssetId IN :assetIdsList];
    
                    Map<String, AssetStatePeriod> assetPeriodMap = new Map<String, AssetStatePeriod>();
                    for(AssetStatePeriod assetPeri :assetsPeriods ){
                        assetPeriodMap.put(assetPeri.AssetId, assetPeri);
                    }
    
    
                    List<BillingScheduleGroup> assetsSchedules = new List<BillingScheduleGroup>([SELECT ReferenceEntityId, (SELECT Id, NextBillingDate FROM BillingScheduleGroupToBillingSchedule ORDER BY NextBillingDate DESC LIMIT 1) FROM BillingScheduleGroup WHERE ReferenceEntityId IN :assetIdsList]); 
                    Map<String, BillingScheduleGroup> assetScheduleMap = new Map<String, BillingScheduleGroup>();
                    for(BillingScheduleGroup a :assetsSchedules ){
                        assetScheduleMap.put(a.ReferenceEntityId, a);
                    }
                  List<OrderAction> orderActionList = [select id, Type, SourceAssetId from OrderAction where SourceAssetId IN: assetIdsList WITH SECURITY_ENFORCED];

                  for(OrderAction oa : orderActionList){

                    if(assetIdsList.contains(oa.SourceAssetId)){

                        assetTypeMap.put(oa.SourceAssetId, oa.type);

                    }


                  }
        		
                //   lstWebstore = [select id from webstore];
                  memberNetwork = [select Id, NetworkId, Member.name from NetworkMember where memberId =: uList[0].id with SECURITY_ENFORCED];
                  String webStoreName = '';
                  string tempWebstoreName = '';

                  if(memberNetwork.size()> 0){
                    if(memberNetwork.size() > 1){

                        //get websoter id
                        tempWebstoreName = [SELECT WebStoreId, Webstore.Name  FROM WebStoreNetwork WHERE NetworkId = :communityId LIMIT 1].Webstore.Name;

                        webStoreName = tempWebstoreName.replaceAll( '\\s+', '');



                    }
                    
                }
                 
                 
                   
                        for(Asset a :assetList ){
                            if(productsMap.get(a.Product2Id).Id != null){
                                RSM_SubscriptionsWrapper pd = new RSM_SubscriptionsWrapper();
                                pd.productId  = a.Product2Id;
                                pd.assetId    = a.Id;
                                if(webStoreName != ''){
                                        pd.imageUrl   =  productImageUrlsByProductIds.containsKey(pd.productId) ? '/' + webStoreName + productImageUrlsByProductIds.get(pd.productId) : '';
                                }else{

                                    pd.imageUrl   =  productImageUrlsByProductIds.containsKey(pd.productId) ? productImageUrlsByProductIds.get(pd.productId) : '';
                                }
                                pd.product    = productsMap.get(a.Product2Id);
                                pd.asset      = a;

                                if(assetTypeMap.containsKey(a.id)){

                                    pd.assetType = assetTypeMap.get(a.id);
                                            if( assetTypeMap.get(a.id) == 'Cancellation'){

                                                pd.isCancelled = true;

                                             }else{

                                                pd.isCancelled = false;

                                            }
                                    
                                }else{

                                    pd.assetType = 'New Sale';

                                    pd.isCancelled = false;


                                }

                                for(ProductSellingModelOption psmo : productsMap.get(a.Product2Id).ProductSellingModelOptions){
                                    if(psmo.ProductSellingModel.Name != 'One-Time'){
                                        pd.isOneTime  = false;  
                                    }else{
                                        pd.isOneTime  = true;
                                    }

                                    if(psmo.ProductSellingModel.Name == 'Evergreen Monthly'){

                                        pd.isEverGreen = true;

                                        
                                    }else{

                                        pd.isEverGreen = false;

                                    }
                                }
                                if(assetPeriodMap.containsKey(a.Id)){
                                    pd.assetperiod      = assetPeriodMap.get(a.Id);
                                    AssetStatePeriod asp = assetPeriodMap.get(a.Id);
                                    if(pd.isEverGreen == true){
                                        if(asp.EndDate != null){
                                            pd.isTermed = true;
                                        }else{
                                            pd.isTermed = false;
                                        }
                                    }
                                }else{
                                    pd.assetperiod = null;
                                }
                                response.add(pd);
                            }
                        }
                  
                }            
            }        
    
            
            result.totalItemCount   = allAssets.size();
            result.pageSize         = pageSize; //total size of data on one page
            result.pageNumber       = pageNumber; //page number
            result.records          = response;
            
        } catch(Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }

}