import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_chat_app/model/group_model.dart';
import 'package:flutter_web_chat_app/screen/group/group_details/add_member/add_members_view_model.dart';
import 'package:flutter_web_chat_app/screen/group/group_details/add_member/widgets/user_card.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/color_res.dart';
import 'package:flutter_web_chat_app/utils/styles.dart';
import 'package:stacked/stacked.dart';

class AddMembers extends StatelessWidget {
  final GroupModel groupModel;

  const AddMembers(this.groupModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddMembersViewModel>.reactive(
      onModelReady: (model) async {
        model.init(groupModel);
      },
      viewModelBuilder: () => AddMembersViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorRes.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Platform.isIOS
                    ? Icons.arrow_back_ios_rounded
                    : Icons.arrow_back_rounded,
                color: ColorRes.dimGray,
              ),
              onPressed: () => Get.back(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppRes.newGroup,
                  style: AppTextStyle(
                    color: ColorRes.dimGray,
                    weight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  AppRes.add_participants,
                  style: AppTextStyle(
                    color: ColorRes.dimGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          body: model.isBusy
              ? Center(
                  child: Platform.isIOS
                      ? const CupertinoActivityIndicator()
                      : const CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: model.users!.length,
                  itemBuilder: (context, index) {
                    return UserCard(
                      user: model.users![index],
                      onTap: model.selectUserClick,
                      isSelected: model.isSelected(model.users![index]),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: model.nextClick,
            backgroundColor: ColorRes.green,
            child: const Icon(
              Icons.navigate_next_rounded,
              color: ColorRes.white,
            ),
          ),
        );
      },
    );
  }
}
