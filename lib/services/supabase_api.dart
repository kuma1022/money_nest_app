import 'dart:async';
import 'dart:convert';
import 'package:money_nest_app/db/app_database.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseApi {
  final SupabaseClient client;

  SupabaseApi(this.client) {
    _initInternalListener();
  }

  StreamController<AuthState>? _authController;
  Stream<AuthState> get authStateChanges {
    _authController ??= StreamController<AuthState>.broadcast();
    return _authController!.stream;
  }

  StreamSubscription<dynamic>? _internalSub;
  void _initInternalListener() {
    _internalSub ??= client.auth.onAuthStateChange.listen((data) {
      try {
        _authController?.add(data);
      } catch (_) {}
    });
  }

  // 页面调用：返回 StreamSubscription，页面负责取消
  StreamSubscription<AuthState> addAuthStateListener(
    void Function(AuthState e) onData,
  ) {
    return authStateChanges.listen(onData);
  }

  Future<void> dispose() async {
    await _internalSub?.cancel();
    await _authController?.close();
    _internalSub = null;
    _authController = null;
  }

  // 调用 Supabase 函数
  Future<FunctionResponse> supabaseInvoke(
    String functionName, {
    Map<String, String>? headers,
    Object? body,
    Iterable<MultipartFile>? files,
    Map<String, dynamic>? queryParameters,
    HttpMethod method = HttpMethod.post,
    String? region,
  }) async {
    return await client.functions.invoke(
      functionName,
      headers: headers,
      body: body,
      files: files,
      queryParameters: queryParameters,
      method: method,
      region: region,
    );
  }
}
