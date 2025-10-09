using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;

namespace Actime.Controllers
{
    public class CityController : BaseCrudController<City, TextSearchObject, CityRequest, CityRequest>
    {
        public CityController(ICityService cityService) : base(cityService)
        {
        }
    }
}
