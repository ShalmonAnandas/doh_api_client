mixin ResponseUtils {
// Helper method to convert Map<Object?, Object?> to Map<String, dynamic>
  Map<String, dynamic> convertMap(Map<Object?, Object?> map) {
    return map.map((key, value) {
      // Handle nested maps
      if (value is Map<Object?, Object?>) {
        value = convertMap(value);
      }
      // Handle lists that might contain maps
      else if (value is List) {
        value = convertList(value);
      }
      return MapEntry(key.toString(), value);
    });
  }

// Helper method to convert items in a list
  List convertList(List list) {
    return list.map((item) {
      if (item is Map<Object?, Object?>) {
        return convertMap(item);
      }
      return item;
    }).toList();
  }
}
