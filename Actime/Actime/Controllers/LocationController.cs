using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;

namespace Actime.Controllers
{
    public class LocationController : BaseCrudController<Location, TextSearchObject, LocationRequest, LocationRequest>
    {
        public LocationController(ILocationService locationService) : base(locationService)
        {
        }
    }
}