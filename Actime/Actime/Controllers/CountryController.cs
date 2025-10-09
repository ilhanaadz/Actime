using Actime.Model.Entities;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;

namespace Actime.Controllers
{
    public class CountryController : BaseController<Country, BaseSearchObject> 
    {
        public CountryController(ICountryService countryService) : base(countryService)
        {
        }
    }
}
