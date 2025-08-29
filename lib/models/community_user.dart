import 'package:meet_christ/models/user.dart';
import 'package:uuid/uuid.dart';

class CommunityUser extends User {
  bool isAdmin = false;
  String communityUserId;

  CommunityUser({
    required super.name,
    required super.id,
    required super.email,
    required super.profilePictureUrl,
    required this.communityUserId,
    this.isAdmin = false,
  });

  static CommunityUser newUser() {
    return CommunityUser(
      name: "",
      id: "",
      email: "",
      profilePictureUrl: null,
      communityUserId: Uuid().v4(),
    );
  }

  CommunityUser fromUser(User user) {
    return CommunityUser(
      name: user.name,
      id: user.id,
      email: user.email,
      profilePictureUrl: user.profilePictureUrl,
      communityUserId: communityUserId,
    );
  }

  /// Create CommunityUser from Map
  factory CommunityUser.fromMap(Map<String, dynamic> map, String documentId) {
    return CommunityUser(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      communityUserId: map['communityUserId'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  /// Convert CommunityUser to Map
  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'communityUserId': communityUserId,
      'isAdmin': isAdmin,
    };
  }

  /// Convert List<Map> to list
  static List<CommunityUser> listFromMapList(List<Map<String, dynamic>> docs) {
    return docs
        .map((map) => CommunityUser.fromMap(map, map['id'] ?? '')) // assumes ID is inside map for batch
        .toList();
  }

  /// Convert to List<Map>
  static List<Map<String, dynamic>> listToMapList(List<CommunityUser> users) {
    return users.map((user) {
      final map = user.toMap();
      map['id'] = user.id; // add id explicitly
      return map;
    }).toList();
  }

  @override
  String toString() {
    return 'CommunityUser{id: $id, name: $name, email: $email, profilePictureUrl: $profilePictureUrl, communityUserId: $communityUserId, isAdmin: $isAdmin}';
  }
}
