// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:money_nest_app/db/app_database.dart';
import 'package:intl/intl.dart';

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

  Future<void> _addHistory(DateTime date, double value, String note) async {
    await widget.db.into(widget.db.customAssetHistory).insert(
          CustomAssetHistoryCompanion.insert(
            assetId: widget.asset.id,
            recordDate: date,
            value: drift.Value(value),
            note: drift.Value(note),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
  }
  
  void _showHistoryDialog(BuildContext context, {CustomAssetHistoryData? history}) {
    final valueController = TextEditingController(text: history?.value.toString() ?? '');
    final noteController = TextEditingController(text: history?.note ?? '');
    DateTime selectedDate = history?.recordDate ?? DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(history == null ? 'Add History Record' : 'Edit Record', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: 'Value', labelStyle: TextStyle(color: Colors.white70)),
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
                       // Update logic using stateful builder or just var
                       selectedDate = picked;
                       (context as Element).markNeedsBuild();
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
               if (val != null) {
                 if (history == null) {
                   _addHistory(selectedDate, val, noteController.text);
                 } else {
                   (widget.db.update(widget.db.customAssetHistory)
                        ..where((t) => t.id.equals(history.id)))
                      .write(CustomAssetHistoryCompanion(
                        recordDate: drift.Value(selectedDate),
                        value: drift.Value(val),
                        note: drift.Value(noteController.text),
                      ));
                 }
                 Navigator.pop(context);
               }
            },
            child: const Text('Save'),
          ),
        ],
      ),
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
                  title: Text(
                    '${widget.asset.currency} ${NumberFormat('#,##0.00').format(rec.value)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${DateFormat('yyyy-MM-dd').format(rec.recordDate)}\n${rec.note ?? ''}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () => _showHistoryDialog(context, history: rec),
                  ),
                  onLongPress: () {
                     // Delete?
                     showDialog(
                       context: context,
                       builder: (context) => AlertDialog(
                         title: const Text('Delete record?'),
                         actions: [
                           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                           TextButton(
                             onPressed: () {
                               (widget.db.delete(widget.db.customAssetHistory)..where((t) => t.id.equals(rec.id))).go();
                               Navigator.pop(context);
                             }, 
                             child: const Text('Delete', style: TextStyle(color: Colors.red))
                           ),
                         ],
                       )
                     );
                  },
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
