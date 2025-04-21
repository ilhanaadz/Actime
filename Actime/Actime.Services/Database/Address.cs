namespace Actime.Services.Database
{
    public class Address
    {
        public int Id { get; set; }
        public required string Street { get; set; }
        public required string PostalCode { get; set; }
        public string? Coordinates { get; set; }
        public int CityId { get; set; }

        public virtual City City { get; set; } = null!;
    }
}
