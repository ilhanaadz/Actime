namespace Actime.Model.Entities
{
    /// <summary>
    /// DTO for organization participations summary (events with participant counts)
    /// </summary>
    public class EventParticipation
    {
        public int EventId { get; set; }
        public string EventName { get; set; } = string.Empty;
        public int ParticipantsCount { get; set; }
    }
}
