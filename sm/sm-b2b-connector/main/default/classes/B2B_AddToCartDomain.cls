global with sharing class B2B_AddToCartDomain {
    @AuraEnabled
    public String productId { get; set; }
    
    @AuraEnabled
    public Boolean isNonCPQStore { get; set; }

    @AuraEnabled
    public String cartId { get; set; }

    @AuraEnabled
    public String effectiveAccountId { get; set; }

    @AuraEnabled
    public String communityId { get; set; }

    @AuraEnabled
    public String webstore { get; set; }

    @AuraEnabled
    public String webstoreId { get; set; }

    @AuraEnabled
    public String pricebookId { get; set; }

    @AuraEnabled
    public User currentUser { get; set; }

    @AuraEnabled
    public String listPrice { get; set; }

    @AuraEnabled
    public String unitPrice { get; set; }

    @AuraEnabled
    public String quantity { get; set; }

    @AuraEnabled
    public Boolean isProratedPrice { get; set; }

    @AuraEnabled
    public boolean isRecurringProduct { get; set; }

    @AuraEnabled
    public String cartType { get; set; }

    @AuraEnabled
    public String contractNumber { get; set; }

    @AuraEnabled
    public String salesRepId { get; set; }

    @AuraEnabled
    public String currencyCode { get; set; }

    @AuraEnabled
    public Map<String, String> productToQty { get; set; }

    @AuraEnabled
    public Map<String, Object> subscriberInput { get; set; }

    @AuraEnabled
    public List<B2B_CartItem> cartItems { get; set; }

    @AuraEnabled
    public Map<String, B2B_CartItem> productIdToCartItem { get; set; }

    public class B2B_CartItem {
        @AuraEnabled
        public String cartItemId { get; set; }

        @AuraEnabled
        public String cartId { get; set; }

        @AuraEnabled
        public String quantity { get; set; }

        @AuraEnabled
        public Decimal freeProducts { get; set; }

        @AuraEnabled
        public String listPrice { get; set; }

        @AuraEnabled
        public String unitPrice { get; set; }

        @AuraEnabled
        public String totalListPrice { get; set; }

        @AuraEnabled
        public String totalPrice { get; set; }

        @AuraEnabled
        public String productId { get; set; }

        @AuraEnabled
        public String currencyCode { get; set; }

        @AuraEnabled
        public String recurringPrice { get; set; }

        @AuraEnabled
        public String subProdTerm { get; set; }

        @AuraEnabled
        public Integer renewalUplift { get; set; }
        
        @AuraEnabled
        public Integer upfront { get; set; }

        @AuraEnabled
        public String upfrontPrice { get; set; }
        
        @AuraEnabled
        public Integer uplift { get; set; }

        @AuraEnabled
        public String pricebookEntryId { get; set; }

        @AuraEnabled
        public String subscriptionId { get; set; }
        
        @AuraEnabled
        public Date subscriptionStartDate { get; set; }

        @AuraEnabled
        public String subcriptionQuanity { get; set; }
    }
}