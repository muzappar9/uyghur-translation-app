import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier_provider.dart';
import '../../data/models/auth_models.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';

/// 认证屏幕 - 登录/注册
class AuthenticationScreen extends ConsumerStatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  ConsumerState<AuthenticationScreen> createState() =>
      _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen> {
  bool _isLoginMode = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authOperationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? '登录' : '注册'),
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 应用标题
              const SizedBox(height: 40),
              const Text(
                '维吾尔翻译',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '精准翻译 实时识别',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 60),

              // 登录/注册表单
              if (_isLoginMode)
                LoginForm(
                  onLoginPressed: (email, password) {
                    final request = LoginRequest(
                      email: email,
                      password: password,
                    );
                    ref.read(authOperationProvider.notifier).login(request);
                  },
                  isLoading: authState.isLoading,
                  errorMessage: authState.error,
                )
              else
                RegisterForm(
                  onRegisterPressed:
                      (email, password, confirmPassword, displayName) {
                    if (password != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('密码不匹配')),
                      );
                      return;
                    }
                    final request = RegisterRequest(
                      email: email,
                      password: password,
                      passwordConfirm: confirmPassword,
                      displayName: displayName,
                    );
                    ref.read(authOperationProvider.notifier).register(request);
                  },
                  isLoading: authState.isLoading,
                  errorMessage: authState.error,
                ),

              const SizedBox(height: 24),

              // 模式切换
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginMode ? '没有账户? ' : '已有账户? ',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                      });
                    },
                    child: Text(
                      _isLoginMode ? '注册' : '登录',
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 游客登录按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(authOperationProvider.notifier).loginAnonymously();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                  ),
                  child: const Text(
                    '以游客身份继续',
                    style: TextStyle(color: Color(0xFF2196F3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
