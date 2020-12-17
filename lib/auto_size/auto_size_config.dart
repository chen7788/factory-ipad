import 'package:flutter/cupertino.dart';

/// Auto Size Config.
class AutoSizeConfig {
  ///  width 默认设计稿  尺寸dp or pt。
  static double _designWidth = 1920;
  static double _designHeight = 1200;

  static Orientation _orientation = Orientation.landscape;

  static double get designWidth => _designWidth;

  static double get designHeight => _designHeight;

  static Orientation get designOrientation => _orientation;

  /// 配置设计稿尺寸 屏幕 宽，高.
  /// Configuration design draft size  screen width, height, density.
  static void setDesignWH(
      {double width, double height, Orientation orientation}) {
    _designWidth = width ?? _designWidth;
    _designHeight = height ?? _designHeight;
    _orientation = orientation ?? _orientation;
  }
}
