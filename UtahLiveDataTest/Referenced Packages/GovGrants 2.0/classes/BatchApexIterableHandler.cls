/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class BatchApexIterableHandler extends GNT.JobManager implements Database.AllowsCallouts, Database.Batchable<Object>, Database.Stateful {
    global BatchApexIterableHandler() {

    }
    global void execute(Database.BatchableContext BC, List<Object> scope) {

    }
    global abstract void execute(List<Object> param0);
    global virtual void finish() {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global abstract List<Object> getRecords();
    global System.Iterable start(Database.BatchableContext BC) {
        return null;
    }
}
