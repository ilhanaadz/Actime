namespace Actime.Services.Database
{
    public abstract class SoftDeleteEntity : BaseEntity
    {
        public DateTime? DeletedAt { get; set; }
        public string? DeletedBy { get; set; }
        public bool IsDeleted { get; set; } = false;
    }
}