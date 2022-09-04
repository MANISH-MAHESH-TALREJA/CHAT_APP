import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_chat_app/screen/forgot_password/forgot_password_view_model.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/color_res.dart';
import 'package:flutter_web_chat_app/utils/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_chat_app/utils/styles.dart';
import 'package:stacked/stacked.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.background,
      body: ViewModelBuilder<ForgotPasswordViewModel>.reactive(
        onModelReady: (model) async {
          model.init();
        },
        viewModelBuilder: () => ForgotPasswordViewModel(),
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
                            AppRes.forgot_password,
                            style: AppTextStyle(
                              fontSize: 32,
                              color: ColorRes.green,
                              weight: FontWeight.bold,
                            ),
                          ),
                          verticalSpaceMassive,
                          TextFieldWidget(
                            controller: model.emailController,
                            title: AppRes.email,
                            validation: model.emailValidation,
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
                                    title: AppRes.submit,
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
