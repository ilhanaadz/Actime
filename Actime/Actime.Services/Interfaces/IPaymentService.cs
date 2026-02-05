namespace Actime.Services.Interfaces
{
    public interface IPaymentService
    {
        Task<string> CreatePaymentIntentAsync(int eventId, int userId);
        Task HandleWebhookAsync(string payload, string signature);
    }
}
