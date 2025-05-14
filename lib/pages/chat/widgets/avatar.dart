import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/routers.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

Widget buildAvatar(types.User author) {
  return GestureDetector(
    onTap: () {
      if (author.imageUrl != null && author.imageUrl!.startsWith("http")) {
        Get.toNamed(Routers.AIConfigPageUrl);
      }
    },
    child: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipOval(
        child: CircleAvatar(
          child: author.imageUrl == null || !author.imageUrl!.startsWith("http")
              ? Image.asset(author.imageUrl!)
              : Image.network(author.imageUrl!),
        ),
      ),
    ),
  );
}
