import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class ExpenseStorageService {
  static const String _fileName = 'expenses.json';
  static const String _webKey = 'coinlock_transactions';

  // Load all transactions from storage
  Future<List<Transaction>> loadTransactions() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final contents = prefs.getString(_webKey);
        if (contents == null) return [];
        final List<dynamic> jsonList = json.decode(contents);
        return jsonList.map((json) => Transaction.fromJson(json)).toList();
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_fileName');
        
        if (!await file.exists()) {
          return [];
        }
        
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        return jsonList.map((json) => Transaction.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }

  // Save the entire list of transactions to storage
  Future<void> saveTransactions(List<Transaction> transactions) async {
    try {
      final String jsonString = json.encode(transactions.map((t) => t.toJson()).toList());
      
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_webKey, jsonString);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_fileName');
        await file.writeAsString(jsonString);
      }
    } catch (e) {
      print('Error saving transactions: $e');
    }
  }
}
