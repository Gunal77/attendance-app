class Employee {
  const Employee({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role,
    this.projectId,
    this.projectName,
    this.projectLocation,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? role;
  final String? projectId;
  final String? projectName;
  final String? projectLocation;
  final DateTime? createdAt;

  static Employee fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      final text = value.toString();
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    final project = json['projects'] as Map<String, dynamic>?;

    return Employee(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      projectId: json['project_id']?.toString(),
      projectName: project?['name']?.toString(),
      projectLocation: project?['location']?.toString(),
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'project_id': projectId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

