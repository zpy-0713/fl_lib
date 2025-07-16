typedef JsonFromJson<T> = T Function(Map<String, dynamic> json);
typedef JsonToJson<T> = Map<String, dynamic> Function(T object);