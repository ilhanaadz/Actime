using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;

namespace Actime.Services
{
    public interface ICityService : ICrudService<City, TextSearchObject, CityRequest, CityRequest>
    {

    }
}
