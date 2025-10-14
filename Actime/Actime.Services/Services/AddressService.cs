using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class AddressService : BaseCrudService<Model.Entities.Address, TextSearchObject, Address, AddressRequest, AddressRequest>, IAddressService
    {
        public AddressService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Address> ApplyFilter(IQueryable<Address> query, TextSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Text))
            {
                var searchText = search.Text.Trim().ToLower();

                query = query.Where(c =>
                    c.Street.ToLower().Contains(searchText)
                    || c.PostalCode.ToLower().Contains(searchText)
                    || c.City.Name.ToLower().Contains(searchText)
                    || (c.Coordinates != null && c.Coordinates.ToLower().Contains(searchText)));
            }

            return base.ApplyFilter(query, search);
        }
    }
}