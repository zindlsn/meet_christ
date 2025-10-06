import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/models/user.dart';
import 'package:uuid/uuid.dart';

class GroupService {
  final IGroupRepository _repository;

  GroupService(this._repository);

  Future<Group> getGroup(String id) => _repository.getGroup(id);

  Future<List<Group>> getCommunityGroups(String communityId) =>
      _repository.getGroupsByCommunity(communityId);

  Future<List<Group>> getUserGroups(String userId) =>
      _repository.getUserGroups(userId);

  Future<String> createGroup({required Group group}) async {
    final id = await _repository.createGroup(group);

    if (group.profileImage != null) {
      await _repository.uploadGroupImage(id, group.profileImage!);
      await _repository.updateGroup(
        group.copyWith(id: id, profileImage: group.profileImage),
      );
    }

    return id;
  }

  Stream<List<Group>> watchCommunityGroups(String communityId) =>
      _repository.watchCommunityGroups(communityId);

  Future<void> addMember(String groupId, String userId) =>
      _repository.addGroupMember(groupId, userId);

  Future<void> removeMember(String groupId, String userId) =>
      _repository.removeGroupMember(groupId, userId);

  Future<void> promoteToAdmin(String groupId, String userId) =>
      _repository.addGroupAdmin(groupId, userId);

  // Additional business logic methods
  Future<void> createGroupWithMembers({required Group group}) async {
    await Future.wait(
      group.members.map((user) => addMember(group.id, user.id)),
    );
  }
}

class FirestoreGroupRepository implements IGroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  FirestoreGroupRepository();

  @override
  Future<Group> getGroup(String id) async {
    final doc = await _firestore.collection('groups').doc(id).get();
    if (!doc.exists) throw Exception('Group not found');

    // Get members and admins
    final members = await _getUsersFromList(doc.data()?['memberIds'] ?? []);
    final admins = await _getUsersFromList(doc.data()?['adminIds'] ?? []);

    return Group.fromDto(
      GroupDto.fromMap(doc.data()!, doc.id),
      members: members,
      admins: admins,
    );
  }

  @override
  Future<List<Group>> getGroupsByCommunity(String communityId) async {
    final snapshot = await _firestore
        .collection('groups')
        .where('communityId', isEqualTo: communityId)
        .get();

    return await _mapGroupDocs(snapshot.docs);
  }

  @override
  Future<List<Group>> getUserGroups(String userId) async {
    final snapshot = await _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .get();

    return await _mapGroupDocs(snapshot.docs);
  }

  @override
  Future<String> createGroup(Group group) async {
    final id = _uuid.v4();
    final dto = group.toDto();

    await _firestore.collection('groups').doc(id).set({
      ...dto.toMap(),
      'memberIds': group.members.map((u) => u.id).toList(),
      'adminIds': group.admins.map((u) => u.id).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return id;
  }

  @override
  Future<void> updateGroup(Group group) async {
    final dto = group.toDto();
    await _firestore.collection('groups').doc(group.id).update({
      ...dto.toMap(),
      'memberIds': group.members.map((u) => u.id).toList(),
      'adminIds': group.admins.map((u) => u.id).toList(),
    });
  }

  @override
  Future<void> deleteGroup(String id) async {
    await _firestore.collection('groups').doc(id).delete();
  }

  @override
  Future<String> uploadGroupImage(String groupId, Uint8List image) async {
    final ref = _storage.ref('group_images/$groupId');
    await ref.putData(image);
    return await ref.getDownloadURL();
  }

  @override
  Stream<List<Group>> watchCommunityGroups(String communityId) {
    return _firestore
        .collection('groups')
        .where('communityId', isEqualTo: communityId)
        .snapshots()
        .asyncMap((snapshot) => _mapGroupDocs(snapshot.docs));
  }

  @override
  Future<void> addGroupMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> removeGroupMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> addGroupAdmin(String groupId, String userId) async {
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(
        _firestore.collection('groups').doc(groupId),
      );

      // Add to admins and members if not already present
      transaction.update(doc.reference, {
        'adminIds': FieldValue.arrayUnion([userId]),
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    });
  }

  // Helper methods
  Future<List<Group>> _mapGroupDocs(List<DocumentSnapshot> docs) async {
    final groups = <Group>[];

    for (final doc in docs) {
      final members = await _getUsersFromList(doc['memberIds'] ?? []);
      final admins = await _getUsersFromList(doc['adminIds'] ?? []);

      groups.add(
        Group.fromDto(
          GroupDto.fromMap(doc.data()! as Map<String, dynamic>, doc.id),
          members: members,
          admins: admins,
        ),
      );
    }

    return groups;
  }

  Future<List<UserModel>> _getUsersFromList(List<dynamic> userIds) async {
    // Implement your user fetching logic here
    // Example: return await userRepository.getUsersByIds(List<String>.from(userIds));
    return []; // Placeholder
  }
}

abstract class IGroupRepository {
  Future<Group> getGroup(String id);
  Future<List<Group>> getGroupsByCommunity(String communityId);
  Future<List<Group>> getUserGroups(String userId);
  Future<String> createGroup(Group group);
  Future<void> updateGroup(Group group);
  Future<void> deleteGroup(String id);
  Future<String> uploadGroupImage(String groupId, Uint8List image);
  Stream<List<Group>> watchCommunityGroups(String communityId);
  Future<void> addGroupMember(String groupId, String userId);
  Future<void> removeGroupMember(String groupId, String userId);
  Future<void> addGroupAdmin(String groupId, String userId);
}
