/**
 * Created by admin on 2019-06-11.
 */

public with sharing abstract class TriggerHandler {

    // Internal mapping of handlers
    Map<String, List<TriggerFunction>> eventFunctionMapping = new Map<String, List<TriggerFunction>>();

    // Force build on handler creation
    public TriggerHandler() {
        build();
    }

    // Abstract Method to be implemented by Object Handlers
    abstract void build();

    // Bind functions to events
    public void bind(TriggerManager.Evt e, TriggerFunction f) {
        List<TriggerFunction> functions = eventFunctionMapping.get(e.name());
        if (functions == null) {
            functions = new List<TriggerFunction>();
            eventFunctionMapping.put(e.name(), functions);
        }
        functions.add(f);
    }

    // Unbind a function from the handler
    public void unbind(TriggerManager.Evt e, TriggerFunction f) {
        List<TriggerFunction> functions = eventFunctionMapping.get(e.name());
        if (functions != null) {
            for (Integer i = 0; i <= functions.size(); i++) {
                if (functions.get(i) == f) {
                    functions.remove(i);
                }
            }
        }
    }

    // Invokes correct handlers as per the context of trigger and available registered handlers
    public void run() {
        TriggerManager.Evt e = null;
        if(Trigger.isInsert && Trigger.isBefore){
            e = TriggerManager.Evt.BeforeInsert;
        } else if(Trigger.isInsert && Trigger.isAfter){
            e = TriggerManager.Evt.AfterInsert;
        } else if(Trigger.isUpdate && Trigger.isBefore){
            e = TriggerManager.Evt.BeforeUpdate;
        } else if(Trigger.isUpdate && Trigger.isAfter){
            e = TriggerManager.Evt.AfterUpdate;
        } else if(Trigger.isDelete && Trigger.isBefore){
            e = TriggerManager.Evt.BeforeDelete;
        } else if(Trigger.isDelete && Trigger.isAfter){
            e = TriggerManager.Evt.AfterDelete;
        } else if(Trigger.isUndelete){
            e = TriggerManager.Evt.AfterUndelete;
        }
        List<TriggerFunction> functions = eventFunctionMapping.get(e.name());
        if (functions != null && !functions.isEmpty()) {
            // Run each applicable function
            for (TriggerFunction f : functions.clone()) {
                f.main(this); // Inject handler to the function
            }
        }
    }

    // Base Trigger Function. To be bound to events.
    public abstract class TriggerFunction {

        TriggerHandler handler;

        // Main method injection to add the handler
        public void main(TriggerHandler h) {
            handler = h;
            main();
        }

        // Main Method that must be implemented by Trigger Functions
        abstract void main();

        // Remove this function from the handler for an event
        protected void unbind(TriggerManager.Evt e) {
            handler.unbind(e, this);
        }

    }


}