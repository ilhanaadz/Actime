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

        // Thread-safe model reference
        private ITransformer? _model;
        private readonly object _modelLock = new();

        public EventRecommenderService(ActimeContext context)
        {
            _mlContext = new MLContext();
            _context = context;
        }

        /// <summary>
        /// Trains or retrains the recommendation model.
        /// Thread-safe: locks only during training.
        /// </summary>
        public void TrainModel()
        {
            lock (_modelLock)
            {
                var interactions = _context.Participations
                    .Select(x => new EventInteraction
                    {
                        UserId = (uint)x.UserId,
                        EventId = (uint)x.EventId,
                        Label = 1
                    })
                    .ToList();

                if (!interactions.Any())
                    return; // no data to train

                var data = _mlContext.Data.LoadFromEnumerable(interactions);

                var options = new MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(EventInteraction.UserId),
                    MatrixRowIndexColumnName = nameof(EventInteraction.EventId),
                    LabelColumnName = nameof(EventInteraction.Label),
                    LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01,
                    Lambda = 0.025,
                    NumberOfIterations = 100
                };

                var estimator = _mlContext.Recommendation()
                    .Trainers
                    .MatrixFactorization(options);

                _model = estimator.Fit(data);
            }
        }

        /// <summary>
        /// Returns recommended event IDs for a given user.
        /// Pure inference, does not block other threads.
        /// </summary>
        public List<int> RecommendEvents(int userId, int numberOfResults)
        {
            // Capture the current model reference for thread-safety
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

            var predictionEngine = _mlContext.Model
                .CreatePredictionEngine<EventInteraction, EventPrediction>(model);

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
