class GlobalStore {
  static final GlobalStore _instance = GlobalStore._internal();
  factory GlobalStore() => _instance;
  GlobalStore._internal();

  String? userId;
  int? accountId;
  // 其它全局变量...
}
