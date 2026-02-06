namespace Actime.Services.Database
{
    public class Organization : SoftDeleteEntity
    {
        public required string Name { get; set; }
        public required string Email { get; set; }
        public string? Description { get; set; }
        public string? LogoUrl { get; set; }
        public string? PhoneNumber { get; set; }
        public int CategoryId { get; set; }
        public int AddressId { get; set; }

        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public virtual Category Category { get; set; } = null!;
        public virtual Address Address { get; set; } = null!;
        public virtual ICollection<Membership> Memberships { get; set; } = new HashSet<Membership>();
        public virtual ICollection<Event> Events { get; set; } = new HashSet<Event>();
        public virtual ICollection<Review> Reviews { get; set; } = new HashSet<Review>();
    }
}