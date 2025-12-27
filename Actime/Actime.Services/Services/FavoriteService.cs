using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class FavoriteService : BaseCrudService<Model.Entities.Favorite, TextSearchObject, Database.Favorite, FavoriteInsertRequest, FavoriteUpdateRequest>, IFavoriteService
    {
        public FavoriteService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
