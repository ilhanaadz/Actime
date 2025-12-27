namespace Actime.Model.Requests
{
    public class ScheduleInsertRequest
    {
        public int OrganizationId { get; set; }
        public required string DayOfWeek { get; set; }
        public TimeOnly? StartTime { get; set; }
        public TimeOnly? EndTime { get; set; }
        public int ActivityTypeId { get; set; }
        public string? Description { get; set; }
        public int LocationId { get; set; }
    }
}
