/**
 * @description       : 
 * @author            : Devanshu Sood
 * @group             : 
 * @last modified on  : 10-11-2022
 * @last modified by  : Devanshu Sood
**/
public inherited sharing class B2B_Constants {
    public B2B_Constants() {}

    public static B2B_Constants.Profile Profile {
        get {
            return Profile == null ? (Profile = new B2B_Constants.Profile()) : Profile;
        }
        private set;
    }

    public static B2B_Constants.UserRole UserRole {
        get {
            return UserRole == null ? (UserRole = new B2B_Constants.UserRole()) : UserRole;
        }
        private set;
    }

    public static PermissionSet PermissionSet {
        get {
            return PermissionSet == null ? (PermissionSet = new B2B_Constants.PermissionSet()) : PermissionSet;
        }
        private set;
    }

    public static Module Module {
        get {
            return Module == null ? (Module = new Module()) : Module;
        }
        private set;
    }

    public static B2BFlow B2BFlow {
        get {
            return B2BFlow == null ? (B2BFlow = new B2BFlow()) : B2BFlow;
        }
        private set;
    }
    
    public static SObjectType SObjectType {
        get {
            return SObjectType == null ? (SObjectType = new B2B_Constants.SObjectType()) : SObjectType;
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

    public class B2BFlow {
        public final String RENEWAL_FLOW = 'SM_Renewal_Checkout';
        public final String BUY_NOW_FLOW = 'Cybersecurity_SM_CheckOut';
    }

    public class Profile extends SObjectType {
        private Profile() {
            this.objectType = Schema.Profile.getSObjectType();
        }

        public final String STANDARD_USER = 'Standard User';
        public final String SYSTEM_ADMIN = 'System Administrator';
        public final String GUEST_USER = 'Guest License User';
        public final String CUSTOMER_COMMUNITY_USER = 'Customer Community User';
        public final String CUSTOMER_COMMUNITY_PLUS_USER = 'Customer Community Plus User';
        public final String B2B_LIGHTNING_COMMUNITY_PLUS = 'B2B Lightning Community Plus';
    }

    public class PermissionSet extends SObjectType {
        private PermissionSet() {
            this.objectType = Schema.PermissionSet.getSObjectType();
        }

        public final String B2B_BUYER = 'B2BBuyer';
        public final String RSM_PORTAL_USER = 'RSM_Portal_User';
        public final String RSM_SF_USER = 'RSM_SF_User';
    }

    public class UserRole extends SObjectType {
        private UserRole() {
            this.objectType = Schema.UserRole.getSObjectType();
        }

        public final String RSM_PORTAL_OWNER_ROLE_NAME = 'RSM Role';
        public final String RSM_PORTAL_OWNER_ROLE_DEVELOPER_NAME = 'RSMRole';
    }

    public virtual class SObjectType extends SystemFields {
        protected Schema.SObjectType objectType;

        public final String Id = 'Id';
        public final String NAME = 'Name';
        public final String RECORD_TYPE_ID = 'RecordTypeId';
        public final String RECORD_TYPE_DEVELOPER_NAME = 'RecordType.DeveloperName';
        public final String RECORD_TYPE_NAME = 'RecordType.Name';
        public final String RECORD_TYPE = 'RecordType';
        public final String OWNER = 'Owner';
        public final String OWNER_ID = 'OwnerId';
        public final String OWNER_NAME = 'Owner.Name';
        public final String LAST_VIEWED_DATE = 'LastViewedDate';

        public Schema.SObjectType SOBJECT_TYPE {
            get {
                return this.objectType;
            }
        }

        public String OBJECT_NAME {
            get {
                return this.objectType.getDescribe().getName();
            }
        }
    }

    public virtual class SystemFields {
        public final String ID = 'Id';
        public final String CREATED_BY = 'CreatedBy';
        public final String CREATED_BY_ID = 'CreatedById';
        public final String CREATED_DATE = 'CreatedDate';
        public final String LAST_MODIFIED_DATE_TIME = 'LastModifiedDate';
        public final String RECORD_TYPE_ID = 'RecordTypeId';
        public final String CURRENCY_ISO_CODE = 'CurrencyIsoCode';
        public final String DEVELOPER_NAME = 'DeveloperName';
        /**
         * ALL SYSTEM SOBJECT FIELDS
         */
    }
}