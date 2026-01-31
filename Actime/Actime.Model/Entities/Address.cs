namespace Actime.Model.Entities
{
    public class Address
    {
        public int Id { get; set; }
        public required string Street { get; set; }
        public required string PostalCode { get; set; }
        public string? Coordinates { get; set; }
        public int CityId { get; set; }
        public string? CityName { get; set; }

        public City? City { get; set; }
    }
}
