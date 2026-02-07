using Actime.Model.Entities;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.ML;
using Microsoft.ML.Trainers;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class EventRecommenderService : IEventRecommenderService
    {
        private readonly MLContext _mlContext;
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly IMapper _mapper;

        private ITransformer? _model;
        private readonly object _modelLock = new();

        public EventRecommenderService(IServiceScopeFactory scopeFactory, IMapper mapper)
        {
            _mlContext = new MLContext(seed: 42);
            _scopeFactory = scopeFactory;
            _mapper = mapper;
        }

        public void TrainModel()
        {
            lock (_modelLock)
            {
                using var scope = _scopeFactory.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<ActimeContext>();

                var interactions = context.Participations
                    .Select(x => new EventInteraction
                    {
                        UserId = (uint)x.UserId,
                        EventId = (uint)x.EventId,
                        Label = 1f
                    })
                    .ToList();

                if (!interactions.Any())
                    return;

                var data = _mlContext.Data.LoadFromEnumerable(interactions);

                var pipeline =
                    _mlContext.Transforms.Conversion.MapValueToKey(
                        outputColumnName: "UserIdEncoded",
                        inputColumnName: nameof(EventInteraction.UserId))

                    .Append(_mlContext.Transforms.Conversion.MapValueToKey(
                        outputColumnName: "EventIdEncoded",
                        inputColumnName: nameof(EventInteraction.EventId)))

                    .Append(_mlContext.Recommendation().Trainers.MatrixFactorization(
                        new MatrixFactorizationTrainer.Options
                        {
                            MatrixColumnIndexColumnName = "UserIdEncoded",
                            MatrixRowIndexColumnName = "EventIdEncoded",
                            LabelColumnName = nameof(EventInteraction.Label),
                            LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                            Alpha = 0.01,
                            Lambda = 0.025,
                            NumberOfIterations = 100
                        }));

                _model = pipeline.Fit(data);
            }
        }

        public List<Model.Entities.Event> RecommendEvents(int userId, int numberOfResults)
        {
            if (_model == null)
            {
                lock (_modelLock)
                {
                    if (_model == null)
                        TrainModel();
                }
            }

            if (_model == null)
                return new();

            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ActimeContext>();

            var userEventIds = context.Participations
                .Where(p => p.UserId == userId)
                .Select(p => p.EventId)
                .ToHashSet();

            // Cold start fallback
            if (!userEventIds.Any())
            {
                var popularEvents = context.Events
                    .Include(e => e.Organization)
                    .Include(e => e.Location)
                    .Include(e => e.ActivityType)
                    .Include(e => e.Participations)
                    .OrderByDescending(e => e.Participations.Count)
                    .Take(numberOfResults)
                    .ToList();

                return MapEventsWithRelations(popularEvents);
            }

            var candidateEventIds = context.Events
                .Where(e => !userEventIds.Contains(e.Id))
                .Select(e => e.Id)
                .ToList();

            if (!candidateEventIds.Any())
                return new();

            var predictionEngine =
                _mlContext.Model.CreatePredictionEngine<EventInteraction, EventPrediction>(_model);

            var topEventIds = candidateEventIds
                .Select(eventId => new
                {
                    EventId = eventId,
                    Score = predictionEngine.Predict(new EventInteraction
                    {
                        UserId = (uint)userId,
                        EventId = (uint)eventId
                    }).Score
                })
                .OrderByDescending(x => x.Score)
                .Take(numberOfResults)
                .Select(x => x.EventId)
                .ToList();

            var topEvents = context.Events
                .Include(e => e.Organization)
                .Include(e => e.Location)
                .Include(e => e.ActivityType)
                .Include(e => e.Participations)
                .Where(e => topEventIds.Contains(e.Id))
                .ToList();

            return MapEventsWithRelations(topEvents);
        }

        private List<Model.Entities.Event> MapEventsWithRelations(List<Database.Event> entities)
        {
            return entities.Select(entity =>
            {
                var mapped = _mapper.Map<Model.Entities.Event>(entity);

                mapped.OrganizationName = entity.Organization?.Name;
                mapped.OrganizationLogoUrl = entity.Organization?.LogoUrl;
                mapped.Location = entity.Location?.Name;
                mapped.ActivityTypeName = entity.ActivityType?.Name;
                mapped.ParticipantsCount = entity.Participations?.Count ?? 0;

                return mapped;
            }).ToList();
        }
    }
}
