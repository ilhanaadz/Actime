namespace Actime.Services.Database
{
    public class City
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public int CountryId { get; set; }

        public virtual Country Country { get; set; } = null!;
    }
}
