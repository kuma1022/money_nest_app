// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/assets/custom/custom_asset_list_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CustomAssetsPage extends StatefulWidget {
  final AppDatabase db;

  const CustomAssetsPage({super.key, required this.db});

  @override
  State<CustomAssetsPage> createState() => _CustomAssetsPageState();
}

class _CustomAssetsPageState extends State<CustomAssetsPage> {
  Stream<List<CustomAssetCategory>> _getCategoryStream() {
    final userId = GlobalStore().userId ?? '';
    return (widget.db.select(widget.db.customAssetCategories)
          ..where((t) => t.userId.equals(userId)))
        .watch();
  }

  Future<void> _addCategory(String name, Color color) async {
    final userId = GlobalStore().userId;
    if (userId == null) return;

    await widget.db.into(widget.db.customAssetCategories).insert(
          CustomAssetCategoriesCompanion.insert(
            userId: userId,
            name: name,
            colorHex: drift.Value(color.value.toRadixString(16).padLeft(8, '0')),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
  }

  Future<void> _updateCategory(CustomAssetCategory category, String name, Color color) async {
    await (widget.db.update(widget.db.customAssetCategories)
          ..where((t) => t.id.equals(category.id)))
        .write(CustomAssetCategoriesCompanion(
      name: drift.Value(name),
      colorHex: drift.Value(color.value.toRadixString(16).padLeft(8, '0')),
      updatedAt: drift.Value(DateTime.now()),
    ));
  }

  Future<void> _deleteCategory(int id) async {
    await (widget.db.delete(widget.db.customAssetCategories)
          ..where((t) => t.id.equals(id)))
        .go();
  }
  
  void _showCategoryDialog(BuildContext context, {CustomAssetCategory? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    Color pickedColor = category?.colorHex != null
        ? Color(int.parse(category!.colorHex!, radix: 16))
        : Colors.blue;
    
    // We need a variable to track color in the dialog state
    // but without StatefulBuilder in the dialog, it won't rebuild the color circle.
    // I'll wrap the content in StatefulBuilder.

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                category == null ? 'New Category' : 'Edit Category',
                style: const TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Color:', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Pick a color'),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: pickedColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      pickedColor = color;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: pickedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      if (category == null) {
                        _addCategory(nameController.text, pickedColor);
                      } else {
                        _updateCategory(category, nameController.text, pickedColor);
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
        title: const Text('Other Assets', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<CustomAssetCategory>>(
        stream: _getCategoryStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
             // If table doesn't exist yet, it will error.
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;
          
          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet', style: TextStyle(color: Colors.white70)));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              Color catColor = Colors.blue;
              if (category.colorHex != null) {
                try {
                  catColor = Color(int.parse(category.colorHex!, radix: 16));
                } catch (_) {}
              }

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: catColor,
                    child: Text(
                      category.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(category.name, style: const TextStyle(color: Colors.white)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _showCategoryDialog(context, category: category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                           showDialog(
                             context: context,
                             builder: (context) => AlertDialog(
                               backgroundColor: Colors.grey[900],
                               title: const Text('Delete?', style: TextStyle(color: Colors.white)),
                               content: const Text('This will delete all assets in this category.', style: TextStyle(color: Colors.white70)),
                               actions: [
                                 TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                 TextButton(
                                   onPressed: () {
                                     _deleteCategory(category.id);
                                     Navigator.pop(context);
                                   }, 
                                   child: const Text('Delete', style: TextStyle(color: Colors.red))
                                 ),
                               ],
                             )
                           );
                        },
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomAssetListPage(
                          db: widget.db,
                          category: category,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
