class User {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });

  set(String id) => User(
    name: name,
    email: email,
    profilePictureUrl: profilePictureUrl,
    id: id,
  );

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, profilePictureUrl: $profilePictureUrl}';
  }
}

class EventUser {
  final String userId;
  final String eventId;
  final String role;
  final String status; // Consider making this an enum for clarity
  final bool canComment;
  String photoUrl;
  final List<String> eventPermissions;
  final List<String> commentPermissions;
  final String name = "Name";

  /// Use enum for better type safety:
  /// 0 - Not Attending
  /// 1 - Attending
  /// 2 - Maybe
  final AttendingStatus attendingStatus;

  EventUser({
    required this.userId,
    required this.eventId,
    required this.role,
    required this.status,
    required this.canComment,
    required this.eventPermissions,
    required this.attendingStatus,
    this.commentPermissions = const [CommentPermissions.canAdd],
    this.photoUrl = '',
  });


  static EventUser host(String userId, String eventId) => EventUser(
    userId: userId,
    eventId: eventId,
    role: Roles.organizer,
    status: '',
    canComment: true,
    eventPermissions: [EventPermissions.canEdit, EventPermissions.canDelete],
    commentPermissions: [CommentPermissions.canAdd],
    attendingStatus: AttendingStatus.attending,
  );

  static EventUser attendee(String userId, String eventId) => EventUser(
    userId: userId,
    eventId: eventId,
    role: Roles.attendee,
    status: '',
    canComment: true,
    eventPermissions: [],
    commentPermissions: [CommentPermissions.canAdd],
    attendingStatus: AttendingStatus.attending,
  );
}

enum AttendingStatus {
  notAttending, // 0
  attending, // 1
  maybe, // 2
}

class EventPermissions {
  static const String canEdit = "can_edit";
  static const String canDelete = "can_delete";
  static const String canInvite = "can_invite";
  static const String canView = "can_view";
}

class CommentPermissions {
  static const String canAdd = "can_add";
  static const String canDelete = "can_delete";
  static const String canEdit = "can_edit";
}

class Roles {
  static const String organizer = "organizer";
  static const String speaker = "co-organizer";
  static const String attendee = "attendee";
}
