namespace Actime.Model.SearchObjects
{
    public class UserSearchObject : TextSearchObject
    {
        public bool IncludeOrganizations { get; set; } = false;
    }
}
