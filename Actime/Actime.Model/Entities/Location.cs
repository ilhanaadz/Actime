namespace Actime.Model.Entities
{
    public class Location
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public int AddressId { get; set; }
        public int? Capacity { get; set; }
        public string? Description { get; set; }
        public string? ContactInfo { get; set; }

        public Address? Address { get; set; }
    }
}
