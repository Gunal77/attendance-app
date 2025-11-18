class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.userEmail,
    this.userName,
    this.checkIn,
    this.checkOut,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String userId;
  final String userEmail;
  final String? userName;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  String get displayName => (userName?.trim().isNotEmpty ?? false) ? userName!.trim() : userEmail;

  String get formattedDate => checkIn != null ? DateTime(checkIn!.year, checkIn!.month, checkIn!.day).toIso8601String() : '';

  static AttendanceRecord fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      final text = value.toString();
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return AttendanceRecord(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      userEmail: (json['user_email'] ?? json['email'] ?? json['userEmail'] ?? '').toString(),
      userName: json['user_name']?.toString() ?? json['name']?.toString(),
      checkIn: parseDate(json['check_in_time'] ?? json['checkInTime']),
      checkOut: parseDate(json['check_out_time'] ?? json['checkOutTime']),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
    );
  }
}


