public inherited sharing class B2B_Constants {
    public B2B_Constants() {}

    public static Module Module {
        get {
            return Module == null ? (Module = new Module()) : Module;
        }
        private set;
    }

    public class Module {
        public final String ORG_DEFAULT = 'Org Default';
        public final String APP_CONFIG = 'App Config';
        public final String FLS_CHECKS = 'FLS Checks';
        public final String EMAIL = 'Email';
        public final String CHECKOUT_FLOW = 'Checkout Flow';
        public final String TRIGGER_HANDLER = 'Trigger Handler';
    }
}