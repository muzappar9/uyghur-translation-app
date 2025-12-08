import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';

/// 网络连接通知器
class NetworkConnectivityNotifier {
  /// Connectivity 实例
  final Connectivity _connectivity = Connectivity();

  /// 当前连接状态
  late bool _isOnline;

  /// 构造函数
  NetworkConnectivityNotifier() {
    _isOnline = true;
    _initialize();
  }

  /// 初始化
  Future<void> _initialize() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
      appLogger
          .d('${_isOnline ? '🌐' : '📴'} 初始网络状态: ${_isOnline ? "在线" : "离线"}');
    } catch (e) {
      appLogger.w('⚠️ 检查网络连接失败: $e');
      _isOnline = true; // 默认假设在线
    }
  }

  /// 监听网络连接变化
  Stream<bool> onConnectivityChanged() {
    return _connectivity.onConnectivityChanged.map((result) {
      final isOnline = result != ConnectivityResult.none;
      _isOnline = isOnline;
      appLogger.d('🔄 网络状态变化: ${isOnline ? "连接" : "断开"}');
      return isOnline;
    });
  }

  /// 获取当前连接状态
  Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
      return _isOnline;
    } catch (e) {
      appLogger.w('⚠️ 检查连接失败: $e');
      return _isOnline;
    }
  }

  /// 获取缓存的连接状态（不发起网络请求）
  bool get cachedIsOnline => _isOnline;

  /// 获取连接类型
  Future<ConnectivityResult> getConnectionType() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      appLogger.w('⚠️ 获取连接类型失败: $e');
      return ConnectivityResult.none;
    }
  }

  /// 检查是否是移动网络
  Future<bool> isMobileConnection() async {
    final connectionType = await getConnectionType();
    return connectionType == ConnectivityResult.mobile;
  }

  /// 检查是否是 WiFi 连接
  Future<bool> isWifiConnection() async {
    final connectionType = await getConnectionType();
    return connectionType == ConnectivityResult.wifi;
  }
}
