namespace Actime.Model
{
    public class Organization
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public required string Email { get; set; }
        public string? Description { get; set; }
        public string? LogoUrl { get; set; }
        public string? PhoneNumber { get; set; }
        public int CategoryId { get; set; }
        public int AddressId { get; set; }
        public DateTime CreatedAt { get; init; } = DateTime.Now;
        public DateTime? LastModifiedAt { get; set; }

        //NOTE: Can have a schedule list, should I add it as virtual?
    }
}