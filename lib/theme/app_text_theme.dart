import 'package:flutter/material.dart';
import 'package:social_graph/theme/app_color_palette.dart';

class AppTextTheme extends TextTheme {
  const AppTextTheme({
    required this.titleLSemiBold,
    required this.titleLMedium,
    required this.titleLRegular,
    required this.titleMSemiBold,
    required this.titleMMedium,
    required this.titleMRegular,
    required this.titleSSemiBold,
    required this.titleSMedium,
    required this.titleSRegular,
    required this.titleXSSemiBold,
    required this.titleXSMedium,
    required this.titleXSRegular,
    required this.bodyLSemiBold,
    required this.bodyLMedium,
    required this.bodyLRegular,
    required this.bodyXLSemiBold,
    required this.bodyXLMedium,
    required this.bodyXLRegular,
    required this.bodyMSemiBold,
    required this.bodyMMedium,
    required this.bodyMRegular,
    required this.bodySSemiBold,
    required this.bodySMedium,
    required this.bodySRegular,
    required this.captionLSemiBold,
    required this.captionLMedium,
    required this.captionLRegular,
    required this.captionMSemiBold,
    required this.captionMMedium,
    required this.captionMRegular,
    required this.captionSSemiBold,
    required this.captionSMedium,
    required this.captionSRegular,
    required this.codeMonotype,
  }) : super();

  static AppTextTheme get current => AppTextTheme(
    titleLSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 40,
      height: 48 / 40,
      fontWeight: FontWeight.w600,
    ),
    titleLMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 40,
      height: 48 / 40,
      fontWeight: FontWeight.w500,
    ),
    titleLRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 40,
      height: 48 / 40,
      fontWeight: FontWeight.w400,
    ),
    titleMSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w600,
    ),
    titleMMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w500,
    ),
    titleMRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w400,
    ),
    titleSSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w600,
    ),
    titleSMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w500,
    ),
    titleSRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w400,
    ),
    titleXSSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 20,
      height: 30 / 20,
      fontWeight: FontWeight.w600,
    ),
    titleXSMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 20,
      height: 30 / 20,
      fontWeight: FontWeight.w500,
    ),
    titleXSRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 20,
      height: 30 / 20,
      fontWeight: FontWeight.w400,
    ),
    bodyXLSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 18,
      height: 28 / 18,
      fontWeight: FontWeight.w600,
    ),
    bodyXLMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 18,
      height: 28 / 18,
      fontWeight: FontWeight.w500,
    ),
    bodyXLRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 18,
      height: 28 / 18,
      fontWeight: FontWeight.w400,
    ),
    bodyLSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 16,
      height: 21 / 16,
      fontWeight: FontWeight.w600,
    ),
    bodyLMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 16,
      height: 21 / 16,
      fontWeight: FontWeight.w500,
    ),
    bodyLRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 16,
      height: 21 / 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
    ),
    bodyMMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
    ),
    bodyMRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
    ),
    bodySSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w600,
    ),
    bodySMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
    ),
    bodySRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w400,
    ),
    captionLSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
    ),
    captionLMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500,
    ),
    captionLRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
    ),
    captionMSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w600,
    ),
    captionMMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w500,
    ),
    captionMRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w400,
    ),
    captionSSemiBold: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 10,
      height: 13 / 10,
      fontWeight: FontWeight.w600,
    ),
    captionSMedium: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 10,
      height: 13 / 10,
      fontWeight: FontWeight.w500,
    ),
    captionSRegular: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 10,
      height: 13 / 10,
      fontWeight: FontWeight.w400,
    ),
    codeMonotype: TextStyle(
      color: GraphAppColorPalette.white100,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'monospace',
      fontFamilyFallback: const <String>["Courier"],
      backgroundColor: Colors.transparent,
    ),
  );

  //
  //  Title
  //
  final TextStyle titleLSemiBold;
  final TextStyle titleLMedium;
  final TextStyle titleLRegular;

  final TextStyle titleMSemiBold;
  final TextStyle titleMMedium;
  final TextStyle titleMRegular;

  final TextStyle titleSSemiBold;
  final TextStyle titleSMedium;
  final TextStyle titleSRegular;

  final TextStyle titleXSSemiBold;
  final TextStyle titleXSMedium;
  final TextStyle titleXSRegular;

  //
  //  Body
  //
  final TextStyle bodyXLSemiBold;
  final TextStyle bodyXLMedium;
  final TextStyle bodyXLRegular;

  final TextStyle bodyLSemiBold;
  final TextStyle bodyLMedium;
  final TextStyle bodyLRegular;

  final TextStyle bodyMSemiBold;
  final TextStyle bodyMMedium;
  final TextStyle bodyMRegular;

  final TextStyle bodySSemiBold;
  final TextStyle bodySMedium;
  final TextStyle bodySRegular;

  //
  //  Caption
  //
  final TextStyle captionLSemiBold;
  final TextStyle captionLMedium;
  final TextStyle captionLRegular;

  final TextStyle captionMSemiBold;
  final TextStyle captionMMedium;
  final TextStyle captionMRegular;

  final TextStyle captionSSemiBold;
  final TextStyle captionSMedium;
  final TextStyle captionSRegular;

  ///
  ///  Code
  ///
  final TextStyle codeMonotype;
}
