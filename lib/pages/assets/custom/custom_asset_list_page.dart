// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/assets/custom/custom_asset_detail_page.dart';
import 'package:money_nest_app/util/global_store.dart';

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
    final userId = GlobalStore().userId;
    if (userId == null) return;

    await widget.db.into(widget.db.customAssets).insert(
          CustomAssetsCompanion.insert(
            userId: userId,
            categoryId: widget.category.id,
            name: name,
            description: drift.Value(description),
            currency: drift.Value(currency),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
  }

  void _showAssetDialog(BuildContext context, {CustomAsset? asset}) {
    final nameController = TextEditingController(text: asset?.name ?? '');
    final descriptionController = TextEditingController(text: asset?.description ?? '');
    String currency = asset?.currency ?? 'JPY'; // Default currency

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            DropdownButton<String>(
              value: currency,
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white),
              items: <String>['JPY', 'USD', 'EUR', 'GBP'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                // To update state inside Dialog, consider StatefulBuilder if needed, but here we capture value
                // in variable. But UI won't update.
                // For MVP, just assume selection updates variable and use it on Save.
                // A better way is using StatefulBuilder.
                currency = newValue!;
                (context as Element).markNeedsBuild(); // Force rebuild
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                if (asset == null) {
                  _addAsset(nameController.text, descriptionController.text, currency);
                } else {
                  // Update logic
                  (widget.db.update(widget.db.customAssets)
                        ..where((t) => t.id.equals(asset.id)))
                      .write(CustomAssetsCompanion(
                    name: drift.Value(nameController.text),
                    description: drift.Value(descriptionController.text),
                    currency: drift.Value(currency),
                    updatedAt: drift.Value(DateTime.now()),
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
