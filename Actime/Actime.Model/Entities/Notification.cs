namespace Actime.Model.Entities
{
    public class Notification
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public required string Message { get; set; }
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsDeleted { get; set; }
    }
}
