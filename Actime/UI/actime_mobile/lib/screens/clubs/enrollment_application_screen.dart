import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../services/services.dart';

class EnrollmentApplicationScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const EnrollmentApplicationScreen({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });

  @override
  State<EnrollmentApplicationScreen> createState() => _EnrollmentApplicationScreenState();
}

class _EnrollmentApplicationScreenState extends State<EnrollmentApplicationScreen> {
  final _enrollmentService = EnrollmentService();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    setState(() => _isLoading = true);

    try {
      final response = await _enrollmentService.createEnrollment(
        organizationId: widget.organizationId,
        message: _messageController.text.isNotEmpty ? _messageController.text : null,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prijava je uspješno poslana!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri slanju prijave'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške. Pokušajte ponovo.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.organizationName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          'Prijava za članstvo',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Popunite formu da biste poslali prijavu za članstvo u klubu.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Poruka (opcionalno)',
                  hintText: 'Napišite zašto želite postati član ovog kluba...',
                  alignLabelWithHint: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vašu prijavu će pregledati administratori kluba',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Pošalji prijavu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
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
