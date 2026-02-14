import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';

class CustomAssetsPage extends StatefulWidget {
  final AppDatabase db;

  const CustomAssetsPage({super.key, required this.db});

  @override
  State<CustomAssetsPage> createState() => _CustomAssetsPageState();
}

class _CustomAssetsPageState extends State<CustomAssetsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('その他資産', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'その他資産（カスタム資産）\n機能はまだ実装されていません',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add custom asset category
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
