import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_chat_app/model/message_model.dart';
import 'package:flutter_web_chat_app/utils/app.dart';
import 'package:flutter_web_chat_app/utils/color_res.dart';
import 'package:flutter_web_chat_app/utils/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageMessage extends StatelessWidget {
  final MessageModel message;
  final bool selectionMode;
  final bool sender;

  const ImageMessage(this.message, this.selectionMode, this.sender, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        sender
            ? Container()
            : Container(
                constraints: BoxConstraints(
                  maxWidth: Get.width / 3,
                  minWidth: Get.width / 4,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  message.senderName ?? "Unknown",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle(
                    color: ColorRes.black,
                    weight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
        Container(
          margin: EdgeInsets.only(
            left: sender ? 10 : 0,
            right: sender ? 0 : 10,
            bottom: 10,
          ),
          height: 200.h,
          width: 200.h,
          child: Stack(
            children: <Widget>[
              InkWell(
                onTap: selectionMode
                    ? null
                    : () async {
                        await Get.dialog(
                          Dialog(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: message.content!,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: CachedNetworkImage(
                    imageUrl: message.content!,
                    width: 200.0.h,
                    height: 200.0.h,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return Padding(
                        padding: EdgeInsets.all(80.h),
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      );
                    },
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 10, bottom: 5),
                  child: Text(
                    hFormat(
                        DateTime.fromMillisecondsSinceEpoch(message.sendTime!)),
                    style: AppTextStyle(
                      color: ColorRes.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
