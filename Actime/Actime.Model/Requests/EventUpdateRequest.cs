namespace Actime.Model.Requests
{
    public class EventUpdateRequest
    {
        public string? Title { get; set; }
        public string? Description { get; set; }
        public DateTime? Start { get; set; }
        public DateTime? End { get; set; }
        public int? LocationId { get; set; }
        public int? MaxParticipants { get; set; }
        public bool? IsFree { get; set; }
        public decimal? Price { get; set; }
        public int? EventStatusId { get; set; }
        public int? ActivityTypeId { get; set; }
    }
}