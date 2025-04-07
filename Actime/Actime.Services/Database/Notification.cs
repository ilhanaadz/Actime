namespace Actime.Services.Database
{
    public class Notification : SoftDeleteEntity
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public required string Message { get; set; }
        public bool IsRead { get; set; }

        public virtual User User { get; set; } = null!;
    }
}
