import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isEmojiVisible;
  final Function onBlurred;
  final ValueChanged<String> onSentMessage;
  final ValueChanged<String> onSentImage;
  final focusNode = FocusNode();

  InputWidget({
    required this.controller,
    required this.isEmojiVisible,
    required this.onSentMessage,
    required this.onSentImage,
    required this.onBlurred,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 0.5)),
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            buildEmoji(),
            buildSelectImage(),
            Expanded(child: buildTextField()),
            buildSend(),
          ],
        ),
      );

  Widget buildEmoji() => Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: IconButton(
          icon: Icon(
            isEmojiVisible
                ? Icons.emoji_emotions_rounded
                : Icons.emoji_emotions_outlined,
          ),
          onPressed: onClickedEmoji,
        ),
      );

  Widget buildSelectImage() => Container(
        margin: const EdgeInsets.only(right: 4),
        child: IconButton(
          icon: Icon(Icons.add_photo_alternate),
          onPressed: () {
            final file = OpenFilePicker()
              ..filterSpecification = {
                //JPG PNG JPEG GIF WEBP TIFF PSD RAW BMP HEIF INDD
                'Images':
                    '*.jpg;*.jpeg;*.png;*.gif;*.webp;*.tiff;*.psd;*.raw;*.bmp;*.heif;*.indd;'
              }
              ..defaultFilterIndex = 0
              ..defaultExtension = 'jpg'
              ..title = 'Select an image';

            final result = file.getFile();
            if (result != null) {
              onSentImage(result.path);
            }
          },
        ),
      );

  Widget buildTextField() => TextField(
        focusNode: focusNode,
        controller: controller,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration.collapsed(
          hintText: 'Type your message...',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      );

  Widget buildSend() => Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            if (controller.text.trim().isEmpty) {
              return;
            }

            onSentMessage(controller.text);
            controller.clear();
          },
        ),
      );

  void onClickedEmoji() async {
    if (isEmojiVisible) {
      focusNode.requestFocus();
    }
    onBlurred();
  }
}
