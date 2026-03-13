import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'add_transaction_form.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String) onDeleteTransaction;
  final Function(Transaction) onUpdateTransaction;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onDeleteTransaction,
    required this.onUpdateTransaction,
  });

  // Helper for Badge Colors
  Map<String, dynamic> _getCategoryStyle(Category category) {
    return {
      'bg': const Color(0xFF00FFFF).withOpacity(0.1),
      'text': const Color(0xFF00FFFF),
      'border': const Color(0xFF00FFFF).withOpacity(0.3),
    };
  }

  @override
  Widget build(BuildContext context) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Horizontal scroll for the table
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
            dataRowMinHeight: 60,
            dataRowMaxHeight: 70,
            columnSpacing: 24,
            columns: _buildColumns(),
            rows: transactions.map((tx) => _buildRow(context, tx)).toList(),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    const textStyle = TextStyle(
      color: Colors.white60,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    );
    return [
      const DataColumn(label: Text("DATE", style: textStyle)),
      const DataColumn(label: Text("TYPE", style: textStyle)),
      const DataColumn(label: Text("CATEGORY", style: textStyle)),
      const DataColumn(label: Text("DESCRIPTION", style: textStyle)),
      const DataColumn(label: Text("PERSON", style: textStyle)),
      const DataColumn(label: Text("AMOUNT", style: textStyle), numeric: true),
      const DataColumn(label: Text("ACTION", style: textStyle), numeric: true),
    ];
  }

  DataRow _buildRow(BuildContext context, Transaction tx) {
    final style = _getCategoryStyle(tx.category);
    final bool isIncome = tx.type == TransactionType.income;

    return DataRow(
      cells: [
        DataCell(Text(DateFormat('MMM d, hh:mm a').format(tx.date),
            style: const TextStyle(color: Colors.white70, fontSize: 13))),
        DataCell(Row(
          children: [
            Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: isIncome ? const Color(0xFF00FFFF) : Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(tx.type.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        )),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: style['bg'],
            border: Border.all(color: style['border']),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tx.category.name.toUpperCase(),
            style: TextStyle(color: style['text'], fontSize: 10, fontWeight: FontWeight.bold),
          ),
        )),
        DataCell(Text(tx.description, style: const TextStyle(color: Colors.white, fontSize: 13))),
        DataCell(Text(_normalizeName(tx.person), style: const TextStyle(color: Colors.white70, fontSize: 13))),
        DataCell(Text(
          "${isIncome ? '+' : '-'}\₹${tx.amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: isIncome ? const Color(0xFF00FFFF) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        )),
        DataCell(_buildActionMenu(context, tx)),
      ],
    );
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
          onDeleteTransaction(tx.id);
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
            onUpdateTransaction(updatedTx);
            Navigator.pop(context);
          },
          initialTransaction: tx,
        ),
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
}