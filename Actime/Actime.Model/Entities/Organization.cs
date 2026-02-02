namespace Actime.Model.Entities
{
    public class Organization
    {
        public int Id { get; set; }
        public required string Name { get; set; } //NOTE: Could be username (from user entity) or separate
        public required string Email { get; set; }
        public string? Description { get; set; }
        public string? LogoUrl { get; set; }
        public string? PhoneNumber { get; set; }
        public int UserId { get; set; }
        public int CategoryId { get; set; }
        public int AddressId { get; set; }
        public DateTime CreatedAt { get; init; } = DateTime.Now;
        public DateTime? LastModifiedAt { get; set; }

        public string? CategoryName { get; set; }
        public string? Address { get; set; }
        public int MembersCount { get; set; }
        public bool IsMember { get; set; }
        public int? MembershipStatusId { get; set; }
    }
}