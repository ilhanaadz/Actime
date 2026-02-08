using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using MembershipNotificationMessage = Actime.Model.Entities.MembershipNotificationMessage;

namespace Actime.Services.Services
{
    public class MembershipService : BaseCrudService<Model.Entities.Membership,MembershipSearchObject, Database.Membership, MembershipInsertRequest, MembershipUpdateRequest>, IMembershipService
    {
        private readonly IBus _bus;
        private int _previousMembershipStatusId;

        public MembershipService(ActimeContext context, IMapper mapper, IBus bus) : base(context, mapper)
        {
            _bus = bus ?? throw new ArgumentNullException(nameof(bus));
        }

        protected override IQueryable<Membership> ApplyFilter(IQueryable<Membership> query, MembershipSearchObject search)
        {
            if (search.IncludeUser)
            {
                query = query.Include(x => x.User);
            }

            if (search.IncludeOrganization)
            {
                query = query.Include(x => x.Organization);
            }

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

        protected override Task OnUpdating(Membership entity, MembershipUpdateRequest request)
        {
            _previousMembershipStatusId = entity.MembershipStatusId;
            return Task.CompletedTask;
        }

        protected override async Task OnUpdated(Membership entity)
        {
            // Check if enrollment status changed from Pending to Approved or Rejected
            if (_previousMembershipStatusId == 1 && entity.MembershipStatusId != 1)
            {
                await PublishMembershipNotificationAsync(entity);
            }
        }

        private async Task PublishMembershipNotificationAsync(Membership entity)
        {
            // Only notify for approved (2) or rejected (3) status
            if (entity.MembershipStatusId != 2 && entity.MembershipStatusId != 3)
                return;

            var organization = await _context.Set<Database.Organization>()
                .Where(o => o.Id == entity.OrganizationId)
                .Select(o => new { o.Name })
                .FirstOrDefaultAsync();

            if (organization == null)
                return;

            var message = new MembershipNotificationMessage
            {
                UserId = entity.UserId,
                OrganizationId = entity.OrganizationId,
                OrganizationName = organization.Name,
                MembershipStatusId = entity.MembershipStatusId,
                Timestamp = DateTime.Now
            };

            await _bus.PubSub.PublishAsync(message);
            Console.WriteLine($"[RabbitMQ] Published membership notification: User {entity.UserId}, Org '{organization.Name}', Status {entity.MembershipStatusId}");
        }

        public async Task<bool> CancelMembershipByOrganizationAsync(int userId, int organizationId)
        {
            // Find pending (1) or active (2) membership
            var membership = await _context.Set<Membership>()
                .FirstOrDefaultAsync(m =>
                    m.UserId == userId &&
                    m.OrganizationId == organizationId &&
                    (m.MembershipStatusId == 1 || m.MembershipStatusId == 2) && // Pending or Active
                    !m.IsDeleted);

            if (membership == null)
                return false;

            // Set membership status to cancelled (4)
            membership.MembershipStatusId = 4;
            membership.EndDate = DateTime.Now;
            membership.LastModifiedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }
    }
}
