import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_chat_app/screen/register/sign_up_view_model.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/color_res.dart';
import 'package:flutter_web_chat_app/utils/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_chat_app/utils/styles.dart';
import 'package:stacked/stacked.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.background,
      body: ViewModelBuilder<SignUpViewModel>.reactive(
        onModelReady: (model) async {
          model.init();
        },
        viewModelBuilder: () => SignUpViewModel(),
        builder: (context, model, child) {
          return SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Form(
                    key: model.formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            AppRes.sign_up,
                            style: AppTextStyle(
                              fontSize: 32,
                              color: ColorRes.green,
                              weight: FontWeight.bold,
                            ),
                          ),
                          verticalSpaceMassive,
                          TextFieldWidget(
                            controller: model.nameController,
                            title: AppRes.full_name,
                            validation: model.nameValidation,
                            readOnly: model.isBusy,
                          ),
                          TextFieldWidget(
                            controller: model.emailController,
                            title: AppRes.email,
                            validation: model.emailValidation,
                            readOnly: model.isBusy,
                          ),
                          TextFieldWidget(
                            controller: model.passwordController,
                            title: AppRes.password,
                            validation: model.passwordValidation,
                            obs: true,
                            readOnly: model.isBusy,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: model.isBusy
                                ? Container(
                                    decoration: const BoxDecoration(
                                      color: ColorRes.green,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Center(
                                      child: Platform.isMacOS
                                          ? const CupertinoActivityIndicator()
                                          : const CircularProgressIndicator(),
                                    ),
                                  )
                                : EvolveButton(
                                    onTap: model.submitButtonTap,
                                    title: AppRes.sign_up,
                                  ),
                          ),
                          InkWell(
                            onTap: model.signInClick,
                            child: Text(
                              AppRes.sign_in,
                              style: AppTextStyle(
                                fontSize: 16,
                                color: ColorRes.green,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                    size: 30.h,
                    color: ColorRes.green,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
