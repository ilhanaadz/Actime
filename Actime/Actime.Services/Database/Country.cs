namespace Actime.Services.Database
{
    public  class Country
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public string? Code { get; set; }
        
        public virtual ICollection<City> Cities { get; set; } = new HashSet<City>();
    }
}
