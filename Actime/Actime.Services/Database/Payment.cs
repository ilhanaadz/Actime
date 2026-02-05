namespace Actime.Services.Database
{
    public class Payment : BaseEntity
    {
        public int UserId { get; set; }
        public int EventId { get; set; }
        public string StripePaymentIntentId { get; set; } = null!;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "eur";
        public string Status { get; set; } = "pending";

        public virtual User User { get; set; } = null!;
        public virtual Event Event { get; set; } = null!;
    }
}
