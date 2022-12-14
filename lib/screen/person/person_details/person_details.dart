import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_chat_app/model/user_model.dart';
import 'package:flutter_web_chat_app/screen/person/person_details/person_details_view_model.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/app_state.dart';
import 'package:flutter_web_chat_app/utils/color_res.dart';
import 'package:flutter_web_chat_app/utils/styles.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class PersonDetails extends StatelessWidget {
  final UserModel userModel;
  final String? roomId;

  const PersonDetails(this.userModel, this.roomId, {super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PersonDetailsViewModel>.reactive(
      onModelReady: (model) async {
        model.init(userModel, roomId!);
      },
      builder: (context, model, child) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, __) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.h,
                  floating: false,
                  pinned: true,
                  flexibleSpace: LayoutBuilder(builder:
                      (BuildContext context,
                      BoxConstraints constraints) {
                    model.isExpanded =
                        constraints.biggest.height != 80;
                    return FlexibleSpaceBar(
                      background: FadeInImage(
                        image: NetworkImage(userModel.profilePicture!),
                        fit: BoxFit.cover,
                        placeholder:
                        AssetImage(AssetsRes.profileImage),
                      ),
                    );
                  }),
                  backgroundColor: ColorRes.white,
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
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                children: [
                  verticalSpaceSmall,
                  Container(
                    color: ColorRes.white,
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    child: Text(
                      userModel.name!,
                      style: AppTextStyle(
                        fontSize: 18,
                        color: ColorRes.black,
                      ),
                    ),
                  ),
                  verticalSpaceSmall,
                  Container(
                    color: ColorRes.white,
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Email",
                                style: AppTextStyle(
                                  fontSize: 18,
                                  color: ColorRes.green,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                userModel.email!,
                                style: AppTextStyle(
                                  fontSize: 14,
                                  color: ColorRes.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.message_rounded,
                          color: ColorRes.green,
                          size: 25,
                        )
                      ],
                    ),
                  ),
                  verticalSpaceSmall,
                  roomId != null
                      ? StreamBuilder<DocumentSnapshot>(
                    stream: chatRoomService
                        .streamParticularRoom(roomId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!.get("blockBy") ==
                            null
                            ? InkWell(
                          onTap: () {
                            showConfirmationDialog(
                                model.blockTap,
                                "Are you sure you want to block this use?");
                          },
                          child: Container(
                            color: ColorRes.white,
                            height: 50,
                            width: Get.width,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8),
                            child: Row(
                              children: [
                                horizontalSpaceSmall,
                                const Icon(
                                  Icons.block,
                                  color: ColorRes.red,
                                  size: 22,
                                ),
                                horizontalSpaceMedium,
                                Text(
                                  "Block",
                                  style: AppTextStyle(
                                    fontSize: 18,
                                    color: ColorRes.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            : snapshot.data!.get("blockBy") ==
                            appState.currentUser!.uid
                            ? InkWell(
                          onTap: () {
                            showConfirmationDialog(
                                model.unBlockTap,
                                "Are you sure you want to unblock this use?");
                          },
                          child: Container(
                            color: ColorRes.white,
                            height: 50,
                            width: Get.width,
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8),
                            child: Row(
                              children: [
                                horizontalSpaceSmall,
                                const Icon(
                                  Icons.block,
                                  color: ColorRes.red,
                                  size: 22,
                                ),
                                horizontalSpaceMedium,
                                Text(
                                  "Unblock",
                                  style: AppTextStyle(
                                    fontSize: 18,
                                    color:
                                    ColorRes.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            : Container();
                      } else {
                        return Container();
                      }
                    },
                  )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
      viewModelBuilder: () => PersonDetailsViewModel(),
    );
  }
}
