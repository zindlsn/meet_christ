import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_christ/models/address.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/user.dart';
import 'package:uuid/uuid.dart';

class Group {
  final String id;
  late Community? community;
  final String name;
  final String description;
  final Address? address;
  final Uint8List? profileImage;
  final List<Event> events;
  final List<UserModel> members = [];
  final List<UserModel> admins = [];
  String? createdBy;
  DateTime? createdOn;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.events,
    this.profileImage,
    this.createdBy,
    this.createdOn,
  });

  Group copyWith({
    String? id,
    Community? community,
    String? name,
    String? description,
    Address? address,
    Uint8List? profileImage,
    List<Event>? events,
    List<UserModel>? members,
    List<UserModel>? admins,
    String? createdBy,
    DateTime? createdOn,
    bool clearProfileImage = false,
  }) {
    return Group(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        address: address ?? this.address,
        events: events ?? List<Event>.from(this.events),
        profileImage: clearProfileImage
            ? null
            : (profileImage ?? this.profileImage),
        createdBy: createdBy ?? this.createdBy,
        createdOn: createdOn ?? this.createdOn,
      )
      ..members.addAll(members ?? this.members)
      ..admins.addAll(admins ?? this.admins)
      ..community = community ?? this.community;
  }

  static Group newNewGroup(String name) {
    return Group(
      id: Uuid().v4(),
      name: name,
      description: "",
      address: null,
      events: [],
    );
  }

  // === Convert from DTO ===
  factory Group.fromDto(
    GroupDto dto, {
    List<Event>? events,
    Uint8List? profileImage,
    List<UserModel>? members,
    List<UserModel>? admins,
  }) {
    return Group(
        id: dto.id,
        name: dto.name,
        description: dto.description,
        address: dto.address,
        events: events ?? [],
        profileImage: profileImage,
        createdBy: dto.createdBy,
        createdOn: dto.createdOn,
      )
      ..members.addAll(members ?? [])
      ..admins.addAll(admins ?? []);
  }

  GroupDto toDto() {
    return GroupDto(
      id: id,
      communityId: community?.id,
      name: name,
      events: [],
      description: description,
      address: address,
      profileImage: profileImage,
      createdBy: createdBy,
      createdOn: createdOn,
    );
  }
}

class GroupDto {
  final String id;
  String? communityId;
  final String name;
  final String description;
  final Address? address;
  final Uint8List? profileImage;
  List<EventDto> events = [];
  String? createdBy;
  DateTime? createdOn;

  GroupDto({
    required this.id,
    required this.communityId,
    required this.name,
    required this.description,
    this.address,
    this.profileImage,
    this.createdBy,
    required this.events,
    this.createdOn,
  });

  static GroupDto newNewGroup(String name) {
    return GroupDto(
      id: Uuid().v4(),
      communityId: null,
      name: name,
      description: "",
      events: [],
      address: null,
    );
  }

  // === Deserialize (from plain Map, e.g. Firestore) ===
  factory GroupDto.fromMap(Map<String, dynamic> map, String id) {
    // Note: profileImage usually not stored as Uint8List directly in Firestore,
    // typically stored as image URL or separately
    return GroupDto(
      id: id,
      events: [],
      communityId: map['communityId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      profileImage:
          null, // Usually images are handled by URLs/storage buckets, so handle separately
      createdBy: map['createdBy'],
      createdOn: map['createdOn'] != null
          ? (map['createdOn'] as Timestamp).toDate()
          : null,
    );
  }

  // === Serialize to Map (for Firestore or JSON storage) ===
  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'name': name,
      'description': description,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdOn != null) 'createdOn': createdOn,
      // profileImage represented differently, usually by URL, handle separately
    };
  }

  Group toEntity({
    required List<EventDto> events,
    Uint8List? profileImage,
    List<UserModel> members = const [],
    List<UserModel> admins = const [],
  }) {
    return Group(
        id: id,
        name: name,
        description: description,
        address: address,
        events: events
            .map((event) => event.toEntity(attendees: [], organizers: []))
            .toList(),
        profileImage: profileImage,
        createdBy: createdBy,
        createdOn: createdOn,
      )
      ..members.addAll(members)
      ..admins.addAll(admins);
  }
}
