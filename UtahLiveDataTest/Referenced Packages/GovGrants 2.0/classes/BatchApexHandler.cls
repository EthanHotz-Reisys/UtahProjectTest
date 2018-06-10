/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class BatchApexHandler extends GNT.JobManager implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global BatchApexHandler() {

    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) {

    }
    global abstract void execute(List<SObject> param0);
    global virtual void finish() {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global abstract String getQuery();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
