// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/assets/custom/custom_asset_detail_page.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:provider/provider.dart';
import 'package:money_nest_app/services/data_sync_service.dart';

class CustomAssetListPage extends StatefulWidget {
  final AppDatabase db;
  final CustomAssetCategory category;

  const CustomAssetListPage({
    super.key,
    required this.db,
    required this.category,
  });

  @override
  State<CustomAssetListPage> createState() => _CustomAssetListPageState();
}

class _CustomAssetListPageState extends State<CustomAssetListPage> {
  Stream<List<CustomAsset>> _getAssetsStream() {
    final userId = GlobalStore().userId ?? '';
    return (widget.db.select(widget.db.customAssets)
          ..where((t) => t.userId.equals(userId) & t.categoryId.equals(widget.category.id)))
        .watch();
  }

  Future<void> _addAsset(String name, String description, String currency) async {
    await Provider.of<DataSyncService>(context, listen: false).addCustomAsset(
      widget.category.id,
      name,
      description,
      currency,
    );
  }

  Future<void> _updateAsset(CustomAsset asset, String name, String description, String currency) async {
    await Provider.of<DataSyncService>(context, listen: false).updateCustomAsset(
      asset.id,
      widget.category.id,
      name,
      description,
      currency,
    );
  }

  Future<void> _deleteAsset(int id) async {
    await Provider.of<DataSyncService>(context, listen: false).deleteCustomAsset(id);
  }

  void _showAssetDialog(BuildContext context, {CustomAsset? asset}) {
    final nameController = TextEditingController(text: asset?.name ?? '');
    final descriptionController = TextEditingController(text: asset?.description ?? '');
    String currency = asset?.currency ?? 'JPY'; // Default currency

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(asset == null ? 'Add Asset to ${widget.category.name}' : 'Edit Asset', style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white70)),
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.white70)),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Currency: ', style: TextStyle(color: Colors.white)),
                      DropdownButton<String>(
                        value: currency,
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        items: <String>['JPY', 'USD', 'EUR', 'GBP', 'CNY'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                             currency = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                if (asset != null)
                  TextButton(
                    onPressed: () {
                      // Confirm delete
                      showDialog(
                        context: context, 
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Asset?'),
                          content: const Text('This will delete the asset and its history.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            TextButton(
                                onPressed: () {
                                  _deleteAsset(asset.id);
                                  Navigator.pop(ctx); // Close confirm
                                  Navigator.pop(context); // Close edit dialog
                                }, 
                                child: const Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        )
                      );
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      if (asset == null) {
                        _addAsset(nameController.text, descriptionController.text, currency);
                      } else {
                        _updateAsset(asset, nameController.text, descriptionController.text, currency);
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
        title: Text(widget.category.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<CustomAsset>>(
        stream: _getAssetsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final assets = snapshot.data!;

          if (assets.isEmpty) {
             return const Center(child: Text('No assets in this category', style: TextStyle(color: Colors.white70)));
          }

          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(asset.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(asset.description ?? '', style: const TextStyle(color: Colors.white70)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomAssetDetailPage(
                          db: widget.db,
                          asset: asset,
                        ),
                      ),
                    );
                  },
                  onLongPress: () => _showAssetDialog(context, asset: asset),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
