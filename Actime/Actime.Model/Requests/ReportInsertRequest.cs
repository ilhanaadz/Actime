namespace Actime.Model.Requests
{
    public class ReportInsertRequest
    {
        public int OrganizationId { get; set; }
        public int ReportTypeId { get; set; }
        public required string ReportData { get; set; }
    }
}
