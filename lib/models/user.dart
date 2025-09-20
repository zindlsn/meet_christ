class User {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String? profilePictureUrl;
  final UserStatus status;

  User({
    required this.id,
    required this.firstname,
    required this.email,
    this.profilePictureUrl,
    required this.lastname,
    this.status = UserStatus.active,
  });

  set(String id) => User(
    firstname: firstname,
    email: email,
    lastname: lastname,
    profilePictureUrl: profilePictureUrl,
    id: id,
  );

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      firstname: map['firstname'] ?? '',
      email: map['email'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      lastname: map['lastname'] ?? '',
      status: UserStatus.values[map['status'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstname': firstname,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'lastname': lastname,
      'status': status.index,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, firstname: $firstname, email: $email, profilePictureUrl: $profilePictureUrl, lastname: $lastname, status: $status, status: $status }';
  }
}

class EventUser {
  final String userId;
  final String eventId;
  final String role;
  final String status; // Consider making this an enum for clarity
  final bool canComment;
  String? photoUrl;
  final List<String> eventPermissions;
  final List<String> commentPermissions;
  final String name = "Name Lastname";
  DateTime joinedAt  = DateTime.now();
  

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
    this.commentPermissions = const [],
    this.photoUrl = '',
  });

  /// Factory constructor for creating an organizer EventUser
  static EventUser host(String userId, String eventId) => EventUser(
    userId: userId,
    eventId: eventId,
    role: Roles.organizer,
    status: '',
    canComment: true,
    eventPermissions: EventPermissions.all,
    commentPermissions: CommentPermissions.all,
    attendingStatus: AttendingStatus.attending,
  );

  /// Factory method for creating an attendee EventUser
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

  /// Convert [Map] -> [EventUser]
  static EventUser fromMap(data) {
    return EventUser(
      userId: data['userId'],
      eventId: data['eventId'],
      role: data['role'],
      status: data['status'],
      canComment: data['canComment'],
      eventPermissions: List<String>.from(data['eventPermissions'] ?? []),
      commentPermissions: List<String>.from(data['commentPermissions'] ?? []),
      photoUrl: data['photoUrl'],
      attendingStatus: AttendingStatus.values[data['attendingStatus'] as int],
    )..joinedAt = DateTime.parse(data['joinedAt']);
  }

  /// Convert [EventUser] -> [Map]
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'role': role,
      'status': status,
      'canComment': canComment,
      'eventPermissions': eventPermissions,
      'commentPermissions': commentPermissions,
      'photoUrl': photoUrl,
      'joinedAt': joinedAt.toIso8601String(),
      'attendingStatus': attendingStatus.index,
    };
  }
}

class EventUserDto {
  final String userId;
  final String eventId;
  final String role;
  final String status;
  final bool canComment;
  final String? photoUrl;
  final List<String> eventPermissions;
  final List<String> commentPermissions;
  final String name;
  final DateTime joinedAt;
  final AttendingStatus attendingStatus;

  EventUserDto({
    required this.userId,
    required this.eventId,
    required this.role,
    required this.status,
    required this.canComment,
    required this.eventPermissions,
    required this.commentPermissions,
    required this.attendingStatus,
    this.photoUrl,
    this.name = "Name Lastname",
    required this.joinedAt,
  });

  factory EventUserDto.fromJson(Map<String, dynamic> json) {
    return EventUserDto(
      userId: json['userId'] as String,
      eventId: json['eventId'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      canComment: json['canComment'] as bool,
      eventPermissions: List<String>.from(json['eventPermissions'] ?? []),
      commentPermissions: List<String>.from(json['commentPermissions'] ?? []),
      photoUrl: json['photoUrl'] as String?,
      name: json['name'] ?? "Name Lastname",
      joinedAt: DateTime.parse(json['joinedAt']),
      attendingStatus: AttendingStatus.values[json['attendingStatus'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventId': eventId,
      'role': role,
      'status': status,
      'canComment': canComment,
      'eventPermissions': eventPermissions,
      'commentPermissions': commentPermissions,
      'photoUrl': photoUrl,
      'name': name,
      'joinedAt': joinedAt.toIso8601String(),
      'attendingStatus': attendingStatus.index,
    };
  }

  /// Convert [EventUser] -> [EventUserDto]
  factory EventUserDto.fromDto(EventUser user) {
    return EventUserDto(
      userId: user.userId,
      eventId: user.eventId,
      role: user.role,
      status: user.status,
      canComment: user.canComment,
      eventPermissions: user.eventPermissions,
      commentPermissions: user.commentPermissions,
      photoUrl: user.photoUrl,
      name: user.name,
      joinedAt: user.joinedAt,
      attendingStatus: user.attendingStatus,
    );
  }

  /// Convert [EventUserDto] -> [EventUser]
  EventUser toDto() {
    return EventUser(
      userId: userId,
      eventId: eventId,
      role: role,
      status: status,
      canComment: canComment,
      eventPermissions: eventPermissions,
      commentPermissions: commentPermissions,
      photoUrl: photoUrl,
      attendingStatus: attendingStatus,
    )..joinedAt = joinedAt;
  }
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
  static const String canAddMembers = "can_add_members";
  static const String canDeleteMembers = "can_delete_members";

  static const List<String> all = [canEdit, canDelete, canInvite, canView];
}

class CommentPermissions {
  static const String canAdd = "can_add";
  static const String canDelete = "can_delete";
  static const String canEdit = "can_edit";

  static const List<String> all = [canAdd, canDelete, canEdit];
}

class Roles {
  static const String organizer = "organizer";
  static const String speaker = "co-organizer";
  static const String attendee = "attendee";
}

enum EventUserStatus { invited, going, notGoing, maybe, rejoined }

enum UserStatus { active, inactive, banned,deleted }
