using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class LocationController : BaseCrudController<Location, TextSearchObject, LocationRequest, LocationRequest>
    {
        public LocationController(ILocationService locationService) : base(locationService)
        {
        }

        [AllowAnonymous]
        public override Task<PagedResult<Location>> Get([FromQuery] TextSearchObject? search = null)
        {
            return base.Get(search);
        }

        [AllowAnonymous]
        public override Task<Location?> GetById(int id)
        {
            return base.GetById(id);
        }
    }
}