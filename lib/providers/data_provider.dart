import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mini_fiverr/models/chat_model.dart';
import 'package:mini_fiverr/models/job_model.dart';
import 'package:mini_fiverr/models/message_model.dart';
import 'package:mini_fiverr/models/notification_model.dart';
import 'package:mini_fiverr/models/professional_model.dart';
import 'package:mini_fiverr/models/security_question_model.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/utils/dummy_data.dart';
import 'package:mini_fiverr/utils/local_storage.dart';
import 'package:uuid/uuid.dart';

class DataProvider extends ChangeNotifier {
  final LocalStorage _storage = LocalStorage();
  final Uuid _uuid = const Uuid();

  bool _isReady = false;
  UserModel? _currentUser;
  List<ProfessionalModel> _professionals = <ProfessionalModel>[];
  List<HireRequestModel> _hireRequests = <HireRequestModel>[];
  List<ConversationModel> _conversations = <ConversationModel>[];
  List<NotificationModel> _notifications = <NotificationModel>[];
  final Map<String, UserModel> _profiles = <String, UserModel>{};
  final Map<String, List<SecurityQuestionModel>> _securityByUser =
      <String, List<SecurityQuestionModel>>{};

  bool get isReady => _isReady;
  UserModel? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.client;
  List<ProfessionalModel> get professionals => List<ProfessionalModel>.unmodifiable(_professionals);
  List<HireRequestModel> get hireRequests => List<HireRequestModel>.unmodifiable(_hireRequests);
  List<ConversationModel> get conversations => List<ConversationModel>.unmodifiable(_conversations);
  List<NotificationModel> get notifications => List<NotificationModel>.unmodifiable(_notifications);

  List<SecurityQuestionModel> securityQuestionsFor(String userId) {
    return _securityByUser[userId] ?? <SecurityQuestionModel>[];
  }

  int get unreadNotificationCount =>
      _notifications.where((NotificationModel n) => !n.isRead).length;

  int get totalUnreadMessages => _conversations.fold<int>(
        0,
        (int sum, ConversationModel c) => sum + c.unreadCount,
      );

  Future<void> syncWithAuth(User? firebaseUser) async {
    if (!_isReady) {
      await _load();
    }
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    if (!_profiles.containsKey(firebaseUser.uid)) {
      _profiles[firebaseUser.uid] = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        fullName: firebaseUser.displayName ?? 'Demo User',
        role: UserRole.client,
      );
      _securityByUser[firebaseUser.uid] = DemoData.defaultSecurityQuestions;
    }

