using Actime.Model.Settings;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Stripe;

namespace Actime.Services.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly ActimeContext _context;
        private readonly IOptions<StripeSettings> _stripeSettings;

        public PaymentService(ActimeContext context, IOptions<StripeSettings> stripeSettings)
        {
            _context = context;
            _stripeSettings = stripeSettings;
        }

        private StripeClient GetClient() => new(_stripeSettings.Value.SecretKey);

        public async Task<string> CreatePaymentIntentAsync(int eventId, int userId)
        {
            var ev = await _context.Events.FindAsync(eventId)
                ?? throw new Exception("Event not found");

            if (ev.IsFree)
                throw new Exception("Event is free — no payment required");

            var amountInCents = (long)(ev.Price * 100);

            var paymentIntentService = new PaymentIntentService(GetClient());
            var paymentIntent = await paymentIntentService.CreateAsync(new PaymentIntentCreateOptions
            {
                Amount = amountInCents,
                Currency = "eur",
                PaymentMethodTypes = new List<string> { "card" },
                Metadata = new Dictionary<string, string>
                {
                    { "EventId", eventId.ToString() },
                    { "UserId", userId.ToString() }
                }
            });

            _context.Payments.Add(new Payment
            {
                UserId = userId,
                EventId = eventId,
                StripePaymentIntentId = paymentIntent.Id,
                Amount = ev.Price,
                Currency = "eur",
                Status = "pending"
            });
            await _context.SaveChangesAsync();

            return paymentIntent.ClientSecret;
        }

        public async Task HandleWebhookAsync(string payload, string signature)
        {
            Stripe.Event stripeEvent;
            try
            {
                stripeEvent = EventUtility.ConstructEvent(payload, signature, _stripeSettings.Value.WebhookSecret);
            }
            catch
            {
                throw new Exception("Invalid webhook signature");
            }

            if (stripeEvent.Type == "payment_intent.succeeded")
            {
                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                if (paymentIntent == null) return;

                // Update local Payment record
                var payment = await _context.Payments.FirstOrDefaultAsync(p => p.StripePaymentIntentId == paymentIntent.Id);
                if (payment != null)
                {
                    payment.Status = "succeeded";
                    await _context.SaveChangesAsync();
                }

                // Update Participation PaymentStatus to paid (2) if it exists
                if (paymentIntent.Metadata.TryGetValue("EventId", out var eventIdStr)
                    && paymentIntent.Metadata.TryGetValue("UserId", out var userIdStr)
                    && int.TryParse(eventIdStr, out var eventId)
                    && int.TryParse(userIdStr, out var userId))
                {
                    var participation = await _context.Participations
                        .FirstOrDefaultAsync(p => p.EventId == eventId && p.UserId == userId);
                    if (participation != null)
                    {
                        participation.PaymentStatusId = 2; // paid
                        await _context.SaveChangesAsync();
                    }
                }
            }
            else if (stripeEvent.Type == "payment_intent.payment_failed")
            {
                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                if (paymentIntent == null) return;

                var payment = await _context.Payments
                    .FirstOrDefaultAsync(p => p.StripePaymentIntentId == paymentIntent.Id);
                if (payment != null)
                {
                    payment.Status = "failed";
                    await _context.SaveChangesAsync();
                }
            }
        }
    }
}
