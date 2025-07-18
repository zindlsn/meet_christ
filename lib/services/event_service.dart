import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/repositories/events_repository.dart';
import 'package:meet_christ/repositories/file_repository.dart';

class EventService {
  final DatabaseService2<String, EventDto> adapter;
  final FileRepository fileRepository;
  EventService({required this.adapter, required this.fileRepository});

  Future<Event> create(Event data) async {
    EventDto dto = data.toDto();

    EventDto createdDto = await adapter.create(dto);

    Event createdEntity = Event.fromDto(createdDto);
    return createdEntity;
  }

  Future<List<Event>?> getAllById(String id) async {
    var result = await adapter.getAllById(id);
    if (result != null) {
      return result.map((dto) => Event.fromDto(dto)).toList();
    }
    return null;
  }

  Future<bool> update(Event data) async {
    EventDto dto = data.toDto();
    bool isUpdated = await adapter.update(dto);
    return isUpdated;
  }

  Future<List<Event>> createAll(List<Event> allData) async {
    List<EventDto> createdDto = await adapter.createAll(
      allData.map((data) => data.toDto()).toList(),
    );
    var savedData = createdDto.map((dto) => Event.fromDto(dto)).toList();
    return savedData;
  }

  Future<List<Event>> getAll() async {
    var retrieved = await adapter.getAll();
    return retrieved.map((dto) => Event.fromDto(dto)).toList();
  }

  Future<Event?> getById(String id) async {
    var result = await adapter.getById(id);
    if (result != null) {
      return Event.fromDto(result);
    }
    return null;
  }
}

class EventRepository implements DatabaseService2<String, EventDto> {
  final DatabaseService2<String, EventDto> adapter;

  EventRepository({required this.adapter});

  @override
  Future<EventDto> create(EventDto data) async {
    return await adapter.create(data);
  }

  @override
  Future<List<EventDto>?> getAllById(String id) async {
    return await adapter.getAllById(id);
  }

  @override
  Future<bool> update(EventDto data) async {
    return await adapter.update(data);
  }

  @override
  Future<List<EventDto>> createAll(List<EventDto> allData) async {
    return await adapter.createAll(allData);
  }

  @override
  Future<List<EventDto>> getAll() async {
    return await adapter.getAll();
  }

  @override
  Future<EventDto?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }
}

class EventDataSource implements DatabaseService2<String, EventDto> {
  final CollectionReference col = FirebaseFirestore.instance.collection(
    "events",
  );

  @override
  Future<List<EventDto>> createAll(List<EventDto> allData) {
    // TODO: implement createAll
    throw UnimplementedError();
  }

  @override
  Future<List<EventDto>> getAll() async {
    final QuerySnapshot snapshot = await col.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return EventDto(
        title: '',
        description: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        location: '',
        uid: '',
      );
    }).toList();
  }

  @override
  Future<List<EventDto>?> getAllById(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    List<EventDto> result = [];
    return result;
  }

  @override
  Future<bool> update(EventDto data) {
    // TODO: implement update
    throw UnimplementedError();
  }

  Future<List<EventDto>?> getAllGroupEventsFromMemberId(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    List<EventDto> result = [];
    return result;
  }

  @override
  Future<EventDto?> getById(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    var data = doc.data() as Map<String, dynamic>;
    EventDto.fromMap(data, doc.id);
  }

  @override
  Future<EventDto> create(EventDto data) {
    // TODO: implement create
    throw UnimplementedError();
  }
}

abstract class FirestoreModel<K, T> {
  Map<String, dynamic> toMap();

  T fromMap(Map<String, dynamic> map);

  String get id;
}

class DataServiceGeneric<K, T> implements DatabaseService2<K, T> {
  final DatabaseService2<K, T> adapter;

  DataServiceGeneric({required this.adapter});

  @override
  Future<T> create(T data) async {
    return await adapter.create(data);
  }

  @override
  Future<List<T>?> getAllById(K id) async {
    return await adapter.getAllById(id);
  }

  @override
  Future<bool> update(T data) async {
    return await adapter.update(data);
  }

