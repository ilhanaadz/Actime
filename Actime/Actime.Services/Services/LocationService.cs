using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class LocationService : BaseCrudService<Model.Entities.Location, TextSearchObject, Location, LocationRequest, LocationRequest>, ILocationService
    {
        public LocationService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}