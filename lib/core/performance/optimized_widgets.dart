import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// ============================================
/// Stage 21: 列表性能优化组件
/// ============================================

/// 高性能列表构建器
class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double? itemExtent;
  final double? cacheExtent;
  final ScrollController? controller;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget? separator;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final double loadMoreThreshold;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
    this.cacheExtent,
    this.controller,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.shrinkWrap = false,
    this.separator,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.onLoadMore,
    this.loadMoreThreshold = 200,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading) {
      return emptyWidget ?? const SizedBox.shrink();
    }

    Widget listView;

    if (separator != null) {
      listView = ListView.separated(
        controller: controller,
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        cacheExtent: cacheExtent,
        itemCount: items.length + (isLoading ? 1 : 0),
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        separatorBuilder: (context, index) => separator!,
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return loadingWidget ?? _buildDefaultLoadingIndicator();
          }
          return itemBuilder(context, items[index], index);
        },
      );
    } else {
      listView = ListView.builder(
        controller: controller,
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemExtent: itemExtent,
        cacheExtent: cacheExtent,
        itemCount: items.length + (isLoading ? 1 : 0),
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return loadingWidget ?? _buildDefaultLoadingIndicator();
          }
          return itemBuilder(context, items[index], index);
        },
      );
    }

    if (onLoadMore != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - loadMoreThreshold) {
              if (!isLoading) {
                onLoadMore!();
              }
            }
          }
          return false;
        },
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildDefaultLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// 优化的GridView
class OptimizedGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final ScrollController? controller;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool isLoading;
  final double? cacheExtent;

  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.childAspectRatio = 1.0,
    this.controller,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.shrinkWrap = false,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.cacheExtent,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading) {
      return emptyWidget ?? const SizedBox.shrink();
    }

    return GridView.builder(
      controller: controller,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      cacheExtent: cacheExtent,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length + (isLoading ? crossAxisCount : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return loadingWidget ?? const SizedBox.shrink();
        }
        return itemBuilder(context, items[index], index);
      },
    );
  }
}

/// 懒加载容器
class LazyLoadContainer extends StatefulWidget {
  final Widget Function() builder;
  final Widget placeholder;
  final double preloadOffset;

  const LazyLoadContainer({
    super.key,
    required this.builder,
    this.placeholder = const SizedBox.shrink(),
    this.preloadOffset = 100,
  });

  @override
  State<LazyLoadContainer> createState() => _LazyLoadContainerState();
}

class _LazyLoadContainerState extends State<LazyLoadContainer> {
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return widget.builder();
    }

    return VisibilityDetector(
      offset: widget.preloadOffset,
      onVisible: () {
        if (mounted && !_isLoaded) {
          setState(() => _isLoaded = true);
        }
      },
      child: widget.placeholder,
    );
  }
}

/// 可见性检测器
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onVisible;
  final double offset;

  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisible,
    this.offset = 0,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  bool _hasBeenVisible = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!_hasBeenVisible) {
          _checkVisibility();
        }
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_hasBeenVisible) {
              _checkVisibility();
            }
          });
          return widget.child;
        },
      ),
    );
  }

  void _checkVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final offsetToReveal = viewport.getOffsetToReveal(renderObject, 0.0);

    if (offsetToReveal.offset < widget.offset) {
      _hasBeenVisible = true;
      widget.onVisible();
    }
  }
}

/// 虚拟化列表项
class VirtualizedListItem extends StatelessWidget {
  final int index;
  final double itemHeight;
  final Widget Function(BuildContext context) builder;

  const VirtualizedListItem({
    super.key,
    required this.index,
    required this.itemHeight,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: RepaintBoundary(
        child: builder(context),
      ),
    );
  }
}

/// 高性能图片预加载
class ImagePreloader {
  static final Map<String, bool> _preloadedImages = {};

  /// 预加载图片
  static Future<void> preload(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    for (final url in imageUrls) {
      if (_preloadedImages[url] == true) continue;

      try {
        await precacheImage(NetworkImage(url), context);
        _preloadedImages[url] = true;
      } catch (e) {
        _preloadedImages[url] = false;
      }
    }
  }

  /// 预加载Asset图片
  static Future<void> preloadAssets(
    BuildContext context,
    List<String> assetPaths,
  ) async {
    for (final path in assetPaths) {
      if (_preloadedImages[path] == true) continue;

      try {
        await precacheImage(AssetImage(path), context);
        _preloadedImages[path] = true;
      } catch (e) {
        _preloadedImages[path] = false;
      }
    }
  }

  /// 清除预加载记录
  static void clearCache() {
    _preloadedImages.clear();
  }

  /// 检查是否已预加载
  static bool isPreloaded(String url) {
    return _preloadedImages[url] == true;
  }
}

/// 滚动性能优化的Sliver列表
class OptimizedSliverList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double? itemExtent;

  const OptimizedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
  });

  @override
  Widget build(BuildContext context) {
    if (itemExtent != null) {
      return SliverFixedExtentList(
        itemExtent: itemExtent!,
        delegate: SliverChildBuilderDelegate(
          (context, index) => RepaintBoundary(
            child: itemBuilder(context, items[index], index),
          ),
          childCount: items.length,
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: false, // 我们手动添加了
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => RepaintBoundary(
          child: itemBuilder(context, items[index], index),
        ),
        childCount: items.length,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: false,
      ),
    );
  }
}
