public with sharing class ObjectBag {
    private static Map<String, Schema.SObjectType> globalDescribe;

    private Map<String, Object> values = new Map<String, Object>();

    public ObjectBag() {
    }

    public ObjectBag(Map<String,Object> values) {
        this();
        putAll(values);
    }

    public void put(String key, Object o) {
        values.put(key, o);
    }

    public void put(SObject o) {
        String objectName = o.getSObjectType().getDescribe().getName();
        values.put(objectName, o);
    }

    public void putAll(Map<String, Object> topLevelValues) {
        values.putAll(topLevelValues);
    }

    public Object get(String path) {
        String[] atoms = path.split('\\s*\\.\\s*');
        Object currentValue = values;
        for(Integer i = 0, size = atoms.size(); i < size; i++) {
            currentValue = getProperty(currentValue, atoms[i], i < size - 1);
        }
        return currentValue;
    }

    private static Object getProperty(Object o, String property, Boolean isInnerProperty) {
        if(o instanceof Map<String, Object>) {
            return ((Map<String, Object>)o).get(property);
        }

        if(o instanceof SObject) {
            if(isInnerProperty) {
                return ((SObject)o).getSObject(property);
            }
            return ((SObject)o).get(property);
        }

        return null;
    }
}