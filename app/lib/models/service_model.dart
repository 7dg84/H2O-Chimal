class ServiceRequirement {
  final String documentTypeId;
  final String documentTypeName;
  final bool isRequired;
  final String notes;

  ServiceRequirement({
    required this.documentTypeId,
    required this.documentTypeName,
    required this.isRequired,
    required this.notes,
  });

  factory ServiceRequirement.fromJson(Map<String, dynamic> json) {
    return ServiceRequirement(
      documentTypeId: json['document_type_id'],
      documentTypeName: json['document_type_name'],
      isRequired: json['required'] ?? false,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_type_id': documentTypeId,
      'document_type_name': documentTypeName,
      'required': isRequired,
      'notes': notes,
    };
  }
}

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String responseTime;
  final List<ServiceRequirement> requirements;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.responseTime,
    required this.requirements,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    var requirementsList = json['requirements'] as List? ?? [];
    return ServiceModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      responseTime: json['response_time'] ?? '',
      requirements: requirementsList
          .map((req) => ServiceRequirement.fromJson(req))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'response_time': responseTime,
      'requirements': requirements.map((req) => req.toJson()).toList(),
    };
  }
}
