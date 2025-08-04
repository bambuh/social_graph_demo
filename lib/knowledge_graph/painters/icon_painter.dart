import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_graph/gen/assets.gen.dart';

class IconPainter {
  static PictureInfo? userPictureInfo;
  static PictureInfo? groupPictureInfo;
  static PictureInfo? eventPictureInfo;
  static PictureInfo? placePictureInfo;

  static bool get isInitialized =>
      groupPictureInfo != null &&
      eventPictureInfo != null &&
      placePictureInfo != null;

  static Future<void> init(BuildContext context) async {
    final assetBundle = DefaultAssetBundle.of(context);
    final String placeSvgString = await assetBundle.loadString(
      Assets.mapPin.path,
    );
    placePictureInfo = await vg.loadPicture(
      SvgStringLoader(placeSvgString),
      null,
    );
    final String eventSvgString = await assetBundle.loadString(
      Assets.calendarEvent.path,
    );
    eventPictureInfo = await vg.loadPicture(
      SvgStringLoader(eventSvgString),
      null,
    );
    final String groupSvgString = await assetBundle.loadString(
      Assets.userGroup.path,
    );
    groupPictureInfo = await vg.loadPicture(
      SvgStringLoader(groupSvgString),
      null,
    );
    final String userSvgString = await assetBundle.loadString(Assets.user.path);
    userPictureInfo = await vg.loadPicture(
      SvgStringLoader(userSvgString),
      null,
    );
  }

  static void dispose() {
    groupPictureInfo?.picture.dispose();
    eventPictureInfo?.picture.dispose();
    placePictureInfo?.picture.dispose();
    userPictureInfo?.picture.dispose();
    groupPictureInfo = null;
    eventPictureInfo = null;
    placePictureInfo = null;
    userPictureInfo = null;
  }
}
