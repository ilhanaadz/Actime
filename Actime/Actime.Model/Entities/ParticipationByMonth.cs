namespace Actime.Model.Entities
{
    public class ParticipationByMonth
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public string MonthName { get; set; } = string.Empty;
        public int ParticipantsCount { get; set; }
    }
}
