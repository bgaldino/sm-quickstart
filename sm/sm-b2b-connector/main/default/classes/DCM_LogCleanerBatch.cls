/**
 * MIT License
 *
 * Copyright (c) 2019 Piotr Kożuchowski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
/**
 * This batch is responsible for deleting logs past retention date.
 */
public without sharing class DCM_LogCleanerBatch implements Database.Batchable<SObject> {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date retentionDate = DCM_LoggerSettings.getRetentionDate();
        return Database.getQueryLocator(
            'SELECT ID' +
            ' FROM DCM_Application_Log__c' +
            ' WHERE CreatedDate < :retentionDate'
        );
    }

    public void execute(Database.BatchableContext bc, List<DCM_Application_Log__c> logs) {
        DmlManager.deleteAsSystem(logs);
    }

    public void finish(Database.BatchableContext bc) {
    }
}