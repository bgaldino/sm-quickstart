/**
 * @author            : Vasudev Ramachandran
 * @last modified on  : 01-21-2021
 * @last modified by  : Vasudev Ramachandran
**/
public with sharing class B2BOrdersHelper {
    
    
    public static B2BOrderModel getB2BOrderModel(Order orderDetail){
        B2BOrderModel orderModel = new B2BOrderModel();
        
        if(null != orderDetail){
            //order Id
            if(isNotNullOrEmpty(orderDetail.Id)){
                orderModel.orderId = orderDetail.Id;
            }
            //order Name
            if(isNotNullOrEmpty(orderDetail.Name)){
                orderModel.name = orderDetail.Name;
            }
            //created date
            if(isNotNullOrEmpty(String.valueOfGmt(orderDetail.CreatedDate))){
                orderModel.createdDate = orderDetail.CreatedDate;
            }
            //Total order amount
            if(isNotNullOrEmpty(String.valueOf(orderDetail.TotalAmount))){
                orderModel.totalAmount = orderDetail.TotalAmount;
            }
            //Account name
            if(isNotNullOrEmpty(orderDetail.Account.Name)){
                orderModel.accountName = orderDetail.Account.Name;
            }
            //Order Status
            if(isNotNullOrEmpty(orderDetail.Status)){
                orderModel.status = orderDetail.Status;
            }
            //Order detail
            if(isNotNullOrEmpty(orderDetail.Status)){
                orderModel.status = orderDetail.Status;
            }
            //Order type
            if(isNotNullOrEmpty(orderDetail.Type)){
                orderModel.orderType = orderDetail.Type;
            }
            
        }
       
        
       return orderModel; 
    }
    
    private static boolean isNotNullOrEmpty(String value){
        
        if(null != value && String.isNotBlank((value))){
            return true;
        } else{
            return false;
        }
    }
    
    public static String getRecordTypeNameById(Id recordId){
         return recordId.getSObjectType().getDescribe().getName();
    }

}