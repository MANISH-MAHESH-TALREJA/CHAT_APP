import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_web_chat_app/model/room_model.dart';
import 'package:flutter_web_chat_app/model/send_notification_model.dart';
import 'package:flutter_web_chat_app/model/user_model.dart';
import 'package:flutter_web_chat_app/screen/group/new_group/add_description/add_description.dart';
import 'package:flutter_web_chat_app/screen/home/home_screen.dart';
import 'package:flutter_web_chat_app/service/chat_room_service/chat_room_service.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/app_state.dart';
import 'package:stacked/stacked.dart';

class SelectMembersViewModel extends BaseViewModel {
  List<UserModel>? users = [];
  List<UserModel>? selectedMembers = [];
  bool? isGroup;

  init(bool isGroup) async {
    this.isGroup = isGroup;

    setBusy(true);
    await addUsersInList().then((value) {
      setBusy(false);
    });
  }

  Future<void> addUsersInList() async {
    QuerySnapshot querySnapshot = await userService.getUsers();
    if (querySnapshot.docs.isNotEmpty) {
      List<UserModel> totalUsers =
          querySnapshot.docs.map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>)).toList();

      if (isGroup!) {
        users = totalUsers;
      } else {
        List<RoomModel> filterUserList = [];
        ChatRoomService().getCurrentUserRooms().listen((event) {
          for (var element in event.docs) {
            filterUserList.add(RoomModel.fromMap(element.data() as Map<String, dynamic>));
          }
          for (var element in totalUsers) {
            bool flag = false;
            for (int i = 0; i < filterUserList.length; i++) {
              if (filterUserList[i].membersId!.contains(element.uid)) {
                flag = true;
                break;
              }
            }
            if (flag == false) {
              users!.add(element);
            }
          }
          notifyListeners();
        });
      }
    } else {
      users = [];
    }
  }

  void nextClick() {
    if (selectedMembers!.isEmpty) {
      showErrorToast(AppRes.select_at_least_one_member);
    } else {
      Get.to(() => AddDescription(selectedMembers!));
    }
  }

  bool isSelected(UserModel userModel) {
    return selectedMembers!.contains(userModel);
  }

  void selectUserClick(UserModel user) async {
    if (isGroup!) {
      if (selectedMembers!.contains(user)) {
        selectedMembers!.remove(user);
      } else {
        selectedMembers!.add(user);
      }

      notifyListeners();
    } else {
      setBusy(true);
      String chatId = '';
      if (user.uid.hashCode <= appState.currentUser!.uid.hashCode) {
        chatId = '${user.uid}-${appState.currentUser!.uid}';
      } else {
        chatId = '${appState.currentUser!.uid}-${user.uid}';
      }
      await chatRoomService.createChatRoom({
        "isGroup": false,
        "id": chatId,
        "membersId": [appState.currentUser!.uid, user.uid],
        "lastMessage": "Tap here",
        "${appState.currentUser!.uid}_typing": false,
        "${user.uid}_typing": false,
        "${appState.currentUser!.uid}_newMessage": 0,
        "${user.uid}_newMessage": 1,
        "lastMessageTime": DateTime.now(),
        "blockBy": null,
      });
      SendNotificationModel sendNotificationModel = SendNotificationModel(
        fcmToken: user.fcmToken,
        roomId: chatId,
        id: appState.currentUser!.uid,
        body: "Tap here to chat",
        title: "${appState.currentUser!.name} send you a message",
        isGroup: false,
      );
      // ignore: unnecessary_statements
      (user.fcmToken != appState.currentUser!.fcmToken)
          ? messagingService.sendNotification(sendNotificationModel)
          // ignore: unnecessary_statements
          : null;
      Get.offAll(() => const HomeScreen());
    }
  }
}
