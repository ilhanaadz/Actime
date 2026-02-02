namespace Actime.Model.Entities
{
    public class Event
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public required string Title { get; set; }
        public string? Description { get; set; }
        public DateTime Start { get; set; }
        public DateTime End { get; set; }
        public int LocationId { get; set; }
        public int? MaxParticipants { get; set; }
        public bool IsFree { get; set; }
        public decimal Price { get; set; }
        public int EventStatusId { get; set; }
        public int ActivityTypeId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime LastModifiedAt { get; set; }

        public string? OrganizationName { get; set; }
        public string? OrganizationLogoUrl { get; set; }
        public string? Location { get; set; }
        public string? ActivityTypeName { get; set; }
        public int ParticipantsCount { get; set; }

        /// <summary>
        /// Indicates if the current user is enrolled in this event.
        /// Populated based on CurrentUserId from search object.
        /// </summary>
        public bool IsEnrolled { get; set; }
    }
}
