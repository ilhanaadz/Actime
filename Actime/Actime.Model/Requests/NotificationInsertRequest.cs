namespace Actime.Model.Requests
{
    public class NotificationInsertRequest
    {
        public int UserId { get; set; }
        public required string Message { get; set; }
        public bool IsRead { get; set; } = false;
    }
}
