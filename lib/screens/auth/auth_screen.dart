import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';
import 'package:blog_app/providers/auth_provider.dart';

enum _AuthMode { signIn, join }

const double _mdBreakpoint = 768;
const double _lgBreakpoint = 1024;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchMode(_AuthMode mode) {
    if (_mode == mode) {
      return;
    }
    setState(() {
      _mode = mode;
    });
    context.read<AuthProvider>().clearError();
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final AuthProvider auth = context.read<AuthProvider>();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final bool succeeded = _mode == _AuthMode.join
        ? await auth.register(email: email, password: password)
        : await auth.login(email: email, password: password);
    if (succeeded && mounted) {
      Router.neglect(context, () => context.replace('/'));
    }
  }

  void _continueAsGuest() {
    Router.neglect(context, () => context.replace('/'));
  }

  String? _validateEmail(String? value) {
    final String input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Email address is required';
    }
    if (!input.contains('@') || !input.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final String input = value ?? '';
    if (input.isEmpty) {
      return 'Password is required';
    }
    if (input.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isDesktop = constraints.maxWidth >= _lgBreakpoint;
            final bool useDisplayHeadline = constraints.maxWidth >= _mdBreakpoint;
            final Widget form = _AuthForm(
              formKey: _formKey,
              mode: _mode,
              auth: auth,
              emailController: _emailController,
              passwordController: _passwordController,
              useDisplayHeadline: useDisplayHeadline,
              onModeChanged: _switchMode,
              onSubmit: _submit,
              onContinueAsGuest: _continueAsGuest,
              validateEmail: _validateEmail,
              validatePassword: _validatePassword,
            );

            if (!isDesktop) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  child: form,
                ),
              );
            }

            return Row(
              children: <Widget>[
                const Expanded(child: _AuthHeroPane()),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      child: form,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuthHeroPane extends StatelessWidget {
  const _AuthHeroPane();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceContainerLow,
      child: SizedBox.expand(
        child: Image.asset(
          'assets/images/info-graphic.png',
          fit: BoxFit.cover,
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.formKey,
    required this.mode,
    required this.auth,
    required this.emailController,
    required this.passwordController,
    required this.useDisplayHeadline,
    required this.onModeChanged,
    required this.onSubmit,
    required this.onContinueAsGuest,
    required this.validateEmail,
    required this.validatePassword,
  });

  final GlobalKey<FormState> formKey;
  final _AuthMode mode;
  final AuthProvider auth;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool useDisplayHeadline;
  final ValueChanged<_AuthMode> onModeChanged;
  final VoidCallback onSubmit;
  final VoidCallback onContinueAsGuest;
  final FormFieldValidator<String> validateEmail;
  final FormFieldValidator<String> validatePassword;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'The Journal',
              style: useDisplayHeadline ? AppTypography.display : AppTypography.headlineLgMobile,
            ),
            const SizedBox(height: 12),
            Text(
              'Built for clarity. Sign in to continue your reading lane.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            _ModeToggle(mode: mode, onModeChanged: onModeChanged),
            const SizedBox(height: 40),
            TextFormField(
              controller: emailController,
              enabled: !auth.isLoading,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              style: AppTypography.bodyLg,
              decoration: const InputDecoration(labelText: 'Email address'),
              validator: validateEmail,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: passwordController,
              enabled: !auth.isLoading,
              obscureText: true,
              style: AppTypography.bodyLg,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: validatePassword,
              onFieldSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: 32),
            if (auth.errorMessage != null) ...<Widget>[
              Text(
                auth.errorMessage!,
                style: AppTypography.bodyMd.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 16),
            ],
            _SubmitButton(
              label: mode == _AuthMode.join ? 'Create Account' : 'Continue',
              isLoading: auth.isLoading,
              onPressed: auth.isLoading ? null : onSubmit,
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: auth.isLoading ? null : onContinueAsGuest,
                child: Text(
                  'Continue as Guest',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onModeChanged});

  final _AuthMode mode;
  final ValueChanged<_AuthMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: <Widget>[
          _ModeTab(
            label: 'Sign In',
            selected: mode == _AuthMode.signIn,
            onTap: () => onModeChanged(_AuthMode.signIn),
          ),
          const SizedBox(width: 32),
          _ModeTab(
            label: 'Join',
            selected: mode == _AuthMode.join,
            onTap: () => onModeChanged(_AuthMode.join),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.primary : AppColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.headlineMd.copyWith(color: color),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Color background = _hovering ? AppColors.inverseSurface : AppColors.primary;
    final Color foreground = _hovering ? AppColors.inverseOnSurface : AppColors.onPrimary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(2),
              onTap: widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: widget.isLoading
                    ? Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: foreground,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.label,
                            style: AppTypography.labelMd.copyWith(
                              color: foreground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 300),
                            offset: _hovering ? const Offset(0.3, 0) : Offset.zero,
                            child: Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: foreground,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
