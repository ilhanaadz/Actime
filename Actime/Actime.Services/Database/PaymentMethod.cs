namespace Actime.Services.Database
{
    public class PaymentMethod : SoftDeleteEntity
    {
        public int Id { get; set; }
        public required string Name { get; set; }
    }
}
