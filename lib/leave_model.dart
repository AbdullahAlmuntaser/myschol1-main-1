

class Leave {
  final int? id;
  final int staffId;
  final String leaveType; // e.g., "Annual Leave", "Sick Leave", "Casual Leave"
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final String reason;
  final String status; // e.g., "Pending", "Approved", "Rejected"
  final int? approvedByUserId; // ID of the user who approved the leave
  final String? rejectionReason;

  Leave({
    this.id,
    required this.staffId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.approvedByUserId,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staffId': staffId,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'status': status,
      'approvedByUserId': approvedByUserId,
      'rejectionReason': rejectionReason,
    };
  }

  factory Leave.fromMap(Map<String, dynamic> map) {
    return Leave(
      id: map['id'] as int?,
      staffId: map['staffId'] as int,
      leaveType: map['leaveType'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      reason: map['reason'] as String,
      status: map['status'] as String,
      approvedByUserId: map['approvedByUserId'] as int?,
      rejectionReason: map['rejectionReason'] as String?,
    );
  }

  @override
  String toString() {
    return 'Leave{id: $id, staffId: $staffId, leaveType: $leaveType, startDate: $startDate, endDate: $endDate, reason: $reason, status: $status, approvedByUserId: $approvedByUserId, rejectionReason: $rejectionReason}';
  }

  Leave copyWith({
    int? id,
    int? staffId,
    String? leaveType,
    String? startDate,
    String? endDate,
    String? reason,
    String? status,
    int? approvedByUserId,
    String? rejectionReason,
  }) {
    return Leave(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
