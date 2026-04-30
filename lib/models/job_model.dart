enum HireRequestStatus { pending, accepted, declined, active, completed }
typedef JobStatus = HireRequestStatus;

class HireRequestModel {
  const HireRequestModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.professionalId,
    required this.professionalName,
    required this.projectTitle,
    required this.projectDescription,
    required this.budget,
    required this.deadline,
    required this.createdAt,
    this.progress = 0.0,
    this.status = HireRequestStatus.pending,
    this.amountReleased = false,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String professionalId;
  final String professionalName;
  final String projectTitle;
  final String projectDescription;
  final double budget;
  final DateTime deadline;
  final DateTime createdAt;
  final double progress;
  final HireRequestStatus status;
  final bool amountReleased;

  HireRequestModel copyWith({
    double? progress,
    HireRequestStatus? status,
    bool? amountReleased,
  }) {
    return HireRequestModel(
      id: id,
      clientId: clientId,
      clientName: clientName,
      professionalId: professionalId,
      professionalName: professionalName,
      projectTitle: projectTitle,
      projectDescription: projectDescription,
      budget: budget,
      deadline: deadline,
      createdAt: createdAt,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      amountReleased: amountReleased ?? this.amountReleased,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'projectTitle': projectTitle,
      'projectDescription': projectDescription,
      'budget': budget,
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'progress': progress,
      'status': status.name,
      'amountReleased': amountReleased,
    };
  }

  factory HireRequestModel.fromJson(Map<String, dynamic> map) {
    return HireRequestModel(
      id: map['id'] as String,
      clientId: map['clientId'] as String,
      clientName: map['clientName'] as String,
      professionalId: map['professionalId'] as String,
      professionalName: map['professionalName'] as String,
      projectTitle: map['projectTitle'] as String,
      projectDescription: map['projectDescription'] as String,
      budget: (map['budget'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      progress: ((map['progress'] ?? 0.0) as num).toDouble(),
      status: HireRequestStatus.values.firstWhere(
        (HireRequestStatus status) => status.name == map['status'],
        orElse: () => HireRequestStatus.pending,
      ),
      amountReleased: (map['amountReleased'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => toJson();
}

class JobModel extends HireRequestModel {
  JobModel({
    required super.id,
    required super.clientId,
    required super.clientName,
    required super.professionalId,
    required super.professionalName,
    required String description,
    required super.budget,
    required DateTime? deadline,
    required super.status,
    required super.createdAt,
    DateTime? updatedAt,
  }) : super(
          projectTitle: '',
          projectDescription: description,
          deadline: deadline ?? DateTime.now().add(const Duration(days: 7)),
        );

  factory JobModel.fromMap(Map<String, dynamic> map) {
    final req = HireRequestModel.fromJson(map);
    return JobModel(
      id: req.id,
      clientId: req.clientId,
      clientName: req.clientName,
      professionalId: req.professionalId,
      professionalName: req.professionalName,
      description: req.projectDescription,
      budget: req.budget,
      deadline: req.deadline,
      status: req.status,
      createdAt: req.createdAt,
    );
  }
}
