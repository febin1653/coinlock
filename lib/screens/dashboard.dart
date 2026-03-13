import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'summary.dart';
import 'add_transaction_form.dart';
import 'latest_transactions.dart';
import 'personhistory.dart';

class Dashboard extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(TransactionType, Category, double, String, String, DateTime) onAddTransaction;
  final VoidCallback onViewAllHistory;
  final Function(String) onPersonClick;
  final Function(String)? onDeleteTransaction;
  final Function(Transaction)? onUpdateTransaction;
  final String? selectedPerson;

  const Dashboard({
    super.key,
    required this.transactions,
    required this.onAddTransaction,
    required this.onViewAllHistory,
    required this.onPersonClick,
    this.onDeleteTransaction,
    this.onUpdateTransaction,
    this.selectedPerson,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Summary Section (Equivalent to <Summary />)
          SummaryWidget(transactions: transactions),
          
          const SizedBox(height: 24),

          // 2. Person Summary Section
          PersonHistoryWidget(
            transactions: transactions,
            onPersonClick: onPersonClick,
            selectedPerson: selectedPerson,
            limit: 2,
            onViewAll: onViewAllHistory,
          ),

          const SizedBox(height: 24),

          // 3. Form Section (Equivalent to <AddTransactionForm />)
          AddTransactionForm(onAddTransaction: onAddTransaction),
          
          const SizedBox(height: 24),

          // 4. List Section (Equivalent to <LatestTransactions />)
          LatestTransactions(
            transactions: transactions,
            limit: 4,
            onViewAll: onViewAllHistory,
            onPersonClick: onPersonClick,
            onDeleteTransaction: onDeleteTransaction,
            onUpdateTransaction: onUpdateTransaction,
          ),
        ],
      ),
    );
  }
}