import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain_extention/features/conversation/data/datasource/i_firestore_datasource.dart';
import 'package:domain_extention/features/conversation/domain/entity/conversation_message.dart';

class FirestoreDatasource implements IFirestoreDatasource {
  FirestoreDatasource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _messages({
    required String userId,
    required String characterId,
  }) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('characters')
        .doc(characterId)
        .collection('messages');
  }

  DocumentReference<Map<String, dynamic>> _character({
    required String userId,
    required String characterId,
  }) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('characters')
        .doc(characterId);
  }

  @override
  Future<List<ConversationMessage>> loadMessages({
    required String userId,
    required String characterId,
  }) async {
    final snapshot =
        await _messages(
              userId: userId,
              characterId: characterId,
            )
            .orderBy('createdAt', descending: true)
            .limit(60)
            .get()
            .timeout(const Duration(seconds: 10));

    return [
      for (final doc in snapshot.docs.reversed) ?_parse(doc),
    ];
  }

  @override
  Future<void> appendMessage({
    required String userId,
    required String characterId,
    required ConversationMessage message,
  }) async {
    final createdAt = Timestamp.fromDate(message.createdAt.toUtc());
    final batch = _db.batch();
    final messages = _messages(userId: userId, characterId: characterId);
    final doc = message.id == null || message.id!.isEmpty
        ? messages.doc()
        : messages.doc(message.id);
    batch.set(doc, {
      'role': message.role,
      'text': message.text,
      'createdAt': createdAt,
    });
    batch.set(_character(userId: userId, characterId: characterId), {
      'updatedAt': createdAt,
      'characterId': characterId,
    }, SetOptions(merge: true));
    // Firestore queues writes offline and completes this future when the
    // server acknowledges them. The caller starts the save in the background.
    await batch.commit();
  }

  ConversationMessage? _parse(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final role = data['role'];
    final text = data['text'];
    if (role is! String || text is! String) {
      return null;
    }
    if (role != 'user' && role != 'assistant') {
      return null;
    }
    if (text.trim().isEmpty) {
      return null;
    }
    final rawCreatedAt = data['createdAt'];
    final createdAt = switch (rawCreatedAt) {
      Timestamp value => value.toDate().toLocal(),
      DateTime value => value.toLocal(),
      String value => DateTime.tryParse(value)?.toLocal(),
      _ => null,
    };
    return ConversationMessage(
      id: doc.id,
      role: role,
      text: text,
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
