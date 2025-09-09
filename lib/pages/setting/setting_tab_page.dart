import 'package:flutter/material.dart';

class SettingsTabPage extends StatefulWidget {
  const SettingsTabPage({super.key});

  @override
  State<SettingsTabPage> createState() => _SettingsTabPageState();
}

class _SettingsTabPageState extends State<SettingsTabPage> {
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
            _PremiumCard(cardColor: cardColor, borderColor: borderColor),
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
  const _PremiumCard({required this.cardColor, required this.borderColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F0FF), Color(0xFFD6F5F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFB7D8F6), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部icon和角标
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: Color(0xFF1976D2),
                size: 32,
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFB3E5FC).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_graph,
                  color: Color(0xFF4DD0E1),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 标题
          const Center(
            child: Text.rich(
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
          const Center(
            child: Text(
              'ログインして全機能にアクセスしましょう',
              style: TextStyle(color: Colors.black54, fontSize: 13),
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
            children: const [
              _PremiumFeatureBox(
                icon: Icons.visibility_off_outlined,
                iconColor: Color(0xFF43A047),
                label: '広告なし',
              ),
              _PremiumFeatureBox(
                icon: Icons.show_chart_outlined,
                iconColor: Color(0xFF1976D2),
                label: '高度分析',
              ),
              _PremiumFeatureBox(
                icon: Icons.cloud_sync_outlined,
                iconColor: Color(0xFF00ACC1),
                label: 'クラウド同期',
              ),
              _PremiumFeatureBox(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: Color(0xFFFF9800),
                label: '複数口座',
              ),
            ],
          ),
          const SizedBox(height: 18),
          // 登录按钮
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.star_border, size: 22),
              label: const Text(
                'ログイン・新規登録',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '月額たった480円〜で全機能が使い放題',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
  const _PremiumFeatureBox({
    required this.icon,
    required this.iconColor,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
