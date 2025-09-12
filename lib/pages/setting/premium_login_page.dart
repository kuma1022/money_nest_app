import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/glass_tab.dart';

class PremiumLoginPage extends StatefulWidget {
  const PremiumLoginPage({super.key});

  @override
  State<PremiumLoginPage> createState() => _PremiumLoginPageState();
}

class _PremiumLoginPageState extends State<PremiumLoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();
  final TextEditingController regPasswordConfirmController =
      TextEditingController();
  final TextEditingController regNicknameController = TextEditingController();
  bool passwordObscure = true;
  bool regPasswordObscure = true;
  bool regPasswordConfirmObscure = true;
  String? regEmailError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _onLogin() async {
    // 登录逻辑
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PremiumSubscribePage()),
    );
  }

  void _onRegister() async {
    // 邮箱验证
    final email = regEmailController.text.trim();
    final emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    setState(() {
      regEmailError = emailValid ? null : '正しいメールアドレスを入力してください';
    });
    if (!emailValid) return;

    // 注册逻辑
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PremiumSubscribePage()),
    );
  }

  void _onAppleLogin() async {
    // 这里应集成Apple官方SDK
    // 示例：弹窗提示
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apple IDでログイン'),
        content: const Text('ここでApple公式のApple IDログイン画面を表示します（SDK連携が必要です）。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 渐变背景层
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB6D0E2),
                  Color(0xFFD6EFFF),
                  Color(0xFFE3E0F9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 2. 内容层（可滚动）
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                        ),
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'プレミアム機能をご利用ください',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  // 毛玻璃卡片
                  GlassTab(
                    borderRadius: 24,
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 18,
                    ),
                    tabController: _tabController,
                    tabs: ['ログイン', '新規登録'],
                    tabBarContent: _buildTabBarContent(context),
                  ),
                  const SizedBox(height: 24),
                  // 下面是“スキップ（デモモード）”
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'スキップ（デモモード）',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // “戻る”按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFE5E6EA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '戻る',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 利用規約说明
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 登录tab内容
  Widget _buildLoginTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          const Text(
            'アカウントにログイン',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            'メールアドレス',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined),
              hintText: 'moneygrow@gmail.com',
              filled: true,
              fillColor: Colors.white.withOpacity(0.4),
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
          const Text(
            'パスワード',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: passwordController,
            obscureText: passwordObscure,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: '••••••••',
              filled: true,
              fillColor: Colors.white.withOpacity(0.4),
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
                ),
                onPressed: () =>
                    setState(() => passwordObscure = !passwordObscure),
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4385F5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _onLogin,
              child: const Text(
                'ログイン',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('または', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE5E6EA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.apple, size: 22, color: Colors.black),
              label: const Text('Apple ID'),
              onPressed: _onAppleLogin,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 新規登録tab内容
  Widget _buildRegisterTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          const Text(
            '新規アカウント作成',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            'ニックネーム（任意）',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: regNicknameController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline),
              hintText: 'マネー太郎',
              filled: true,
              fillColor: Colors.white.withOpacity(0.4),
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
          const Text(
            'メールアドレス',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: regEmailController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined),
              hintText: 'example@email.com',
              filled: true,
              fillColor: Colors.white.withOpacity(0.4),
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
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          const Text(
            'パスワード',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: regPasswordController,
            obscureText: regPasswordObscure,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: '••••••••',
              filled: true,
              fillColor: Colors.white.withOpacity(0.4),
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
                ),
                onPressed: () =>
                    setState(() => regPasswordObscure = !regPasswordObscure),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'パスワード確認',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: regPasswordConfirmController,
            obscureText: regPasswordConfirmObscure,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: '••••••••',
              filled: true,
              fillColor: Colors.white.withOpacity(0.4),
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
                ),
                onPressed: () => setState(
                  () => regPasswordConfirmObscure = !regPasswordConfirmObscure,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4385F5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _onRegister,
              child: const Text(
                'アカウント作成',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('または', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE5E6EA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.apple, size: 22, color: Colors.black),
              label: const Text('Apple ID'),
              onPressed: _onAppleLogin,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 替换Tab内容部分
  Widget _buildTabBarContent(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _tabController.index == 0
          ? SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(), // 不出现滚动条
              child: _buildLoginTab(context),
            )
          : SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: _buildRegisterTab(context),
            ),
    );
  }
}

// 订阅会员页面（示例）
class PremiumSubscribePage extends StatelessWidget {
  const PremiumSubscribePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'プレミアム会員登録',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'ここにプレミアム会員のプラン選択・決済画面を実装してください。',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
