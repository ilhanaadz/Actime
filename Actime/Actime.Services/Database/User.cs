namespace Actime.Services.Database
{
    public class User : SoftDeleteEntity
    {
        public int Id { get; set; }
        public required string Email { get; set; }
        public required string Username { get; set; }
        public required string PasswordHash { get; set; }
        public required string PasswordSalt { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? PhoneNumber { get; set; }
        public string? ProfileImageUrl { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public int RoleId { get; set; }

        public virtual Role Role { get; set; } = null!;
    }
}