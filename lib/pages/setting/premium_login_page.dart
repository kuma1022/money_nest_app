import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/glass_tab.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/setting/verification_dialog.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/services/data_sync_service.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:provider/provider.dart';
import 'package:money_nest_app/services/supabase_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PremiumLoginPage extends StatefulWidget {
  final AppDatabase db;
  const PremiumLoginPage({super.key, required this.db});

  @override
  State<PremiumLoginPage> createState() => _PremiumLoginPageState();
}

class _PremiumLoginPageState extends State<PremiumLoginPage> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();
  final TextEditingController regPasswordConfirmController =
      TextEditingController();
  final TextEditingController regNicknameController = TextEditingController();

  // UI状态
  bool passwordObscure = true;
  bool regPasswordObscure = true;
  bool regPasswordConfirmObscure = true;
  String? regEmailError;
  String? loginError;
  String? registerError;
  bool isLoading = false;

  StreamSubscription<dynamic>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataSync = Provider.of<DataSyncService>(context, listen: false);
      _authSubscription = dataSync.supabaseApi.addAuthStateListener((data) {
        final event = data.event;
        final session = data.session;

        if (event == AuthChangeEvent.signedIn && session != null) {
          print('User signed in: ${session.user.email}');
          if (mounted) {
            setState(() => isLoading = false);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PremiumSubscribePage()),
            );
          }
        }
      });
    });
  }

  // 登录方法 - 修复响应数据处理
  Future<void> _onLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => loginError = 'メールアドレスとパスワードを入力してください');
      return;
    }

    // 邮箱格式验证
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        loginError = '正しいメールアドレスを入力してください';
      });
      return;
    }

    setState(() {
      isLoading = true;
      loginError = null;
    });

    try {
      // 调用 Edge Function
      final dataSync = Provider.of<DataSyncService>(context, listen: false);
      final res = await dataSync.userLogin(email, password);

      print('Login response status: ${res.status}');
      print('Login response data: ${res.data}');
      print('Login response data type: ${res.data.runtimeType}');

      // 安全地检查响应状态和数据
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
              loginError = 'サーバーレスポンスの解析に失敗しました';
            });
            return;
          }
        }

        // 现在检查是否为 Map
        if (responseData is Map) {
          final success = responseData['success'];
          final userId = responseData['user_id'];
          final subscriptions = responseData['subscriptions'];

          print('Parsed data - success: $success, user_id: $userId');

          if (success == true && userId != null) {
            print('Login successful for user: $userId');

            try {
              // 1. 首先清空所有旧数据
              await GlobalStore().clearAllUserData();

              // 2. 保存基本用户信息
              GlobalStore().userId = userId.toString();
              await GlobalStore().saveUserIdToPrefs();

              // 3. 处理订阅和账户信息
              int? accountId;
              bool hasActiveSubscription = false;

              if (subscriptions != null &&
                  subscriptions is List &&
                  subscriptions.isNotEmpty) {
                for (final sub in subscriptions) {
                  if (sub is Map) {
                    // 安全地获取账户ID
                    final rawAccountId = sub['account_id'];
                    if (rawAccountId != null) {
                      if (rawAccountId is int) {
                        accountId ??= rawAccountId;
                      } else if (rawAccountId is String) {
                        try {
                          accountId ??= int.parse(rawAccountId);
                        } catch (e) {
                          print('Failed to parse account_id: $rawAccountId');
                        }
                      }
                    }

                    // 检查订阅状态
                    //final status = sub['status'] as String?;
                    //final platform = sub['platform'] as String?;

                    //if (status != null && platform != null) {
                    //  print(
                    //    'Found subscription: platform=$platform, status=$status',
                    //  );
                    //  if (status == 'active' || status == 'trial') {
                    //    hasActiveSubscription = true;
                    //  }
                    //}
                  }
                }
              }

              // 4. 保存账户ID
              if (accountId != null) {
                GlobalStore().accountId = accountId;
                await GlobalStore().saveAccountIdToPrefs();
                print('Account ID saved: $accountId');
              } else {
                print('Warning: No account_id found for user');
              }

              // 5. 等待一小段时间确保数据保存完成
              await Future.delayed(const Duration(milliseconds: 100));

              // 6. 验证全局状态是否正确设置
              print(
                'GlobalStore state - userId: ${GlobalStore().userId}, accountId: ${GlobalStore().accountId}',
              );

              // 7. 按顺序进行完整的数据初始化
              print('Starting app data initialization...');
              await _performCompleteInitialization();
              print('App data initialization completed');

              if (mounted) {
                Navigator.of(context).pop();

                // 根据订阅状态显示不同的消息
                String message;
                if (hasActiveSubscription) {
                  message = 'ログインに成功しました（プレミアム会員）';
                } else if (subscriptions != null &&
                    subscriptions is List &&
                    subscriptions.isNotEmpty) {
                  message = 'ログインに成功しました（無料会員）';
                } else {
                  message = 'ログインに成功しました';
                }

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }
            } catch (e) {
              print('Error during login initialization: $e');
              setState(() {
                loginError = 'ログイン後の初期化に失敗しました: ${e.toString()}';
              });
            }
          } else {
            final error = responseData['error'];
            setState(() {
              loginError = error?.toString() ?? 'ログインに失敗しました';
            });
          }
        } else {
          print('Response data is not a Map: ${responseData.runtimeType}');
          setState(() {
            loginError = 'サーバーからの応答が無効です: ${responseData.runtimeType}';
          });
        }
      } else {
        setState(() {
          loginError = 'サーバーエラーが発生しました (${res.status})';
        });
      }
    } catch (e) {
      print('Login error: $e');
      print('Login error type: ${e.runtimeType}');

      // 更详细的错误处理
      String errorMessage = 'ネットワークエラーが発生しました';
      if (e.toString().contains('FunctionsException')) {
        errorMessage = 'サーバー機能エラーが発生しました';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'リクエストがタイムアウトしました';
      }

      setState(() => loginError = errorMessage);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 注册方法 - 修复响应数据处理
  Future<void> _onRegister() async {
    final email = regEmailController.text.trim();
    final password = regPasswordController.text.trim();
    final confirmPassword = regPasswordConfirmController.text.trim();
    final nickname = regNicknameController.text.trim();

    // 输入验证保持不变...
    final emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    setState(() {
      regEmailError = emailValid ? null : '正しいメールアドレスを入力してください';
      registerError = null;
    });
    if (!emailValid) return;

    if (password.isEmpty) {
      setState(() {
        registerError = 'パスワードを入力してください';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        registerError = 'パスワードは6文字以上で入力してください';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        registerError = 'パスワードが一致しません';
      });
      return;
    }

    setState(() {
      isLoading = true;
      registerError = null;
    });

    try {
      // 第一步：发送验证码 - 调用 Edge Function
      final dataSync = Provider.of<DataSyncService>(context, listen: false);
      final res = await dataSync.userRegister(email, password, nickname);

      print('Registration response status: ${res.status}');
      print('Registration response data: ${res.data}');
      print('Registration response data type: ${res.data.runtimeType}');

      // 检查响应状态和数据
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
              registerError = 'サーバーレスポンスの解析に失敗しました';
            });
            return;
          }
        }

        // 现在检查是否为 Map
        if (responseData is Map) {
          // 安全地获取值，支持不同的 key 类型
          final success = responseData['success'];

          print('Parsed data - success: $success');

          if (success == true) {
            // 弹出验证码输入弹窗
            if (mounted) {
              showDialog(
                context: context,
                builder: (_) => VerificationDialog(
                  email: email,
                  password: password,
                  nickname: nickname,
                ),
              );
            }
          } else {
            final error = responseData['error'];
            setState(() {
              registerError = error?.toString() ?? 'アカウント作成に失敗しました';
            });
          }
        } else {
          // 响应数据格式不正确
          print('Response data is not a Map: ${responseData.runtimeType}');
          setState(() {
            registerError = 'サーバーからの応答が無効です: ${responseData.runtimeType}';
          });
        }
      } else {
        setState(() {
          registerError = 'サーバーエラーが発生しました (${res.status})';
        });
      }
    } catch (e) {
      print('Registration error: $e');
      print('Registration error type: ${e.runtimeType}');

      // 更详细的错误处理
      String errorMessage = 'ネットワークエラーが発生しました';
      if (e.toString().contains('FunctionsException')) {
        errorMessage = 'サーバー機能エラーが発生しました';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'リクエストがタイムアウトしました';
      }

      setState(() => registerError = errorMessage);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Apple 登录占位
  Future<void> _onAppleLogin() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apple IDでログイン'),
        content: const Text(
          'Apple IDログインは近日実装予定です。\n'
          '現在はメールアドレスでのログインをご利用ください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    regEmailController.dispose();
    regPasswordController.dispose();
    regPasswordConfirmController.dispose();
    regNicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Explicitly set black background
      body: Stack(
        children: [
          // Background Gradient - Removed for simple dark mode or kept as subtle dark gradient if needed.
          // For consistency with other pages, we can just filter it or make it very dark.
          // But user asked for "Simple Dark Mode", usually implies solid or very dark background.
          // Let's us a simple solid black background as base, maybe a subtle gradient if really needed, but sticking to black is safer.
          Container(
           color: Colors.black, // Fully black
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogoHeader(),
                  GlassTab(
                    borderRadius: 24,
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 18,
                    ),
                    tabs: const ['ログイン', '新規登録'],
                    tabBarContentList: _buildTabBarContent(context),
                  ),
                  _buildSkipButton(),
                  _buildBackButton(),
                  _buildTermsText(),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 16), // Light shadow for dark mode
            ],
          ),
          child: const Icon(
            Icons.bar_chart_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'MoneyGrow - 資産管理アプリ',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'プレミアム機能をご利用ください',
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {},
      child: const Text(
        'スキップ（デモモード）',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFF1C1C1E), // Dark card color
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF2C2C2E)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '戻る',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          children: [
            const TextSpan(text: '続行することで、'),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  '利用規約',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF4385F5),
                  ),
                ),
              ),
            ),
            const TextSpan(text: 'および'),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'プライバシーポリシー',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF4385F5),
                  ),
                ),
              ),
            ),
            const TextSpan(text: 'に同意したことになります。'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> _buildTabBarContent(BuildContext context) {
    return [
      SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: _buildLoginTab(context),
      ),
      SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: _buildRegisterTab(context),
      ),
    ];
  }

  Widget _buildLoginTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          const Text(
            'アカウントにログイン',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          if (loginError != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                loginError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 10),

          // 邮箱字段标题和输入框
          const Text(
            'メールアドレス',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
              hintText: 'moneygrow@gmail.com',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 密码字段标题和输入框
          const Text(
            'パスワード',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: passwordController,
            obscureText: passwordObscure,
            enabled: !isLoading,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  passwordObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => passwordObscure = !passwordObscure),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 登录按钮
          ElevatedButton(
            onPressed: isLoading ? null : _onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4385F5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'ログイン',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 18),

          // 分隔线
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFF2C2C2E))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('または', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider(color: Color(0xFF2C2C2E))),
            ],
          ),
          const SizedBox(height: 18),

          // Apple ID 登录按钮
          OutlinedButton.icon(
            onPressed: isLoading ? null : _onAppleLogin,
            icon: const Icon(Icons.apple, size: 22, color: Colors.white),
            label: const Text('Apple ID'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black, // Dark background
              side: const BorderSide(color: Color(0xFF2C2C2E)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRegisterTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          const Text(
            '新規アカウント作成',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          if (registerError != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                registerError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 10),

          // 昵称输入字段
          const Text(
            'ニックネーム（任意）',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: regNicknameController,
            enabled: !isLoading,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
              hintText: 'マネー太郎',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 邮箱输入字段
          const Text(
            'メールアドレス',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: regEmailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
              hintText: 'example@email.com',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              errorText: regEmailError,
            ),
          ),
          const SizedBox(height: 14),

          // 密码输入字段
          const Text(
            'パスワード',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: regPasswordController,
            obscureText: regPasswordObscure,
            enabled: !isLoading,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  regPasswordObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => regPasswordObscure = !regPasswordObscure),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 密码确认输入字段
          const Text(
            'パスワード確認',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: regPasswordConfirmController,
            obscureText: regPasswordConfirmObscure,
            enabled: !isLoading,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  regPasswordConfirmObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(
                  () => regPasswordConfirmObscure = !regPasswordConfirmObscure,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 注册按钮
          ElevatedButton(
            onPressed: isLoading ? null : _onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4385F5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'アカウント作成',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 18),

          // 分隔线
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFF2C2C2E))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('または', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider(color: Color(0xFF2C2C2E))),
            ],
          ),
          const SizedBox(height: 18),

          // Apple ID 注册按钮
          OutlinedButton.icon(
            onPressed: isLoading ? null : _onAppleLogin,
            icon: const Icon(Icons.apple, size: 22, color: Colors.white),
            label: const Text('Apple ID'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black, // Dark background
              side: const BorderSide(color: Color(0xFF2C2C2E)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 进行完整的数据初始化
  Future<void> _performCompleteInitialization() async {
    try {
      final dataSync = Provider.of<DataSyncService>(context, listen: false);
      // 初始化应用数据（login）
      await AppUtils().initializeAppData(dataSync, true);
      // 刷新股票价格
      //await dataSync.getStockPricesByYHFinanceAPI();
      // 刷新全局数据
      await AppUtils().calculateAndSavePortfolio(
        widget.db,
        GlobalStore().userId!,
        GlobalStore().accountId!,
      );
      // 刷新总资产和总成本
      //await AppUtils().refreshTotalAssetsAndCosts(dataSync, forcedUpdate: true);
    } catch (e) {
      print('Error in complete initialization: $e');
      // 重新抛出异常以便上层处理
      rethrow;
    }
  }
}

// 订阅页面
class PremiumSubscribePage extends StatelessWidget {
  const PremiumSubscribePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'プレミアム会員登録',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'ここにプレミアム会員のプラン選択・決済画面を実装してください。',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
