class Project {
  const Project({
    required this.id,
    required this.name,
    this.location,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  static Project fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      final text = value.toString();
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    return Project(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      location: json['location']?.toString(),
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

