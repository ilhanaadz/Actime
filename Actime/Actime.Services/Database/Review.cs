namespace Actime.Services.Database
{
    public class Review : BaseEntity
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int OrganizationId { get; set; }
        public int Score { get; set; }
        public string? Text { get; set; }

        public virtual User User { get; set; } = null!;
        public virtual Organization Organization { get; set; } = null!;
    }
}