  @override
  Future<List<T>> createAll(List<T> allData) async {
    return await adapter.createAll(allData);
  }

  @override
  Future<List<T>> getAll() async {
    return await adapter.getAll();
  }

  @override
  Future<T?> getById(K id) {
    // TODO: implement getById
    throw UnimplementedError();
  }
}

class CommunityGroupService
    implements DatabaseService2<String, CommunityGroup> {
  final DatabaseService2<String, CommunityGroup> adapter;

  CommunityGroupService({required this.adapter});

  @override
  Future<CommunityGroup> create(CommunityGroup data) async {
    return await adapter.create(data);
  }

  @override
  Future<List<CommunityGroup>?> getAllById(String id) async {
    return await adapter.getAllById(id);
  }

  @override
  Future<bool> update(CommunityGroup data) async {
    return await adapter.update(data);
  }

  @override
  Future<List<CommunityGroup>> createAll(List<CommunityGroup> allData) async {
    return await adapter.createAll(allData);
  }

  @override
  Future<List<CommunityGroup>> getAll() async {
    return await adapter.getAll();
  }

  @override
  Future<CommunityGroup?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }
}


/*
class FirestoreCommunityGroupAdapterGeneric<K, T extends FirestoreModel>
    implements DatabaseService2<K, T> {
  late CollectionReference col;

  final String collection;

  FirestoreCommunityGroupAdapterGeneric({required this.collection}) {
    col = FirebaseFirestore.instance.collection(collection);
  }
  @override
  Future<T> create(T data) async {
    final docRef = col.doc();
    await docRef.set(data.toMap());
    return data;
  }

  @override
  Future<List<T>> createAll(List<T> allData) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final item in allData) {
      final docRef = col.doc();
      batch.set(docRef, item.toMap());
    }

    await batch.commit();
    return allData;
  }

  @override
  Future<List<T>> getAll() async {
    QuerySnapshot snapshot = await col.get();
    List<T> result =
        snapshot.docs
                .map(
                  (doc) => CommunityGroup.fromMap(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList()
            as List<T>;

    return result;
  }

  @override
  Future<List<T>?> getAllById(K id) async {
    final snapshot = await col.where('id', isEqualTo: id).get();
    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs
            .map(
              (doc) =>
                  CommunityGroup.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList()
        as List<T>;
  }

  @override
  Future<bool> update(T data) async {
    try {
      await col.doc(data.id).update(data.toMap());
      return true;
    } catch (e) {
      print("Firestore update error: $e");
      return false;
    }
  }
}

class FirestoreCommunityGroupAdapter2
    implements DatabaseService2<String, CommunityGroup> {
  final CollectionReference col = FirebaseFirestore.instance.collection(
    "communityGroups",
  );

  @override
  Future<CommunityGroup> create(CommunityGroup data) async {
    final docRef = col.doc();
    final dataWithId = data.copyWith(id: docRef.id);
    await docRef.set(dataWithId.toMap());
    return dataWithId;
  }

  @override
  Future<List<CommunityGroup>> createAll(List<CommunityGroup> allData) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final item in allData) {
      final docRef = col.doc();
      final newItem = item.copyWith(id: docRef.id);
      batch.set(docRef, newItem.toMap());
    }

    await batch.commit();
    return allData;
  }

  @override
  Future<List<CommunityGroup>> getAll() async {
    QuerySnapshot snapshot = await col.get();
    List<CommunityGroup> result =
        snapshot.docs
                .map(
                  (doc) => CommunityGroup.fromMap(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList()
            as List<CommunityGroup>;

    return result;
  }

  @override
  Future<List<CommunityGroup>?> getAllById(String id) async {
    final snapshot = await col.where('id', isEqualTo: id).get();
    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs
            .map(
              (doc) =>
                  CommunityGroup.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList()
        as List<CommunityGroup>;
  }

  @override
  Future<bool> update(CommunityGroup data) async {
    try {
      await col.doc(data.id).update(data.toMap());
      return true;
    } catch (e) {
      print("Firestore update error: $e");
      return false;
    }
  }
}
*/