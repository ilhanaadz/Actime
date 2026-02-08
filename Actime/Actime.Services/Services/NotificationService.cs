using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class NotificationService : BaseCrudService<Model.Entities.Notification, NotificationSearchObject, Database.Notification, NotificationInsertRequest, NotificationUpdateRequest>, INotificationService
    {
        // Optional callback for sending real-time notifications
        public static Func<int, string, Task>? OnNotificationCreated { get; set; }

        public NotificationService(Database.ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Database.Notification> ApplyFilter(IQueryable<Database.Notification> query, NotificationSearchObject search)
        {
            if (!search.IncludeDeleted)
            {
                query = query.Where(x => !x.IsDeleted);
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.IsRead.HasValue)
            {
                query = query.Where(x => x.IsRead == search.IsRead.Value);
            }

            if (search.CreatedFrom.HasValue)
            {
                query = query.Where(x => x.CreatedAt >= search.CreatedFrom.Value);
            }

            if (search.CreatedTo.HasValue)
            {
                query = query.Where(x => x.CreatedAt <= search.CreatedTo.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.MessageContains))
            {
                query = query.Where(x => x.Message.Contains(search.MessageContains));
            }

            query = query.OrderByDescending(x => x.CreatedAt);

            return base.ApplyFilter(query, search);
        }

        protected override async Task<bool> OnDeleting(Notification entity)
        {
            entity.IsDeleted = true;
            entity.DeletedAt = DateTime.Now;

            _context.Entry(entity).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return false; // Return false to disable hard delete
        }

        protected override Task OnCreating(Notification entity, NotificationInsertRequest request)
        {
            entity.CreatedAt = DateTime.Now;
            return Task.CompletedTask;
        }

        protected override async Task OnCreated(Notification entity)
        {
            // Trigger optional callback for real-time notifications
            if (OnNotificationCreated != null)
            {
                try
                {
                    await OnNotificationCreated(entity.UserId, entity.Message);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[Notification] Failed to send real-time notification: {ex.Message}");
                }
            }
        }

        public async Task<bool> MarkAsReadAsync(int id)
        {
            var notification = await _context.Set<Notification>().FindAsync(id);
            if (notification == null || notification.IsDeleted)
                return false;

            notification.IsRead = true;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> MarkAllAsReadAsync(int userId)
        {
            var notifications = await _context.Set<Notification>()
                .Where(x => x.UserId == userId && !x.IsRead && !x.IsDeleted)
                .ToListAsync();

            if (!notifications.Any())
                return false;

            foreach (var notification in notifications)
            {
                notification.IsRead = true;
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<int> GetUnreadCountAsync(int userId)
        {
            return await _context.Set<Notification>()
                .Where(x => x.UserId == userId && !x.IsRead && !x.IsDeleted)
                .CountAsync();
        }
    }
}
