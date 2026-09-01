import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

// ---------------------------------------------------------
// Tactical Auth Terminal - KrugX
// ---------------------------------------------------------

class TacticalAuthScreen extends ConsumerStatefulWidget {
  const TacticalAuthScreen({super.key});

  @override
  ConsumerState<TacticalAuthScreen> createState() => _TacticalAuthScreenState();
}

enum AuthMode { login, signup, recovery }

class _TacticalAuthScreenState extends ConsumerState<TacticalAuthScreen> with TickerProviderStateMixin {
  final _operatorIdController = TextEditingController();
  final _encryptionKeyController = TextEditingController();
  final _operatorNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthMode _mode = AuthMode.login;
  bool _isObscured = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _operatorIdController.dispose();
    _encryptionKeyController.dispose();
    _operatorNameController.dispose();
    super.dispose();
  }

  Future<void> _executeAuth() async {
    setState(() => _errorMessage = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _operatorIdController.text.trim();
    final password = _encryptionKeyController.text;

    final notifier = ref.read(authProvider.notifier);
    bool success = false;

    if (_mode == AuthMode.login) {
      success = await notifier.login(email, password);
    } else if (_mode == AuthMode.signup) {
      final name = _operatorNameController.text.trim();
      success = await notifier.signup(email, password, name.isEmpty ? null : name);
    } else {
      success = await notifier.resetPassword(email);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("RECOVERY_INITIATED // CHECK_COMMS", style: TextStyle(fontFamily: 'JetBrains Mono')),
            backgroundColor: Color(0xFF1A1A1A),
          ),
        );
        setState(() => _mode = AuthMode.login);
        return;
      }
    }

    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      setState(() {
        _errorMessage = ref.read(authProvider).error ?? "AUTH_FAILED: Invalid Credentials";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Dot Matrix Background
          CustomPaint(
            size: Size.infinite,
            painter: DotMatrixPainter(),
          ),
          
          Column(
            children: [
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Center HUD
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxHeight < 700;
                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 500),
                                child: _buildCenterHUD(authState, isCompact),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Mobile Bottom Nav
              if (!isDesktop) _buildMobileNav(),
            ],
          ),
          
          // Crosshairs
          _buildCrosshair(top: 24, left: 24, label: "0x00"),
          _buildCrosshair(top: 24, right: 24, label: "0xFF"),
          _buildCrosshair(bottom: 24, left: 24, label: "0x01"),
          _buildCrosshair(bottom: 24, right: 24, label: "0xF0"),
        ],
      ),
    );
  }



  Widget _buildCenterHUD(AuthState authState, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 24.0 : 48.0),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          
          Text(
            "KrugerX",
            style: TextStyle(
              fontFamily: 'Archivo Narrow',
              fontSize: isCompact ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.red,
              shadows: [Shadow(color: Colors.red.withValues(alpha: 0.7), blurRadius: 10)],
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: isCompact ? 24 : 48),
            
            _buildInputField(
              label: "> OPERATOR_ID",
              controller: _operatorIdController,
              hint: "[INPUT_ID]",
            ),
            SizedBox(height: isCompact ? 16 : 24),
            
            if (_mode == AuthMode.signup) ...[
              _buildInputField(
                label: "> ALIAS",
                controller: _operatorNameController,
                hint: "[DISPLAY_NAME]",
              ),
              SizedBox(height: isCompact ? 16 : 24),
            ],
            
            if (_mode != AuthMode.recovery) ...[
              _buildInputField(
                label: "> ENCRYPTION_KEY",
                controller: _encryptionKeyController,
                hint: "••••••••",
                isPassword: true,
              ),
              SizedBox(height: isCompact ? 24 : 48),
            ] else ...[
              SizedBox(height: isCompact ? 16 : 24),
            ],
            
            AnimatedAuthButton(
              onTap: authState.isLoading ? null : _executeAuth,
              padding: EdgeInsets.symmetric(vertical: isCompact ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                border: Border.all(color: Colors.red),
                boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 15)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (authState.isLoading)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                  else ...[
                    const Icon(Icons.terminal, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      _mode == AuthMode.login ? "EXECUTE_AUTH" 
                      : _mode == AuthMode.signup ? "EXECUTE_REGISTER" 
                      : "EXECUTE_RECOVERY",
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        shadows: [Shadow(color: Colors.red.withValues(alpha: 0.7), blurRadius: 10)],
                        letterSpacing: 4,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            
            SizedBox(height: isCompact ? 8 : 16),
            const Text(
              "--- OR ---",
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                color: Color(0xFF550000),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: isCompact ? 8 : 16),
            
            Semantics(
              button: true,
              label: "Continue with Google",
              child: AnimatedAuthButton(
                onTap: authState.isLoading ? null : () {
                  ref.read(authProvider.notifier).loginWithGoogle();
                },
                padding: EdgeInsets.symmetric(vertical: isCompact ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: const Color(0xFF550000)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (authState.isLoading)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                    else ...[
                      Icon(Icons.email, color: Colors.red.withValues(alpha: 0.8), size: 16),
                      const SizedBox(width: 12),
                      Text(
                        "CONTINUE_WITH_GMAIL",
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: Colors.red.withValues(alpha: 0.8),
                          letterSpacing: 2,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),

            SizedBox(height: isCompact ? 12 : 16),
            if (_errorMessage != null)
              Text(
                "> SYSTEM_MSG: $_errorMessage",
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.red.withValues(alpha: 0.7), blurRadius: 10)],
                ),
              ),
            SizedBox(height: isCompact ? 12 : 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                InkWell(
                  onTap: () => setState(() {
                    _mode = _mode == AuthMode.login ? AuthMode.signup : AuthMode.login;
                    _errorMessage = null;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      _mode == AuthMode.login ? "[SWITCH_TO_REGISTER]" : "[SWITCH_TO_LOGIN]",
                      style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() {
                    _mode = _mode == AuthMode.recovery ? AuthMode.login : AuthMode.recovery;
                    _errorMessage = null;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      _mode == AuthMode.recovery ? "[CANCEL_RECOVERY]" : "[INITIATE_RECOVERY]",
                      style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/'),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      "[ABORT_UPLINK]",
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        color: Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String hint, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            color: Colors.red,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _isObscured,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'REQUIRED_FIELD';
            if (isPassword && value.length < 4) return 'INSUFFICIENT_ENTROPY';
            return null;
          },
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 14,
            color: Colors.red,
            letterSpacing: (isPassword && _isObscured) ? 8 : 1,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF333333)),
            errorStyle: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              color: Colors.red,
            ),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility : Icons.visibility_off,
                color: Colors.red.withValues(alpha: 0.5),
              ),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
            ) : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCrosshair({double? top, double? bottom, double? left, double? right, required String label}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? BorderSide(color: Colors.white.withValues(alpha: 0.2)) : BorderSide.none,
            bottom: bottom != null ? BorderSide(color: Colors.white.withValues(alpha: 0.2)) : BorderSide.none,
            left: left != null ? BorderSide(color: Colors.white.withValues(alpha: 0.2)) : BorderSide.none,
            right: right != null ? BorderSide(color: Colors.white.withValues(alpha: 0.2)) : BorderSide.none,
          ),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: Color(0xFF333333))),
      ),
    );
  }

  Widget _buildMobileNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMobileNavItem(Icons.qr_code_scanner, "AUTH", true, onTap: () {}),
          _buildMobileNavItem(Icons.radar, "STATUS", false, onTap: () => context.push('/profile')),
          _buildMobileNavItem(Icons.terminal, "CMD", false, onTap: () => context.go('/')),
          _buildMobileNavItem(Icons.settings_input_component, "SYS", false, onTap: () => context.push('/settings')),
        ],
      ),
    );
  }

  Widget _buildMobileNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.red : const Color(0xFF777777), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              color: isActive ? Colors.red : const Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

class DotMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
      
    for (double x = 0; x < size.width; x += 24) {
      for (double y = 0; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedAuthButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final BoxDecoration decoration;
  final EdgeInsets padding;

  const AnimatedAuthButton({super.key, required this.onTap, required this.child, required this.decoration, required this.padding});

  @override
  State<AnimatedAuthButton> createState() => _AnimatedAuthButtonState();
}

class _AnimatedAuthButtonState extends State<AnimatedAuthButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.disableAnimationsOf(context);
    
    Widget content = Container(
      width: double.infinity,
      padding: widget.padding,
      decoration: widget.decoration,
      child: widget.child,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.onTap != null ? (_) {
          setState(() => _isPressed = false);
          widget.onTap!();
        } : null,
        onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
        child: disableAnim
            ? content
            : content.animate(target: (_isHovered || _isPressed) && widget.onTap != null ? 1 : 0)
                .scaleXY(end: _isPressed ? 0.95 : 1.02, duration: 150.ms, curve: Curves.easeOut)
                .tint(color: Colors.white.withValues(alpha: 0.1), end: 0.5),
      ),
    );
  }
}
