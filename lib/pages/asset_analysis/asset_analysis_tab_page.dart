import 'package:flutter/material.dart';

class AssetAnalysisPage extends StatefulWidget {
  const AssetAnalysisPage({super.key});

  @override
  State<AssetAnalysisPage> createState() => _AssetAnalysisPageState();
}

class _AssetAnalysisPageState extends State<AssetAnalysisPage> {
  int tabIndex = 0; // 0: 資産分析, 1: 損益分析
  int stockTab = 1; // 0: 日本株, 1: 米国株
  int calendarTab = 1; // 0: 月別, 1: 年別

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF7F8FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '資産分析',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab切换
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E6EA)),
              ),
              child: Row(
                children: [
                  _AnalysisTabButton(
                    text: '資産分析',
                    selected: tabIndex == 0,
                    onTap: () => setState(() => tabIndex = 0),
                  ),
                  _AnalysisTabButton(
                    text: '損益分析',
                    selected: tabIndex == 1,
                    onTap: () => setState(() => tabIndex = 1),
                  ),
                ],
              ),
            ),
            if (tabIndex == 0) ...[
              // Pie Chart & Asset Trend
              _AssetPieCard(),
              const SizedBox(height: 18),
              _AssetTrendCard(),
            ] else ...[
              // 損益分析
              _StockTabSwitcher(
                selected: stockTab,
                onChanged: (i) => setState(() => stockTab = i),
              ),
              const SizedBox(height: 14),
              _ProfitSummaryCard(isJapan: stockTab == 0),
              const SizedBox(height: 18),
              _ProfitTop5Card(isJapan: stockTab == 0),
              const SizedBox(height: 18),
              _LossTop5Card(isJapan: stockTab == 0),
              const SizedBox(height: 18),
              _ProfitTrendCard(),
              const SizedBox(height: 18),
              _ProfitCalendarCard(
                tab: calendarTab,
                onTabChanged: (i) => setState(() => calendarTab = i),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- UI部件实现 ---

class _AnalysisTabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _AnalysisTabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1976D2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _StockTabSwitcher extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _StockTabSwitcher({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      child: Row(
        children: [
          _StockTabButton(
            text: '日本株',
            selected: selected == 0,
            onTap: () => onChanged(0),
          ),
          _StockTabButton(
            text: '米国株',
            selected: selected == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _StockTabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _StockTabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1976D2) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// --- 損益分析卡片 ---

class _ProfitSummaryCard extends StatelessWidget {
  final bool isJapan;
  const _ProfitSummaryCard({required this.isJapan});
  @override
  Widget build(BuildContext context) {
    // 示例数据
    final profit = isJapan ? 125000 : 75000;
    final loss = isJapan ? 25000 : 5000;
    final net = isJapan ? 100000 : 70000;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isJapan ? '日本株 総合損益' : '米国株 総合損益',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Color(0xFF43A047),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '総利益',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Text(
                        '¥${profit.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(
                          color: Color(0xFF43A047),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEAEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.trending_down,
                        color: Color(0xFFE53935),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '総損失',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Text(
                        '¥${loss.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              '純損益\n¥${net.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
              style: const TextStyle(
                color: Color(0xFF009688),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitTop5Card extends StatelessWidget {
  final bool isJapan;
  const _ProfitTop5Card({required this.isJapan});
  @override
  Widget build(BuildContext context) {
    // 示例数据
    final items = isJapan
        ? [
            ['6758', 'ソニー', 75000],
            ['7203', 'トヨタ自動車', 50000],
            ['4689', 'Zホールディングス', 25000],
            ['9984', 'ソフトバンクグループ', 15000],
          ]
        : [
            ['AAPL', 'Apple Inc.', 30000],
            ['MSFT', 'Microsoft', 25000],
            ['GOOGL', 'Alphabet', 20000],
            ['TSLA', 'Tesla', 15000],
            ['NVDA', 'NVIDIA', 10000],
            ['8306', '三菱UFJ', 10000],
          ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '利益 Top 5',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1976D2),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'すべて見る →',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          ...List.generate(items.length, (i) {
            final item = items[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF43A047),
                  radius: 16,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  item[0] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  item[1] as String,
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Text(
                  '¥${item[2].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: Color(0xFF43A047),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
                minLeadingWidth: 32,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LossTop5Card extends StatelessWidget {
  final bool isJapan;
  const _LossTop5Card({required this.isJapan});
  @override
  Widget build(BuildContext context) {
    // 示例数据
    final items = isJapan
        ? [
            ['9432', 'NTT', 15000],
            ['6501', '日立製作所', 10000],
          ]
        : [
            ['9432', 'NTT', 15000],
            ['6501', '日立製作所', 10000],
          ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '損失 Top 5',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1976D2),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'すべて見る →',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          ...List.generate(items.length, (i) {
            final item = items[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEAEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE53935),
                  radius: 16,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  item[0] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  item[1] as String,
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Text(
                  '¥${item[2].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
                minLeadingWidth: 32,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// --- 资产分析tab内容 ---

class _AssetPieCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 这里只用静态图和数据占位，实际可用fl_chart等库绘制
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '資産総覧',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Text(
                      '品類別',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Icon(Icons.expand_more, size: 18, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Pie chart placeholder
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFF43A047),
                      Color(0xFF1976D2),
                      Color(0xFFFFA726),
                      Color(0xFF8E24AA),
                      Color(0xFF43A047),
                    ],
                    stops: [0.0, 0.46, 0.74, 0.90, 1.0],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '資産総額',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '¥1,600,000',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    _AssetPieLegend(
                      color: Color(0xFF43A047),
                      label: '日本株',
                      value: '¥750,000',
                      percent: '46.9%',
                    ),
                    _AssetPieLegend(
                      color: Color(0xFF1976D2),
                      label: '米国株',
                      value: '¥450,000',
                      percent: '28.1%',
                    ),
                    _AssetPieLegend(
                      color: Color(0xFFFFA726),
                      label: '現金',
                      value: '¥250,000',
                      percent: '15.6%',
                    ),
                    _AssetPieLegend(
                      color: Color(0xFF8E24AA),
                      label: 'その他',
                      value: '¥150,000',
                      percent: '9.4%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssetPieLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String percent;
  const _AssetPieLegend({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Text(
            percent,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _AssetTrendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 静态折线图占位
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '資産走勢',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Text(
                      '6ヶ月',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Icon(Icons.expand_more, size: 18, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _LineChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

// 折线图简单占位
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);

    // 绘制点
    final dotPaint = Paint()..color = const Color(0xFF1976D2);
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- 損益分析tab内容 ---

class _ProfitTrendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '収益走勢',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _LineChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitCalendarCard extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTabChanged;
  const _ProfitCalendarCard({required this.tab, required this.onTabChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '収益カレンダー',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              _CalendarTabSwitcher(tab: tab, onChanged: onTabChanged),
            ],
          ),
          const SizedBox(height: 8),
          if (tab == 1) _YearCalendarView() else _MonthCalendarView(),
        ],
      ),
    );
  }
}

class _CalendarTabSwitcher extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onChanged;
  const _CalendarTabSwitcher({required this.tab, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CalendarTabButton(
          text: '月別',
          selected: tab == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 6),
        _CalendarTabButton(
          text: '年別',
          selected: tab == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _CalendarTabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _CalendarTabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1976D2) : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// 年别视图
class _YearCalendarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 示例数据
    final months = [
      ['1月', '+45K', '+1.2%', true],
      ['2月', '+32K', '+2.1%', true],
      ['3月', '−18K', '−1.2%', false],
      ['4月', '+67K', '+4.5%', true],
      ['5月', '+28K', '+1.8%', true],
      ['6月', '+51K', '+3.4%', true],
      ['7月', '−22K', '−1.4%', false],
      ['8月', '+39K', '+2.6%', true],
      ['9月', '+44K', '+2.9%', true],
      ['10月', '+35K', '+2.3%', true],
      ['11月', '+23K', '+1.5%', true],
      ['12月', '+0K', '+0%', true],
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: months.map((m) {
        final isProfit = m[3] as bool;
        return Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isProfit ? const Color(0xFFE8F8F0) : const Color(0xFFFDEAEA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                m[0] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                m[1] as String,
                style: TextStyle(
                  color: isProfit
                      ? const Color(0xFF43A047)
                      : const Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                m[2] as String,
                style: TextStyle(
                  color: isProfit
                      ? const Color(0xFF43A047)
                      : const Color(0xFFE53935),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// 月别视图
class _MonthCalendarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 示例数据
    final days = [
      [1, '+15K', '+1.2%', true],
      [2, '−8K', '−0.6%', false],
      [3, '+22K', '+1.7%', true],
      [4, '+5K', '+0.4%', true],
      [5, '−12K', '−0.9%', false],
      [8, '+8K', '+0.6%', true],
      [10, '−5K', '−0.4%', false],
      [15, '+18K', '+1.3%', true],
      [20, '+3K', '+0.2%', true],
      [25, '−10K', '−0.7%', false],
      [29, '+44K', '+2.9%', true],
    ];
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: Center(
                child: Text('日', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('月', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('火', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('水', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('木', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('金', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('土', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days.map((d) {
            final isProfit = d[3] as bool;
            return Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isProfit
                    ? const Color(0xFFE8F8F0)
                    : const Color(0xFFFDEAEA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${d[0]}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    d[1] as String,
                    style: TextStyle(
                      color: isProfit
                          ? const Color(0xFF43A047)
                          : const Color(0xFFE53935),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    d[2] as String,
                    style: TextStyle(
                      color: isProfit
                          ? const Color(0xFF43A047)
                          : const Color(0xFFE53935),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
