namespace Actime.Model.Requests
{
    public class NotificationUpdateRequest
    {
        public required string Message { get; set; }
        public bool IsRead { get; set; }
    }
}
