using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class LocationService : BaseCrudService<Model.Entities.Location, TextSearchObject, Location, LocationRequest, LocationRequest>, ILocationService
    {
        public LocationService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Location> ApplyFilter(IQueryable<Location> query, TextSearchObject search)
        {
            query = query
                .Include(l => l.Address)
                    .ThenInclude(a => a!.City)
                        .ThenInclude(c => c!.Country);

            if (!string.IsNullOrWhiteSpace(search.Text))
            {
                var searchText = search.Text.Trim().ToLower();

                query = query.Where(l =>
                    l.Name.ToLower().Contains(searchText)
                    || (l.Description != null && l.Description.ToLower().Contains(searchText))
                    || (l.Address != null && l.Address.Street.ToLower().Contains(searchText))
                    || (l.Address != null && l.Address.City != null && l.Address.City.Name.ToLower().Contains(searchText)));
            }

            return base.ApplyFilter(query, search);
        }

        protected override async Task OnCreating(Location entity, LocationRequest request)
        {
            var exists = await _context.Locations
                .AnyAsync(l => l.Name.ToLower() == entity.Name.ToLower()
                            && l.AddressId == entity.AddressId);

            if (exists)
            {
                var address = await _context.Addresses
                    .Include(a => a.City)
                    .FirstOrDefaultAsync(a => a.Id == entity.AddressId);
                throw new InvalidOperationException($"Location with name '{entity.Name}' at address '{address?.Street}, {address?.City?.Name}' already exists.");
            }

            await base.OnCreating(entity, request);
        }
    }
}