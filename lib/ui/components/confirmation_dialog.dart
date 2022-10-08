import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants.dart';

Future<dynamic> confirmationDialog(title, content, context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: AlertDialog(
          title: Text(title, style: TextStyle(color: textColor),),
          content: Text(content, style: TextStyle(color: textColor)),
          backgroundColor: primaryColorC,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  primary: textColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  )
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Nu"),
            ),
            TextButton(
                style: TextButton.styleFrom(
                  primary: textColor,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Da")
            ),
          ],
        ),
      );
    },
  );
}