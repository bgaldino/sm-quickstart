/*
 * DCM_CrudException represents a running user's lack of read/create/update/delete access at a profile (or permission set)
 * level.
 */
public class DCM_CrudException extends DCM_SecurityException {
    public DCM_CrudException(DCM_OperationType operation, Schema.SObjectType objectType) {
        this.operationType = operation;
        this.objectType = objectType;
        if (operation == DCM_OperationType.CREATE)
            this.setMessage(System.Label.fflib_security_error_object_not_insertable);
        else if (operation == DCM_OperationType.READ)
            this.setMessage(System.Label.fflib_security_error_object_not_readable);
        else if (operation == DCM_OperationType.MODIFY)
            this.setMessage(System.Label.fflib_security_error_object_not_updateable);
        else if (operation == DCM_OperationType.DEL)
            this.setMessage(System.Label.fflib_security_error_object_not_deletable);

        this.setMessage(String.format(this.getMessage(), new List<String>{ objectType.getDescribe().getName() }));
    }
}
