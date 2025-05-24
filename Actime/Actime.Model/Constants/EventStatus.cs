namespace Actime.Model.Constants
{
    public enum EventStatus
    {
        Pending = 1,
        Upcoming,
        InProgress,
        Completed,
        Cancelled,
        Postponed, //The event is delayed, but a new date is not yet decided.
        Rescheduled //The event has been moved to a new specific date/time.
    }
}
