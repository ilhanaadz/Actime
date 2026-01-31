using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class AddressService : BaseCrudService<Model.Entities.Address, TextSearchObject, Address, AddressRequest, AddressRequest>, IAddressService
    {
        public AddressService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Address> ApplyFilter(IQueryable<Address> query, TextSearchObject search)
        {
            query = query
                .Include(a => a.City)
                    .ThenInclude(c => c!.Country);

            if (!string.IsNullOrWhiteSpace(search.Text))
            {
                var searchText = search.Text.Trim().ToLower();

                query = query.Where(a =>
                    a.Street.ToLower().Contains(searchText)
                    || a.PostalCode.ToLower().Contains(searchText)
                    || (a.City != null && a.City.Name.ToLower().Contains(searchText))
                    || (a.Coordinates != null && a.Coordinates.ToLower().Contains(searchText)));
            }

            return base.ApplyFilter(query, search);
        }
    }
}