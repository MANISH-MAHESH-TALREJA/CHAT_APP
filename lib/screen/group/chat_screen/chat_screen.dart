import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:flutter_web_chat_app/model/group_model.dart';
import 'package:flutter_web_chat_app/model/message_model.dart';
import 'package:flutter_web_chat_app/screen/group/chat_screen/chat_screen_view_model.dart';
import 'package:flutter_web_chat_app/screen/group/chat_screen/widget/input_bottom_bar.dart';
import 'package:flutter_web_chat_app/screen/group/chat_screen/widget/header.dart';
import 'package:flutter_web_chat_app/screen/group/chat_screen/widget/message_view/message_view.dart';
import 'package:flutter_web_chat_app/screen/group/chat_screen/widget/scroll_down_button.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/app_state.dart';
import 'package:flutter_web_chat_app/utils/color_res.dart';
import 'package:flutter_web_chat_app/utils/common_widgets.dart';
import 'package:stacked/stacked.dart';

AppLifecycleState? appLifeState;

class ChatScreen extends StatefulWidget {
  final GroupModel? groupModel;
  final bool? isFromHome;

  const ChatScreen(this.groupModel, this.isFromHome, {super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

bool appIsBG = false;

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appLifeState = state;
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (kDebugMode) {
        print(widget.groupModel!.groupId);
      }
      appIsBG = true;
      if (widget.groupModel!.groupId != null) {
        chatRoomService.updateLastMessage(
          {"typing_id": null},
          widget.groupModel!.groupId!,
        );
      }
    }
    chatRoomService.updateLastMessage(
      {"${appState.currentUser!.uid}_newMessage": 0},
      widget.groupModel!.groupId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatScreenViewModel>.reactive(
      onModelReady: (model) async {
        model.init(widget.groupModel!, widget.isFromHome!);
      },
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            if (model.isForwardMode || model.isDeleteMode) {
              model.clearClick();
            } else {
              model.clearNewMessage();
              model.onBack();
            }
            return false;
          },
          child: GestureDetector(
            onTap: () {
              if (model.isAttachment) {
                model.isAttachment = false;
                model.notifyListeners();
              }
            },
            child: StreamBuilder<DocumentSnapshot>(
              stream: groupService.getGroupStream(
                  // ignore: unnecessary_null_comparison
                  (widget.groupModel!.groupId! != null ||
                      widget.groupModel!.groupId! != "")
                      ? widget.groupModel!.groupId!
                      : appState.currentActiveRoom!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  model.clearNewMessage();
                  if (snapshot.data!.exists) {
                    GroupModel groupData = GroupModel.fromMap(
                      snapshot.data!.data() as Map<String, dynamic>,
                      snapshot.data!.id,
                    );
                    if (groupData.members!
                        .where((element) =>
                    element.memberId ==
                        appState.currentUser!.uid)
                        .isEmpty) {
                      Future.delayed(const Duration(seconds: 2))
                          .then((value) => model.onBack());
                      return Scaffold(
                        backgroundColor: ColorRes.background,
                        body: const Center(
                          child: Text(
                              "You have been removed from this group"),
                        ),
                        appBar: AppBar(
                          leading: Container(
                            margin:
                            const EdgeInsets.symmetric(horizontal: 13),
                            child: InkWell(
                              onTap: model.onBack,
                              child: Icon(
                                Platform.isIOS
                                    ? Icons.arrow_back_ios
                                    : Icons.arrow_back,
                                color: ColorRes.dimGray,
                              ),
                            ),
                          ),
                          backgroundColor: ColorRes.white,
                          elevation: 0,
                        ),
                      );
                    } else {
                      model.updateGroupInfo(groupData);
                      return Scaffold(
                        backgroundColor: ColorRes.background,
                        appBar: PreferredSize(
                          preferredSize: Size(Get.width, 50),
                          child: Header(
                            groupModel: groupData,
                            onBack: model.onBack,
                            headerClick: model.headerClick,
                            isDeleteMode: model.isDeleteMode,
                            isForwardMode: model.isForwardMode,
                            deleteClick: model.deleteClickMessages,
                            forwardClick: model.forwardClickMessages,
                            clearClick: model.clearClick,
                          ),
                        ),
                        body: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            AbsorbPointer(
                              absorbing: model.isAttachment,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: PaginateFirestore(
                                      padding: const EdgeInsets.all(10.0),
                                      query:
                                      chatRoomService.getMessages(
                                          model
                                              .groupModel!.groupId!,
                                          model.chatLimit),
                                      itemBuilderType:
                                      PaginateBuilderType
                                          .listView,
                                      isLive: true,
                                      itemsPerPage: 10,
                                      scrollController:
                                      model.listScrollController,
                                      itemBuilder: (context,
                                          documentSnapshot, index) {
                                        if (!model.listMessage
                                            .contains(
                                            documentSnapshot[index])) {
                                          model.listMessage
                                              .add(documentSnapshot[index]);
                                        }
                                        return MessageView(
                                          index,
                                          MessageModel.fromMap(
                                            documentSnapshot[index].data() as Map<String, dynamic>,
                                            documentSnapshot[index].id,
                                          ),
                                          model.downloadDocument,
                                          model.selectedMessages,
                                          model.onTapPressMessage,
                                          model.onLongPressMessage,
                                          model.isDeleteMode,
                                          model.isForwardMode,
                                        );
                                      },
                                      onEmpty: const Center(
                                        child: Text("Send message"),
                                      ),
                                      reverse: true,
                                    ),
                                  ),
                                  InputBottomBar(
                                    msgController: model.controller,
                                    onTextFieldChange:
                                    model.onTextFieldChange,
                                    onCameraTap: model.onCameraTap,
                                    onSend: model.onSend,
                                    message: model.mMessage,
                                    focusNode: model.focusNode,
                                    onAttachment:
                                    model.onAttachmentTap,
                                    isTyping: model.isTyping,
                                    clearReply: model.clearReply,
                                  ),
                                ],
                              ),
                            ),
                            SafeArea(
                              child: AnimatedOpacity(
                                opacity: model.isAttachment ? 1 : 0,
                                duration: const Duration(milliseconds: 500),
                                child: model.isAttachment
                                    ? AttachmentView(
                                  onGalleryTap:
                                  model.onGalleryTap,
                                  onAudioTap: model.onAudioTap,
                                  onVideoTap: model.onVideoTap,
                                  onDocumentTap:
                                  model.onDocumentTap,
                                )
                                    : Container(),
                              ),
                            ),
                            model.showScrollDownBtn
                                ? Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 60),
                                child: ScrollDownButton(
                                  onTap: model.onScrollDownTap,
                                ),
                              ),
                            )
                                : Container(),
                            model.uploadingMedia
                                ? Container(
                              height: Get.height,
                              width: Get.width,
                              color: ColorRes.dimGray
                                  .withOpacity(0.3),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Platform.isIOS
                                      ? const CupertinoActivityIndicator()
                                      : const CircularProgressIndicator(),
                                  verticalSpaceSmall,
                                  const Text("Uploading media")
                                ],
                              ),
                            )
                                : Container()
                          ],
                        ),
                      );
                    }
                  } else {
                    Future.delayed(const Duration(seconds: 2))
                        .then((value) => model.onBack());
                    return Scaffold(
                      backgroundColor: ColorRes.background,
                      body: const Center(
                        child: Text("This group is deleted"),
                      ),
                      appBar: AppBar(
                        leading: Container(
                          margin:
                          const EdgeInsets.symmetric(horizontal: 13),
                          child: InkWell(
                            onTap: model.onBack,
                            child: Icon(
                              Platform.isIOS
                                  ? Icons.arrow_back_ios
                                  : Icons.arrow_back,
                              color: ColorRes.dimGray,
                            ),
                          ),
                        ),
                        backgroundColor: ColorRes.white,
                        elevation: 0,
                      ),
                    );
                  }
                } else {
                  return Scaffold(
                    backgroundColor: ColorRes.background,
                    appBar: PreferredSize(
                      preferredSize: Size(Get.width, 50),
                      child: Header(
                        groupModel: widget.groupModel!,
                        onBack: model.onBack,
                        headerClick: model.headerClick,
                        isDeleteMode: model.isDeleteMode,
                        isForwardMode: model.isForwardMode,
                        deleteClick: model.deleteClickMessages,
                        forwardClick: model.forwardClickMessages,
                        clearClick: model.clearClick,
                      ),
                    ),
                    body: Center(
                      child: Platform.isIOS
                          ? const CupertinoActivityIndicator()
                          : const CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
      viewModelBuilder: () => ChatScreenViewModel(),
    );
  }
}
