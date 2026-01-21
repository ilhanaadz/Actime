using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class CountryController : BaseController<Country, BaseSearchObject> 
    {
        public CountryController(ICountryService countryService) : base(countryService)
        {
        }

        [AllowAnonymous]
        public override Task<PagedResult<Country>> Get([FromQuery] BaseSearchObject? search = null)
        {
            return base.Get(search);
        }

        [AllowAnonymous]
        public override Task<Country?> GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
