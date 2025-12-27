using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class FavoriteService : BaseCrudService<Model.Entities.Favorite, FavoriteSearchObject, Database.Favorite, FavoriteInsertRequest, FavoriteUpdateRequest>, IFavoriteService
    {
        public FavoriteService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Favorite> ApplyFilter(IQueryable<Favorite> query, FavoriteSearchObject search)
        {
            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.EntityId.HasValue)
            {
                query = query.Where(x => x.EntityId == search.EntityId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.EntityType))
            {
                query = query.Where(x => x.EntityType == search.EntityType);
            }

            return base.ApplyFilter(query, search);
        }
    }
}
