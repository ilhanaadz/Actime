using Actime.Model.Entities;

namespace Actime.Services.Interfaces
{
    public interface IEventRecommenderService
    {
        void TrainModel();
        List<Event> RecommendEvents(int userId, int numberOfResults);
    }
}
