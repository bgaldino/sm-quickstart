public with sharing class RC_AssetNextBillingDate {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance();
    @InvocableMethod(
        label='RC_AssetNextBillingDate'
        description='Fetches the next billing date for the asset'
        category='Revenue Cloud'
      )
    public static List<Date> getNextBillingDate(List<String> assetIds){
        List <Date> nextBillingDateList = new List <Date>();
        Map<String,object> resultData = new Map<String,object>();
        for (String assetId : assetIds) {
            try {
                string cancelDate = '';
                Date nextBillingDate;
                List<BillingScheduleGroup> billingSechd = new List<BillingScheduleGroup>();
                billingSechd = [select id, EffectiveNextBillingDate, EndDate from BillingScheduleGroup where ReferenceEntityId =: assetId];
                if(billingSechd.size() > 0){
                    //cancelDate = string.valueof(billingSechd[0].EffectiveNextBillingDate)+'T00:00:00-00:00';
                    cancelDate = string.valueof(billingSechd[0].EffectiveNextBillingDate);
                    nextBillingDate=billingSechd[0].EffectiveNextBillingDate;
                    nextBillingDateList.add(nextBillingDate);
                }else{
                    //cancelDate = string.valueof(system.today())+'T00:00:00-00:00';
                    cancelDate = string.valueof(system.today());
                    nextBillingDate=system.today();
                    nextBillingDateList.add(nextBillingDate);
                }
            } catch(Exception e) {
                LOGGER.error(e);
                throw new AuraHandledException(e.getMessage());
            } finally {
                LOGGER.flush();
            }
        }
        return nextBillingDateList;
    }
}