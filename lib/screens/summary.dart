import 'package:flutter/material.dart';
import '../models/transaction.dart';

class SummaryWidget extends StatelessWidget {
  final List<Transaction> transactions;

  const SummaryWidget({super.key, required this.transactions});

  // Calculation logic using fold (Dart's version of reduce)
  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double _getCategoryTotal(Category category) {
    return transactions
        .where((t) => t.category == category && t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    final double balance = totalIncome - totalExpense;
    const Color cyanAccent = Color(0xFF00FFFF);

    return Column(
      children: [
        // 1. Main Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cyanAccent.withOpacity(0.3)),
          ),
          child: Stack(
            children: [
              // Subtle Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cyanAccent.withOpacity(0.1), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("CURRENT BALANCE",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 1.5,
                              fontSize: 14)),
                      Icon(Icons.account_balance_wallet,
                          size: 40, color: cyanAccent.withOpacity(0.4)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text("₹${balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w200, // Light for premium look
                          letterSpacing: -1)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Income & Expense Row
        Row(
          children: [
            Expanded(child: _buildSmallStatCard("Total Income", totalIncome, Icons.trending_up, cyanAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallStatCard("Total Expense", totalExpense, Icons.trending_down, cyanAccent)),
          ],
        ),
        const SizedBox(height: 16),

        // 3. Category Breakdown Grid
        Row(
          children: [
            Expanded(child: _buildCategoryCard("Utility", _getCategoryTotal(Category.utility))),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryCard("Personal", _getCategoryTotal(Category.personal))),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryCard("Investment", _getCategoryTotal(Category.investment))),
          ],
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildSmallStatCard(String label, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label.toUpperCase(),
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, letterSpacing: 1)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text("₹${amount.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String label, double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text("₹${amount.toStringAsFixed(0)}", // Rounded for small grid items
              style: const TextStyle(color: Color(0xFF00FFFF), fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}