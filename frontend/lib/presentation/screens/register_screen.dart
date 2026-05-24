import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl   = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _department = 'Bilgisayar Müh.';
  int _year = 1;

  static const _departments = [
    'Bilgisayar Müh.', 'Elektrik-Elektronik Müh.', 'Endüstri Müh.',
    'Makine Müh.', 'İşletme', 'Psikoloji', 'Hukuk', 'Tıp',
    'Mimarlık', 'Matematik',
  ];

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      studentId:  _idCtrl.text.trim(),
      name:       _nameCtrl.text.trim(),
      department: _department,
      year:       _year,
      email:      _emailCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Kayıt başarısız.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Yeni Hesap', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _field('Ad Soyad', _nameCtrl, Icons.person_outline,
                            validator: (v) => (v == null || v.trim().length < 2) ? 'Ad Soyad gerekli' : null),
                        const SizedBox(height: 14),
                        _field('Öğrenci ID', _idCtrl, Icons.badge_outlined,
                            hint: 'Örn: s1a2b3c',
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'ID gerekli' : null),
                        const SizedBox(height: 14),
                        _field('E-posta', _emailCtrl, Icons.email_outlined,
                            keyboard: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
                              if (!v.contains('@')) return 'Geçersiz e-posta';
                              return null;
                            }),
                        const SizedBox(height: 14),
                        _sectionLabel('Bölüm'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _department,
                          dropdownColor: AppColors.card,
                          decoration: const InputDecoration(),
                          style: const TextStyle(color: AppColors.text, fontSize: 15),
                          items: _departments
                              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (v) => setState(() => _department = v!),
                        ),
                        const SizedBox(height: 14),
                        _sectionLabel('Sınıf'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _year,
                          dropdownColor: AppColors.card,
                          decoration: const InputDecoration(),
                          style: const TextStyle(color: AppColors.text, fontSize: 15),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1. Sınıf')),
                            DropdownMenuItem(value: 2, child: Text('2. Sınıf')),
                            DropdownMenuItem(value: 3, child: Text('3. Sınıf')),
                            DropdownMenuItem(value: 4, child: Text('4. Sınıf')),
                          ],
                          onChanged: (v) => setState(() => _year = v!),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: auth.loading ? null : _register,
                            child: auth.loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Kayıt Ol'),
                          ),
                        ),
                        const SizedBox(height: 20),
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

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hint,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textMuted),
          ),
          validator: validator,
        ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
