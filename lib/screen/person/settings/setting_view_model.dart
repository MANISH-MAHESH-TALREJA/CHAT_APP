import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_web_chat_app/model/group_model.dart';
import 'package:flutter_web_chat_app/screen/landing/landing_screen.dart';
import 'package:flutter_web_chat_app/screen/person/settings/widget/dialog_view.dart';
import 'package:flutter_web_chat_app/service/auth_service/auth_service.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/app_state.dart';
import 'package:flutter_web_chat_app/utils/exception.dart';
import 'package:stacked/stacked.dart';

class SettingViewModel extends BaseViewModel {
  bool isExpanded = true;

  GroupModel? groupModel;

  final ImagePicker picker = ImagePicker();

  bool imageLoader = false;

  init() async {
    appState.currentUser =
        await userService.getUserModel(firebaseAuth.currentUser!.uid);
  }

  void updateNameTap(String name) async {
    appState.currentUser!.name = name;
    userService.updateUser(
      appState.currentUser!.uid!,
      {"name": name},
    );
    notifyListeners();
  }

  void editTap() {
    Get.dialog(
      Dialog(
        child: PersonInfoDialog(
          appState.currentUser!.name!,
          updateNameTap,
        ),
      ),
    );
  }

  logoutTap() async {
    try {
      showConfirmationDialog(
        () async {
          await authService.logout();
          Get.offAll(() => LandingScreen());
        },
        "Are you sure you want logout?",
      );
    } catch (e)
    {
      debugPrint(e.toString());
    }
  }

  void imageClick() async {
    try {
      // ignore: deprecated_member_use
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageLoader = true;
        notifyListeners();
        String? imageUrl =
            await storageService.uploadGroupIcon(File(pickedFile.path));
        if (imageUrl != null) {
          appState.currentUser!.profilePicture = imageUrl;
          userService.updateUser(
            appState.currentUser!.uid!,
            {"profilePicture": imageUrl},
          );
        }
        imageLoader = false;
        notifyListeners();
      }
    } catch (e) {
      handleException(e);
    }
  }
}
