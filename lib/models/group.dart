import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_christ/models/address.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/user.dart';
import 'package:uuid/uuid.dart';

class CommunityGroup {
  final String id;
  String communityId;
  final String name;
  final String description;
  final Address? address;
  final Uint8List? profileImage;
  final List<Event> events;
  final List<User> members = [];
  final List<User> admins = [];
  String? createdBy;
  DateTime? createdOn;

  CommunityGroup({
    required this.id,
    required this.communityId,
    required this.name,
    required this.description,
    required this.address,
    required this.events,
    this.profileImage,
    this.createdBy,
    this.createdOn,
  });

  static CommunityGroup newNewGroup(String name) {
    return CommunityGroup(
      id: Uuid().v4(),
      communityId: "",
      name: name,
      description: "",
      address: null,
      events: [],
    );
  }

  // === Convert from DTO ===
  factory CommunityGroup.fromDto(
    CommunityGroupDto dto, {
    List<Event>? events,
    Uint8List? profileImage,
    List<User>? members,
    List<User>? admins,
  }) {
    return CommunityGroup(
        id: dto.id,
        communityId: dto.communityId,
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

  // === Convert to DTO ===
  CommunityGroupDto toDto() {
    return CommunityGroupDto(
      id: id,
      communityId: communityId,
      name: name,
      description: description,
      address: address,
      profileImage: profileImage,
      createdBy: createdBy,
      createdOn: createdOn,
    );
  }
}

class CommunityGroupDto {
  final String id;
  String communityId;
  final String name;
  final String description;
  final Address? address;
  final Uint8List? profileImage;
  String? createdBy;
  DateTime? createdOn;

  CommunityGroupDto({
    required this.id,
    required this.communityId,
    required this.name,
    required this.description,
    this.address,
    this.profileImage,
    this.createdBy,
    this.createdOn,
  });

  static CommunityGroupDto newNewGroup(String name) {
    return CommunityGroupDto(
      id: Uuid().v4(),
      communityId: "",
      name: name,
      description: "",
      address: null,
    );
  }

  // === Deserialize (from plain Map, e.g. Firestore) ===
  factory CommunityGroupDto.fromMap(Map<String, dynamic> map, String id) {
    // Note: profileImage usually not stored as Uint8List directly in Firestore,
    // typically stored as image URL or separately
    return CommunityGroupDto(
      id: id,
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
}
