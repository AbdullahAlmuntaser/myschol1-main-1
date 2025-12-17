

class BorrowRecord {
  final int? id;
  final int bookId;
  final int studentId;
  final String borrowDate; // YYYY-MM-DD
  final String? returnDate; // YYYY-MM-DD
  final String status; // e.g., "Borrowed", "Returned", "Overdue"

  BorrowRecord({
    this.id,
    required this.bookId,
    required this.studentId,
    required this.borrowDate,
    this.returnDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'studentId': studentId,
      'borrowDate': borrowDate,
      'returnDate': returnDate,
      'status': status,
    };
  }

  factory BorrowRecord.fromMap(Map<String, dynamic> map) {
    return BorrowRecord(
      id: map['id'] as int?,
      bookId: map['bookId'] as int,
      studentId: map['studentId'] as int,
      borrowDate: map['borrowDate'] as String,
      returnDate: map['returnDate'] as String?,
      status: map['status'] as String,
    );
  }

  @override
  String toString() {
    return 'BorrowRecord{id: $id, bookId: $bookId, studentId: $studentId, borrowDate: $borrowDate, returnDate: $returnDate, status: $status}';
  }

  BorrowRecord copyWith({
    int? id,
    int? bookId,
    int? studentId,
    String? borrowDate,
    String? returnDate,
    String? status,
  }) {
    return BorrowRecord(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      studentId: studentId ?? this.studentId,
      borrowDate: borrowDate ?? this.borrowDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
    );
  }
}
