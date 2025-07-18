import 'dart:typed_data';

import 'package:meet_christ/models/address.dart';
import 'package:meet_christ/models/community_user.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/group.dart';

class Community {
  final String id;
  final String uid;
  final String name;
  final String description;
  final Address? address;
  final List<Event> events;
  final List<CommunityUser> members;
  final List<CommunityGroup> groups;
  final Uint8List? profileImage;

  Community({
    required this.id,
    required this.uid,
    required this.name,
    required this.description,
    required this.address,
    this.events = const [],
    this.members = const [],
    this.groups = const [],
    this.profileImage,
  });

  Community copyWith({
    String? uid,
    String? name,
    String? description,
    Address? address,
    List<Event>? events,
    List<CommunityUser>? members,
    List<CommunityGroup>? groups,
    Uint8List? profileImage,
    Event? addEvent,
    CommunityUser? addMember,
    CommunityGroup? addGroup,
  }) {
    return Community(
      id: id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      events: [
        ...this.events,
        if (addEvent != null) addEvent,
        if (events != null) ...events, // overrides additions if both provided
      ],
      members: [
        ...this.members,
        if (addMember != null) addMember,
        if (members != null) ...members,
      ],
      groups: [
        ...this.groups,
        if (addGroup != null) addGroup,
        if (groups != null) ...groups,
      ],
      profileImage: profileImage ?? this.profileImage,
    );
  }

  /// Create Community entity from a CommunityDto
  factory Community.fromDto(
    CommunityDto dto, {
    Address? address,
    List<CommunityUser>? members,
    List<CommunityGroup>? groups,
    Uint8List? profileImage,
  }) {
    return Community(
      id: dto.id,
      uid: dto.uid,
      name: dto.name,
      description: dto.description,
      address: address,
      events: dto.events.map((e) => e.toEntity()).toList(),
      members: members ?? [],
      groups: groups ?? [],
      profileImage: profileImage,
    );
  }

  /// Convert Community entity to CommunityDto
  CommunityDto toDto({String? profileImageUrl}) {
    return CommunityDto(
      id: id,
      uid: uid,
      name: name,
      description: description,
      events: events.map((e) => e.toDto()).toList(),
      profileImageUrls: profileImageUrl,
      communityGroups: groups.map((e) => e.toDto()).toList(),
    );
  }
}

class CommunityDto {
  final String id;
  final String uid;
  final String name;
  final String description;
  final List<EventDto> events;
  List<CommunityGroupDto>? communityGroups = [];
  String? profileImageUrls;

  CommunityDto({
    required this.id,
    required this.uid,
    required this.name,
    required this.description,
    this.events = const [],
    this.communityGroups,
    this.profileImageUrls,
  });

  /// Construct CommunityDto from a Firestore Map
  static CommunityDto fromMap(Map<String, dynamic> data, String id) {
    final eventsData = data['events'] as List<dynamic>? ?? [];
    return CommunityDto(
      id: id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      events: eventsData
          .map((e) => EventDto.fromMap(e as Map<String, dynamic>, ''))
          .toList(),
      profileImageUrls: data['profileImageUrls'],
    );
  }

  /// Convert CommunityDto to a Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'events': events.map((e) => e.toMap()).toList(),
      if (profileImageUrls != null) 'profileImageUrls': profileImageUrls,
    };
  }

  /// Return a copy of CommunityDto with updated events
  CommunityDto copyWith({List<EventDto>? events, String? profileImageUrls}) {
    return CommunityDto(
      id: id,
      uid: uid,
      name: name,
      description: description,
      events: events ?? this.events,
      profileImageUrls: profileImageUrls ?? this.profileImageUrls,
    );
  }
}
