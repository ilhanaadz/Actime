using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class MembershipService : BaseCrudService<Model.Entities.Membership,MembershipSearchObject, Database.Membership, MembershipInsertRequest, MembershipUpdateRequest>, IMembershipService
    {
        public MembershipService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Membership> ApplyFilter(IQueryable<Membership> query, MembershipSearchObject search)
        {
            if (!search.IncludeDeleted)
            {
                query = query.Where(x => !x.IsDeleted);
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.OrganizationId.HasValue)
            {
                query = query.Where(x => x.OrganizationId == search.OrganizationId.Value);
            }

            if (search.MembershipStatusId.HasValue)
            {
                query = query.Where(x => x.MembershipStatusId == search.MembershipStatusId.Value);
            }

            if (search.StartDateFrom.HasValue)
            {
                query = query.Where(x => x.StartDate >= search.StartDateFrom.Value);
            }

            if (search.StartDateTo.HasValue)
            {
                query = query.Where(x => x.StartDate <= search.StartDateTo.Value);
            }

            if (search.EndDateFrom.HasValue)
            {
                query = query.Where(x => x.EndDate >= search.EndDateFrom.Value);
            }

            if (search.EndDateTo.HasValue)
            {
                query = query.Where(x => x.EndDate <= search.EndDateTo.Value);
            }

            if (search.IsActive.HasValue)
            {
                var now = DateTime.Now;
                if (search.IsActive.Value)
                {
                    query = query.Where(x => x.StartDate <= now && (x.EndDate == null || x.EndDate >= now));
                }
                else
                {
                    query = query.Where(x => x.StartDate > now || (x.EndDate != null && x.EndDate < now));
                }
            }

            return base.ApplyFilter(query, search);
        }

        protected override Task OnCreating(Membership entity, MembershipInsertRequest request)
        {
            if (entity.StartDate == default)
            {
                entity.StartDate = DateTime.Now;
            }

            return Task.CompletedTask;
        }
    }
}
