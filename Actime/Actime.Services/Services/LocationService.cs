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
    }
}