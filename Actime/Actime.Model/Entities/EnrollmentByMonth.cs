namespace Actime.Model.Entities
{
    public class EnrollmentByMonth
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public string MonthName { get; set; } = string.Empty;
        public int MembersCount { get; set; }
    }
}
