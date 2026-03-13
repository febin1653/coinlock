import 'package:flutter/material.dart';
import '../models/transaction.dart';

class PersonHistoryWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String)? onPersonClick;
  final String? selectedPerson;
  final int? limit;
  final VoidCallback? onViewAll;

  const PersonHistoryWidget({
    super.key,
    required this.transactions,
    this.onPersonClick,
    this.selectedPerson,
    this.limit,
    this.onViewAll,
  });

  // Helper class to hold calculated stats
  _PersonStats _getPersonStats(String person) {
    final normalizedSearchPerson = _normalizeName(person);
    final personTransactions = transactions.where((t) => _normalizeName(t.person) == normalizedSearchPerson).toList();
    
    final income = personTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
        
    final expense = personTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return _PersonStats(
      income: income,
      expense: expense,
      count: personTransactions.length,
      balance: income - expense,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Unique People or filter to selected person
    List<String> people;
    if (selectedPerson != null && selectedPerson!.isNotEmpty) {
      people = [_normalizeName(selectedPerson!)];
    } else {
      people = transactions.map((t) => _normalizeName(t.person)).toSet().toList();
    }

    if (people.isEmpty) return const SizedBox.shrink();

    final bool isMoreAvailable = limit != null && people.length > limit! && selectedPerson == null;
    final displayPeople = limit != null ? people.take(limit!).toList() : people;

    final Color cyanAccent = const Color(0xFF00FFFF);

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, color: cyanAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    selectedPerson != null ? "Selected Person Summary" : "Person Summary",
                    style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 0.5),
                  ),
                ],
              ),
              if (selectedPerson != null)
                TextButton(
                  onPressed: onPersonClick != null ? () => onPersonClick!("") : null,
                  child: Text("Show All", style: TextStyle(color: cyanAccent, fontSize: 13)),
                )
              else if (isMoreAvailable && onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text("View All (${people.length})", style: TextStyle(color: cyanAccent, fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Grid Layout (handles 1 or more items)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 220,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: displayPeople.length,
            itemBuilder: (context, index) {
              final person = displayPeople[index];
              final stats = _getPersonStats(person);

              return _buildPersonCard(person, stats, cyanAccent);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(String person, _PersonStats stats, Color cyan) {
    return InkWell(
      onTap: onPersonClick != null ? () => onPersonClick!(person) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            // Avatar & Name Row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: cyan,
                  child: Text(
                    person.isNotEmpty ? person[0].toUpperCase() : "?",
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(person, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("${stats.count} transactions", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    ],
                  ),
                ),
                if (onPersonClick != null)
                  Text("View →", style: TextStyle(color: cyan, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),

            // Stats rows
            _rowItem(Icons.arrow_upward, "Income", "₹${stats.income.toStringAsFixed(2)}", cyan),
            const SizedBox(height: 12),
            _rowItem(Icons.arrow_downward, "Expense", "₹${stats.expense.toStringAsFixed(2)}", Colors.white70),
            
            const Spacer(),
            const Divider(color: Colors.white10),
            
            // Balance Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Balance", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                Text("₹${stats.balance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowItem(IconData icon, String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          ],
        ),
        Text(val, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
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

class _PersonStats {
  final double income;
  final double expense;
  final int count;
  final double balance;
  _PersonStats({required this.income, required this.expense, required this.count, required this.balance});
}