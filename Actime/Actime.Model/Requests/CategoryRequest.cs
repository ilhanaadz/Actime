using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class CategoryRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Category name is required")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
        public required string Name { get; set; }

        public string? Description { get; set; }
    }
}