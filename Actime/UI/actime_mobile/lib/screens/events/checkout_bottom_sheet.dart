import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../constants/participation_constants.dart';
import '../../components/actime_button.dart';
import '../../models/event.dart';

class CheckoutBottomSheet extends StatefulWidget {
  final Event event;

  const CheckoutBottomSheet({
    super.key,
    required this.event,
  });

  /// Returns selected PaymentMethod ID on success, null if dismissed.
  static Future<int?> show(BuildContext context, Event event) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutBottomSheet(event: event),
    );
  }

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

/// Internal state for the checkout sheet.
/// _stage drives the UI: form → processing → success.
enum _CheckoutStage { form, processing, success }

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  int _selectedPaymentMethod = PaymentMethod.payPal;
  _CheckoutStage _stage = _CheckoutStage.form;

  Future<void> _handleCheckout() async {
    setState(() => _stage = _CheckoutStage.processing);

    // Dummy delay — simulates network round-trip to payment gateway.
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() => _stage = _CheckoutStage.success);

    // Brief pause so the user can see the success state.
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    Navigator.pop(context, _selectedPaymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingDefault),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_stage == _CheckoutStage.form) ...[
              _buildHeader(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildPaymentMethodSection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildSummarySection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildTotalSection(),
              const SizedBox(height: AppDimensions.spacingXLarge),
              ActimePrimaryButton(
                label: 'Complete checkout',
                onPressed: _handleCheckout,
              ),
            ] else if (_stage == _CheckoutStage.processing) ...[
              const SizedBox(height: AppDimensions.spacingLarge),
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    const Text(
                      'Processing payment...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
            ] else ...[
              // success
              const SizedBox(height: AppDimensions.spacingLarge),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 64),
                    const SizedBox(height: AppDimensions.spacingMedium),
                    const Text(
                      'Payment successful!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
            ],
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.close,
            color: AppColors.textMuted,
            size: AppDimensions.iconLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment method',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        _buildPaymentOption(
          id: PaymentMethod.payPal,
          icon: Icons.paypal,
          label: 'PayPal',
          iconColor: const Color(0xFF003087),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        _buildPaymentOption(
          id: PaymentMethod.creditCard,
          icon: Icons.credit_card,
          label: 'Credit Card',
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required int id,
    required IconData icon,
    required String label,
    Color? iconColor,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingDefault,
          vertical: AppDimensions.spacingMedium,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.event.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              widget.event.formattedPrice,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.only(top: AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total:',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            widget.event.formattedPrice,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
