import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/user_model.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';

class BodyStatsPage extends StatefulWidget {
  final String userId;
  final AuthService authService;
  final UserModel? initialData;

  const BodyStatsPage({
    super.key,
    required this.userId,
    required this.authService,
    this.initialData,
  });

  @override
  State<BodyStatsPage> createState() => _BodyStatsPageState();
}

class _BodyStatsPageState extends State<BodyStatsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _ageCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _heightCtrl = TextEditingController(text: d?.height != null ? '${d!.height}' : '');
    _weightCtrl = TextEditingController(text: d?.weight != null ? '${d!.weight}' : '');
    _ageCtrl = TextEditingController(text: d?.age != null ? '${d!.age}' : '');
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final fields = <String, dynamic>{
        if (_heightCtrl.text.trim().isNotEmpty)
          'height': double.tryParse(_heightCtrl.text.trim()),
        if (_weightCtrl.text.trim().isNotEmpty)
          'weight': double.tryParse(_weightCtrl.text.trim()),
        if (_ageCtrl.text.trim().isNotEmpty)
          'age': int.tryParse(_ageCtrl.text.trim()),
      };
      await widget.authService.updateProfile(widget.userId, fields);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Body statistics updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating stats: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              Color(0xFF0D1B1B),
              Color(0xFF162A2A),
              Color(0xFF1A3333),
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
                      child: RoundIconButton(
                        icon: CupertinoIcons.arrow_left,
                        onTap: () => Navigator.pop(context),
                        outlined: true,
                        isSquare: true,
                      ),
                    ),
                    const Text(
                      'Body Statistics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ── Illustration/Hero Area
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.heart_fill, color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keep your stats updated',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Accurate body metrics help us tailor your habit journey.',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ── Input Fields
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _StatsInputTile(
                          controller: _ageCtrl,
                          label: 'Age',
                          icon: CupertinoIcons.calendar,
                          suffix: 'years',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 16),
                        _StatsInputTile(
                          controller: _heightCtrl,
                          label: 'Height',
                          icon: CupertinoIcons.arrow_up_arrow_down,
                          suffix: 'cm',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 16),
                        _StatsInputTile(
                          controller: _weightCtrl,
                          label: 'Weight',
                          icon: CupertinoIcons.circle,
                          suffix: 'kg',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 40),
                        
                        // ── Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 10,
                              shadowColor: AppColors.primary.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                  )
                                : const Text(
                                    'Save Statistics',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
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

class _StatsInputTile extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String suffix;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _StatsInputTile({
    required this.controller,
    required this.label,
    required this.icon,
    required this.suffix,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 24,
      opacity: 0.1,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
              ],
            ),
          ),
          Text(
            suffix,
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
