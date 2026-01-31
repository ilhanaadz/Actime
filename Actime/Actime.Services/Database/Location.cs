namespace Actime.Services.Database
{
    public class Location
    {
        public int Id { get; set; }
        public int AddressId { get; set; }
        public string Name { get; set; } = null!;
        public int? Capacity { get; set; }
        public string? Description { get; set; }
        public string? ContactInfo { get; set; }

        public virtual Address Address { get; set; } = null!;
    }
}
