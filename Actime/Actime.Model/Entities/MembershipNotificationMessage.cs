namespace Actime.Model.Entities
{
    public class MembershipNotificationMessage
    {
        public int UserId { get; set; }
        public int OrganizationId { get; set; }
        public string OrganizationName { get; set; } = string.Empty;
        public int MembershipStatusId { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
