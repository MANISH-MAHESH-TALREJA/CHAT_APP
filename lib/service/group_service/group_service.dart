import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_chat_app/model/group_model.dart';
import 'package:flutter_web_chat_app/utils/exception.dart';
import 'package:flutter_web_chat_app/utils/firestore_collections.dart';

class GroupService {
  CollectionReference group =
      FirebaseFirestore.instance.collection(FireStoreCollections.groups);

  Future<DocumentReference> createGroup(GroupModel groupModel) async {
    try {
      return await group.add(groupModel.toMap());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<void> updateGroupDesc(
      String groupId, String title, String desc) async {
    try {
      await group.doc(groupId).update({
        "name": title,
        "description": desc,
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await group.doc(groupId).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<void> updateGroupMember(String groupId, List<dynamic> members) async {
    try {
      await group.doc(groupId).update({"members": members});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    try {
      await group.doc(groupId).update(data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Stream<QuerySnapshot> streamGroup() {
    try {
      return group.snapshots();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Stream<DocumentSnapshot> getGroupStream(String id) {
    try {
      return group.doc(id).snapshots();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<DocumentSnapshot> getGroup(String id) async {
    try {
      return await group.doc(id).get();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }

  Future<GroupModel> getGroupModel(String id) async {
    try {
      DocumentSnapshot doc = await group.doc(id).get();
      return GroupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      handleException(e);
      rethrow;
    }
  }
}
