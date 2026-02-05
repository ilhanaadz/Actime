import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;
import '../../constants/constants.dart';
import '../../constants/participation_constants.dart';
import '../../components/actime_button.dart';
import '../../models/event.dart';
import '../../services/stripe_payment_service.dart';

class CheckoutBottomSheet extends StatefulWidget {
  final Event event;

  const CheckoutBottomSheet({
    super.key,
    required this.event,
  });

  /// Returns PaymentMethod.creditCard on successful Stripe payment, null if dismissed.
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

/// _stage drives the UI: form → processing → success.
enum _CheckoutStage { form, processing, success }

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  _CheckoutStage _stage = _CheckoutStage.form;
  String? _errorMessage;
  final _stripeService = StripePaymentService();

  Future<void> _handleCheckout() async {
    setState(() {
      _stage = _CheckoutStage.processing;
      _errorMessage = null;
    });

    try {
      final eventId = int.tryParse(widget.event.id) ?? 0;

      final response = await _stripeService.createPaymentIntent(eventId);
      if (!response.success || response.data == null) {
        if (!mounted) return;
        setState(() {
          _stage = _CheckoutStage.form;
          _errorMessage = response.message ?? 'Greška pri pokretanju plaćanja';
        });
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: response.data!,
          merchantDisplayName: 'Actime',
        ),
      );

      //    Returns null if the user dismisses without paying.
      final result = await Stripe.instance.presentPaymentSheet();
      if (result == null) {
        // User dismissed — stay on form, no error shown.
        if (!mounted) return;
        setState(() => _stage = _CheckoutStage.form);
        return;
      }

      // Payment confirmed by Stripe
      if (!mounted) return;
      setState(() => _stage = _CheckoutStage.success);

      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      Navigator.pop(context, PaymentMethod.creditCard);
    } catch (e) {
      if (!mounted) return;
      if (e is StripeException) {
        setState(() {
          _stage = _CheckoutStage.form;
          _errorMessage = e.error.localizedMessage;
        });
      } else {
        setState(() {
          _stage = _CheckoutStage.form;
          _errorMessage = 'Došlo je do greške. Pokušajte ponovo.';
        });
      }
    }
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
              _buildSummarySection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildTotalSection(),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppDimensions.spacingMedium),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppDimensions.spacingXLarge),
              ActimePrimaryButton(
                label: 'Pay ${widget.event.formattedPrice}',
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
