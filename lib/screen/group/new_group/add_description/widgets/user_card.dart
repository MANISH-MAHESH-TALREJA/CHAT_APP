import 'package:flutter/material.dart';
import 'package:flutter_web_chat_app/model/user_model.dart';
import 'package:flutter_web_chat_app/utils/color_res.dart';
import 'package:flutter_web_chat_app/utils/styles.dart';

class UserCard extends StatelessWidget {
  final UserModel? user;

  const UserCard({super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(bottom: 3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.network(
                user!.profilePicture!,
                height: 40,
                width: 40,
              ),
            ),
          ),
          Text(
            user!.name!.split(" ").first,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle(
              color: ColorRes.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
