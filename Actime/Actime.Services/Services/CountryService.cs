using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class CountryService : BaseService<Model.Entities.Country, BaseSearchObject, Country>, ICountryService
    {
        public CountryService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
