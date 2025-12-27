using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;

namespace Actime.Controllers
{
    public class FavoriteController : BaseCrudController<Favorite, TextSearchObject, FavoriteInsertRequest, FavoriteUpdateRequest>
    {
        public FavoriteController(IFavoriteService favoriteService) : base(favoriteService)
        {
        }
    }
}
