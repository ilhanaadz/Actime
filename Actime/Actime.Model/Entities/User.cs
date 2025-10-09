namespace Actime.Model.Entities
{
    public class User
    {
        public int Id { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public required string Username { get; set; }
        public required string Email { get; set; }
        public string? PhoneNumber { get; set; }
        public string? ProfileImageUrl { get; set; }
        public DateTime DateOfBirth { get; set; }
        public bool IsDeleted { get; set; } = true;
        public DateTime CreatedAt { get; init; } = DateTime.Now;
        public DateTime? LastModifiedAt { get; set; }
    }
}
