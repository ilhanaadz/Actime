namespace Actime.Model.Entities
{
    public class EventParticipation
    {
        public int EventId { get; set; }
        public string EventName { get; set; } = string.Empty;
        public int ParticipantsCount { get; set; }
    }
}
