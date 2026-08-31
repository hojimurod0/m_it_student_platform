import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/complaints/data/repositories/complaints_repository_impl.dart';
import 'package:m_it_student_platform/features/complaints/presentation/bloc/complaints_bloc.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final TextEditingController _bodyController = TextEditingController();

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => ComplaintsBloc(
        repository: sl.isRegistered<ComplaintsRepository>()
            ? sl<ComplaintsRepository>()
            : ComplaintsRepositoryImpl(),
      ),
      child: BlocConsumer<ComplaintsBloc, ComplaintsState>(
        listener: (context, state) {
          if (state is ComplaintsSuccess) {
            AppHaptics.medium();
            MitToast.success(
              context,
              'Dars qoldirish arizangiz muvaffaqiyatli yuborildi!',
            );
            Navigator.of(context).pop();
          }
          if (state is ComplaintsError) {
            AppHaptics.error();
            MitToast.error(
              context,
              state.message.replaceAll('Exception:', '').trim(),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF001426) : const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: isDark ? const Color(0xFF001E36) : Colors.white,
              elevation: 0,
              centerTitle: false,
              title: Text(
                'Dars qoldirish arizasi',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: isDark ? Colors.white : const Color(0xFF001E36),
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: isDark ? Colors.white : const Color(0xFF001E36),
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Info Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF001E36)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF002F52) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3FF32).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            size: 22,
                            color: Color(0xFFD3FF32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sababli dars qoldirish",
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF001E36),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Darsga kela olmasligingiz sababini yozing. Ushbu ariza markaz ma'muriyati va mentoringizga to'g'ridan-to'g'ri yetkaziladi.",
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Single Text Area (Textfield bitta yetadi)
                  Text(
                    'Ariza sababi va tushuntirish:',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF001E36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bodyController,
                    maxLines: 7,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: isDark ? Colors.white : const Color(0xFF001E36),
                    ),
                    decoration: InputDecoration(
                      hintText: "Darsga kela olmaslik sababini yozing (masalan: Sog'lig'im yomonlashgani sababli bugungi darsga kela olmayman)...",
                      hintStyle: TextStyle(
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF001E36) : Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF002F52) : const Color(0xFFCBD5E1),
                          width: 1.1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFD3FF32),
                          width: 1.8,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is ComplaintsSubmitting
                          ? null
                          : () {
                              final text = _bodyController.text.trim();
                              if (text.isEmpty) {
                                MitToast.warning(
                                  context,
                                  'Iltimos, dars qoldirish sababini yozing',
                                );
                                return;
                              }
                              context.read<ComplaintsBloc>().add(
                                    SubmitComplaintEvent(
                                      subject: 'Dars qoldirish arizasi',
                                      body: text,
                                    ),
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3FF32),
                        foregroundColor: const Color(0xFF001E36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: state is ComplaintsSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF001E36),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 19, color: Color(0xFF001E36)),
                                SizedBox(width: 8),
                                Text(
                                  'Arizani yuborish',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: Color(0xFF001E36),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
