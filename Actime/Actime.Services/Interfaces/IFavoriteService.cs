using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IFavoriteService : ICrudService<Favorite, TextSearchObject, FavoriteInsertRequest, FavoriteUpdateRequest>
    {
    }
}
