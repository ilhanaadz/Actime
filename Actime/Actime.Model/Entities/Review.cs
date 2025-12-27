namespace Actime.Model.Entities
{
    public class Review
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int OrganizationId { get; set; }
        public int Score { get; set; }
        public string? Text { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
