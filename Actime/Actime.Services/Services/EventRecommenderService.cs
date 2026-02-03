using Actime.Model.Entities;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using Microsoft.ML;
using Microsoft.ML.Trainers;

namespace Actime.Services.Services
{
    public class EventRecommenderService : IEventRecommenderService
    {
        private readonly MLContext _mlContext;
        private readonly ActimeContext _context;

        private ITransformer? _model;
        private readonly object _modelLock = new();

        public EventRecommenderService(ActimeContext context)
        {
            _mlContext = new MLContext(seed: 42);
            _context = context;
        }

        public void TrainModel()
        {
            lock (_modelLock)
            {
                var interactions = _context.Participations
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

        public List<int> RecommendEvents(int userId, int numberOfResults)
        {
            var model = _model;
            if (model == null)
                return new List<int>();

            var userEventIds = _context.Participations
                .Where(x => x.UserId == userId)
                .Select(x => x.EventId)
                .ToHashSet();

            var candidateEventIds = _context.Events
                .Where(e => !userEventIds.Contains(e.Id))
                .Select(e => e.Id)
                .ToList();

            var predictionEngine =
                _mlContext.Model.CreatePredictionEngine<EventInteraction, EventPrediction>(model);

            return candidateEventIds
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
        }
    }
}
