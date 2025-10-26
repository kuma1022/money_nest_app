import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/setting/premium_login_page.dart';
import 'package:money_nest_app/util/global_store.dart';

class SettingsTabPage extends StatefulWidget {
  final AppDatabase db;
  const SettingsTabPage({super.key, required this.db});

  @override
  State<SettingsTabPage> createState() => _SettingsTabPageState();
}

class _SettingsTabPageState extends State<SettingsTabPage>
    with WidgetsBindingObserver {
  bool _isLoggedIn = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GlobalStore().addListener(_onGlobalStoreChanged);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GlobalStore().removeListener(_onGlobalStoreChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用恢复前台时刷新登录状态
    if (state == AppLifecycleState.resumed) {
      _checkLoginStatus();
    }
  }

  void _onGlobalStoreChanged() {
    _checkLoginStatus();
  }

  // 检查登录状态
  Future<void> _checkLoginStatus() async {
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    print('Checking login status - userId: $userId, accountId: $accountId');

    setState(() {
      _isLoggedIn = userId != null && userId.isNotEmpty && accountId != null;
      // 这里可以从 GlobalStore 或其他地方获取用户名
      _userName = _isLoggedIn ? 'ユーザー' : null; // 临时使用默认名称
    });

    print('Login status updated - isLoggedIn: $_isLoggedIn');
  }

  // 登出功能
  Future<void> _logout() async {
    // 显示确认对话框
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウト'),
          content: const Text('本当にログアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('ログアウト'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // 清理数据库中的用户数据
      await widget.db.initialize();

      // 清空持久化数据
      await GlobalStore().clearAllUserData();

      // 更新UI状态
      setState(() {
        _isLoggedIn = false;
        _userName = null;
      });

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ログアウトしました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF23242A) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF23242A)
        : const Color(0xFFE5E6EA);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // プレミアム機能
            _PremiumCard(
              cardColor: cardColor,
              borderColor: borderColor,
              isLoggedIn: _isLoggedIn,
              userName: _userName,
              onLoginPressed: () async {
                if (_isLoggedIn) {
                  await _logout();
                } else {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => PremiumLoginPage(db: widget.db),
                    ),
                  );
                  // 如果登录成功，刷新状态
                  print('Login result: $result');
                  if (result == true) {
                    print('Login successful, refreshing status...');
                    await _checkLoginStatus();
                  }
                }
              },
            ),
            const _NoAdCard(),
            const SizedBox(height: 10),
            _DisplaySettingsCard(
              cardColor: cardColor,
              borderColor: borderColor,
            ),
            // データ管理
            _SectionCard(
              icon: Icons.storage_outlined,
              title: 'データ管理',
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _SettingsTile(
                  icon: Icons.download_outlined,
                  label: 'データエクスポート',
                  onTap: () {},
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                _SettingsTile(
                  icon: Icons.upload_outlined,
                  label: 'データインポート',
                  onTap: () {},
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                _SettingsTile(
                  icon: Icons.account_balance_outlined,
                  label: '証券会社連携',
                  trailing: const Text(
                    '近日公開',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  onTap: () {},
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // セキュリティ
            _SectionCard(
              icon: Icons.shield_outlined,
              title: 'セキュリティ',
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _SettingsTile(
                  icon: Icons.backup_outlined,
                  label: 'データバックアップ',
                  onTap: () {},
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                _SettingsTile(
                  icon: Icons.delete_outline,
                  label: 'データの削除',
                  labelColor: Colors.red,
                  iconColor: Colors.red,
                  trailing: const Icon(Icons.chevron_right, color: Colors.red),
                  onTap: () {},
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // サポート・情報
            _SectionCard(
              icon: Icons.help_outline,
              title: 'サポート・情報',
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _SettingsTile(
                  label: 'ヘルプ・FAQ',
                  onTap: () {},
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                _SettingsTile(
                  label: 'お問い合わせ',
                  onTap: () {},
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                _SettingsTile(
                  label: 'プライバシーポリシー',
                  onTap: () {},
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
                _SettingsTile(
                  label: '利用規約',
                  onTap: () {},
                  cardColor: cardColor,
                  borderColor: borderColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // アプリ情報
            _AppInfoCard(cardColor: cardColor, borderColor: borderColor),
            const SizedBox(height: 32),
            // フッター
            Center(
              child: Text(
                '© 2024 Asset Manager App. All rights reserved.',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// プレミアム機能カード
class _PremiumCard extends StatelessWidget {
  final Color cardColor;
  final Color borderColor;
  final bool isLoggedIn;
  final String? userName;
  final VoidCallback onLoginPressed;

  const _PremiumCard({
    required this.cardColor,
    required this.borderColor,
    required this.isLoggedIn,
    this.userName,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLoggedIn
              ? [const Color(0xFFE8F5E8), const Color(0xFFF0FFF0)] // 绿色系 - 已登录
              : [const Color(0xFFE3F0FF), const Color(0xFFD6F5F2)], // 蓝色系 - 未登录
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLoggedIn ? const Color(0xFFC8E6C9) : const Color(0xFFB7D8F6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部icon和角标
          Row(
            children: [
              Icon(
                isLoggedIn ? Icons.account_circle : Icons.emoji_events_outlined,
                color: isLoggedIn
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF1976D2),
                size: 32,
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isLoggedIn
                      ? const Color(0xFFC8E6C9).withOpacity(0.3)
                      : const Color(0xFFB3E5FC).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLoggedIn ? Icons.check_circle : Icons.auto_graph,
                  color: isLoggedIn
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF4DD0E1),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 标题
          Center(
            child: isLoggedIn
                ? Column(
                    children: [
                      Text(
                        'ようこそ、${userName ?? 'ユーザー'}さん',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'プレミアム機能をお楽しみください',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'プレミアム機能で\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: '投資をもっと賢く',
                          style: TextStyle(
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isLoggedIn ? 'すべての機能が利用可能です' : 'ログインして全機能にアクセスしましょう',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 18),
          // 四宫格功能
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.8,
            children: [
              _PremiumFeatureBox(
                icon: Icons.visibility_off_outlined,
                iconColor: Color(0xFF43A047),
                label: '広告なし',
                isActive: isLoggedIn,
              ),
              _PremiumFeatureBox(
                icon: Icons.show_chart_outlined,
                iconColor: Color(0xFF1976D2),
                label: '高度分析',
                isActive: isLoggedIn,
              ),
              _PremiumFeatureBox(
                icon: Icons.cloud_sync_outlined,
                iconColor: Color(0xFF00ACC1),
                label: 'クラウド同期',
                isActive: isLoggedIn,
              ),
              _PremiumFeatureBox(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: Color(0xFFFF9800),
                label: '複数口座',
                isActive: isLoggedIn,
              ),
            ],
          ),
          const SizedBox(height: 18),
          // 登录/登出按钮
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoggedIn
                    ? Colors.red
                    : const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: Icon(
                isLoggedIn ? Icons.logout : Icons.star_border,
                size: 22,
              ),
              label: Text(
                isLoggedIn ? 'ログアウト' : 'ログイン・新規登録',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: onLoginPressed,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isLoggedIn ? 'プレミアム会員として登録済み' : '月額たった480円〜で全機能が使い放題',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isActive;

  const _PremiumFeatureBox({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withOpacity(0.95)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (isActive) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check_circle, color: Colors.green, size: 14),
          ],
        ],
      ),
    );
  }
}

// 通用设置区块
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color cardColor;
  final Color borderColor;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    required this.cardColor,
    required this.borderColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.7),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

// 单个设置项
class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color? labelColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color borderColor;
  const _SettingsTile({
    this.icon,
    required this.label,
    this.labelColor,
    this.iconColor,
    this.trailing,
    this.onTap,
    required this.cardColor,
    required this.borderColor,
  });
  @override
  Widget build(BuildContext context) {
    final isDanger = labelColor == Colors.red;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDanger ? Colors.red.withOpacity(0.06) : cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: ListTile(
        leading: icon != null
            ? Icon(
                icon,
                color: iconColor ?? (isDanger ? Colors.red : Colors.black54),
                size: 22,
              )
            : null,
        title: Text(
          label,
          style: TextStyle(
            color: labelColor ?? (isDanger ? Colors.red : Colors.black87),
            fontWeight: isDanger ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              color: isDanger ? Colors.red : Colors.black26,
              size: 20,
            ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        minLeadingWidth: 28,
      ),
    );
  }
}

// アプリ情報卡片
class _AppInfoCard extends StatelessWidget {
  final Color cardColor;
  final Color borderColor;
  const _AppInfoCard({required this.cardColor, required this.borderColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.7),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                'アプリ情報',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: Text('バージョン')),
              Text('1.2.3'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Expanded(child: Text('ビルド')),
              Text('202408280001'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Expanded(child: Text('リリース日')),
              Text('2024年8月28日'),
            ],
          ),
        ],
      ),
    );
  }
}

// 底部广告去除卡片
class _NoAdCard extends StatelessWidget {
  const _NoAdCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18, bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6F7EF), Color(0xFFF6FFFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFB2DFDB), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFB2DFDB),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.visibility_off_outlined,
              color: Color(0xFF219473),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '広告を非表示にする',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '快適な操作体験を',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFF219473),
              side: const BorderSide(color: Color(0xFFB2DFDB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
              minimumSize: const Size(0, 36),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {},
            child: const Text(
              '詳細',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// 表示設定カード
class _DisplaySettingsCard extends StatefulWidget {
  final Color cardColor;
  final Color borderColor;
  const _DisplaySettingsCard({
    required this.cardColor,
    required this.borderColor,
    super.key,
  });

  @override
  State<_DisplaySettingsCard> createState() => _DisplaySettingsCardState();
}

class _DisplaySettingsCardState extends State<_DisplaySettingsCard> {
  bool darkMode = false;
  String currency = 'JPY';
  bool notification = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.borderColor, width: 0.7),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.palette_outlined, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                '表示設定',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ダークモード
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.brightness_6_outlined,
              color: Colors.black54,
            ),
            title: const Text('ダークモード', style: TextStyle(fontSize: 14)),
            trailing: Switch(
              value: darkMode,
              onChanged: (v) => setState(() => darkMode = v),
            ),
            onTap: () => setState(() => darkMode = !darkMode),
            minLeadingWidth: 28,
          ),
          // 通貨
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.attach_money_outlined,
              color: Colors.black54,
            ),
            title: const Text('通貨', style: TextStyle(fontSize: 14)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currency,
                  items: const [
                    DropdownMenuItem(value: 'JPY', child: Text('JPY')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'CNY', child: Text('CNY')),
                  ],
                  onChanged: (v) => setState(() {
                    if (v != null) currency = v;
                  }),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  icon: const Icon(Icons.expand_more, size: 18),
                ),
              ),
            ),
            minLeadingWidth: 28,
          ),
          // 通知
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.black54,
            ),
            title: const Text('通知', style: TextStyle(fontSize: 14)),
            trailing: Switch(
              value: notification,
              onChanged: (v) => setState(() => notification = v),
            ),
            onTap: () => setState(() => notification = !notification),
            minLeadingWidth: 28,
          ),
        ],
      ),
    );
  }
}
