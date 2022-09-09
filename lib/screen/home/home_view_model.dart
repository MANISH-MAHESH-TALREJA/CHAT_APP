import 'package:get/get.dart';
import 'package:flutter_web_chat_app/model/group_model.dart';
import 'package:flutter_web_chat_app/model/user_model.dart';
import 'package:flutter_web_chat_app/screen/person/chat_screen/chat_screen.dart'
    as person;
import 'package:flutter_web_chat_app/screen/group/chat_screen/chat_screen.dart'
    as group;
import 'package:flutter_web_chat_app/screen/group/new_group/select_member/select_members.dart';
import 'package:flutter_web_chat_app/screen/person/settings/setting.dart';
import 'package:flutter_web_chat_app/service/auth_service/auth_service.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/app_state.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {

  void init() async {
    setBusy(true);
    appState.currentUser =
        await userService.getUserModel(firebaseAuth.currentUser!.uid);
    final fcmToken = await messagingService.getFcmToken();
    await userService
        .updateUser(appState.currentUser!.uid!, {"fcmToken": fcmToken});
    setBusy(false);
  }

  gotoSettingPage() {
    Get.to(() => const SettingDetails());
  }

  onUserCardTap(UserModel userModel, String roomId) {
    Get.to(() => person.ChatScreen(userModel, true, roomId));
  }

  void createGroupClick() {
    Get.to(() => const SelectMembers(true));
  }

  void personalChatClick() {
    Get.to(() => const SelectMembers(false));
  }

  void groupClick(GroupModel groupModel) {
    Get.to(() => group.ChatScreen(groupModel, true));
  }
}
