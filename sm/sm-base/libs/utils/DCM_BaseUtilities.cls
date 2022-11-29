public class DCM_BaseUtilities {
    public static Boolean isNullOrEmpty(Object obj) {
        return obj == null ||
            (obj instanceof String && String.isBlank((String) obj)) ||
            (obj instanceof Set<Object> && ((Set<Object>) obj).isEmpty()) ||
            (obj instanceof List<Object> && ((List<Object>) obj).isEmpty()) ||
            (obj instanceof Map<String, String> && ((Map<String, String>) obj).isEmpty()) ||
            (obj instanceof Map<Object, Object> && ((Map<Object, Object>) obj).isEmpty()) ||
            (obj instanceof Map<String, Object> && ((Map<String, Object>) obj).isEmpty());
    }

    public static Boolean isNotNullOrEmpty(Object obj) {
        return !isNullOrEmpty(obj);
    }

}