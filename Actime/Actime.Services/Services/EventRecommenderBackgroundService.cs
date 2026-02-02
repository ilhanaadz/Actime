using Actime.Services.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Actime.Services.Services
{
    public class EventRecommenderBackgroundService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<EventRecommenderBackgroundService> _logger;
        private readonly TimeSpan _retrainInterval = TimeSpan.FromHours(1);

        public EventRecommenderBackgroundService(
            IServiceScopeFactory scopeFactory,
            ILogger<EventRecommenderBackgroundService> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("EventRecommenderBackgroundService started.");

            await TrainOnce(stoppingToken);

            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(_retrainInterval, stoppingToken);
                await TrainOnce(stoppingToken);
            }
        }

        private async Task TrainOnce(CancellationToken stoppingToken)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var recommender = scope.ServiceProvider
                    .GetRequiredService<IEventRecommenderService>();

                _logger.LogInformation("Training recommendation model...");
                recommender.TrainModel();
                _logger.LogInformation("Model training completed.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during model training.");
            }

            await Task.CompletedTask;
        }
    }
}
