import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/user_model.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/constants/app_colors.dart';

class PersonalInformationPage extends StatefulWidget {
  final String userId;
  final AuthService authService;
  final UserModel? initialData;

  const PersonalInformationPage({
    super.key,
    required this.userId,
    required this.authService,
    this.initialData,
  });

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  bool _isAccountExpanded = true;
  bool _isSecurityExpanded = true;

  late final TextEditingController _usernameCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;

  late final TextEditingController _currentPassCtrl;
  late final TextEditingController _newPassCtrl;
  late final TextEditingController _confirmPassCtrl;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isUpdatingPassword = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _usernameCtrl = TextEditingController(text: d?.username ?? '');
    _firstNameCtrl = TextEditingController(text: d?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: d?.lastName ?? '');
    _emailCtrl = TextEditingController(text: d?.email ?? '');

    _currentPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final fields = <String, dynamic>{
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'username': _usernameCtrl.text.trim(),
      };
      await widget.authService.updateProfile(widget.userId, fields);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account information updated!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _updatePassword() async {
    if (_currentPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter current password')),
      );
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isUpdatingPassword = true);
    try {
      await widget.authService.reauthenticateAndChangePassword(
          _currentPassCtrl.text, _newPassCtrl.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E3E),
              Color(0xFF4A6666),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(
                            CupertinoIcons.arrow_left,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── Account section
                        _SectionHeader(
                          text: 'Account',
                          isExpanded: _isAccountExpanded,
                          onTap: () => setState(() => _isAccountExpanded = !_isAccountExpanded),
                        ),
                        _CollapsibleSection(
                          isExpanded: _isAccountExpanded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              _ProfileField(
                                controller: _usernameCtrl,
                                label: 'Username',
                                icon: CupertinoIcons.at,
                                hint: 'Enter your username',
                              ),
                              const SizedBox(height: 8),
                              _ProfileField(
                                controller: _firstNameCtrl,
                                label: 'First Name',
                                icon: CupertinoIcons.person,
                                hint: 'Enter your first name',
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 8),
                              _ProfileField(
                                controller: _lastNameCtrl,
                                label: 'Last Name',
                                icon: CupertinoIcons.person,
                                hint: 'Enter your last name',
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 8),
                              _ProfileField(
                                controller: _emailCtrl,
                                label: 'Email',
                                icon: CupertinoIcons.mail,
                                hint: 'your@email.com',
                                readOnly: true,
                                suffixText: 'Read-only',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Security section
                        _SectionHeader(
                          text: 'Security',
                          isExpanded: _isSecurityExpanded,
                          onTap: () => setState(() => _isSecurityExpanded = !_isSecurityExpanded),
                        ),
                        _CollapsibleSection(
                          isExpanded: _isSecurityExpanded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              _DialogField(
                                controller: _currentPassCtrl,
                                label: 'Current Password',
                                obscure: _obscureCurrent,
                                onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                              ),
                              const SizedBox(height: 12),
                              _DialogField(
                                controller: _newPassCtrl,
                                label: 'New Password',
                                obscure: _obscureNew,
                                onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                              const SizedBox(height: 12),
                              _DialogField(
                                controller: _confirmPassCtrl,
                                label: 'Confirm Password',
                                obscure: _obscureConfirm,
                                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: _isUpdatingPassword ? null : _updatePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.15),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  child: _isUpdatingPassword
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text(
                                          'Update Password',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              disabledBackgroundColor: Colors.white.withAlpha(100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    'Save Changes',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF0A1F1F),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
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

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.text,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Icon(
              isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  final bool isExpanded;
  final Widget child;

  const _CollapsibleSection({required this.isExpanded, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: SizedBox(
        width: double.infinity,
        child: isExpanded ? child : const SizedBox.shrink(),
      ),
    );
  }
}

// ── Profile Field ─────────────────────────────────────────────────────────────

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final bool readOnly;
  final String? suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.readOnly = false,
    this.suffixText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
            color: readOnly 
                ? Colors.white.withOpacity(0.5) 
                : Colors.white,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
            filled: true,
            fillColor: Colors.white.withOpacity(0.12),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixText: suffixText,
            suffixStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Colors.white, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ── Dialog Field ──────────────────────────────────────────────────────────────

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggleObscure;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: Colors.white.withOpacity(0.5),
            size: 18,
          ),
          onPressed: onToggleObscure,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
