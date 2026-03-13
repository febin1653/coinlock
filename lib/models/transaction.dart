enum TransactionType { income, expense }

enum Category { utility, personal, investment }

class Transaction {
  final String id;
  final TransactionType type;
  final Category category;
  final double amount;
  final String description;
  final String person;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.person,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'category': category.index,
      'amount': amount,
      'description': description,
      'person': person,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: TransactionType.values[json['type']],
      category: Category.values[json['category']],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      person: json['person'],
      date: DateTime.parse(json['date']),
    );
  }
}
