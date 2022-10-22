public with sharing class B2B_SetupConstants {

    public static final ServiceConfigurationModules MODULES = new ServiceConfigurationModules();
    public static final ServiceConfigurationConfigs CONFIGS = new ServiceConfigurationConfigs();
    public static final OracleApiConfigs ORACLE_CONFIGS = new OracleApiConfigs();
    public static final CartItemTypes CART_ITEM_TYPES = new CartItemTypes();
    public static final OrderItemTypes ORDER_ITEM_TYPES = new OrderItemTypes();
    public static final FedexAuthSetup FEDEX_AUTH_SETUP = new FedexAuthSetup();
    public static final ShippingServices SHIPPING_SERVICES = new ShippingServices();
    public static final UsWarehouseTypes WAREHOUSE_TYPES = new UsWarehouseTypes();

    public static final Set<String> SHIP_CONTACT_ADDRESS_TYPES = new Set<String>{
        'Shipping'
    };
    public static final Set<String> BILL_CONTACT_ADDRESS_TYPES = new Set<String>{
         'Billing'
    };

    public static final String PRODUCT_DETAIL_MODULE = 'Product Detail';
    public static final String PRODUCT_DETAIL_CONFIG = 'Product Detail Page';
    public static final String PRODUCT_DETAIL_IMAGES = 'Product Detail Images';

    public static final String PRODUCT_INVENTORY_SOBJECT = 'B2B_Product_Inventory__c';

    public static final String PRODUCT_PRICING_MODULE = 'Product Pricing';

    public static final String PRODUCT_LIST_MODULE = 'PRODUCTLIST';
    public static final String PRODUCT_LIST_CONFIG = 'PRODUCTLISTPAGE';

    public static final Set<String> ACTIVE_CART_STATUSES = new Set<String>{'Active','Checkout','Processing'};
    public static final String CART_STATUS_ACTIVE = 'Active';
    public static final String CART_TYPE = 'Cart';

    public static final String CART_MODULE = 'Cart';
    public static final String ADD_TO_CART_CONFIG = 'Add_To_Cart';

    public static String AUTHORIZATIONTITLE = 'Authorization';
    public static String AUTHORIZATION = 'authorization';
    public static String ENDPOINT = 'endPoint';
    public static String METHOD = 'method';
    public static String CONTENTTYPE = 'Content-type';
    public static String CONTENT = 'contentType';
    public static String BODY = 'requestBody';
    public static String POST = 'POST';
    public static String PUT = 'PUT';
    public static String HTTPDELETE = 'DELETE';
    public static String APPLICATION_JSON = 'application/json';
    public static String BEARER = 'Bearer';

    public static final String ALPHA_UPPERCASE_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    public static final String ALPHA_LOWERCASE_CHARS = 'abcdefghijklmnopqrstuvwxyz';
    public static final String NUMERIC_CHARS = '0123456789';
    public static final String BASE_64_CHARS = ALPHA_UPPERCASE_CHARS + ALPHA_LOWERCASE_CHARS + NUMERIC_CHARS + '+/';

    public static final String ORDER_CREATION = 'Order Creation';
    public static final String TAXES_CALCULATION = 'Taxes Calculation';
    public static final String SHIPPING_COST_CALCULATION = 'Shipping Cost Calculation';
    public static final String CHECKOUT_FLOW = 'Checkout flow';
    public static final string BUYER_INFO_UPDATE = 'Buyer Information Update';
    public static final string ASSET_RENEWAL = 'Asset Renewal';
    public static final string ASSET_CANCELLATION = 'Asset Cancellation';
    public static final string SELF_REGISTRATION = 'Self Registration';
    public static final string REQUEST_DISCOUNT = 'Request Discount';
    public static final string MANAGE_SUBSCRIPTION = 'Manage Subscription';
    public static final string FEATURE_PRODUCTS = 'Feature Products';
    public static final string REST_CALLOUT = 'Rest Callout';
    public static final string DISCOUNT_UPDATE = 'Discount Update';

    public class CartItemTypes {
        public final String PRODUCT = 'Product';
        public final String CHARGE = 'Charge';
    }

    public class OrderItemTypes {
        public final String PRODUCT = 'Order Product';
        public final String CHARGE = 'Delivery Charge';
    }

    public class ServiceConfigurationModules {
        public final String PRODUCT_PRICING = 'Product Pricing';
        public final String QUICK_ORDER = 'Quick Order';
        public final String CART = 'Cart';
        public final String PRODUCT_INVENTORY = 'Inventory';
    }

    public class ServiceConfigurationConfigs {
        public final String PRODUCT_DETAIL_PAGE = 'Product Detail Page';
        public final String QUICK_ORDER_PAGE = 'Quick Order Page';
        public final String ADD_TO_CART = 'Add_To_Cart';
        public final String PRODUCT_PRICING = 'Product_Pricing';
        public final String PRODUCT_INVENTORY = 'Inventory_Check';
        public final String PRODUCT_SUBSCRIPTION = 'Subscription_Pricing';
    }

    public class OracleApiConfigs {
        public final String ON_HAND = 'On Hand';
        public final String PRICING_LINE = 'Pricing Line';
        public final String PRICING_BATCH = 'Pricing Batch';
        public final String CC_TOKEN = 'CC Token';
        public final String CREATE_ORDER = 'Create Order';
    }

    public class FedexAuthSetup {
        public final String NORTH = 'Fedex NW';
        public final String EAST = 'Fedex EW';
    }

    public class ShippingServices {
        public final String FEDEX = 'FedEx';
        public final String DHL = 'DHL';
    }

    public class UsWarehouseTypes {
        public final String NORTH = 'USE';
        public final String EAST = 'UTP';
    }

}