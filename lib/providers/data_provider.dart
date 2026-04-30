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
  DataProvider() {
    _loadFuture = _load();
  }

  final LocalStorage _storage = LocalStorage();
  final Uuid _uuid = const Uuid();
  late final Future<void> _loadFuture;

  bool _isReady = false;
  UserModel? _currentUser;
  String? _activeUserId;
  List<ProfessionalModel> _professionals = <ProfessionalModel>[];
  List<HireRequestModel> _hireRequests = <HireRequestModel>[];
  List<ConversationModel> _conversations = <ConversationModel>[];
  List<NotificationModel> _notifications = <NotificationModel>[];
  final Map<String, UserModel> _profiles = <String, UserModel>{};
  final Map<String, List<SecurityQuestionModel>> _securityByUser = <String, List<SecurityQuestionModel>>{};
  final Map<String, Map<String, dynamic>> _userStates = <String, Map<String, dynamic>>{};

  bool get isReady => _isReady;
  UserModel? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.client;
  List<ProfessionalModel> get professionals => List<ProfessionalModel>.unmodifiable(_professionals);
  List<HireRequestModel> get hireRequests => List<HireRequestModel>.unmodifiable(_hireRequests);
  List<HireRequestModel> get clientRequests => _requestListForCurrentUser(null, asClient: true);
  List<HireRequestModel> get professionalRequests => _requestListForCurrentUser(null, asClient: false);
  List<ConversationModel> get conversations => List<ConversationModel>.unmodifiable(_conversations);
  List<NotificationModel> get notifications => List<NotificationModel>.unmodifiable(_notifications);
  int get unreadNotificationCount => _notifications.where((NotificationModel notification) => !notification.isRead).length;
  int get totalUnreadMessages => _conversations.fold<int>(0, (int total, ConversationModel conversation) => total + conversation.unreadCount);
  List<ProfessionalModel> get favoriteProfessionals {
    final List<String> favoriteIds = _currentUser?.favoriteProfessionalIds ?? <String>[];
    return _professionals.where((ProfessionalModel professional) => favoriteIds.contains(professional.id)).toList(growable: false);
  }

  Future<void> syncWithAuth(User? authUser) async {
    await _loadFuture;

    if (authUser == null) {
      _currentUser = null;
      _activeUserId = null;
      _clearSimulationState();
      notifyListeners();
      return;
    }

    final String uid = authUser.uid;
    final UserModel profile = _profiles[uid] ?? _profileFromAuth(authUser);
    _profiles[uid] = profile;
    _currentUser = profile;
    _activeUserId = uid;

    _loadSimulationStateForUser(uid, demoAccount: _isDemoUser(authUser, profile));
    await _persist();
    notifyListeners();
  }

  Future<void> completeSignupProfile({
    required String uid,
    required String email,
    required String fullName,
    required UserRole role,
  }) async {
    await _loadFuture;

    final UserModel profile = UserModel(
      id: uid,
      email: email,
      fullName: fullName,
      role: role,
      bio: '',
      avatarPath: _defaultAvatarForName(fullName),
      companyName: '',
      lookingForTalent: '',
      title: '',
      skills: <String>[],
      experienceYears: 0,
      previousCompany: '',
      workPreferences: <String>[],
      hourlyRate: 5,
      walletBalance: 0,
      earnings: 0,
      favoriteProfessionalIds: <String>[],
    );

    _profiles[uid] = profile;
    _currentUser = profile;
    _activeUserId = uid;
    _securityByUser.remove(uid);
    _clearSimulationState();
    await _persist();
    notifyListeners();
  }

  Future<void> updateProfile({
    required String fullName,
    required String bio,
    String avatarPath = '',
    required String companyName,
    required String lookingForTalent,
    required String title,
    required List<String> skills,
    required int experienceYears,
    required String previousCompany,
    required List<String> workPreferences,
    required double hourlyRate,
    required List<SecurityQuestionModel> security,
  }) async {
    await _loadFuture;

    final UserModel? current = _currentUser;
    if (current == null) {
      return;
    }

    final UserModel updated = current.copyWith(
      fullName: fullName,
      bio: bio,
      avatarPath: avatarPath.trim().isEmpty ? current.avatarPath : avatarPath.trim(),
      companyName: companyName,
      lookingForTalent: lookingForTalent,
      title: title,
      skills: skills,
      experienceYears: experienceYears,
      previousCompany: previousCompany,
      workPreferences: workPreferences,
      hourlyRate: hourlyRate,
    );

    _currentUser = updated;
    _profiles[updated.id] = updated;
    _securityByUser[updated.id] = security;
    await _persist();
    notifyListeners();
  }

  List<SecurityQuestionModel> securityQuestionsFor(String uid) {
    return List<SecurityQuestionModel>.unmodifiable(_securityByUser[uid] ?? <SecurityQuestionModel>[]);
  }

  List<SecurityQuestionModel> securityQuestionsForEmail(String email) {
    UserModel? user;
    for (final UserModel profile in _profiles.values) {
      if (profile.email.toLowerCase() == email.toLowerCase()) {
        user = profile;
        break;
      }
    }
    if (user == null) return [];
    return List<SecurityQuestionModel>.unmodifiable(_securityByUser[user.id] ?? <SecurityQuestionModel>[]);
  }

  bool verifySecurityAnswers(String email, String answer1, String answer2) {
    UserModel? user;
    for (final UserModel profile in _profiles.values) {
      if (profile.email.toLowerCase() == email.toLowerCase()) {
        user = profile;
        break;
      }
    }
    if (user == null) {
      return false;
    }

    final List<SecurityQuestionModel> questions = _securityByUser[user.id] ?? <SecurityQuestionModel>[];
    if (questions.length < 2) {
      return false;
    }

    final String stored1 = questions[0].answer.trim().toLowerCase();
    final String stored2 = questions[1].answer.trim().toLowerCase();
    return stored1 == answer1.trim().toLowerCase() && stored2 == answer2.trim().toLowerCase();
  }

  Future<void> switchRole() async {
    await _loadFuture;

    final UserModel? current = _currentUser;
    if (current == null) {
      return;
    }

    final UserModel updated = current.copyWith(
      role: current.role == UserRole.client ? UserRole.professional : UserRole.client,
    );
    _currentUser = updated;
    _profiles[updated.id] = updated;
    await _persist();
    notifyListeners();
  }

  Future<void> toggleFavorite(String professionalId) async {
    await _loadFuture;

    final UserModel? current = _currentUser;
    if (current == null) {
      return;
    }

    final List<String> favoriteIds = List<String>.from(current.favoriteProfessionalIds);
    if (favoriteIds.contains(professionalId)) {
      favoriteIds.remove(professionalId);
    } else {
      favoriteIds.add(professionalId);
    }

    final UserModel updated = current.copyWith(favoriteProfessionalIds: favoriteIds);
    _currentUser = updated;
    _profiles[updated.id] = updated;
    await _persist();
    notifyListeners();
  }

  Future<bool> sendHireRequest({
    required ProfessionalModel pro,
    required String projectTitle,
    required String description,
    required double budget,
    required DateTime deadline,
  }) async {
    await _loadFuture;

    final UserModel? current = _currentUser;
    if (current == null) {
      return false;
    }

    final HireRequestModel request = HireRequestModel(
      id: _uuid.v4(),
      clientId: current.id,
      clientName: current.fullName,
      professionalId: pro.id,
      professionalName: pro.name,
      projectTitle: projectTitle,
      projectDescription: description,
      budget: budget,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
    _hireRequests.insert(0, request);
    _notifications.insert(
      0,
      NotificationModel(
        id: _uuid.v4(),
        title: 'Request sent',
        body: 'Your request for ${pro.name} was sent',
        previewText: projectTitle,
        timestamp: DateTime.now(),
        type: NotificationType.newHireRequest,
        relatedRequestId: request.id,
      ),
    );
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> updateRequestStatus(String id, HireRequestStatus status) async {
    await _loadFuture;

    final int index = _hireRequests.indexWhere((HireRequestModel request) => request.id == id);
    if (index < 0) {
      return;
    }

    final HireRequestModel updatedRequest = _hireRequests[index].copyWith(status: status);
    _hireRequests[index] = updatedRequest;

    if (status == HireRequestStatus.accepted) {
      _notifications.insert(
        0,
        NotificationModel(
          id: _uuid.v4(),
          title: 'Request accepted',
          body: '${updatedRequest.professionalName} accepted your hire request',
          previewText: updatedRequest.projectTitle,
          timestamp: DateTime.now(),
          type: NotificationType.hireAccepted,
          relatedRequestId: updatedRequest.id,
        ),
      );
    } else if (status == HireRequestStatus.declined) {
      _notifications.insert(
        0,
        NotificationModel(
          id: _uuid.v4(),
          title: 'Request declined',
          body: '${updatedRequest.professionalName} declined your hire request',
          previewText: updatedRequest.projectTitle,
          timestamp: DateTime.now(),
          type: NotificationType.hireDeclined,
          relatedRequestId: updatedRequest.id,
        ),
      );
    }

    await _persist();
    notifyListeners();
  }

  Future<void> completeJobAndReleasePayment(String requestId) async {
    await _loadFuture;

    final int index = _hireRequests.indexWhere((HireRequestModel request) => request.id == requestId);
    if (index < 0) {
      return;
    }

    final HireRequestModel request = _hireRequests[index].copyWith(
      status: HireRequestStatus.completed,
      amountReleased: true,
    );
    _hireRequests[index] = request;

    final UserModel? professional = _profiles[request.professionalId];
    if (professional != null) {
      final UserModel updatedProfessional = professional.copyWith(
        earnings: professional.earnings + request.budget,
        walletBalance: professional.walletBalance + request.budget,
      );
      _profiles[updatedProfessional.id] = updatedProfessional;
      if (_currentUser?.id == updatedProfessional.id) {
        _currentUser = updatedProfessional;
      }
    }

    _notifications.insert(
      0,
      NotificationModel(
        id: _uuid.v4(),
        title: 'Payment released',
        body: 'Payment for ${request.projectTitle} was released',
        timestamp: DateTime.now(),
        type: NotificationType.projectCompleted,
        relatedRequestId: request.id,
      ),
    );
    await _persist();
    notifyListeners();
  }

  ConversationModel openConversationWith({
    required String otherUserId,
    required String otherUserName,
    required String otherAvatar,
  }) {
    final String me = _currentUser?.id ?? '';
    final int existing = _conversations.indexWhere(
      (ConversationModel conversation) => conversation.meId == me && conversation.otherUserId == otherUserId,
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
    final int index = _conversations.indexWhere((ConversationModel conversation) => conversation.id == conversationId);
    if (index < 0 || content.trim().isEmpty) {
      return;
    }

    final ConversationModel conversation = _conversations[index];
    final List<MessageModel> nextMessages = <MessageModel>[
      ...conversation.messages,
      MessageModel(
        id: _uuid.v4(),
        senderId: _currentUser?.id ?? '',
        content: content.trim(),
        timestamp: DateTime.now(),
        isSentByMe: true,
        isRead: true,
      ),
    ];
    _conversations[index] = conversation.copyWith(messages: nextMessages);
    _persist();
    notifyListeners();
  }

  Future<void> simulateReply({
    required String conversationId,
    required String reply,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    final int index = _conversations.indexWhere((ConversationModel conversation) => conversation.id == conversationId);
    if (index < 0) {
      return;
    }

    final ConversationModel conversation = _conversations[index];
    final List<MessageModel> nextMessages = <MessageModel>[
      ...conversation.messages,
      MessageModel(
        id: _uuid.v4(),
        senderId: conversation.otherUserId,
        content: reply,
        timestamp: DateTime.now(),
        isSentByMe: false,
        isRead: false,
      ),
    ];
    _conversations[index] = conversation.copyWith(messages: nextMessages);
    _notifications.insert(
      0,
      NotificationModel(
        id: _uuid.v4(),
        title: 'New message',
        body: '${conversation.otherUserName} sent a message',
        previewText: reply,
        timestamp: DateTime.now(),
        type: NotificationType.message,
        relatedConversationId: conversation.id,
      ),
    );
    _persist();
    notifyListeners();
  }

  Future<void> markConversationAsRead(String conversationId) async {
    final int index = _conversations.indexWhere((ConversationModel conversation) => conversation.id == conversationId);
    if (index < 0) {
      return;
    }

    final ConversationModel conversation = _conversations[index];
    final List<MessageModel> nextMessages = conversation.messages
        .map((MessageModel message) => message.isSentByMe ? message : message.copyWith(isRead: true))
        .toList();
    _conversations[index] = conversation.copyWith(messages: nextMessages);
    await _persist();
    notifyListeners();
  }

  Future<void> markAllConversationsAsRead() async {
    _conversations = _conversations
        .map(
          (ConversationModel conversation) => conversation.copyWith(
            messages: conversation.messages
                .map((MessageModel message) => message.isSentByMe ? message : message.copyWith(isRead: true))
                .toList(),
          ),
        )
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String id) async {
    final int index = _notifications.indexWhere((NotificationModel notification) => notification.id == id);
    if (index < 0) {
      return;
    }
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    await _persist();
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    _notifications = _notifications.map((NotificationModel notification) => notification.copyWith(isRead: true)).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final Map<String, dynamic>? cached = await _storage.readData();
    _professionals = cached == null
        ? DemoData.professionals
        : (cached['professionals'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic entry) => ProfessionalModel.fromJson(entry as Map<String, dynamic>))
            .toList();

    if (cached != null) {
      _profiles.clear();
      for (final MapEntry<String, dynamic> entry in (cached['profiles'] as Map<String, dynamic>? ?? <String, dynamic>{}).entries) {
        _profiles[entry.key] = UserModel.fromJson(entry.value as Map<String, dynamic>);
      }

      _securityByUser.clear();
      for (final MapEntry<String, dynamic> entry in (cached['securityByUser'] as Map<String, dynamic>? ?? <String, dynamic>{}).entries) {
        _securityByUser[entry.key] = (entry.value as List<dynamic>)
            .map((dynamic question) => SecurityQuestionModel.fromJson(question as Map<String, dynamic>))
            .toList();
      }

      _userStates.clear();
      for (final MapEntry<String, dynamic> entry in (cached['userStates'] as Map<String, dynamic>? ?? <String, dynamic>{}).entries) {
        _userStates[entry.key] = Map<String, dynamic>.from(entry.value as Map);
      }
    }

    _isReady = true;
  }

  Future<void> _persist() {
    if (_activeUserId != null) {
      _userStates[_activeUserId!] = _stateForCurrentUser();
    }

    return _storage.writeData(<String, dynamic>{
      'professionals': _professionals.map((ProfessionalModel professional) => professional.toJson()).toList(),
      'profiles': _profiles.map((String key, UserModel value) => MapEntry<String, dynamic>(key, value.toJson())),
      'securityByUser': _securityByUser.map(
        (String key, List<SecurityQuestionModel> value) => MapEntry<String, dynamic>(
          key,
          value.map((SecurityQuestionModel question) => question.toJson()).toList(),
        ),
      ),
      'userStates': _userStates,
    });
  }

  Map<String, dynamic> _stateForCurrentUser() {
    return <String, dynamic>{
      'hireRequests': _hireRequests.map((HireRequestModel request) => request.toJson()).toList(),
      'conversations': _conversations.map((ConversationModel conversation) => conversation.toJson()).toList(),
      'notifications': _notifications.map((NotificationModel notification) => notification.toJson()).toList(),
    };
  }

  void _clearSimulationState() {
    _hireRequests = <HireRequestModel>[];
    _conversations = <ConversationModel>[];
    _notifications = <NotificationModel>[];
  }

  void _loadSimulationStateForUser(String uid, {required bool demoAccount}) {
    if (!demoAccount) {
      final Map<String, dynamic>? state = _userStates[uid];
      if (state == null) {
        _clearSimulationState();
        return;
      }

      _hireRequests = (state['hireRequests'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic entry) => HireRequestModel.fromJson(entry as Map<String, dynamic>))
          .toList();
      _conversations = (state['conversations'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic entry) => ConversationModel.fromJson(entry as Map<String, dynamic>))
          .toList();
      _notifications = (state['notifications'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic entry) => NotificationModel.fromJson(entry as Map<String, dynamic>))
          .toList();
      return;
    }

    final Map<String, dynamic>? state = _userStates[uid];
    if (state != null) {
      _hireRequests = (state['hireRequests'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic entry) => HireRequestModel.fromJson(entry as Map<String, dynamic>))
          .toList();
      _conversations = (state['conversations'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic entry) => ConversationModel.fromJson(entry as Map<String, dynamic>))
          .toList();
      _notifications = (state['notifications'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic entry) => NotificationModel.fromJson(entry as Map<String, dynamic>))
          .toList();
      return;
    }

    _hireRequests = DemoData.hireRequests;
    _conversations = DemoData.conversations
        .map(
          (ConversationModel conversation) => ConversationModel(
            id: conversation.id,
            meId: uid,
            otherUserId: conversation.otherUserId,
            otherUserName: conversation.otherUserName,
            otherUserAvatar: conversation.otherUserAvatar,
            isOtherOnline: conversation.isOtherOnline,
            messages: conversation.messages,
          ),
        )
        .toList();
    _notifications = DemoData.notifications;

    final UserModel? current = _currentUser;
    if (current != null && current.role == UserRole.client && current.favoriteProfessionalIds.isEmpty) {
      final UserModel seeded = current.copyWith(favoriteProfessionalIds: <String>['pro_1', 'pro_2', 'pro_3']);
      _currentUser = seeded;
      _profiles[uid] = seeded;
    }
  }

  bool _isDemoUser(User? authUser, UserModel profile) {
    final String email = (authUser?.email ?? profile.email).toLowerCase();
    final String name = profile.fullName.toLowerCase();
    final String uid = (authUser?.uid ?? profile.id).toLowerCase();
    return email.contains('.demo@minihire.com') || name.contains('sufyan') || uid == 'sufyan' || uid.startsWith('pro_');
  }

  UserModel _profileFromAuth(User authUser) {
    final String name = (authUser.displayName?.trim().isNotEmpty ?? false)
        ? authUser.displayName!.trim()
        : (authUser.email?.split('@').first ?? 'User');
    return UserModel(
      id: authUser.uid,
      email: authUser.email ?? '',
      fullName: name,
      role: authUser.uid.startsWith('pro_') ? UserRole.professional : UserRole.client,
      bio: '',
      avatarPath: _defaultAvatarForName(name),
      companyName: '',
      lookingForTalent: '',
      title: '',
      skills: <String>[],
      experienceYears: 0,
      previousCompany: '',
      workPreferences: <String>[],
      hourlyRate: 5,
      walletBalance: 0,
      earnings: 0,
      favoriteProfessionalIds: <String>[],
    );
  }

  List<HireRequestModel> _requestListForCurrentUser(HireRequestStatus? status, {required bool asClient}) {
    final UserModel? current = _currentUser;
    if (current == null) {
      return <HireRequestModel>[];
    }

    Iterable<HireRequestModel> list = _hireRequests.where(
      (HireRequestModel request) => asClient ? request.clientId == current.id : request.professionalId == current.id,
    );
    if (status != null) {
      list = list.where((HireRequestModel request) => request.status == status);
    }
    return list.toList(growable: false);
  }

  String _defaultAvatarForName(String name) {
    final String lower = name.trim().toLowerCase();
    if (lower.contains('sufyan')) {
      return 'assets/images/sufyan1.jpeg';
    }
    return '';
  }
}
