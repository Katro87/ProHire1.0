import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'client' or 'professional'
  final bool profileCompleted;
  final bool hasSecurityQuestions;
  final String profilePicUrl;
  final DateTime createdAt;
  final double walletBalance;
  
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
    required this.createdAt,
    this.walletBalance = 0.0,
    this.professionalTitle,
    this.skills,
    this.experience,
    this.hourlyRate,
    this.bio,
    this.isAvailable,
    this.securityQuestions,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'client',
      profileCompleted: map['profileCompleted'] ?? false,
      hasSecurityQuestions: map['hasSecurityQuestions'] ?? false,
      profilePicUrl: map['profilePicUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
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

  Map<String, dynamic> toMap() {
    return {
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
      'securityQuestions': securityQuestions,
    };
  }
}
