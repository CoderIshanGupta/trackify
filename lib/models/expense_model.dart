/// Model for a single expense entry.
class ExpenseModel {
  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime timestamp;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.timestamp,
  });

  /// Factory constructor to convert from map
  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExpenseModel(
      id: docId,
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'General',
      note: map['note'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  /// Converts model to standard map representation
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}