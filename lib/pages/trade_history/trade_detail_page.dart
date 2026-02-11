import 'package:flutter/material.dart';
import 'package:money_nest_app/components/hud_dialog.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/categories.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_edit_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_history_tab_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/services/data_sync_service.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:provider/provider.dart';

class TradeDetailPage extends StatefulWidget {
  final AppDatabase db;
  final TradeRecordDisplay record;

  const TradeDetailPage({required this.db, required this.record, super.key});

  @override
  TradeDetailPageState createState() => TradeDetailPageState();
}

class TradeDetailPageState extends State<TradeDetailPage> {
  late TradeRecordDisplay recordData;
  bool updated = false;

  // 初始化处理
  @override
  void initState() {
    super.initState();
    setState(() {
      recordData = widget.record;
    });
  }

  String get category => Categories.values
      .firstWhere(
        (sub) => sub.code == recordData.assetType,
        orElse: () => Categories.otherAsset,
      )
      .name;

  Color get typeColor {
    switch (recordData.action) {
      case ActionType.buy:
        return AppColors.appUpGreen;
      case ActionType.sell:
        return AppColors.appDownRed;
      case ActionType.dividend:
        return AppColors.appBlue;
    }
  }

  IconData get typeIcon {
    switch (recordData.action) {
      case ActionType.buy:
        return Icons.add_outlined;
      case ActionType.sell:
        return Icons.remove_outlined;
      case ActionType.dividend:
        return Icons.card_giftcard;
    }
  }

  String get typeLabel {
    switch (recordData.action) {
      case ActionType.buy:
        return '買い';
      case ActionType.sell:
        return '売り';
      case ActionType.dividend:
        return '配当';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // 返回
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, updated),
                  ),
                  const Text(
                    '戻る',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '取引詳細',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Chip(
                  label: Text(
                    typeLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFF2C2C2E),
                  labelStyle: TextStyle(color: typeColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(24),
                  // border: Border.all(color: const Color(0xFFE5E6EA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(typeIcon, color: typeColor, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          '${recordData.stockInfo.ticker} - ${recordData.stockInfo.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '取引日',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                recordData.tradeDate,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'カテゴリ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '数量',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${recordData.quantity}株',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '単価',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppUtils().formatMoney(
                                  recordData.price,
                                  recordData.currency,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '取引金額',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2)
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '手数料',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppUtils().formatMoney(
                                  recordData.feeAmount,
                                  recordData.feeCurrency,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                
                              Text(
                                AppUtils().formatMoney(
                                  recordData.feeAmount,
                                  recordData.feeCurrency,
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),, color: Color(0xFF2C2C2E)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '合計金額',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '合計金額',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          recordData.amount,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(2C2C2E),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3C3C3E)
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: AppColors.appGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        // 跳转到编辑页面
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TradeAddEditPage(
                              record: recordData,
                              db: widget.db,
                              mode: 'edit',
                              type: 'asset',
                            ),
                          ),
                        );
                        if (result != null && result is TradeRecordDisplay) {
                          if (!context.mounted) return;
                          await AppUtils().showSuccessHUD(
                            context,
                            message: '取引記録が更新されました',
                          );
                          updated = true;
                          setState(() {
                            recordData = result;
                          });
                        }
                      },
                      child: const Text(
                        '編集',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final dataSync = Provider.of<DataSyncService>(
                          context,
                          listen: false,
                        );
                        // 弹窗确认
                        /*final result = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('削除確認'),
                            content: const Text('この取引記録を削除しますか？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final dataSync = Provider.of<DataSyncService>(
                                    context,
                                    listen: false,
                                  );
                                  final success = await dataSync.deleteAsset(
                                    userId: GlobalStore().userId!,
                                    accountId: GlobalStore().accountId!,
                                    tradeId: widget.record.id,
                                  );
                                  if (!ctx.mounted) return;
                                  Navigator.pop(ctx, success);
                                },
                                child: const Text(
                                  '削除',
                                  style: TextStyle(color: Color(0xFFE53935)),
                                ),
                              ),
                            ],
                          ),
                        );*/
                        final result = await HudDialog.show<bool>(
                          context: context,
                          title: '削除確認',
                          content: const Text(
                            'この取引記録を削除しますか？',
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            HudDialogButton<bool>(
                              text: 'キャンセル',
                              onPressed: () async {
                                return null; // 点击返回 null
                              },
                            ),
                            HudDialogButton<bool>(
                              text: '削除',
                              color: const Color(
                                0xFFE53935,
                              ), // 如果你想要红色才传，如果不要红色就不传
                              onPressed: () async {
                                final dataSync = Provider.of<DataSyncService>(
                                  context,
                                  listen: false,
                                );
                                final success = await dataSync.deleteAsset(
                                  userId: GlobalStore().userId!,
                                  accountId: GlobalStore().accountId!,
                                  tradeId: widget.record.id,
                                );
                                return success; // 返回 success (true/false)
                              },
                            ),
                          ],
                        );

                        if (result == true) {
                          // 刷新全局数据
                          await AppUtils().calculateAndSavePortfolio(
                            widget.db,
                            GlobalStore().userId!,
                            GlobalStore().accountId!,
                          );
                          // 刷新总资产和总成本
                          await AppUtils().refreshTotalAssetsAndCosts(
                            dataSync,
                            forcedUpdate: true,
                          );
                          if (!context.mounted) return;
                          await AppUtils().showSuccessHUD(
                            context,
                            message: '取引記録が削除されました',
                          );
                        } else if (result == false) {
                          if (!context.mounted) return;
                          await AppUtils().showSuccessHUD(
                            context,
                            message: '取引記録の削除に失敗しました',
                          );
                        }
                        if (result != null) {
                          if (!context.mounted) return;
                          Navigator.pop(context, result);
                        }
                      },
                      child: const Text(
                        '削除',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
