namespace Actime.Services.Database
{
    public class Organization : SoftDeleteEntity
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public required string Email { get; set; }
        public string? Description { get; set; }
        public string? LogoUrl { get; set; }
        public string? PhoneNumber { get; set; }
        public int CategoryId { get; set; }
        public int AddressId { get; set; }

        public virtual Category Category { get; set; } = null!;
        public virtual Address Address { get; set; } = null!;
        public virtual ICollection<Membership> Memberships { get; set; } = new HashSet<Membership>();
        public virtual ICollection<Review> Reviews { get; set; } = new HashSet<Review>();
    }
}