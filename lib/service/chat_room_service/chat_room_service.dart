import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_chat_app/model/message_model.dart';
import 'package:flutter_web_chat_app/utils/app_state.dart';
import 'package:flutter_web_chat_app/utils/exception.dart';
import 'package:flutter_web_chat_app/utils/firestore_collections.dart';

class ChatRoomService {
  CollectionReference chatRoom =
      FirebaseFirestore.instance.collection(FireStoreCollections.chatRoom);

  Future<void> createChatRoom(Map<String, dynamic> data) async {
    try {
      await chatRoom.doc(data['id']).set(data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<void> deleteChatRoom(String chatId) async {
    try {
      await chatRoom.doc(chatId).delete();
      await chatRoom.doc(chatId).collection(chatId).get().then((value) {
        for (DocumentSnapshot ds in value.docs) {
          ds.reference.delete();
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<void> updateGroupMembers(String chatId, List<String> members) async {
    try {
      await chatRoom.doc(chatId).update({"membersId": members});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<void> updateGroupNewMessage(String chatId, String userId) async {
    try {
      await chatRoom.doc(chatId).update({"${userId}_newMessage": 1});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Stream<QuerySnapshot> streamRooms() {
    try {
      return chatRoom
          .where("membersId", arrayContains: appState.currentUser!.uid)
          .orderBy("lastMessageTime", descending: true)
          .snapshots();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<QuerySnapshot> getAllRooms() async {
    try {
      return await chatRoom
          .where("membersId", arrayContains: appState.currentUser!.uid)
          .orderBy("lastMessageTime", descending: true)
          .get();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getCurrentUserRooms() {
    try {
      return chatRoom
          .where("isGroup", isEqualTo: false)
          .where("membersId", arrayContains: appState.currentUser!.uid)
          .snapshots();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Stream<DocumentSnapshot> streamParticularRoom(String id) {
    try {
      return chatRoom.doc(id).snapshots();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<DocumentSnapshot> getParticularRoom(String id) {
    try {
      return chatRoom.doc(id).get();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Query getMessages(
    String chatId,
    int limit,
  ) {
    return chatRoom
        .doc(chatId)
        .collection(chatId)
        .orderBy('sendTime', descending: true);
  }

  Future<void> sendMessage(MessageModel message, String roomId) async {
    await chatRoom.doc(roomId).collection(roomId).add(message.toMap());
  }

  Future<void> updateLastMessage(
      Map<String, dynamic> data, String roomId) async {
    await chatRoom.doc(roomId).get().then((value) {
      if (value.exists) {
        value.reference.update(data);
      }
    });
  }

  Future<void> deleteMessage(String messageId, String roomId) async {
    await chatRoom.doc(roomId).collection(roomId).doc(messageId).delete();
  }

  Future<DocumentSnapshot> isRoomAvailable(String roomId) async {
    return await chatRoom.doc(roomId).get();
  }
}
