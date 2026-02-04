using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Services.Services
{
    public class ParticipationService : BaseCrudService<Model.Entities.Participation, ParticipationSearchObject, Database.Participation, ParticipationInsertRequest, ParticipationUpdateRequest>, IParticipationService
    {
        private readonly INotificationService _notificationService;

        public ParticipationService(ActimeContext context, IMapper mapper, INotificationService notificationService) : base(context, mapper)
        {
            _notificationService = notificationService ?? throw new ArgumentNullException(nameof(notificationService));
        }

        protected override IQueryable<Database.Participation> ApplyFilter(IQueryable<Database.Participation> query, ParticipationSearchObject search)
        {
            if (!search.IncludeDeleted)
            {
                query = query.Where(x => !x.IsDeleted);
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.EventId.HasValue)
            {
                query = query.Where(x => x.EventId == search.EventId.Value);
            }

            if (search.AttendanceStatusId.HasValue)
            {
                query = query.Where(x => x.AttendanceStatusId == search.AttendanceStatusId.Value);
            }

            if (search.PaymentMethodId.HasValue)
            {
                query = query.Where(x => x.PaymentMethodId == search.PaymentMethodId.Value);
            }

            if (search.PaymentStatusId.HasValue)
            {
                query = query.Where(x => x.PaymentStatusId == search.PaymentStatusId.Value);
            }

            if (search.RegistrationDateFrom.HasValue)
            {
                query = query.Where(x => x.RegistrationDate >= search.RegistrationDateFrom.Value);
            }

            if (search.RegistrationDateTo.HasValue)
            {
                query = query.Where(x => x.RegistrationDate <= search.RegistrationDateTo.Value);
            }

            if (search.HasPayment.HasValue)
            {
                if (search.HasPayment.Value)
                {
                    query = query.Where(x => x.PaymentMethodId != null && x.PaymentStatusId != null);
                }
                else
                {
                    query = query.Where(x => x.PaymentMethodId == null || x.PaymentStatusId == null);
                }
            }

            query = query.OrderByDescending(x => x.RegistrationDate);

            return base.ApplyFilter(query, search);
        }

        protected override async Task<bool> OnDeleting(Database.Participation entity)
        {
            entity.IsDeleted = true;
            entity.DeletedAt = DateTime.Now;

            _context.Entry(entity).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            var eventData = await _context.Set<Database.Event>()
                .Where(e => e.Id == entity.EventId)
                .Select(e => new { e.Title })
                .FirstOrDefaultAsync();

            if (eventData != null)
            {
                var message = $"Your registration for event '{eventData.Title}' has been canceled.";

                var notificationDto = new NotificationInsertRequest
                {
                    UserId = entity.UserId,
                    Message = message,
                    IsRead = false
                };

                await _notificationService.CreateAsync(notificationDto);
            }

            return false; // Return false in order to disable hard delete
        }

        protected override async Task OnCreating(Database.Participation entity, ParticipationInsertRequest request)
        {
            entity.CreatedAt = DateTime.Now;

            if (entity.RegistrationDate == default)
            {
                entity.RegistrationDate = DateTime.Now;
            }

            // If AttendanceStatusId is not set (0), determine based on event
            if (entity.AttendanceStatusId == 0)
            {
                var eventEntity = await _context.Set<Database.Event>()
                    .FirstOrDefaultAsync(e => e.Id == entity.EventId);

                if (eventEntity != null && eventEntity.IsFree)
                {
                    // Free event: set as Going and Paid
                    entity.AttendanceStatusId = 2;  // Going
                    entity.PaymentStatusId = 2;     // Paid
                    entity.PaymentMethodId = 6;     // Other
                }
                else
                {
                    // Paid event: set as PendingResponse
                    entity.AttendanceStatusId = 1;  // PendingResponse
                    entity.PaymentStatusId = 1;     // Pending
                }
            }
        }

        protected override async Task OnCreated(Database.Participation entity)
        {
            var eventData = await _context.Set<Database.Event>()
                .Where(e => e.Id == entity.EventId)
                .Select(e => new { e.Title, e.Start })
                .FirstOrDefaultAsync();

            if (eventData != null)
            {
                var message = $"Successful registration for event '{eventData.Title}' which will be held on {eventData.Start:dd.MM.yyyy HH:mm}.";

                var notificationDto = new NotificationInsertRequest
                {
                    UserId = entity.UserId,
                    Message = message,
                    IsRead = false
                };

                await _notificationService.CreateAsync(notificationDto);
            }
        }

        public async Task<bool> UpdateAttendanceStatusAsync(int id, int attendanceStatusId)
        {
            var participation = await _context.Set<Database.Participation>().FindAsync(id);
            if (participation == null || participation.IsDeleted)
                return false;

            participation.AttendanceStatusId = attendanceStatusId;
            await _context.SaveChangesAsync();

            await SendAttendanceStatusNotificationAsync(participation, attendanceStatusId);

            return true;
        }

        public async Task<bool> UpdatePaymentStatusAsync(int id, int paymentStatusId)
        {
            var participation = await _context.Set<Database.Participation>().FindAsync(id);
            if (participation == null || participation.IsDeleted)
                return false;

            participation.PaymentStatusId = paymentStatusId;
            await _context.SaveChangesAsync();

            await SendPaymentStatusNotificationAsync(participation, paymentStatusId);
            
            return true;
        }

        private async Task SendAttendanceStatusNotificationAsync(Database.Participation participation, int attendanceStatusId)
        {
            var eventData = await _context.Set<Database.Event>()
                .Where(e => e.Id == participation.EventId)
                .Select(e => new { e.Title })
                .FirstOrDefaultAsync();

            var statusName = await _context.Set<AttendanceStatus>()
                .Where(s => s.Id == attendanceStatusId)
                .Select(s => s.Name)
                .FirstOrDefaultAsync();

            if (eventData != null && statusName != null)
            {
                var message = $"Attendance status for event '{eventData.Title}' has been changed to '{statusName}'.";

                var notificationDto = new NotificationInsertRequest
                {
                    UserId = participation.UserId,
                    Message = message,
                    IsRead = false
                };

                await _notificationService.CreateAsync(notificationDto);
            }
        }

        private async Task SendPaymentStatusNotificationAsync(Database.Participation participation, int paymentStatusId)
        {
            var eventData = await _context.Set<Database.Event>()
                .Where(e => e.Id == participation.EventId)
                .Select(e => new { e.Title })
                .FirstOrDefaultAsync();

            var statusName = await _context.Set<Database.PaymentStatus>()
                .Where(s => s.Id == paymentStatusId)
                .Select(s => s.Name)
                .FirstOrDefaultAsync();

            if (eventData != null && statusName != null)
            {
                var message = $"Payment status for event '{eventData.Title}' has been changed to '{statusName}'.";

                var notificationDto = new NotificationInsertRequest
                {
                    UserId = participation.UserId,
                    Message = message,
                    IsRead = false
                };

                await _notificationService.CreateAsync(notificationDto);
            }
        }

        public async Task<int> GetEventParticipantCountAsync(int eventId)
        {
            return await _context.Set<Database.Participation>()
                .Where(x => x.EventId == eventId && !x.IsDeleted)
                .CountAsync();
        }

        public async Task<List<Model.Entities.Participation>> GetUserParticipationsAsync(int userId)
        {
            var participations = await _context.Set<Database.Participation>()
                .Where(x => x.UserId == userId && !x.IsDeleted)
                .OrderByDescending(x => x.RegistrationDate)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.Participation>>(participations);
        }

        public async Task<List<Model.Entities.Event>> GetUserParticipatedEventsAsync(int userId)
        {
            var events = await _context.Set<Database.Participation>()
                .Where(x => x.UserId == userId && !x.IsDeleted)
                    .Include(x => x.Event)
                .OrderByDescending(x => x.RegistrationDate)
                .Select(x => x.Event)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.Event>>(events);
        }

        public async Task<List<Model.Entities.User>> GetEventParticipantsAsync(int eventId)
        {
            var participants = await _context.Set<Database.Participation>()
                .Where(x => x.EventId == eventId && !x.IsDeleted)
                .Include(x => x.User)
                .Select(x => x.User)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.User>>(participants);
        }

        public async Task<bool> CancelParticipationAsync(int eventId, int userId)
        {
            var participation = await _context.Set<Database.Participation>()
                .FirstOrDefaultAsync(x => x.EventId == eventId && x.UserId == userId && !x.IsDeleted);

            if (participation == null)
                return false;

            // Soft delete the participation
            participation.IsDeleted = true;
            participation.DeletedAt = DateTime.Now;

            // Update attendance status to NotGoing (4)
            participation.AttendanceStatusId = 4;

            await _context.SaveChangesAsync();

            // Send notification
            var eventData = await _context.Set<Database.Event>()
                .Where(e => e.Id == eventId)
                .Select(e => new { e.Title })
                .FirstOrDefaultAsync();

            if (eventData != null)
            {
                var message = $"You have cancelled your participation for event '{eventData.Title}'.";

                var notificationDto = new NotificationInsertRequest
                {
                    UserId = userId,
                    Message = message,
                    IsRead = false
                };

                await _notificationService.CreateAsync(notificationDto);
            }

            return true;
        }
    }
}