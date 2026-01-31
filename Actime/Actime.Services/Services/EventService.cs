using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class EventService : BaseCrudService<Model.Entities.Event, EventSearchObject, Event, EventInsertRequest, EventUpdateRequest>, IEventService
    {
        public EventService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Event> ApplyFilter(IQueryable<Event> query, EventSearchObject search)
        {
            if (search.OrganizationId.HasValue)
            {
                query = query.Where(e => e.OrganizationId == search.OrganizationId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Text))
            {
                query = query.Where(e => e.Title.Contains(search.Text) ||
                                        (e.Description != null && e.Description.Contains(search.Text)));
            }

            return query;
        }
    }
}
