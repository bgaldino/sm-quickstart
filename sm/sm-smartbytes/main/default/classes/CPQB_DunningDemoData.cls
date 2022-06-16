public with sharing class CPQB_DunningDemoData {
    // Ref document for creating some templated data
    // https://salesforce.quip.com/kpLMA6kA70zz
    public static void createDemoMethods() {
        Map<String, Id> methodIdsByName = createDunningMethods();

        createDunningActProactive(methodIdsByName.get('Proactive'));
        createDunningActStandard(methodIdsByName.get('Standard'));
        createDunningActVIP(methodIdsByName.get('VIP'));

    }

    public static Map<String, Id> createDunningMethods() {
        List<SFBD__DunningMethod__c> dunningMethods = new List<SFBD__DunningMethod__c>();
        dunningMethods.add(new SFBD__DunningMethod__c(Name='Proactive', SFBD__Details__c='Early Notification for customers with significant risk of non-payment or ongoing pattern of delayed collections.'));
        dunningMethods.add(new SFBD__DunningMethod__c(Name='Standard', SFBD__Details__c='Standard Collections process that is default for all customers.'));
        dunningMethods.add(new SFBD__DunningMethod__c(Name='VIP', SFBD__Details__c='Exceptional process for customers that do not have significant risk of non-payment.'));

        try {
            Database.insert(dunningMethods);
        } catch (DmlException e) {
            System.debug(e);
        }

        Map<String, Id> methodIdsByName = new Map<String, Id>();
        for(SFBD__DunningMethod__c dm : dunningMethods) {
            methodIdsByName.put(dm.Name, dm.Id);
        }

        return methodIdsByName;
    }

    public static void createDunningActProactive(Id dunningId) {
        List<SFBD__DunningActivity__c> dunningActivities = new List<SFBD__DunningActivity__c>();

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Proactive Email',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Email notification letting customer know the invoice is due in 5 days.',
                            SFBD__OffsetDays__c=-5,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Follow up Email',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Follow up email letting them know that a payment was not received by the due date.',
                            SFBD__OffsetDays__c=1,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='First Call',
                            SFBD__ActivitySubject__c='Call',
                            SFBD__ActivityDetails__c='Collections Analyst to call on the account.',
                            SFBD__OffsetDays__c=5,
                            SFBD__DunningMethod__c=dunningId));
        
        dunningActivities.add(new SFBD__DunningActivity__c(Name='Past Due Email',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Email Notification that the account is past due and services will be shut off when past due 30 days.',
                            SFBD__OffsetDays__c=14,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Second Call',
                            SFBD__ActivitySubject__c='Call',
                            SFBD__ActivityDetails__c='Collections Analyst to call on the account.',
                            SFBD__OffsetDays__c=21,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Shut off Warning',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Email notification that the services will be shut off in 2 days.',
                            SFBD__OffsetDays__c=28,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Shut off Service',
                            SFBD__ActivitySubject__c='Other',
                            SFBD__ActivityDetails__c='Provisioning event to shut off service.',
                            SFBD__OffsetDays__c=31,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Shut off Notification',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Email notification that the services were terminated and to make payment for services to be restored.',
                            SFBD__OffsetDays__c=31,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Send to Collections Agency',
                            SFBD__ActivitySubject__c='Other',
                            SFBD__ActivityDetails__c='Set account as “Send to Collections Agency”.',
                            SFBD__OffsetDays__c=45,
                            SFBD__DunningMethod__c=dunningId));

        try {
            Database.insert(dunningActivities);
        } catch (DmlException e) {
            System.debug(e);
        }
    }


    public static void createDunningActStandard(Id dunningId) {
        List<SFBD__DunningActivity__c> dunningActivities = new List<SFBD__DunningActivity__c>();
        
        dunningActivities.add(new SFBD__DunningActivity__c(Name='First Email',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Email Notification that the account is past due.',
                            SFBD__OffsetDays__c=14,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='First Call',
                            SFBD__ActivitySubject__c='Call',
                            SFBD__ActivityDetails__c='Collections Analyst to call on the account.',
                            SFBD__OffsetDays__c=28,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Past Due Notice',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Email notification that the Account is over 30 days past due and to make a payment to prevent service disruption.',
                            SFBD__OffsetDays__c=32,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Second Call',
                            SFBD__ActivitySubject__c='Call',
                            SFBD__ActivityDetails__c='Collections Analyst to call on the account.',
                            SFBD__OffsetDays__c=45,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Shut off Service',
                            SFBD__ActivitySubject__c='Other',
                            SFBD__ActivityDetails__c='Provisioning event to shut off service.',
                            SFBD__OffsetDays__c=50,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Shut off Notification',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Email notification that the services were terminated and to make payment for services to be restored.',
                            SFBD__OffsetDays__c=50,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Send to Collections Agency',
                            SFBD__ActivitySubject__c='Other',
                            SFBD__ActivityDetails__c='Set account as “Send to Collections Agency”.',
                            SFBD__OffsetDays__c=60,
                            SFBD__DunningMethod__c=dunningId));

        try {
            Database.insert(dunningActivities);
        } catch (DmlException e) {
            System.debug(e);
        }
    }


public static void createDunningActVIP(Id dunningId) {
        List<SFBD__DunningActivity__c> dunningActivities = new List<SFBD__DunningActivity__c>();
        
        dunningActivities.add(new SFBD__DunningActivity__c(Name='First Email',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Email Notification that the account is past due.',
                            SFBD__OffsetDays__c=30,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='First Call',
                            SFBD__ActivitySubject__c='Call',
                            SFBD__ActivityDetails__c='Collections Analyst to call on the account.',
                            SFBD__OffsetDays__c=60,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Past Due Notice',
                            SFBD__ActivitySubject__c='Email',
                            SFBD__ActivityDetails__c='Email notification that the Account is over 60 days past due and to make a payment to prevent service disruption.',
                            SFBD__OffsetDays__c=65,
                            SFBD__DunningMethod__c=dunningId));

        dunningActivities.add(new SFBD__DunningActivity__c(Name='Second Call',
                            SFBD__ActivitySubject__c='Call',
                            SFBD__ActivityDetails__c='Collections Analyst to call on the account.',
                            SFBD__OffsetDays__c=90,
                            SFBD__DunningMethod__c=dunningId));

        try {
            Database.insert(dunningActivities);
        } catch (DmlException e) {
            System.debug(e);
        }
    }
}