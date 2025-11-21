class Project {
  const Project({
    required this.id,
    required this.name,
    this.location,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.description,
    this.budget,
  });

  final String id;
  final String name;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final String? description;
  final double? budget;

  static Project fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      final text = value.toString();
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    double? parseBudget(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    return Project(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      location: json['location']?.toString(),
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      createdAt: parseDate(json['created_at']),
      description: json['description']?.toString(),
      budget: parseBudget(json['budget']),
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
      'description': description,
      'budget': budget,
    };
  }
}
