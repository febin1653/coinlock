import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'personhistory.dart';
import 'filtercontrols.dart';
import 'transaction_list.dart';

class HistoryView extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final dynamic filterType; // 'all' or TransactionType
  final dynamic filterCategory; // 'all' or Category
  final String filterPerson;
  final List<String> uniquePeople;
  
  // Callbacks matching your React Props
  final Function(dynamic) onTypeChange;
  final Function(dynamic) onCategoryChange;
  final Function(String) onPersonChange;
  final Function(String) onDeleteTransaction;
  final Function(Transaction) onUpdateTransaction;
  final VoidCallback onBack;
  final Function(String) onPersonClick;

  const HistoryView({
    super.key,
    required this.transactions,
    required this.filteredTransactions,
    required this.filterType,
    required this.filterCategory,
    required this.filterPerson,
    required this.uniquePeople,
    required this.onTypeChange,
    required this.onCategoryChange,
    required this.onPersonChange,
    required this.onDeleteTransaction,
    required this.onUpdateTransaction,
    required this.onBack,
    required this.onPersonClick,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button (ArrowLeft equivalent)
          InkWell(
            onTap: onBack,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back, color: Color(0xFF00FFFF), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Back to Dashboard",
                    style: TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // PersonHistory Component
          PersonHistoryWidget(transactions: transactions, onPersonClick: onPersonClick),
          const SizedBox(height: 24),

          // FilterControls Component
          FilterControlsWidget(
            selectedType: filterType,
            selectedCategory: filterCategory,
            selectedPerson: filterPerson,
            onTypeChange: onTypeChange,
            onCategoryChange: onCategoryChange,
            onPersonChange: onPersonChange,
            people: uniquePeople,
          ), 
          const SizedBox(height: 32),

          // Header Section
          Text(
            "All Transaction History",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Showing ${filteredTransactions.length} of ${transactions.length} transactions",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // TransactionList Component
          TransactionList(
            transactions: filteredTransactions,
            onDeleteTransaction: onDeleteTransaction,
            onUpdateTransaction: onUpdateTransaction,
          ),
        ],
      ),
    );
  }
}
