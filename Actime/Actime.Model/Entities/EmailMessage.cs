namespace Actime.Model.Entities
{
    public class EmailMessage
    {
        public string To { get; set; } = null!;
        public string Subject { get; set; } = null!;
        public string HtmlBody { get; set; } = null!;
    }
}
