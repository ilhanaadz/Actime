using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

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

            // Filter out organization favorites where:
            // - The organization is deleted
            // - The organization owner hasn't confirmed their email
            query = query.Where(f =>
                f.EntityType != "Organization" ||
                _context.Organizations
                    .Include(o => o.User)
                    .Any(o => o.Id == f.EntityId
                        && !o.IsDeleted
                        && o.User.EmailConfirmed));

            // Filter out event favorites where:
            // - The event is deleted
            // - The event's organization is deleted
            // - The event's organization owner hasn't confirmed their email
            query = query.Where(f =>
                f.EntityType != "Event" ||
                _context.Events
                    .Include(e => e.Organization)
                        .ThenInclude(o => o.User)
                    .Any(e => e.Id == f.EntityId
                        && !e.IsDeleted
                        && !e.Organization.IsDeleted
                        && e.Organization.User.EmailConfirmed));

            return base.ApplyFilter(query, search);
        }
    }
}
