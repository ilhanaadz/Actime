namespace Actime.Services.Database
{
    public class Event : SoftDeleteEntity
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

        public virtual Organization Organization { get; set; } = null!;


    }
}
