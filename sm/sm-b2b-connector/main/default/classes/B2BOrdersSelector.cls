/**
 * @author            : Priyanka Sharma
 * @last modified on  : 03-02-2022
 * @last modified by  : Abhishek Walia
**/
public with sharing class B2BOrdersSelector {

    public static final String OBJECT_API_NAME = 'Order';
    public static final String FILTER_STATUS = 'Order In Progress';

    public static Set<String> getDefaultFields() {
        return new Set<String>{
                'Id',
                'Name',
                'CreatedDate',
                'Pricebook2Id',
                'TotalAmount',
                'AccountId',
                'Account.Name,Account.ownerId',
                'CurrencyIsoCode', 
                'Status',
                'Type',
                'EffectiveDate',
                'OrderNumber',
                'OrderedDate',
                'OpportunityId',
                'Opportunity.AccountId',
                'PoNumber',
                 'createdBy.AccountId',
                'OwnerId, Owner.FirstName, Owner.LastName,Owner.Email',
                '(SELECT Id,CurrencyIsoCode,PriceBookEntryId',
                  'Product2Id, Product2.Name,Product2.ProductCode,Product2.StockKeepingUnit ,Product2.DisplayUrl,Product2.isActive',
                 'Quantity,UnitPrice ,TotalPrice , Description FROM orderItems)'
        };
    }
    
    
    public static Set<String> getAllFields() {
        Set<String> retSet = new Set<String>();
        retSet.addAll(getDefaultFields());
        return retSet;
    }

    public static String getQueryFieldString() {
        List<String> queryFieldsList = new List<String>(getAllFields());
        return String.join(queryFieldsList,',');
    }

    public static String getQueryWhere(Map<String, Object> mapParam) {
        String whereClause = mapParam.containsKey('selectedStatus') ?  ' WHERE Status IN: statusList ' : ' WHERE Id = :currentOrderId ';
        String uId = UserInfo.getUserId();
        User u = [SELECT Id,AccountId,userType FROM User WHERE Id=:uId WITH SECURITY_ENFORCED];
        String accId = u.AccountId;
        if(String.isNotBlank(accId)){
            whereClause += ' AND Cart__c !=NULL '; List<String> taxExemptRTList = B2BUtils.getTaxExemptRecordTypes(); List<String> internalAccountIdList = B2BUtils.getInternalAccounts(); if(!internalAccountIdList.contains(accId)){if(mapParam.containsKey('myOrderOnly') && (Boolean)mapParam.get('myOrderOnly')){whereClause += ' AND createdById = \''+uId+'\' ';} 
            }else{whereClause += ' AND createdById = \''+uId+'\' ';
            }
            if(mapParam.containsKey('filterText') && String.IsNotBlank((String)mapParam.get('filterText'))){ String key = '\'%' + String.escapeSingleQuotes((String)mapParam.get('filterText')) + '%\''; whereClause += ' AND ('; whereClause += ' OrderNumber LIKE '+key; whereClause += ' OR Account.Name LIKE '+key; whereClause += ' OR Status LIKE '+key; whereClause += ' OR Owner.Name LIKE '+key; whereClause += ') ';
            }   
        }else{

        }

        return whereClause;
    }

    public static List<Order> getOrderByStatus(Map<String, Object> mapParam)
    {        
        String selectClause = ' SELECT '+getQueryFieldString()+' FROM '+OBJECT_API_NAME+' ' ;
        String statusListStr = (String)mapParam.get('selectedStatus');
        List<String> statusList = (List<String>)statusListStr.split(';') ;
        String uId = UserInfo.getUserId();
        User u = [SELECT Id,AccountId,userType FROM User WHERE Id=:uId WITH SECURITY_ENFORCED];
        String accId = u.AccountId;
        if(String.isBlank(accId)){
            statusList = new List<String>();
        }
        String whereClause = getQueryWhere(mapParam);
        String limitClause = ' LIMIT '+String.valueOf(mapParam.get('limit'))+' OFFSET '+String.valueOf(mapParam.get('offset'));
        String query = selectClause+whereClause+' ORDER BY CreatedDate DESC'+limitClause;
        System.debug(query);
        return Database.query(query);
    } 
    
    public static Integer getCountData(Map<String, Object> mapParam){
        String statusListStr = (String)mapParam.get('selectedStatus');
        List<String> statusList = (List<String>)statusListStr.split(';') ;
        String uId = UserInfo.getUserId();
        User u = [SELECT Id,AccountId,userType FROM User WHERE Id=:uId WITH SECURITY_ENFORCED];
        String accId = u.AccountId;
        if(String.isBlank(accId)){
            statusList = new List<String>();
        }
        return Database.countQuery ( 'SELECT count() FROM '+ OBJECT_API_NAME + ' '+ getQueryWhere(mapParam) + ' WITH SECURITY_ENFORCED' );
    }

    public static String getAccountId(String userId){
        String accountId    = null;
        List<User> uList = [SELECT Id,AccountId FROM USER WHERE Id=:userId AND AccountId != null WITH SECURITY_ENFORCED];

        if(!uList.isEmpty()){
            accountId = uList.get(0).AccountId;
        }
        return accountId;
    }
    
    
    public static Order getOrderDetails(String orderId){
        Id currentOrderId = orderId;
        
        if(B2BOrdersHelper.getRecordTypeNameById((Id)orderId).equalsIgnoreCase(B2BConstants.OBJ_API_NAME_ORDER_SUMMARY)){
            List<OrderSummary> currentOrderSummaryList = [SELECT Id, OriginalOrderId FROM OrderSummary WHERE Id = :orderId WITH SECURITY_ENFORCED LIMIT 1]; currentOrderId = currentOrderSummaryList[0].OriginalOrderId;
        }
        String whereClause = getQueryWhere(new Map<String,String>());
        String query = 'SELECT ' + getQueryFieldString() + ' FROM Order '+whereClause+' LIMIT 1 ';
        system.debug('whereClause=== '+whereClause);
        List<Order> orderConfirmation = Database.query(query);
        Order orderIns = new Order();
        if(!orderConfirmation.isEmpty()) {
            orderIns =  orderConfirmation.get(0);
        }
        return orderIns;
        
        
    }

}