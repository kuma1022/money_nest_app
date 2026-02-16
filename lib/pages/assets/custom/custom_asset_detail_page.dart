// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:money_nest_app/db/app_database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money_nest_app/services/data_sync_service.dart';

class CustomAssetDetailPage extends StatefulWidget {
  final AppDatabase db;
  final CustomAsset asset;

  const CustomAssetDetailPage({
    super.key,
    required this.db,
    required this.asset,
  });

  @override
  State<CustomAssetDetailPage> createState() => _CustomAssetDetailPageState();
}

class _CustomAssetDetailPageState extends State<CustomAssetDetailPage> {
  Stream<List<CustomAssetHistoryData>> _getHistoryStream() {
    return (widget.db.select(widget.db.customAssetHistory)
          ..where((t) => t.assetId.equals(widget.asset.id))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.recordDate, mode: drift.OrderingMode.desc)]))
        .watch();
  }

  Future<void> _addHistory(DateTime date, double value, double cost, String note) async {
      await Provider.of<DataSyncService>(context, listen: false).addCustomAssetHistory(
        widget.asset.id,
        date,
        value,
        cost,
        note,
      );
  }

  Future<void> _updateHistory(CustomAssetHistoryData history, DateTime date, double value, double cost, String note) async {
      await Provider.of<DataSyncService>(context, listen: false).updateCustomAssetHistory(
        history.id,
        date,
        value,
        cost,
        note,
      );
  }

  Future<void> _deleteHistory(int id) async {
      await Provider.of<DataSyncService>(context, listen: false).deleteCustomAssetHistory(id);
  }
  
  void _showHistoryDialog(BuildContext context, {CustomAssetHistoryData? history}) {
    final valueController = TextEditingController(text: history?.value.toString() ?? '');
    final costController = TextEditingController(text: history?.cost.toString() ?? '0.0');
    final noteController = TextEditingController(text: history?.note ?? '');
    DateTime selectedDate = history?.recordDate ?? DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(history == null ? 'Add History Record' : 'Edit Record', style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: valueController,
                    decoration: const InputDecoration(labelText: 'Value (Current)', labelStyle: TextStyle(color: Colors.white70)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextField(
                    controller: costController,
                    decoration: const InputDecoration(labelText: 'Cost (Original Value)', labelStyle: TextStyle(color: Colors.white70)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Note', labelStyle: TextStyle(color: Colors.white70)),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}", style: const TextStyle(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.blue),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                             setState(() {
                               selectedDate = picked;
                             });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                     final val = double.tryParse(valueController.text);
                     final cost = double.tryParse(costController.text) ?? 0.0;
                     if (val != null) {
                       if (history == null) {
                         _addHistory(selectedDate, val, cost, noteController.text);
                       } else {
                         _updateHistory(history, selectedDate, val, cost, noteController.text);
                       }
                       Navigator.pop(context);
                     }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.asset.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<CustomAssetHistoryData>>(
        stream: _getHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final history = snapshot.data!;
          
          if (history.isEmpty) {
             return const Center(child: Text('No history records', style: TextStyle(color: Colors.white70)));
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final rec = history[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.asset.currency} ${NumberFormat('#,##0.00').format(rec.value)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      if (rec.cost > 0)
                        Text(
                          'Cost: ${widget.asset.currency} ${NumberFormat('#,##0.00').format(rec.cost)}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${DateFormat('yyyy-MM-dd').format(rec.recordDate)}\n${rec.note ?? ''}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _showHistoryDialog(context, history: rec),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                           showDialog(
                             context: context,
                             builder: (context) => AlertDialog(
                               backgroundColor: Colors.grey[900],
                               title: const Text('Delete record?', style: TextStyle(color: Colors.white)),
                               actions: [
                                 TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                 TextButton(
                                   onPressed: () {
                                     _deleteHistory(rec.id);
                                     Navigator.pop(context);
                                   }, 
                                   child: const Text('Delete', style: TextStyle(color: Colors.red))
                                 ),
                               ],
                             )
                           );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHistoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
