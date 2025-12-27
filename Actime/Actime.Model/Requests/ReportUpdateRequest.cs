namespace Actime.Model.Requests
{
    public class ReportUpdateRequest
    {
        public int ReportTypeId { get; set; }
        public required string ReportData { get; set; }
    }
}
