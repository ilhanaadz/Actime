namespace Actime.Model.SearchObjects
{
    public class ScheduleSearchObject : BaseSearchObject
    {
        public int? OrganizationId { get; set; }
        public string? DayOfWeek { get; set; }
        public int? ActivityTypeId { get; set; }
        public int? LocationId { get; set; }
        public TimeOnly? StartTimeFrom { get; set; }
        public TimeOnly? StartTimeTo { get; set; }
    }
}
