using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace Actime.Services.Database
{
    public class ActimeContextFactory : IDesignTimeDbContextFactory<ActimeContext>
    {
        public ActimeContext CreateDbContext(string[] args)
        {
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Path.Combine(Directory.GetCurrentDirectory(), "..", "Actime"))
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .Build();

            var connectionString = configuration.GetConnectionString("DefaultConnection");

            var optionsBuilder = new DbContextOptionsBuilder<ActimeContext>();
            optionsBuilder.UseSqlServer(connectionString);

            return new ActimeContext(optionsBuilder.Options);
        }
    }
}
