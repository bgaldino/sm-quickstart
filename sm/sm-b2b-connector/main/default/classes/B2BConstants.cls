/**
 * @description       : 
 * @author            : Abhishek Walia
 * @group             : Docmation LLC
 * @last modified on  : 02-11-2022
 * @last modified by  : Sathiya
**/
public with sharing class B2BConstants {
    
    public static final String STOREFRONT = 'Markforged';
    
    public static final String IS_SUCCESS = 'isSuccess' ;
    public static final String MESSAGE = 'msg' ;
    public static final String IS_USER_EXIST = 'isUserExist' ;

    public static final String USER_ID = 'userId' ;
    public static final String ACCOUNT_ID = 'accountId' ;
    public static final String CONTACT_ID = 'contactId' ;

    public static final String IS_CART_PAGE = 'isCartPage';
    public static final String IS_CLOSED = 'isClosed';
    public static final String REC_ID = 'recId';
    public static final String PROMO_CODES = 'promoCodes';
    
    // Recommended Product changes done on 02/11/2022 by sathiya
    public static final String PRODUCTS = 'products';
    public static final String PRODUCT_IDS = 'productIds';
    public static final String PRODUCT_ID_STR = 'productIdStr';
    public static final String PRODUCT_SKU_STR = 'productSKUstr';
    public static final String USER_VIEW_ONLY = 'userViewOnly';
    public static final String PRODUCT_PRICING = 'productPricing';
    public static final String PRODUCTS_PRICING = 'productsPricing';
    public static final String PRODUCT_FEATURES = 'productFeatures';
    public static final String RECOMMEND_LIST = 'recommendList';
    public static final String PRODUCT_BUNDLE = 'Bundle';
    public static final String PRODUCT_VARIANT = 'Variant';
    public static final String PRODUCT_IS_VARIANT = 'isVariant';
    public static final String RELATED_PRODUCT = 'Related Product';
    public static final String PRODUCT_IS_BUNDLE = 'isBundle';
    public static final String PRODUCT_VARIATIONPARENT_CLASS = 'VariationParent';
    public static final String PRODUCT_VARIATION_CLASS = 'Variation';
    // changes end by sathiya

    public static final String COMMUNITY_ID = 'communityId';
    public static final String WEB_STORE_ID = 'webstoreId';
    public static final String ORDER_TYPE = 'orderType' ;

    public static final String CART_ID = 'cartId' ;
    public static final String OLD_CART_ID = 'oldCartId' ;
    public static final String OPP_ID = 'oppId' ;
    public static final String OPP_CURRENCY = 'oppCurrency' ;

    public static final String LOGIN_URL = 'loginUrl' ;

    public static final String LABEL = 'label' ;
    public static final String VALUE = 'value' ;

    public static final String STREET_ADDRESS = 'streetAddress' ;
    public static final String CITY = 'city' ;
    public static final String STATE = 'state';
    public static final String COUNTRY = 'country';
    public static final String POSTAL_CODE = 'postalCode';
    public static final String STATE_CODE = 'stateCode';
    public static final String COUNTRY_CODE = 'countryCode';
    public static final String USERNAME_PREFIX = 'UsernamePrefix';

    public static final String STATE_LIST = 'stateList' ;
    public static final String COUNTRY_LIST = 'countryList' ;

    public static final String CURRENCY_CODE = 'currencyCode';

    public static final String FIRSTNAME = 'firstName' ;
    public static final String LASTNAME = 'lastName' ;
    public static final String EMAIL = 'email' ;
    public static final String USERNAME = 'userName' ;
    public static final String PHONE = 'phone' ;
    public static final String ORGANIZATION_NAME = 'organizationName' ;
    public static final String PASSWORD = 'password' ;

    public static final String REC_TYPE_ACCOUNT_CUSTOMER= 'Customer';
    public static final String REC_TYPE_CONTACT_END_USTOMER= 'End Use Customer Contact';
    public static final String REC_TYPE_ACCOUNT_RESELLER = 'Reseller';
    public static final String REC_TYPE_ACCOUNT_PARTNER = 'Partner';

    public static final String SELECTED_DELIVERY = 'selectedDelivery';




    //messages
    public static final String USER_ALREADY_EXIST = 'User already exists, please login.';

    public static final String CART_CURRENT = 'current';
    public static final String CART_ACTIVE = 'Active';
    public static final String CART_CLOSED = 'Closed';
    public static final String CART_CHECKOUT = 'Checkout';
    public static final String CART_PROCESSING = 'Processing';
    public static final String ORDER_DRAFT = 'Draft';
    public static final String QUANTITY = 'quantity';
    public static final String PRICE = 'price';

    public static final String BILLING = 'Billing';
    public static final String SHIPPING = 'Shipping';
    public static final String ULTIMATE_CONSIGNEE = 'Ultimate_Consignee';

    public static final String PRODUCT_ID = 'productId';

    public static final String CART = 'cart';
    public static final String OPP_LINE_ITEMS_MAP = 'oppItemsInputMap';
    public static final String CART_ITEMS_INPUT = 'cartItemsInput';
    public static final String DEFAULT_DELIVERY_METHOD = 'None - Virtual Product';
    public static final String CART_ITEM_LIST = 'cartItemList';


    public static final String ADDRESS_TYPE = 'addressType';
    public static final String ADDRESS_ID = 'addressId';
    public static final String ADDRESS_TYPE_BILLING = 'Billing';
    public static final String ADDRESS_TYPE_SHIPPING = 'Shipping';
    public static final String ADDRESS_TYPE_ULTIMATE_CONSIGNEE = 'Ultimate Consignee';
    public static final String ADDRESS_TYPE_IMPORTING_BROKER = 'Importing Broker';
    public static final String ADDRESS_TYPE_IMPORTER_OF_RECORD = 'Importer Of Record';


    public static final String DELIVERY_INSTRUCTION= 'deliveryInstruction';

    public static final String PROFILE_NAME= 'B2B Lightning Community Plus';
    public static final String COUPON_LIST = 'couponList';
    public static final String COUPON_VALUE = 'couponValue';
    public static final String COUPON_DOESNT_EXIST = 'This coupon does not exist. Please enter a valid coupon code.';
    public static final String COUPON_INACTIVE = 'This coupon is not active.';
    public static final String CART_ITEM_OBJECT = 'cartItemObject';
    public static final String COUPON_ACCOUNT_INACTIVE = 'This coupon is not valid from this user';
    public static final String CART_OBJECT = 'cartObj';
    public static final String USER_INVALID = 'Invalid Account user.';
    public static final String COUPON_ACCOUNT_APPLIED = 'You already have this coupon applied.';
    public static final String COUPON_SUCCESS_APPLIED = 'Success! Your coupon is applied.';
    public static final String ITEM_TERMS_AGREE = 'termsAgree';
    public static final String ITEM_USER_COMPANY = 'userCompany';
    public static final String ITEM_USER_EMAIL = 'userEmail';
    public static final String ITEM_USER_NAME = 'userName';
    public static final String ITEM_PRINTER_ID = 'printerId';
    
    // Error Messages for Shipment module
    public static final String MISSING_REQUIRED_SHIPMENT = 'Missing Required Information in shipment'; 
    public static final String MISSING_REQUIRED_SHIPMENT_ITEMS = 'Missing Required Information in shipment items';
    public static final String MISSING_SHIPMENT_ITEMS = 'Shipment Items are Empty'; 

    public static final String MESSAGING_VALUE = '[M:V]:';    
    
    public static final String OPPORTUNITY_OBJ_API_NAME = 'Opportunity';
    public static final String PROMO_CODE_FIELD_NAME = 'Promo_Code__c';
    public static final String IS_PARTNER_ACCOUNT = 'isPartnerAccount';
    public static final String PROMO_CODES_TO_ADD = 'promoCodesToAdd';
    
    public static final String ORDER_SUMMARY = 'orderSummary';
    public static final String ORDER = 'order';
    public static final String ORDER_ID = 'orderId';
    public static final String OBJ_API_NAME_ORDER_SUMMARY = 'OrderSummary';
    public static final String OBJ_API_NAME_ORDER = 'Order';
    public static final String OBJ_API_NAME_WEB_CART = 'WebCart';
    public static final String ORDER_ITEM_LIST = 'orderItemList';
    public static final String PRODUCT_IMAGE_MAP = 'productImageMap';

    public static final String FIELDNAME_SHIPPING_CARRIER = 'Shipping_Carriers__c';
    
    public static final String DELIVERY_METHODS = 'deliveryMethods';
    public static final String RECORD_ID = 'recordId';
    public static final String INTERNAL_ACCOUNT_ID = 'InternalAccountId';
    public static final String IS_INTERNAL_ACCOUNT = 'isInternalAccount';
    
    public static final String APPLIED_PROMO_CODE = 'appliedPromoCodes';
    public static final String IS_PROMO_CODE = 'isPromoCode';
    public static final String CART_ITEM_PROMO_CODE = 'cartItemPromoCode';
    public static final String CART_LEVEL_PROMO_CODE = 'cartLevelPromoCode';
    public static final String PARTNER_PROMOTION = 'Partner Promo';
    public static final String ORDER_LEVEL_PROMOTION = 'Order Level';
    public static final String CART_ITEM_PROMOTION = 'Line Item';
    
    public static final String EMPTY_STRING = '';

    public static final String HTTP_CONTENT_TYPE = 'Content-Type';
    public static final String HTTP_CONTENT_APP_JSON = 'application/json';
    
    //Shipping
    public static final String SHIPPING_DETAILS = 'shippingDetails';
    public static final String OBJ_API_B2B_SHIPPING = 'B2B_Shipment__c';
    public static final String SHIPPING_CARRIERS_LIST = 'shippingCarriersList';
    public static final String IS_CUSTOMER_PICKUP_ACKNOWLEDGED = 'isCustomerPickupAcknowledged';
    public static final String SHIPMENT_CARRIER = 'shippingCarrier';
    public static final String SHIPPING_ACCOUNT_NUMBER = 'shippingAccountNumber';
    public static final String SHIPPING_CARRIER_NOTE = 'shippingCarrierNote';
    
    

    
    
    
}