    _currentUser = _profiles[firebaseUser.uid];
    _seedConversationsIfNeeded();
    await _persist();
    notifyListeners();
  }

  Future<void> completeSignupProfile({
    required String uid,
    required String email,
    required String fullName,
    required UserRole role,
  }) async {
    _profiles[uid] = UserModel(
      id: uid,
      email: email,
      fullName: fullName,
      role: role,
      title: role == UserRole.professional ? 'Freelance Professional' : '',
      walletBalance: 10000,
    );
    _securityByUser[uid] = DemoData.defaultSecurityQuestions;
    _currentUser = _profiles[uid];
    await _persist();
    notifyListeners();
  }

  void switchRole() {
    final UserModel? user = _currentUser;
    if (user == null) {
      return;
    }
    final UserRole nextRole =
        user.role == UserRole.client ? UserRole.professional : UserRole.client;
    _currentUser = user.copyWith(role: nextRole);
    _profiles[user.id] = _currentUser!;
    _persist();
    notifyListeners();
  }

  void toggleFavorite(String professionalId) {
    final UserModel? user = _currentUser;
    if (user == null || user.role != UserRole.client) {
      return;
    }
    final Set<String> ids = user.favoriteProfessionalIds.toSet();
    if (ids.contains(professionalId)) {
      ids.remove(professionalId);
    } else {
      ids.add(professionalId);
    }
    _updateCurrentUser(user.copyWith(favoriteProfessionalIds: ids.toList()));
  }

  List<ProfessionalModel> get favoriteProfessionals {
    final UserModel? user = _currentUser;
    if (user == null) {
      return <ProfessionalModel>[];
    }
    final Set<String> ids = user.favoriteProfessionalIds.toSet();
    return _professionals.where((ProfessionalModel p) => ids.contains(p.id)).toList();
  }

  void updateProfile({
    required String fullName,
    required String bio,
    required String avatarPath,
    String? companyName,
    String? lookingForTalent,
    String? title,
    List<String>? skills,
    int? experienceYears,
    String? previousCompany,
    List<String>? workPreferences,
    double? hourlyRate,
    required List<SecurityQuestionModel> security,
  }) {
    final UserModel? user = _currentUser;
    if (user == null) {
      return;
    }
    final UserModel next = user.copyWith(
      fullName: fullName,
      bio: bio,
      avatarPath: avatarPath,
      companyName: companyName ?? user.companyName,
      lookingForTalent: lookingForTalent ?? user.lookingForTalent,
      title: title ?? user.title,
      skills: skills ?? user.skills,
      experienceYears: experienceYears ?? user.experienceYears,
      previousCompany: previousCompany ?? user.previousCompany,
      workPreferences: workPreferences ?? user.workPreferences,
      hourlyRate: hourlyRate ?? user.hourlyRate,
    );
    _securityByUser[user.id] = security;
    _updateCurrentUser(next);
  }

  bool verifySecurityAnswers(String email, String answer1, String answer2) {
    final UserModel? target = _profiles.values.firstWhere(
      (UserModel u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => const UserModel(
        id: '',
        email: '',
        fullName: '',
        role: UserRole.client,
      ),
    );
    if (target == null || target.id.isEmpty) {
      return false;
    }
    final List<SecurityQuestionModel> qs = _securityByUser[target.id] ?? <SecurityQuestionModel>[];
    if (qs.length < 2) {
      return false;
    }
    return qs[0].answer.trim().toLowerCase() == answer1.trim().toLowerCase() &&
        qs[1].answer.trim().toLowerCase() == answer2.trim().toLowerCase();
  }

  List<HireRequestModel> get clientRequests {
    final String uid = _currentUser?.id ?? '';
    return _hireRequests.where((HireRequestModel r) => r.clientId == uid).toList();
  }

  List<HireRequestModel> get professionalRequests {
    final String uid = _currentUser?.id ?? '';
    return _hireRequests.where((HireRequestModel r) => r.professionalId == uid).toList();
  }

  void sendHireRequest({
    required ProfessionalModel pro,
    required String projectTitle,
    required String description,
    required double budget,
    required DateTime deadline,
  }) {
    final UserModel? user = _currentUser;
    if (user == null) {
      return;
    }

    _updateCurrentUser(user.copyWith(walletBalance: user.walletBalance - budget));

    _hireRequests.add(
      HireRequestModel(
        id: _uuid.v4(),
        clientId: user.id,
        clientName: user.fullName,
        professionalId: pro.id,
        professionalName: pro.name,
        projectTitle: projectTitle,
        projectDescription: description,
        budget: budget,
        deadline: deadline,
        createdAt: DateTime.now(),
      ),
    );

    _notifications.insert(
      0,
      NotificationModel(
        id: _uuid.v4(),
        title: 'New hire request',
        body: '${user.fullName} sent you a request',
        previewText: projectTitle,
        timestamp: DateTime.now(),
        type: NotificationType.newHireRequest,
      ),
    );

    _persist();
    notifyListeners();
  }

  void updateRequestStatus(String requestId, HireRequestStatus status) {
    final int index = _hireRequests.indexWhere((HireRequestModel r) => r.id == requestId);
    if (index < 0) {
      return;
    }
    _hireRequests[index] = _hireRequests[index].copyWith(status: status);
    _notifications.insert(
      0,
      NotificationModel(
        id: _uuid.v4(),
        title: status == HireRequestStatus.accepted ? 'Request accepted' : 'Request declined',
        body: '${_hireRequests[index].professionalName} ${status.name} your request',
        timestamp: DateTime.now(),
        type: status == HireRequestStatus.accepted
            ? NotificationType.hireAccepted
            : NotificationType.hireDeclined,
        relatedRequestId: requestId,
      ),
    );
    _persist();
    notifyListeners();
  }

  void completeJobAndReleasePayment(String requestId) {
    final int index = _hireRequests.indexWhere((HireRequestModel r) => r.id == requestId);
    if (index < 0) {
      return;
    }
    final HireRequestModel req =
        _hireRequests[index].copyWith(status: HireRequestStatus.completed, amountReleased: true);
    _hireRequests[index] = req;

    final UserModel? pro = _profiles[req.professionalId];
    if (pro != null) {
      _profiles[pro.id] = pro.copyWith(earnings: pro.earnings + req.budget);
    }
    if (_currentUser?.id == req.professionalId) {
      _currentUser = _profiles[req.professionalId];
    }

    _notifications.insert(
      0,
      NotificationModel(
        id: _uuid.v4(),
        title: 'Payment released',
        body: 'Payment for ${req.projectTitle} was released',
        timestamp: DateTime.now(),
        type: NotificationType.projectCompleted,
        relatedRequestId: req.id,
      ),
    );
    _persist();
    notifyListeners();
  }

  ConversationModel openConversationWith({
    required String otherUserId,
    required String otherUserName,
    required String otherAvatar,
  }) {
    final String me = _currentUser?.id ?? '';
    final int existing = _conversations.indexWhere(
      (ConversationModel c) => c.meId == me && c.otherUserId == otherUserId,
    );
    if (existing >= 0) {
      return _conversations[existing];
    }

    final ConversationModel conversation = ConversationModel(
      id: _uuid.v4(),
      meId: me,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserAvatar: otherAvatar,
      isOtherOnline: true,
      messages: <MessageModel>[],
    );
    _conversations.insert(0, conversation);
    _persist();
    notifyListeners();
    return conversation;
  }

  void sendMessage({required String conversationId, required String content}) {
    final int index = _conversations.indexWhere((ConversationModel c) => c.id == conversationId);
    if (index < 0 || content.trim().isEmpty) {
      return;
    }
    final ConversationModel c = _conversations[index];
    final List<MessageModel> nextMessages = <MessageModel>[
      ...c.messages,
      MessageModel(
        id: _uuid.v4(),
        senderId: _currentUser!.id,
        content: content.trim(),
        timestamp: DateTime.now(),
        isSentByMe: true,
        isRead: true,
      ),
    ];
    _conversations[index] = c.copyWith(messages: nextMessages);
    _persist();
    notifyListeners();
  }

  Future<void> simulateReply({
    required String conversationId,
    required String reply,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final int index = _conversations.indexWhere((ConversationModel c) => c.id == conversationId);
    if (index < 0) {
      return;
    }
    final ConversationModel c = _conversations[index];
    final List<MessageModel> next = <MessageModel>[
      ...c.messages,
      MessageModel(
        id: _uuid.v4(),
        senderId: c.otherUserId,
        content: reply,
        timestamp: DateTime.now(),
        isSentByMe: false,
        isRead: false,
      ),
    ];
    _conversations[index] = c.copyWith(messages: next);
    _notifications.insert(
      0,
      NotificationModel(
        id: _uuid.v4(),
        title: 'New message',
        body: '${c.otherUserName} sent a message',
        previewText: reply,
        timestamp: DateTime.now(),
        type: NotificationType.message,
        relatedConversationId: c.id,
      ),
    );
    _persist();
    notifyListeners();
  }

  void markConversationAsRead(String conversationId) {
    final int index = _conversations.indexWhere((ConversationModel c) => c.id == conversationId);
    if (index < 0) {
      return;
    }
    final ConversationModel c = _conversations[index];
    final List<MessageModel> next = c.messages
        .map((MessageModel m) => m.isSentByMe ? m : m.copyWith(isRead: true))
        .toList();
    _conversations[index] = c.copyWith(messages: next);
    _persist();
    notifyListeners();
  }

  void markAllConversationsAsRead() {
    _conversations = _conversations
        .map(
          (ConversationModel c) => c.copyWith(
            messages: c.messages
                .map((MessageModel m) => m.isSentByMe ? m : m.copyWith(isRead: true))
                .toList(),
          ),
        )
        .toList();
    _persist();
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final int index = _notifications.indexWhere((NotificationModel n) => n.id == id);
    if (index < 0) {
      return;
    }
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    _persist();
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications
        .map((NotificationModel n) => n.copyWith(isRead: true))
        .toList();
    _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final Map<String, dynamic>? cached = await _storage.readData();
    if (cached == null) {
      _professionals = DemoData.professionals;
      _hireRequests = <HireRequestModel>[];
      _conversations = DemoData.conversations;
      _notifications = DemoData.notifications;
      _isReady = true;
      return;
    }

    _professionals = (cached['professionals'] as List<dynamic>)
        .map((dynamic e) => ProfessionalModel.fromJson(e as Map<String, dynamic>))
        .toList();
    _hireRequests = (cached['hireRequests'] as List<dynamic>)
        .map((dynamic e) => HireRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
    _conversations = (cached['conversations'] as List<dynamic>)
        .map((dynamic e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    _notifications = (cached['notifications'] as List<dynamic>)
        .map((dynamic e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final Map<String, dynamic> profiles = cached['profiles'] as Map<String, dynamic>;
    profiles.forEach((String key, dynamic value) {
      _profiles[key] = UserModel.fromJson(value as Map<String, dynamic>);
    });

    final Map<String, dynamic> sec = cached['securityByUser'] as Map<String, dynamic>;
    sec.forEach((String key, dynamic value) {
      _securityByUser[key] = (value as List<dynamic>)
          .map((dynamic e) => SecurityQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    _isReady = true;
  }

  Future<void> _persist() {
    return _storage.writeData(
      <String, dynamic>{
        'professionals': _professionals.map((ProfessionalModel p) => p.toJson()).toList(),
        'hireRequests': _hireRequests.map((HireRequestModel h) => h.toJson()).toList(),
        'conversations': _conversations.map((ConversationModel c) => c.toJson()).toList(),
        'notifications': _notifications.map((NotificationModel n) => n.toJson()).toList(),
        'profiles': _profiles.map((String key, UserModel value) => MapEntry<String, dynamic>(key, value.toJson())),
        'securityByUser': _securityByUser.map(
          (String key, List<SecurityQuestionModel> value) => MapEntry<String, dynamic>(
            key,
            value.map((SecurityQuestionModel q) => q.toJson()).toList(),
          ),
        ),
      },
    );
  }

  void _updateCurrentUser(UserModel user) {
    _currentUser = user;
    _profiles[user.id] = user;
    _persist();
    notifyListeners();
  }

  void _seedConversationsIfNeeded() {
    if (_conversations.isNotEmpty) {
      return;
    }
    _conversations = DemoData.conversations;
  }
}
