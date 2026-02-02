using Actime.Model.Constants;

namespace Actime.Model.Requests
{
    public class EventInsertRequest
    {
        public int OrganizationId { get; set; }
        public required string Title { get; set; }
        public string? Description { get; set; }
        public DateTime Start { get; set; }
        public DateTime End { get; set; }
        public int LocationId { get; set; }
        public int? MaxParticipants { get; set; }
        public bool IsFree { get; set; }
        public decimal Price { get; set; }
        public int ActivityTypeId { get; set; }

        /// <summary>
        /// Event status. Defaults to Pending if not specified.
        /// </summary>
        public int EventStatusId { get; set; } = (int)EventStatus.Pending;
    }
}
