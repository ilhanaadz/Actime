namespace Actime.Services.Interfaces
{
    public interface IEventRecommenderService
    {
        void TrainModel();
        List<int> RecommendEvents(int userId, int numberOfResults);
    }
}
