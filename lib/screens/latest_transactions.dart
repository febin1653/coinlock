import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'add_transaction_form.dart';

class LatestTransactions extends StatelessWidget {
  final List<Transaction> transactions;
  final int limit;
  final VoidCallback onViewAll;
  final Function(String)? onPersonClick;
  final Function(String)? onDeleteTransaction;
  final Function(Transaction)? onUpdateTransaction;

  const LatestTransactions({
    super.key,
    required this.transactions,
    this.limit = 5,
    required this.onViewAll,
    this.onPersonClick,
    this.onDeleteTransaction,
    this.onUpdateTransaction,
  });

  // Helper for Badge Colors (Matching your React logic)
  Map<String, Color> _getCategoryColors(Category category) {
    return {
      'bg': const Color(0xFF00FFFF).withOpacity(0.1),
      'text': const Color(0xFF00FFFF),
      'border': const Color(0xFF00FFFF).withOpacity(0.3),
    };
  }

  @override
  Widget build(BuildContext context) {
    final displayList = transactions.take(limit).toList();

    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          "No transactions yet. Add your first transaction above!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.access_time_filled, color: Color(0xFF00FFFF), size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Latest Transactions",
                      style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 0.5),
                    ),
                  ],
                ),
                if (transactions.length > limit)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      "View All (${transactions.length})",
                      style: const TextStyle(color: Color(0xFF00FFFF), fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),

          // Transaction List
          ListView.separated(
            shrinkWrap: true, // Important for use inside a Column
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
            itemBuilder: (context, index) {
              final tx = displayList[index];
              final colors = _getCategoryColors(tx.category);
              final bool isIncome = tx.type == TransactionType.income;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isIncome ? const Color(0xFF00FFFF).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isIncome ? const Color(0xFF00FFFF) : Colors.white.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tx.description,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Category Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors['bg'],
                                  border: Border.all(color: colors['border']!),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tx.category.name.toUpperCase(),
                                  style: TextStyle(color: colors['text'], fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: onPersonClick != null ? () => onPersonClick!(tx.person) : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    _normalizeName(tx.person),
                                    style: TextStyle(
                                      color: const Color(0xFF00FFFF).withOpacity(0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text("•", style: TextStyle(color: Colors.white.withOpacity(0.3))),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM d, hh:mm a').format(tx.date),
                                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    Text(
                      "${isIncome ? '+' : '-'}\₹${tx.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: isIncome ? const Color(0xFF00FFFF) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildActionMenu(context, tx),
                  ],
                ),
              );
            },
          ),
          
          // View More Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: onViewAll,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFF00FFFF).withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "VIEW ALL TRANSACTIONS",
                  style: TextStyle(color: Color(0xFF00FFFF), fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeName(String name) {
    name = name.trim();
    if (name.isEmpty) return name;
    return name.split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Widget _buildActionMenu(BuildContext context, Transaction tx) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white60, size: 20),
      color: const Color(0xFF1A1A1A),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (String result) {
        if (result == 'edit') {
          _showEditDialog(context, tx);
        } else if (result == 'delete') {
          if (onDeleteTransaction != null) onDeleteTransaction!(tx.id);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, color: Color(0xFF00FFFF), size: 18),
              SizedBox(width: 12),
              Text('Edit', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddTransactionForm(
          onAddTransaction: (_, __, ___, ____, _____, ______) {}, // Not used
          onUpdateTransaction: (updatedTx) {
            if (onUpdateTransaction != null) onUpdateTransaction!(updatedTx);
            Navigator.pop(context);
          },
          initialTransaction: tx,
        ),
      ),
    );
  }
}