import 'package:cloud_firestore/cloud_firestore.dart';

enum JobStatus {
  pending,
  accepted,
  declined,
  completed
}

class JobModel {
  final String id;
  final String clientId;
  final String clientName;
  final String professionalId;
  final String professionalName;
  final String description;
  final double budget;
  final DateTime? deadline;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.professionalId,
    required this.professionalName,
    required this.description,
    this.budget = 0.0,
    this.deadline,
    this.status = JobStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      professionalId: map['professionalId'] ?? '',
      professionalName: map['professionalName'] ?? '',
      description: map['description'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      deadline: map['deadline'] != null ? (map['deadline'] as Timestamp).toDate() : null,
      status: JobStatus.values.firstWhere((e) => e.name == (map['status'] ?? 'pending')),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'description': description,
      'budget': budget,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
