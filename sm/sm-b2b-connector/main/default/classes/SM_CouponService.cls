public with sharing class SM_CouponService {
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.COUPON_MODULE);
    @AuraEnabled
    public static String getCartItems(String communityId, String Coupon, String cartId, String effectiveAccountId){
        try{
            String webstoreId = test.isRunningTest() ? [Select id from WebStore Where Name = 'Sflabs'].Id : [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;

            ConnectApi.cartCouponInput cartCouponInput = new ConnectApi.cartCouponInput();
            cartCouponInput.couponCode = Coupon;

            if(!Test.isRunningTest()) {ConnectApi.CartCouponCollection cartCoupon = ConnectApi.CommerceCart.applyCartCoupon(webstoreId, effectiveAccountId, cartId, cartCouponInput); }

            return cartId; 
        } catch(Exception ex) {logger.error(ex); throw new AuraHandledException(ex.getMessage());}
        finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static List<String> getAppliedCoupon(String communityId, String cartId, String effectiveAccountId){
        try{
            String webstoreId = test.isRunningTest() ? [Select id from WebStore Where Name = 'Sflabs'].Id : [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
            List<String> couponCodes = new List<String>();

            ConnectApi.CartCouponCollection cartCoupons = test.isRunningTest() ? new ConnectApi.CartCouponCollection() : ConnectApi.CommerceCart.getCartCoupons(webStoreId, effectiveAccountId, cartId);
            if(test.isRunningTest()) {
                ConnectApi.CartCouponList cartCoupon = new ConnectApi.CartCouponList();
                List<ConnectApi.CartCoupon> coupons = new List<ConnectApi.CartCoupon>();
                ConnectApi.CartCoupon coupon = new ConnectApi.CartCoupon();
                coupon.couponCode = 'testCode';
                coupons.add(coupon);
                cartCoupon.coupons = coupons;
                cartCoupons.cartCoupons = cartCoupon;
            }
            String str = JSON.serialize(cartCoupons);
            Map<String, Object> mp = (Map<String, Object>)JSON.deserializeUntyped(str);
            Map<String, Object> mpt = (Map<String, Object>)mp.get('cartCoupons');
            list<Object> mps = (list<Object>)mpt.get('coupons');

            for(Object coupon : mps) {
                Map<String, Object> mpcoupon = (Map<String, Object>)coupon;
                couponCodes.add((String)mpcoupon.get('couponCode'));
            }
            
            return couponCodes;
        } catch(Exception ex) {logger.error(ex); throw new AuraHandledException(ex.getMessage());}
        finally {
            logger.flush();
        }
    }

    @AuraEnabled
    public static String deleteCartCoupon(String communityId, String cartId, String couponCode, String effectiveAccountId) {
        try{
            String webstoreId = test.isRunningTest() ? [Select id from WebStore Where Name = 'Sflabs'].Id : [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;

            ConnectApi.CartCouponCollection cartCoupons = test.isRunningTest() ? new ConnectApi.CartCouponCollection() : ConnectApi.CommerceCart.getCartCoupons(webStoreId, effectiveAccountId, cartId);
            if(test.isRunningTest()) {
                ConnectApi.CartCouponList cartCoupon = new ConnectApi.CartCouponList();
                List<ConnectApi.CartCoupon> coupons = new List<ConnectApi.CartCoupon>();
                ConnectApi.CartCoupon coupon = new ConnectApi.CartCoupon();
                coupon.couponCode = 'testCode';
                coupons.add(coupon);
                cartCoupon.coupons = coupons;
                cartCoupons.cartCoupons = cartCoupon;
            }
            String str = JSON.serialize(cartCoupons);
            Map<String, Object> mp = (Map<String,Object>)JSON.deserializeUntyped(str);
            Map<String, Object> mpt = (Map<String,Object>)mp.get('cartCoupons');
            list<Object> mps = (list<Object>)mpt.get('coupons');

            String cartCouponId;

            for(Object coupon : mps) {
                Map<String, Object> mpcoupon = (Map<String, Object>)coupon;
                if((String)mpcoupon.get('couponCode') == couponCode) {
                    cartCouponId = (String)mpcoupon.get('cartCouponId');
                    break;
                }
            }

            if(!Test.isRunningTest()) {ConnectApi.CommerceCart.deleteCartCoupon(webstoreId, effectiveAccountId, cartId, cartCouponId);}

            return cartId;
        } catch(Exception ex) {logger.error(ex); throw new AuraHandledException(ex.getMessage());}
        finally {
            logger.flush();
        }
    }

    @AuraEnabled(cacheable=false)
    public static Boolean isQuoteDiscountApplied(String cartId){
        try {
            List<CartItem> cartItemList = [
                SELECT Id
                FROM CartItem
                WHERE r1sm__Discount__c > 0
                AND CartId = :cartId
                WITH SECURITY_ENFORCED
            ];
    
            return !cartItemList.isEmpty();  
        } catch(Exception ex) {logger.error(ex); throw new AuraHandledException(ex.getMessage()); }
        finally {
            logger.flush();
        }
 
    }
}