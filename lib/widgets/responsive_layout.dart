// 响应式布局组件
// 支持手机、平板、桌面多种屏幕尺寸

import 'package:flutter/material.dart';

/// 设备类型
enum DeviceType {
  /// 手机（< 600px）
  mobile,

  /// 平板（600px - 1024px）
  tablet,

  /// 桌面（> 1024px）
  desktop,
}

/// 屏幕方向
enum ScreenOrientation {
  portrait,
  landscape,
}

/// 响应式断点
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// 内容最大宽度
  static const double maxContentWidth = 1200;

  /// 手机端边距
  static const double mobilePadding = 16;

  /// 平板端边距
  static const double tabletPadding = 24;

  /// 桌面端边距
  static const double desktopPadding = 32;
}

/// 响应式布局工具类
class ResponsiveUtils {
  /// 获取设备类型
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < ResponsiveBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// 获取屏幕方向
  static ScreenOrientation getOrientation(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? ScreenOrientation.portrait
        : ScreenOrientation.landscape;
  }

  /// 是否为手机
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 是否为平板
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 是否为桌面
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// 是否为横屏
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == ScreenOrientation.landscape;
  }

  /// 获取响应式边距
  static double getPadding(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return ResponsiveBreakpoints.mobilePadding;
      case DeviceType.tablet:
        return ResponsiveBreakpoints.tabletPadding;
      case DeviceType.desktop:
        return ResponsiveBreakpoints.desktopPadding;
    }
  }

  /// 获取响应式列数
  static int getColumns(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return isLandscape(context) ? 2 : 1;
      case DeviceType.tablet:
        return isLandscape(context) ? 3 : 2;
      case DeviceType.desktop:
        return 4;
    }
  }

  /// 获取内容最大宽度
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > ResponsiveBreakpoints.maxContentWidth
        ? ResponsiveBreakpoints.maxContentWidth
        : screenWidth;
  }
}

/// 响应式构建器
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType,
      ScreenOrientation orientation) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(context);
        final orientation = ResponsiveUtils.getOrientation(context);
        return builder(context, deviceType, orientation);
      },
    );
  }
}

/// 响应式布局（根据设备类型显示不同布局）
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, orientation) {
        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// 响应式行/列布局
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, orientation) {
        // 手机竖屏用列，其他情况用行
        final useColumn = deviceType == DeviceType.mobile &&
            orientation == ScreenOrientation.portrait;

        if (useColumn) {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: _buildSpacedChildren(useColumn),
          );
        } else {
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: _buildSpacedChildren(useColumn),
          );
        }
      },
    );
  }

  List<Widget> _buildSpacedChildren(bool isColumn) {
    final spacer =
        isColumn ? SizedBox(height: spacing) : SizedBox(width: spacing);

    final List<Widget> spacedChildren = [];
    for (var i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(spacer);
      }
    }
    return spacedChildren;
  }
}

/// 响应式网格
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? columns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final cols = columns ?? ResponsiveUtils.getColumns(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// 响应式容器（限制最大宽度并居中）
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool addPadding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.addPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = addPadding
        ? EdgeInsets.all(ResponsiveUtils.getPadding(context))
        : EdgeInsets.zero;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveBreakpoints.maxContentWidth,
        ),
        child: Padding(
          padding: padding ?? responsivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// 主从布局（Master-Detail）
class MasterDetailLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final double masterWidth;
  final double dividerWidth;
  final Color? dividerColor;

  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.masterWidth = 320,
    this.dividerWidth = 1,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, orientation) {
        // 手机端只显示 master，通过导航显示 detail
        if (deviceType == DeviceType.mobile &&
            orientation == ScreenOrientation.portrait) {
          return master;
        }

        // 平板/桌面端显示分栏布局
        return Row(
          children: [
            SizedBox(
              width: masterWidth,
              child: master,
            ),
            if (detail != null) ...[
              VerticalDivider(
                width: dividerWidth,
                color: dividerColor ?? Colors.white24,
              ),
              Expanded(child: detail!),
            ],
          ],
        );
      },
    );
  }
}

