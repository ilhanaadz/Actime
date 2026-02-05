using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class CityService : BaseCrudService<Model.Entities.City, TextSearchObject, City, CityRequest, CityRequest>, ICityService
    {
        public CityService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<City> ApplyFilter(IQueryable<City> query, TextSearchObject search)
        {
            query = query.Include(c => c.Country);

            if (!string.IsNullOrWhiteSpace(search.Text))
            {
                var searchText = search.Text.Trim().ToLower();

                query = query.Where(c =>
                    c.Name.ToLower().Contains(searchText)
                    || (c.Country != null && c.Country.Name.ToLower().Contains(searchText)));
            }

            return base.ApplyFilter(query, search);
        }

        protected override async Task OnCreating(City entity, CityRequest request)
        {
            var exists = await _context.Cities
                .AnyAsync(c => c.Name.ToLower() == entity.Name.ToLower());

            if (exists)
            {
                throw new InvalidOperationException($"City with name '{entity.Name}' already exists.");
            }

            await base.OnCreating(entity, request);
        }
    }
}