/**
 * Created by admin on 2019-06-11.
 */

public with sharing class TriggerManager {

// Enum representing each of before/after CRUD events on Sobjects
public enum Evt {
AfterDelete, AfterInsert, AfterUndelete,
AfterUpdate, BeforeDelete, BeforeInsert, BeforeUpdate
}

// Map of what handlers we have registered with their functions already
static Map<String, TriggerHandler> handlers = new Map<String, TriggerHandler>();

// Static method called from trigger event
public static void execute(String name) {

// Get handler from registered list
TriggerHandler handler = handlers.get(name);

// Check if handler not registered
if (handler == null) {
handler = createHandler(name);
// Make sure we find a handler
if (handler == null) {
throw new TriggerHandlerException('No Trigger Handler registered for : ' + name);
}
handlers.put(name, handler);
}

// Run trigger handler
handler.run();
}

// Private static method to get the appropriate handler for the object type.
private static TriggerHandler createHandler(String name) {
Type t = Type.forName(name);
return (TriggerHandler) t.newInstance();
}

// Trigger Exception
public class TriggerHandlerException extends Exception {}

}