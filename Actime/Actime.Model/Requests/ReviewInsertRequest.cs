namespace Actime.Model.Requests
{
    public class ReviewInsertRequest
    {
        public int UserId { get; set; }
        public int OrganizationId { get; set; }
        public int Score { get; set; }
        public string? Text { get; set; }
    }
}
