using Actime.Model.Requests;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Actime.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        /// <summary>
        /// Creates a Stripe PaymentIntent for the given event.
        /// Returns the clientSecret needed by the Flutter Stripe SDK.
        /// </summary>
        [HttpPost("create-intent")]
        [Authorize]
        public async Task<ActionResult> CreatePaymentIntent([FromBody] CreatePaymentIntentRequest request)
        {
            try
            {
                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
                var clientSecret = await _paymentService.CreatePaymentIntentAsync(request.EventId, userId);
                return Ok(new { clientSecret });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Stripe webhook endpoint. Verifies signature and processes payment events.
        /// Must NOT be authorized — Stripe calls this externally.
        /// </summary>
        [HttpPost("webhook")]
        [AllowAnonymous]
        public async Task<ActionResult> Webhook()
        {
            using var reader = new StreamReader(HttpContext.Request.Body);
            var payload = await reader.ReadToEndAsync();
            var signature = HttpContext.Request.Headers["Stripe-Signature"];

            try
            {
                await _paymentService.HandleWebhookAsync(payload, signature!);
                return Ok();
            }
            catch
            {
                return BadRequest();
            }
        }
    }
}
