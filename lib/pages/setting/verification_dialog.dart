// 验证码弹窗示例
import 'package:flutter/material.dart';
import 'dart:convert'; // 添加 JSON 解析支持
import 'package:money_nest_app/util/global_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 验证码弹窗示例
class VerificationDialog extends StatefulWidget {
  final String email;
  final String password;
  final String nickname;

  const VerificationDialog({
    super.key,
    required this.email,
    required this.password,
    required this.nickname,
  });

  @override
  State<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  String? error;

  Future<void> _verifyCode() async {
    final code = codeController.text.trim();
    if (code.length != 6) {
      setState(() {
        error = '6桁の認証コードを入力してください';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // 第二步：验证验证码并完成注册
      final res = await supabase.functions.invoke(
        'money_grow_api',
        body: {
          'action': 'register',
          'email': widget.email,
          'password': widget.password,
          'name': widget.nickname.isEmpty ? null : widget.nickname,
          'account_type': 'personal',
          'code': code, // 传入验证码
        },
        headers: {'Content-Type': 'application/json'},
        method: HttpMethod.post,
      );

      print('Verification response status: ${res.status}');
      print('Verification response data: ${res.data}');
      print('Verification response data type: ${res.data.runtimeType}');

      if (res.status == 200 && res.data != null) {
        // 更灵活的响应数据处理
        dynamic responseData = res.data is String
            ? jsonDecode(res.data)
            : res.data;

        // 处理可能的 JSON 字符串
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            print('Failed to parse JSON string: $e');
            setState(() {
              error = 'サーバーレスポンスの解析に失敗しました';
            });
            return;
          }
        }

        // 现在检查是否为 Map
        if (responseData is Map) {
          final success = responseData['success'];
          final userId = responseData['user_id'];
          final accountId = responseData['account_id']; // 可能不存在

          print(
            'Parsed data - success: $success, user_id: $userId, account_id: $accountId',
          );

          if (success == true &&
              userId != null &&
              accountId != null &&
              userId is String &&
              accountId is int) {
            // 保存用户信息到全局状态
            await GlobalStore().clearAllUserData();
            GlobalStore().userId = userId.toString();
            GlobalStore().accountId = accountId.toInt();
            await GlobalStore().saveUserIdToPrefs();
            await GlobalStore().saveAccountIdToPrefs();

            // 注册成功，关闭对话框
            if (mounted) {
              Navigator.of(context).pop(); // 关闭验证码对话框
              Navigator.of(context).pop(); // 关闭登录页面
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('アカウント作成が完了しました')));
            }
          } else {
            final errorMsg = responseData['error'];
            setState(() {
              error = errorMsg?.toString() ?? '認証に失敗しました';
            });
          }
        } else {
          print('Response data is not a Map: ${responseData.runtimeType}');
          setState(() {
            error = 'サーバーからの応答が無効です: ${responseData.runtimeType}';
          });
        }
      } else {
        setState(() {
          error = 'サーバーエラーが発生しました (${res.status})';
        });
      }
    } catch (e) {
      print('Verification error: $e');
      print('Verification error type: ${e.runtimeType}');

      // 更详细的错误处理
      String errorMessage = 'ネットワークエラーが発生しました';
      if (e.toString().contains('FunctionsException')) {
        errorMessage = 'サーバー機能エラーが発生しました';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'リクエストがタイムアウトしました';
      }

      setState(() {
        error = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('メール認証'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.email} に認証コードを送信しました。'),
          const SizedBox(height: 16),
          TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            enabled: !isLoading,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: '認証コード（6桁）',
              hintText: '123456',
              counterText: '',
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _verifyCode,
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('確認'),
        ),
      ],
    );
  }
}
