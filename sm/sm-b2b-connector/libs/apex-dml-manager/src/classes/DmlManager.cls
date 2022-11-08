/*
 * Copyright (c), PatronManager LLC
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * - Neither the name of the Patron Holdings nor the names of its contributors
 * may be used to endorse or promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

public inherited sharing class DmlManager {
    // Items in the following set must be entered in lower case
    private static Set<String> exceptionValues = new Set<String>{ 'id', 'isdeleted', 'createddate', 'systemmodstamp', 'lastmodifiedbyid', 'createdbyid', 'lastmodifieddate' };

    private static Map<DCM_OperationType, Map<SObjectType, List<String>>> cachedRestrictedFields = new Map<DCM_OperationType, Map<SObjectType, List<String>>>();

    // CRUD/FLS-safe DML operations. These honor the CRUD and FLS permissions of the running user
    public static void insertAsUser(sObject obj) {
        performDMLOperation(new List<sObject>{ obj }, DCM_OperationType.CREATE);
    }

    public static void updateAsUser(sObject obj) {
        performDMLOperation(new List<sObject>{ obj }, DCM_OperationType.MODIFY);
    }

    public static void upsertAsUser(sObject obj) {
        performDMLOperation(new List<sObject>{ obj }, DCM_OperationType.OP_UPSERT);
    }

    public static void deleteAsUser(sObject obj) {
        performDMLOperation(new List<sObject>{ obj }, DCM_OperationType.DEL);
    }

    public static void mergeAsUser(sObject masterObj, SObject mergeObj) {
        performDMLMergeOperation(masterObj, new List<SObject>{ mergeObj });
    }

    public static void insertAsUser(List<SObject> objList) {
        performDMLOperation(objList, DCM_OperationType.CREATE);
    }

    public static void updateAsUser(List<SObject> objList) {
        performDMLOperation(objList, DCM_OperationType.MODIFY);
    }

    public static void upsertAsUser(List<SObject> objList) {
        performDMLOperation(objList, DCM_OperationType.OP_UPSERT);
    }

    public static void deleteAsUser(List<SObject> objList) {
        performDMLOperation(objList, DCM_OperationType.DEL);
    }

    public static void mergeAsUser(SObject masterObj, List<SObject> mergeList) {
        performDMLMergeOperation(masterObj, mergeList);
    }

    // Pass-thru methods to raw DML operations.
    // Use these sparingly, and only with good reason, since the DML operations are not CRUD/FLS safe
    public static void insertAsSystem(sObject obj) {
        insert obj;
    }

    public static void updateAsSystem(sObject obj) {
        update obj;
    }

    public static void upsertAsSystem(sObject obj) {
        upsert obj;
    }

    public static void deleteAsSystem(sObject obj) {
        delete obj;
    }

    public static void mergeAsSystem(SObject masterObj, SObject mergeObj) {
        Database.merge(masterObj, mergeObj);
    }

    public static void insertAsSystem(List<SObject> objList) {
        insert objList;
    }

    public static void updateAsSystem(List<SObject> objList) {
        update objList;
    }

    public static void upsertAsSystem(List<SObject> objList) {
        upsert objList;
    }

    public static void deleteAsSystem(List<SObject> objList) {
        delete objList;
    }

    public static void mergeAsSystem(SObject masterObj, List<SObject> mergeList) {
        Database.merge(masterObj, mergeList);
    }

    private static void performDMLOperation(List<SObject> objList, DCM_OperationType dmlOperation) {
        Map<SObjectType, List<Id>> objTypeMap = analyzeDMLCollection(objList, dmlOperation);

        checkCRUDPermission(objTypeMap.keySet(), dmlOperation);

        if (dmlOperation == DCM_OperationType.CREATE) {
            for (SObject obj : objList) {
                checkCreateAction(obj);
            }
        } else if (dmlOperation == DCM_OperationType.MODIFY || dmlOperation == DCM_OperationType.OP_UPSERT) {
            Map<Id, SObject> existingRecords = getExistingRecords(objTypeMap);

            for (SObject obj : objList) {
                SObject existingRecord = existingRecords.get(obj.Id);
                if (obj.id != null) {
                    checkUpdateAction(obj, existingRecord);
                } else {
                    checkCreateAction(obj);
                }
            }
        }
        // If no errors have been thrown to this point, execute the dml operation.
        if (dmlOperation == DCM_OperationType.CREATE) {
            insert objList;
        } else if (dmlOperation == DCM_OperationType.MODIFY) {
            update objList;
        } else if (dmlOperation == DCM_OperationType.OP_UPSERT) {
            upsertCollection(objList);
        } else if (dmlOperation == DCM_OperationType.DEL) {
            delete objList;
        }
    }

    /*
     * Checks for CRUD on the master & merge objects and throws error if they don't have the proper object permission
     * If all checks pass, the merge operation is performed.
     *
     * @param masterObj
     * SObject
     * the
     * data
     *       will be merged into
     * @param mergeList
     * List
     * of
     * SObjects
     *       that will be merged into the masterObj
     */
    private static void performDMLMergeOperation(SObject masterObj, List<SObject> mergeList) {
        // Make sure the master object can be updated.
        checkCRUDPermission(new Set<SObjectType>{ masterObj.getSObjectType() }, DCM_OperationType.MODIFY);

        // Make sure the merge object can be deleted.
        checkCRUDPermission(new Set<SObjectType>{ mergeList[0].getSObjectType() }, DCM_OperationType.DEL);

        // If no errors have been thrown to this point, execute the merge operation.
        Database.merge(masterObj, mergeList);
    }

    private static void upsertCollection(List<SObject> objList) {
        // This is to deal with a call to upsertAsUser with a singular object.
        // Since we wrap that into a List<SObject> (which can't be passed into an upsert)
        // we unpack it and upsert the object individually.
        if (objList.size() == 1) {
            upsert objList.get(0);
        } else {
            upsert objList;
        }
    }

    private static Map<String, Object> getFieldMapFromExistingSObject(SObject obj) {
        // Get actual fields present in object.  The getPopulatedFieldsAsMap method removes implicit nulls.
        return obj.getPopulatedFieldsAsMap();
    }

    private static void checkCreateAction(SObject obj) {
        List<String> restrictedFields = cachedRestrictedFields.get(DCM_OperationType.CREATE).get(obj.getSObjectType());
        //Save ourselves a trip through the loop below if there are no restricted fields
        if (restrictedFields == null || restrictedFields.isEmpty()) {
            return;
        }

        Map<String, Object> fieldsMap = getFieldMapFromExistingSObject(obj);

        // If any restricted fields are present, throw an exception
        for (String fieldName : restrictedFields) {
            if (fieldsMap.get(fieldName) != null) {
                // if any of the restricted fields are present in the candidate, throw an exception
                throw new DCM_FlsException(DCM_OperationType.CREATE, obj.getSObjectType(), obj.getSObjectType().getDescribe().fields.getMap().get(fieldName));
            }
        }
    }

    private static void checkUpdateAction(SObject obj, SObject existingRecord) {
        List<String> restrictedFields = cachedRestrictedFields.get(DCM_OperationType.MODIFY).get(obj.getSObjectType());
        //Save ourselves a trip through the loop below if there are no restricted fields
        if (restrictedFields == null || restrictedFields.isEmpty()) {
            return;
        }

        if (existingRecord == null) {
            throw new DmlManagerException('DMLManager ERROR:  An existing record could not be found for object with Id = ' + obj.Id);
        }

        Map<String, Object> fieldsMap = getFieldMapFromExistingSObject(obj);

        // If any of the restricted values are present and have changed in the dml candidate object, throw an exception
        for (String fieldName : restrictedFields) {
            if (fieldsMap.get(fieldName) != null && fieldsMap.get(fieldName) != existingRecord.get(fieldName)) {
                throw new DCM_FlsException(DCM_OperationType.MODIFY, obj.getSObjectType(), obj.getSObjectType().getDescribe().fields.getMap().get(fieldName));
            }
        }
    }

    // For update and upsert operations, retrieve a Map of all existing records, for each object that has an ID.
    // objects without an Id are skipped, because there is no existing record in the database.
    private static Map<Id, SObject> getExistingRecords(Map<SObjectType, List<Id>> objTypeMap) {
        Map<ID, SObject> result = new Map<Id, SObject>();

        Map<SObjectType, List<String>> operationRestrictedFields = cachedRestrictedFields.get(DCM_OperationType.MODIFY);

        for (SObjectType objType : objTypeMap.keySet()) {
            List<String> restrictedFields = operationRestrictedFields.get(objType);

            if (restrictedFields == null || restrictedFields.isEmpty()) {
                continue;
            }

            List<Id> seenIds = objTypeMap.get(objType);
            if (seenIds.isEmpty()) {
                continue;
            }

            String fieldList = String.join(restrictedFields, ',');
            result.putAll((Database.query('SELECT ' + fieldList + ' FROM ' + objType.getDescribe().getName() + ' WHERE Id IN :seenIds')));
        }

        return result;
    }

    // Check CRUD permissions for the current user on the object
    private static void checkCRUDPermission(Set<SObjectType> objTypeList, DCM_OperationType dmlOperation) {
        for (SObjectType objType : objTypeList) {
            DescribeSObjectResult describeObject = objType.getDescribe();
            if (
                (dmlOperation == DCM_OperationType.CREATE && !describeObject.isCreateable()) ||
                (dmlOperation == DCM_OperationType.MODIFY && !describeObject.isUpdateable()) ||
                (dmlOperation == DCM_OperationType.DEL && !describeObject.isDeletable()) ||
                (dmlOperation == DCM_OperationType.OP_UPSERT && !(describeObject.isCreateable() && describeObject.isUpdateable()))
            ) {
                throw new DCM_CrudException(dmlOperation, objType);
            }
        }
    }

    // Get a Map of all the object types in the dml request and the list of fields for each
    // that the current user cannot update, based on FLS security settings
    private static Map<SObjectType, List<Id>> analyzeDMLCollection(List<SObject> objList, DCM_OperationType dmlOperation) {
        Map<SObjectType, List<Id>> result = new Map<SObjectType, List<Id>>();

        for (SObject obj : objList) {
            ensureRestrictedFieldsEntry(obj, dmlOperation);

            List<Id> seenIds = result.get(obj.getSObjectType());
            if (seenIds == null) {
                seenIds = new List<Id>();
                result.put(obj.getSObjectType(), seenIds);
            }

            if (obj.Id == null) {
                continue;
            }

            seenIds.add(obj.Id);
        }
        return result;
    }

    private static void ensureRestrictedFieldsEntry(SObject obj, DCM_OperationType dmlOperation) {
        if (dmlOperation == DCM_OperationType.OP_UPSERT) {
            ensureRestrictedFields(obj, DCM_OperationType.CREATE);
            ensureRestrictedFields(obj, DCM_OperationType.MODIFY);
        } else {
            ensureRestrictedFields(obj, dmlOperation);
        }
    }

    private static void ensureRestrictedFields(SObject obj, DCM_OperationType dmlOperation) {
        Map<SObjectType, List<String>> operationRestrictedFields = cachedRestrictedFields.get(dmlOperation);
        if (operationRestrictedFields == null) {
            operationRestrictedFields = new Map<SObjectType, List<String>>();
            cachedRestrictedFields.put(dmlOperation, operationRestrictedFields);
        }

        if (!operationRestrictedFields.containsKey(obj.getSObjectType())) {
            DescribeSObjectResult describeObject = obj.getSObjectType().getDescribe();

            Map<String, Schema.SObjectField> objectFields = describeObject.fields.getMap();

            List<String> restrictedFields = new List<String>();

            for (String nm : objectFields.keyset()) {
                if (!exceptionValues.contains(nm.toLowerCase())) {
                    DescribeFieldResult fr = objectFields.get(nm).getDescribe();
                    if ((!fr.isCalculated()) && ((dmlOperation == DCM_OperationType.CREATE && !fr.isCreateable()) || (dmlOperation == DCM_OperationType.MODIFY && !fr.isUpdateable()))) {
                        restrictedFields.add(fr.getName());
                    } // there is not an isDeletable method at the field level
                }
            }
            operationRestrictedFields.put(obj.getSObjectType(), restrictedFields);
        }
    }

    public virtual class DmlManagerException extends Exception {
    }
}