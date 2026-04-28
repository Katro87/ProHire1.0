import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'client' or 'professional'
  final bool profileCompleted;
  final bool hasSecurityQuestions;
  final String profilePicUrl;
  final double walletBalance;
  final DateTime createdAt;
  final String? companyName;
  final String? lookingFor;
  final String? industry;
  
  // Professional specific fields
  final String? professionalTitle;
  final List<String>? skills;
  final String? experience;
  final double? hourlyRate;
  final String? bio;
  final bool? isAvailable;
  
  // Security Questions
  final List<Map<String, String>>? securityQuestions;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profileCompleted = false,
    this.hasSecurityQuestions = false,
    this.profilePicUrl = '',
    this.walletBalance = 0.0,
    required this.createdAt,
    this.companyName,
    this.lookingFor,
    this.industry,
    this.professionalTitle,
    this.skills,
    this.experience,
    this.hourlyRate,
    this.bio,
    this.isAvailable,
    this.securityQuestions,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];
    final createdAt = createdAtValue is Timestamp
        ? createdAtValue.toDate()
        : createdAtValue is DateTime
            ? createdAtValue
            : DateTime.now();

    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'client',
      profileCompleted: map['profileCompleted'] ?? false,
      hasSecurityQuestions: map['hasSecurityQuestions'] ?? false,
      profilePicUrl: map['profilePicUrl'] ?? '',
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      createdAt: createdAt,
      companyName: map['companyName'],
      lookingFor: map['lookingFor'],
      industry: map['industry'],
      professionalTitle: map['professionalTitle'],
      skills: map['skills'] != null ? List<String>.from(map['skills']) : null,
      experience: map['experience'],
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      bio: map['bio'],
      isAvailable: map['isAvailable'],
      securityQuestions: map['securityQuestions'] != null 
        ? List<Map<String, String>>.from(
            (map['securityQuestions'] as List).map((i) => Map<String, String>.from(i))
          ) 
        : null,
    );
  }

  String? get title => professionalTitle;

  Map<String, dynamic> toMap() {
    final map = {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'profileCompleted': profileCompleted,
      'hasSecurityQuestions': hasSecurityQuestions,
      'profilePicUrl': profilePicUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'walletBalance': walletBalance,
      'professionalTitle': professionalTitle,
      'skills': skills,
      'experience': experience,
      'hourlyRate': hourlyRate,
      'bio': bio,
      'isAvailable': isAvailable,
    };

    if (companyName != null) {
      map['companyName'] = companyName;
    }
    if (lookingFor != null) {
      map['lookingFor'] = lookingFor;
    }
    if (industry != null) {
      map['industry'] = industry;
    }
    if (securityQuestions != null) {
      map['securityQuestions'] = securityQuestions;
    }

    return map;
  }
}
