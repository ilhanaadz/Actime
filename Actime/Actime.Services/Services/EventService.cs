using Actime.Model.Common;
using Actime.Model.Constants;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Actime.Services.Services
{
    public class EventService : BaseCrudService<Model.Entities.Event, EventSearchObject, Database.Event, EventInsertRequest, EventUpdateRequest>, IEventService
    {
        public EventService(Database.ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<Model.Entities.Event>> GetAsync(EventSearchObject search)
        {
            search ??= new EventSearchObject();

            var query = _context.Set<Database.Event>()
                .Include(e => e.Organization)
                .Include(e => e.Location)
                .Include(e => e.ActivityType)
                .Include(e => e.Participations)
                .AsQueryable();

            query = ApplyFilter(query, search);
            query = ApplySorting(query, search);

            int? totalCount = search.IncludeTotalCount ? await query.CountAsync() : null;

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    int skip = (search.Page.Value - 1) * search.PageSize.Value;
                    query = query.Skip(skip).Take(search.PageSize.Value);
                }
                else if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            var result = list.Select(e => MapEventWithRelations(e, search.CurrentUserId)).ToList();

            return new PagedResult<Model.Entities.Event>
            {
                Items = result,
                TotalCount = totalCount ?? result.Count
            };
        }

        public override async Task<Model.Entities.Event?> GetByIdAsync(int id)
        {
            return await GetByIdAsync(id, null);
        }

        public async Task<Model.Entities.Event?> GetByIdAsync(int id, int? currentUserId)
        {
            var entity = await _context.Set<Database.Event>()
                .Include(e => e.Organization)
                .Include(e => e.Location)
                .Include(e => e.ActivityType)
                .Include(e => e.Participations)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (entity == null)
                return null;

            return MapEventWithRelations(entity, currentUserId);
        }

        private Model.Entities.Event MapEventWithRelations(Database.Event entity, int? currentUserId)
        {
            var mapped = _mapper.Map<Model.Entities.Event>(entity);
            
            mapped.OrganizationName = entity.Organization?.Name;
            mapped.OrganizationLogoUrl = entity.Organization?.LogoUrl;
            mapped.Location = entity.Location?.Name;
            mapped.ActivityTypeName = entity.ActivityType?.Name;
            mapped.ParticipantsCount = entity.Participations?.Count ?? 0;

            // Check if current user is enrolled in this event
            if (currentUserId.HasValue && entity.Participations != null)
            {
                mapped.IsEnrolled = entity.Participations.Any(p => p.UserId == currentUserId.Value);
            }

            return mapped;
        }

        protected override Task OnCreated(Database.Event entity)
        {
            var createdEvent = _mapper.Map<Model.Entities.Event>(entity);

            createdEvent.OrganizationName = _context.Organizations.Find(entity.OrganizationId)?.Name;
            
            var services = new ServiceCollection();

            services.AddEasyNetQ("host=localhost");

            var provider = services.BuildServiceProvider();
            var bus = provider.GetRequiredService<IBus>();

            bus.PubSub.PublishAsync(createdEvent);

            return base.OnCreated(entity);
        }

        protected override IQueryable<Database.Event> ApplyFilter(IQueryable<Database.Event> query, EventSearchObject search)
        {
            if (search.OrganizationId.HasValue)
            {
                query = query.Where(e => e.OrganizationId == search.OrganizationId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Text))
            {
                query = query.Where(e => e.Title.Contains(search.Text));
            }

            // Filter by specific status
            if (search.EventStatusId.HasValue)
            {
                query = query.Where(e => e.EventStatusId == search.EventStatusId.Value);
            }

            // Exclude pending events (for public/anonymous endpoints)
            if (search.ExcludePending)
            {
                query = query.Where(e => e.EventStatusId != (int)Model.Constants.EventStatus.Pending);
            }

            if (search.FromDate != null)
            {
                query = query.Where(e => e.Start >= search.FromDate);
            }

            if (search.ToDate != null)
            {
                query = query.Where(e => e.End <= search.ToDate);
            }

            return query;
        }

        protected override Task OnUpdating(Database.Event entity, EventUpdateRequest request)
        {
            // Validate status transition if EventStatusId is being changed
            if (request.EventStatusId.HasValue && request.EventStatusId.Value != entity.EventStatusId)
            {
                var currentStatus = (EventStatus)entity.EventStatusId;
                var newStatus = (EventStatus)request.EventStatusId.Value;

                if (!IsValidStatusTransition(currentStatus, newStatus))
                {
                    throw new InvalidOperationException(
                        $"Invalid status transition from '{currentStatus}' to '{newStatus}'.");
                }
            }

            // Update LastModifiedAt
            entity.LastModifiedAt = DateTime.UtcNow;

            return Task.CompletedTask;
        }

        /// <summary>
        /// State machine: Validates if status transition is allowed
        /// </summary>
        private static bool IsValidStatusTransition(EventStatus current, EventStatus target)
        {
            var validTransitions = GetValidTransitions(current);
            return validTransitions.Contains(target);
        }

        /// <summary>
        /// State machine: Returns valid next statuses for a given status
        /// </summary>
        private static List<EventStatus> GetValidTransitions(EventStatus status)
        {
            return status switch
            {
                EventStatus.Pending => [EventStatus.Upcoming, EventStatus.Cancelled],
                EventStatus.Upcoming => [EventStatus.InProgress, EventStatus.Postponed, EventStatus.Rescheduled, EventStatus.Cancelled],
                EventStatus.InProgress => [EventStatus.Completed, EventStatus.Postponed, EventStatus.Cancelled],
                EventStatus.Completed => [], // Terminal state
                EventStatus.Cancelled => [], // Terminal state
                EventStatus.Postponed => [EventStatus.Upcoming, EventStatus.Rescheduled, EventStatus.Cancelled],
                EventStatus.Rescheduled => [EventStatus.Upcoming, EventStatus.InProgress, EventStatus.Cancelled],
                _ => []
            };
        }
    }
}
