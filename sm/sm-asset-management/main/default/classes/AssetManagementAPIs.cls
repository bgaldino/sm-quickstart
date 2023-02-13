public with sharing class AssetManagementAPIs {
    
    public static ConnectApi.RevenueAsyncRepresentation renewAssetsAPI(List<String> assetIds){
        ConnectApi.AssetMgmtInitiateRenewalInput input = new ConnectApi.AssetMgmtInitiateRenewalInput();
        input.assetIds = assetIds;
        return ConnectApi.AssetMgmt.initiateRenewal(input);
    }

    public static ConnectApi.RevenueAsyncRepresentation cancelAssetsAPI(List<String> assetIds, Datetime cancelDate){
        ConnectApi.AssetMgmtInitiateCancellationInput input = new ConnectApi.AssetMgmtInitiateCancellationInput();
        input.cancellationOutputType = ConnectApi.AssetMgmtCancellationType.Order;
        input.assetIds = assetIds;
        input.cancellationDate = cancelDate;
        return ConnectApi.AssetMgmt.initiateCancellation(input);
    }

    public static ConnectApi.RevenueAsyncRepresentation amendAssetsAPI(List<String> assetIds, Datetime amendDate, Integer quantity){
        ConnectApi.AssetMgmtInitiateAmendQtyInput input = new ConnectApi.AssetMgmtInitiateAmendQtyInput();
        input.amendmentOutputType = ConnectApi.AssetMgmtAmendmentType.Order;
        input.assetIds = assetIds;
        input.startDate = amendDate;
        input.quantityChange = quantity;
        return ConnectApi.AssetMgmt.initiateAmendQuantity(input);
    }
}