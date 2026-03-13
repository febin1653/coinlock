import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'transaction_list.dart';

class PersonDetailView extends StatelessWidget {
  final String person;
  final List<Transaction> transactions;
  final VoidCallback onBack;
  final Function(String) onDeleteTransaction;
  final Function(Transaction) onUpdateTransaction;

  const PersonDetailView({
    super.key,
    required this.person,
    required this.transactions,
    required this.onBack,
    required this.onDeleteTransaction,
    required this.onUpdateTransaction,
  });

  // Calculation Logic (Equivalent to your React stats object)
  List<Transaction> get _personTransactions => 
      transactions.where((t) => t.person == person).toList();

  double get _income => _personTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get _expense => _personTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  @override
  Widget build(BuildContext context) {
    final double balance = _income - _expense;
    final Color cyanAccent = const Color(0xFF00FFFF);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Back Button
          GestureDetector(
            onTap: onBack,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: cyanAccent, size: 20),
                  const SizedBox(width: 8),
                  Text("Back to History", 
                    style: TextStyle(color: cyanAccent, fontSize: 16)),
                ],
              ),
            ),
          ),

          // 2. Person Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: cyanAccent,
                      child: Text(
                        person.isNotEmpty ? person[0].toUpperCase() : "?",
                        style: const TextStyle(fontSize: 32, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(person, 
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        Text("${_personTransactions.length} total transactions",
                          style: TextStyle(color: Colors.white.withOpacity(0.6))),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                
                // Stats Grid (Using Wrap for responsiveness)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildStatCard("Income", "\$${_income.toStringAsFixed(2)}", Icons.arrow_upward, cyanAccent),
                    _buildStatCard("Expense", "\$${_expense.toStringAsFixed(2)}", Icons.arrow_downward, Colors.white70),
                    _buildStatCard("Balance", "\$${balance.toStringAsFixed(2)}", Icons.person_outline, Colors.white),
                    _buildStatCard("Count", "${_personTransactions.length}", Icons.list_alt, cyanAccent),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 3. Section Title
          Text("Transaction History for $person",
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("All transactions by this person",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
          
          const SizedBox(height: 24),

          // 4. List (Reusing your TransactionList logic)
          TransactionList(
            transactions: _personTransactions, 
            onDeleteTransaction: onDeleteTransaction,
            onUpdateTransaction: onUpdateTransaction,
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 150, // Fixed width for the grid look
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label.toUpperCase(), 
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, 
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}