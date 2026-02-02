namespace Actime.Model.Entities
{
    public class EventInteraction
    {
        public uint UserId { get; set; }
        public uint EventId { get; set; }

        // Implicit feedback
        public float Label { get; set; }
    }
}
