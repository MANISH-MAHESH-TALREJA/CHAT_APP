import 'package:get/get.dart';
import 'package:flutter_web_chat_app/screen/login/sign_in_screen.dart';
import 'package:flutter_web_chat_app/screen/register/sign_up_screen.dart';

class LandingViewModel {
  LandingViewModel();

  void registerClick() {
    Get.to(() => const SignUpScreen());
  }

  void loginClick() {
    Get.to(() => const SignInScreen());
  }
}