/// 翻译界面的平板横屏布局
class TranslationTabletLayout extends StatelessWidget {
  final Widget sourceInput;
  final Widget targetOutput;
  final Widget? actionBar;
  final double dividerWidth;

  const TranslationTabletLayout({
    super.key,
    required this.sourceInput,
    required this.targetOutput,
    this.actionBar,
    this.dividerWidth = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (actionBar != null) actionBar!,
        Expanded(
          child: Row(
            children: [
              Expanded(child: sourceInput),
              SizedBox(width: dividerWidth),
              Expanded(child: targetOutput),
            ],
          ),
        ),
      ],
    );
  }
}

/// 响应式文本大小
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// 手机端字体大小
  final double mobileFontSize;

  /// 平板端字体大小
  final double tabletFontSize;

  /// 桌面端字体大小
  final double desktopFontSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mobileFontSize = 14,
    this.tabletFontSize = 16,
    this.desktopFontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    double fontSize;

    switch (deviceType) {
      case DeviceType.mobile:
        fontSize = mobileFontSize;
        break;
      case DeviceType.tablet:
        fontSize = tabletFontSize;
        break;
      case DeviceType.desktop:
        fontSize = desktopFontSize;
        break;
    }

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 响应式图标大小
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double mobileSize;
  final double tabletSize;
  final double desktopSize;

  const ResponsiveIcon(
    this.icon, {
    super.key,
    this.color,
    this.mobileSize = 20,
    this.tabletSize = 24,
    this.desktopSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    double size;

    switch (deviceType) {
      case DeviceType.mobile:
        size = mobileSize;
        break;
      case DeviceType.tablet:
        size = tabletSize;
        break;
      case DeviceType.desktop:
        size = desktopSize;
        break;
    }

    return Icon(icon, size: size, color: color);
  }
}

/// 响应式间距
class ResponsiveSpacer extends StatelessWidget {
  final double mobileSize;
  final double tabletSize;
  final double desktopSize;
  final Axis axis;

  const ResponsiveSpacer({
    super.key,
    this.mobileSize = 8,
    this.tabletSize = 16,
    this.desktopSize = 24,
    this.axis = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    double size;

    switch (deviceType) {
      case DeviceType.mobile:
        size = mobileSize;
        break;
      case DeviceType.tablet:
        size = tabletSize;
        break;
      case DeviceType.desktop:
        size = desktopSize;
        break;
    }

    return axis == Axis.vertical
        ? SizedBox(height: size)
        : SizedBox(width: size);
  }
}

/// 安全区域包装器（适配刘海屏等）
class SafeAreaWrapper extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsetsGeometry? minimumPadding;

  const SafeAreaWrapper({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimumPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimumPadding != null
          ? EdgeInsets.only(
              top: (minimumPadding as EdgeInsets).top,
              bottom: (minimumPadding as EdgeInsets).bottom,
              left: (minimumPadding as EdgeInsets).left,
              right: (minimumPadding as EdgeInsets).right,
            )
          : EdgeInsets.zero,
      child: child,
    );
  }
}

/// 方向感知布局
class OrientationAwareLayout extends StatelessWidget {
  final Widget portrait;
  final Widget landscape;

  const OrientationAwareLayout({
    super.key,
    required this.portrait,
    required this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.portrait ? portrait : landscape;
      },
    );
  }
}

/// 响应式 EdgeInsets
EdgeInsets responsivePadding(
  BuildContext context, {
  double mobilePadding = 16,
  double tabletPadding = 24,
  double desktopPadding = 32,
}) {
  final deviceType = ResponsiveUtils.getDeviceType(context);
  switch (deviceType) {
    case DeviceType.mobile:
      return EdgeInsets.all(mobilePadding);
    case DeviceType.tablet:
      return EdgeInsets.all(tabletPadding);
    case DeviceType.desktop:
      return EdgeInsets.all(desktopPadding);
  }
}

/// 响应式值选择器
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
}) {
  final deviceType = ResponsiveUtils.getDeviceType(context);
  switch (deviceType) {
    case DeviceType.mobile:
      return mobile;
    case DeviceType.tablet:
      return tablet ?? mobile;
    case DeviceType.desktop:
      return desktop ?? tablet ?? mobile;
  }
}
