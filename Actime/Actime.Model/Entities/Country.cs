namespace Actime.Model.Entities
{
    public class Country
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public string? Code { get; set; }
    }
}