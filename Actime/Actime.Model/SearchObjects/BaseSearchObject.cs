namespace Actime.Model.SearchObjects
{
    public class BaseSearchObject
    {
        public int? Page { get; set; }
        public int? PageSize { get; set; }
        public bool IncludeTotalCount { get; set; }
        public bool RetrieveAll { get; set; }
        public string? SortBy { get; set; }
        public bool SortDescending { get; set; }
    }
}
