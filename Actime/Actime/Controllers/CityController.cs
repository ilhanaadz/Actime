using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class CityController : BaseCrudController<City, TextSearchObject, CityRequest, CityRequest>
    {
        public CityController(ICityService cityService) : base(cityService)
        {
        }

        [AllowAnonymous]
        public override Task<PagedResult<City>> Get([FromQuery] TextSearchObject? search = null)
        {
            return base.Get(search);
        }

        [AllowAnonymous]
        public override Task<City?> GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
