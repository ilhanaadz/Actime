namespace Actime.Model.SearchObjects
{
    public class OrganizationSearchObject : TextSearchObject
    {
        public int? CategoryId { get; set; }

        public bool IncludeUnconfirmed { get; set; } = false;

        /// <summary>
        /// Filter by email confirmation status (admin only).
        /// null = all, true = verified only, false = pending only
        /// </summary>
        public bool? EmailConfirmed { get; set; } = null;
    }
}
