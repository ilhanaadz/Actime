namespace Actime.Model.SearchObjects
{
    public class EventSearchObject : TextSearchObject
    {
        public int? OrganizationId { get; set; }
        public int? EventStatusId { get; set; }

        /// <summary>
        /// If true, excludes events with Pending status from results.
        /// Used for public/anonymous endpoints.
        /// </summary>
        public bool ExcludePending { get; set; } = false;

        /// <summary>
        /// Current user ID used to determine IsEnrolled status.
        /// Set by controller from authenticated user context.
        /// </summary>
        public int? CurrentUserId { get; set; }
    }
}
