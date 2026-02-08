using Actime.Services.Database;
using Microsoft.AspNetCore.Identity;

namespace Actime
{
    public class SeedData
    {
        public static async Task Initialize(ActimeContext context, IServiceProvider services)
        {
            var roleManager = services.GetRequiredService<RoleManager<IdentityRole<int>>>();
            var userManager = services.GetRequiredService<UserManager<User>>();

            if (!context.ActivityTypes.Any())
            {
                await context.ActivityTypes.AddRangeAsync(
                    new ActivityType { Name = "SingleDayTrip" },
                    new ActivityType { Name = "MultiDayTrip" },
                    new ActivityType { Name = "Training" },
                    new ActivityType { Name = "Match" },
                    new ActivityType { Name = "Meeting" },
                    new ActivityType { Name = "Volunteering" },
                    new ActivityType { Name = "Fundraising" },
                    new ActivityType { Name = "AidCampaign" },
                    new ActivityType { Name = "TeamBuilding" },
                    new ActivityType { Name = "Promotion" },
                    new ActivityType { Name = "Competition" },
                    new ActivityType { Name = "Celebration" },
                    new ActivityType { Name = "Workshop" },
                    new ActivityType { Name = "RecruitmentEvent" },
                    new ActivityType { Name = "Camp" },
                    new ActivityType { Name = "Other" }
                );
                await context.SaveChangesAsync();
            }

            if (!context.AttendanceStatuses.Any())
            {
                await context.AttendanceStatuses.AddRangeAsync(
                    new AttendanceStatus { Name = "PendingResponse" },
                    new AttendanceStatus { Name = "Going" },
                    new AttendanceStatus { Name = "Maybe" },
                    new AttendanceStatus { Name = "NotGoing" },
                    new AttendanceStatus { Name = "Attended" },
                    new AttendanceStatus { Name = "Missed" }
                );
                await context.SaveChangesAsync();
            }

            if (!context.EventStatuses.Any())
            {
                await context.EventStatuses.AddRangeAsync(
                    new EventStatus { Name = "Pending" },
                    new EventStatus { Name = "Upcoming" },
                    new EventStatus { Name = "InProgress" },
                    new EventStatus { Name = "Completed" },
                    new EventStatus { Name = "Cancelled" },
                    new EventStatus { Name = "Postponed" },
                    new EventStatus { Name = "Rescheduled" }
                );
                await context.SaveChangesAsync();
            }

            if (!context.MembershipStatuses.Any())
            {
                await context.MembershipStatuses.AddRangeAsync(
                    new MembershipStatus { Name = "Pending" },
                    new MembershipStatus { Name = "Active" },
                    new MembershipStatus { Name = "Suspended" },
                    new MembershipStatus { Name = "Cancelled" },
                    new MembershipStatus { Name = "Expired" },
                    new MembershipStatus { Name = "Rejected" }
                );
                await context.SaveChangesAsync();
            }

            if (!context.PaymentMethods.Any())
            {
                await context.PaymentMethods.AddRangeAsync(
                    new PaymentMethod { Name = "Cash" },
                    new PaymentMethod { Name = "CreditCard" },
                    new PaymentMethod { Name = "BankTransfer" },
                    new PaymentMethod { Name = "PayPal" },
                    new PaymentMethod { Name = "Invoice" },
                    new PaymentMethod { Name = "Other" }
                );
                await context.SaveChangesAsync();
            }

            if (!context.PaymentStatuses.Any())
            {
                await context.PaymentStatuses.AddRangeAsync(
                    new PaymentStatus { Name = "Pending" },
                    new PaymentStatus { Name = "Paid" },
                    new PaymentStatus { Name = "Failed" },
                    new PaymentStatus { Name = "Refunded" }
                );
                await context.SaveChangesAsync();
            }

            if (!context.ReportTypes.Any())
            {
                await context.ReportTypes.AddRangeAsync(
                    new ReportType { Name = "Activity" },
                    new ReportType { Name = "Memberships" },
                    new ReportType { Name = "Participations" },
                    new ReportType { Name = "Fundraising" },
                    new ReportType { Name = "Feedback" },
                    new ReportType { Name = "Events" }
                );
                await context.SaveChangesAsync();
            }

            if (!context.Categories.Any())
            {
                await context.Categories.AddRangeAsync(
                    new Category { Name = "Hiking" },
                    new Category { Name = "Football" },
                    new Category { Name = "Volleyball" },
                    new Category { Name = "Fitness" },
                    new Category { Name = "Basketball" },
                    new Category { Name = "Tennis" },
                    new Category { Name = "Alpinism" },
                    new Category { Name = "Skiing" },
                    new Category { Name = "Running" },
                    new Category { Name = "Boxing" },
                    new Category { Name = "Other" }
                );
                await context.SaveChangesAsync();
            }

            if (!context.Countries.Any())
            {
                await context.Countries.AddRangeAsync(
                    new Country { Name = "Bosnia and Herzegovina" },
                    new Country { Name = "Croatia" },
                    new Country { Name = "Serbia" }
                );
                await context.SaveChangesAsync();
            }

            if (!context.Cities.Any())
            {
                await context.Cities.AddRangeAsync(
                    new City { Name = "Sarajevo", CountryId = 1 },
                    new City { Name = "Mostar", CountryId = 1 },
                    new City { Name = "Zagreb", CountryId = 2 },
                    new City { Name = "Belgrade", CountryId = 3 }
                );
                await context.SaveChangesAsync();
            }

            string[] roles = ["Admin", "User", "Organization"];
            foreach (var roleName in roles)
            {
                if (!await roleManager.RoleExistsAsync(roleName))
                {
                    await roleManager.CreateAsync(new IdentityRole<int>(roleName));
                }
            }

            if (!context.Users.Any())
            {
                var desktopUser = new User
                {
                    UserName = "desktop",
                    Email = "desktop@actime.com",
                    FirstName = "Desktop",
                    LastName = "Admin",
                    EmailConfirmed = true,
                    PhoneNumberConfirmed = true,
                    DateOfBirth = new DateTime(1990, 1, 1)
                };
                var desktopResult = await userManager.CreateAsync(desktopUser, "test");
                if (desktopResult.Succeeded)
                {
                    await userManager.AddToRoleAsync(desktopUser, "Admin");
                }

                var mobileUser = new User
                {
                    UserName = "mobile",
                    Email = "mobile@actime.com",
                    FirstName = "Mobile",
                    LastName = "User",
                    EmailConfirmed = true,
                    PhoneNumberConfirmed = true,
                    DateOfBirth = new DateTime(1995, 6, 15)
                };
                var mobileResult = await userManager.CreateAsync(mobileUser, "test");
                if (mobileResult.Succeeded)
                {
                    await userManager.AddToRoleAsync(mobileUser, "User");
                }

                var adminUser = new User
                {
                    UserName = "admin",
                    Email = "admin@actime.com",
                    FirstName = "Admin",
                    LastName = "Administrator",
                    EmailConfirmed = true,
                    PhoneNumberConfirmed = true,
                    DateOfBirth = new DateTime(1988, 3, 20)
                };
                var adminResult = await userManager.CreateAsync(adminUser, "test");
                if (adminResult.Succeeded)
                {
                    await userManager.AddToRoleAsync(adminUser, "Admin");
                }


                var regularUser = new User
                {
                    UserName = "user",
                    Email = "user@actime.com",
                    FirstName = "Regular",
                    LastName = "User",
                    EmailConfirmed = true,
                    PhoneNumberConfirmed = true,
                    DateOfBirth = new DateTime(1992, 9, 10)
                };
                var regularResult = await userManager.CreateAsync(regularUser, "test");
                if (regularResult.Succeeded)
                {
                    await userManager.AddToRoleAsync(regularUser, "User");
                }

                var orgUser = new User
                {
                    UserName = "organization",
                    Email = "organization@actime.com",
                    FirstName = "Organization",
                    LastName = "Manager",
                    EmailConfirmed = true,
                    PhoneNumberConfirmed = true,
                    DateOfBirth = new DateTime(1985, 12, 5)
                };
                var orgResult = await userManager.CreateAsync(orgUser, "test");
                if (orgResult.Succeeded)
                {
                    await userManager.AddToRoleAsync(orgUser, "Organization");
                }

                string[] firstNames = { "Jane", "Mia", "Joe", "Jack", "Michael", "Lea", "Sara", "Dino", "Ema", "Una",
                                       "David", "Emma", "Oliver", "Sophia", "Liam", "Ava", "Noah", "Isabella", "Ethan", "Mila" };
                string[] lastNames = { "Khan", "Connor", "Garcia", "Tanaka", "Popov", "Muller", "Zahra", "Silva", "Patel", "Andersson",
                                      "Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Martinez", "Wilson", "Anderson" };

                for (int i = 0; i < 20; i++)
                {
                    var user = new User
                    {
                        UserName = $"{firstNames[i].ToLower()}.{lastNames[i].ToLower()}",
                        Email = $"{firstNames[i].ToLower()}.{lastNames[i].ToLower()}@actime.com",
                        FirstName = firstNames[i],
                        LastName = lastNames[i],
                        EmailConfirmed = true,
                        PhoneNumberConfirmed = true,
                        DateOfBirth = new DateTime(1990 + i % 15, (i % 12) + 1, (i % 28) + 1)
                    };

                    var userResult = await userManager.CreateAsync(user, "test");
                    if (userResult.Succeeded)
                    {
                        await userManager.AddToRoleAsync(user, "User");
                    }
                }
            }

            if (!context.Addresses.Any())
            {
                var streetNames = new[]
                {
                    "Baker Street", "Elm Street", "Fifth Avenue", "Main Street", "Sunset Boulevard",
                    "High Street", "Maple Avenue", "Park Lane", "Oxford Street", "King Street"
                };

                var postalCodes = new[]
                {
                    "10000", "71000", "75000", "88000", "11000", "20000", "51000", "31000", "18000", "34000"
                };

                var random = new Random();

                var addresses = new List<Address>();

                for (int i = 0; i < 10; i++)
                {
                    addresses.Add(new Address
                    {
                        Street = streetNames[i],
                        PostalCode = postalCodes[i],
                        Coordinates = $"{random.NextDouble() * 180 - 90},{random.NextDouble() * 360 - 180}",
                        CityId = random.Next(1, 5)
                    });
                }

                await context.Addresses.AddRangeAsync(addresses);
                await context.SaveChangesAsync();
            }

            if (!context.Organizations.Any())
            {
                var organizationUserA = new User
                {
                    UserName = "globalhiking",
                    Email = "info@globalhiking.com",
                    FirstName = "Global Hiking",
                    LastName = "Club",
                    EmailConfirmed = true
                };
                await userManager.CreateAsync(organizationUserA, "test");
                await userManager.AddToRoleAsync(organizationUserA, "Organization");

                var organizationUserB = new User
                {
                    UserName = "sportforall",
                    Email = "contact@sportforall.org",
                    FirstName = "Sport For All",
                    LastName = "Association",
                    EmailConfirmed = true
                };
                await userManager.CreateAsync(organizationUserB, "test");
                await userManager.AddToRoleAsync(organizationUserB, "Organization");

                var organizationUserC = new User
                {
                    UserName = "fitlifegym",
                    Email = "contact@fitlifegym.com",
                    FirstName = "FitLife",
                    LastName = "Gym",
                    EmailConfirmed = true
                };
                await userManager.CreateAsync(organizationUserC, "test");
                await userManager.AddToRoleAsync(organizationUserC, "Organization");

                var organizationUserD = new User
                {
                    UserName = "mountaineers",
                    Email = "info@mountaineers.com",
                    FirstName = "Mountaineers",
                    LastName = "Association",
                    EmailConfirmed = true
                };
                await userManager.CreateAsync(organizationUserD, "test");
                await userManager.AddToRoleAsync(organizationUserD, "Organization");

                var organizationUserE = new User
                {
                    UserName = "cityrunners",
                    Email = "contact@cityrunners.com",
                    FirstName = "City",
                    LastName = "Runners",
                    EmailConfirmed = true
                };
                await userManager.CreateAsync(organizationUserE, "test");
                await userManager.AddToRoleAsync(organizationUserE, "Organization");

                var organizationUserF = new User
                {
                    UserName = "tennisacademy",
                    Email = "info@tennisacademy.com",
                    FirstName = "Tennis",
                    LastName = "Academy",
                    EmailConfirmed = true
                };
                await userManager.CreateAsync(organizationUserF, "test");
                await userManager.AddToRoleAsync(organizationUserF, "Organization");

                // Get the organization test user (UserId = 5)
                var organizationTestUser = await userManager.FindByNameAsync("organization");

                context.Organizations.AddRange(
                    new Organization
                    {
                        Name = "Global Hiking Club",
                        Email = "info@globalhiking.com",
                        Description = "A community of nature lovers and adventure seekers exploring the most beautiful trails in the region.",
                        LogoUrl = null,
                        PhoneNumber = "+38761234567",
                        CategoryId = 1,  // Hiking
                        AddressId = 1,
                        UserId = organizationUserA.Id
                    },
                    new Organization
                    {
                        Name = "Sport for All Association",
                        Email = "contact@sportforall.org",
                        Description = "Promoting sports and healthy lifestyles for all ages and skill levels. Join our community of sport enthusiasts!",
                        LogoUrl = null,
                        PhoneNumber = "+38762345678",
                        CategoryId = 2,  // Football
                        AddressId = 2,
                        UserId = organizationUserB.Id
                    },
                    new Organization
                    {
                        Name = "FitLife Gym",
                        Email = "contact@fitlifegym.com",
                        Description = "Modern fitness center with state-of-the-art equipment, professional trainers, and diverse group classes.",
                        LogoUrl = null,
                        PhoneNumber = "+38763456789",
                        CategoryId = 4,  // Fitness
                        AddressId = 3,
                        UserId = organizationUserC.Id
                    },
                    new Organization
                    {
                        Name = "Mountaineers Association",
                        Email = "info@mountaineers.com",
                        Description = "Professional mountaineering club offering alpine climbing, winter expeditions, and safety training courses.",
                        LogoUrl = null,
                        PhoneNumber = "+38764567890",
                        CategoryId = 7,  // Alpinism
                        AddressId = 4,
                        UserId = organizationUserD.Id
                    },
                    new Organization
                    {
                        Name = "City Runners Club",
                        Email = "contact@cityrunners.com",
                        Description = "Running club for all levels - from beginners to marathon runners. Weekly group runs and training plans.",
                        LogoUrl = null,
                        PhoneNumber = "+38765678901",
                        CategoryId = 9,  // Running
                        AddressId = 5,
                        UserId = organizationUserE.Id
                    },
                    new Organization
                    {
                        Name = "Tennis Academy Pro",
                        Email = "info@tennisacademy.com",
                        Description = "Professional tennis academy with certified coaches, youth programs, and competitive training.",
                        LogoUrl = null,
                        PhoneNumber = "+38766789012",
                        CategoryId = 6,  // Tennis
                        AddressId = 6,
                        UserId = organizationUserF.Id
                    },
                    new Organization
                    {
                        Name = "Active Life Sports Club",
                        Email = "organization@actime.com",
                        Description = "Multi-sport organization offering basketball, volleyball, and fitness programs for all ages and skill levels.",
                        LogoUrl = null,
                        PhoneNumber = "+38767890123",
                        CategoryId = 5,  // Basketball
                        AddressId = 7,
                        UserId = organizationTestUser!.Id
                    }
                );

                await context.SaveChangesAsync();
            }

            if (!context.Locations.Any())
            {
                context.Locations.AddRange(
                    new Location { AddressId = 1, Capacity = 100, Name = "Main hall", ContactInfo = "info@venue1.com" },
                    new Location { AddressId = 2, Capacity = 50, Name = "Central stadium", ContactInfo = "contact@venue2.com" },
                    new Location { AddressId = 3, Capacity = 200, Name = "Outdoor stage", ContactInfo = "events@venue3.com" },
                    new Location { AddressId = 4, Capacity = 30, Name = "Mountain Base Camp", ContactInfo = "camp@hiking.com" },
                    new Location { AddressId = 5, Capacity = 500, Name = "City Arena", ContactInfo = "arena@city.com" },
                    new Location { AddressId = 6, Capacity = 80, Name = "Community Center", ContactInfo = "community@center.com" },
                    new Location { AddressId = 7, Capacity = 150, Name = "Sports Complex", ContactInfo = "sports@complex.com" },
                    new Location { AddressId = 8, Capacity = 40, Name = "Training Ground", ContactInfo = "training@ground.com" },
                    new Location { AddressId = 9, Capacity = 60, Name = "Fitness Studio", ContactInfo = "studio@fitness.com" },
                    new Location { AddressId = 10, Capacity = 250, Name = "Conference Hall", ContactInfo = "conference@hall.com" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.Events.Any())
            {
                var events = new List<Event>
                {
                    // Global Hiking Club events (OrganizationId = 1)
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Annual Hiking Trip",
                        Description = "Explore nature with us on our flagship annual event. Join experienced guides through scenic mountain trails.",
                        Start = DateTime.Now.AddDays(10),
                        End = DateTime.Now.AddDays(12),
                        LocationId = 1,
                        MaxParticipants = 50,
                        IsFree = false,
                        Price = 100,
                        EventStatusId = 2, // Upcoming
                        ActivityTypeId = 2  // MultiDayTrip
                    },
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Weekend Mountain Adventure",
                        Description = "A challenging weekend hike for experienced hikers. Beautiful views guaranteed!",
                        Start = DateTime.Now.AddDays(3),
                        End = DateTime.Now.AddDays(4),
                        LocationId = 4,
                        MaxParticipants = 25,
                        IsFree = false,
                        Price = 75,
                        EventStatusId = 2,
                        ActivityTypeId = 2
                    },
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Beginner's Nature Walk",
                        Description = "Perfect for newcomers! Easy trails with nature education.",
                        Start = DateTime.Now.AddDays(5),
                        End = DateTime.Now.AddDays(5).AddHours(6),
                        LocationId = 1,
                        MaxParticipants = 40,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 1  // SingleDayTrip
                    },
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Night Hike Under the Stars",
                        Description = "Experience the magic of hiking at night with professional guides.",
                        Start = DateTime.Now.AddDays(7),
                        End = DateTime.Now.AddDays(7).AddHours(5),
                        LocationId = 4,
                        MaxParticipants = 20,
                        IsFree = false,
                        Price = 30,
                        EventStatusId = 2,
                        ActivityTypeId = 1
                    },
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Summer Camp Adventure",
                        Description = "Week-long camping and hiking adventure for all skill levels.",
                        Start = DateTime.Now.AddDays(20),
                        End = DateTime.Now.AddDays(27),
                        LocationId = 4,
                        MaxParticipants = 30,
                        IsFree = false,
                        Price = 350,
                        EventStatusId = 2,
                        ActivityTypeId = 15  // Camp
                    },
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Photography Hike",
                        Description = "Combine hiking with nature photography lessons from a professional.",
                        Start = DateTime.Now.AddDays(14),
                        End = DateTime.Now.AddDays(14).AddHours(8),
                        LocationId = 1,
                        MaxParticipants = 15,
                        IsFree = false,
                        Price = 45,
                        EventStatusId = 2,
                        ActivityTypeId = 13  // Workshop
                    },
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Trail Maintenance Volunteering",
                        Description = "Help us maintain our beautiful trails! Tools and lunch provided.",
                        Start = DateTime.Now.AddDays(8),
                        End = DateTime.Now.AddDays(8).AddHours(6),
                        LocationId = 4,
                        MaxParticipants = 50,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 6  // Volunteering
                    },
                    // Past events for Global Hiking Club
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Spring Forest Exploration",
                        Description = "Discover the beauty of spring in our local forests.",
                        Start = DateTime.Now.AddDays(-30),
                        End = DateTime.Now.AddDays(-30).AddHours(6),
                        LocationId = 1,
                        MaxParticipants = 35,
                        IsFree = false,
                        Price = 25,
                        EventStatusId = 4,  // Completed
                        ActivityTypeId = 1
                    },
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Winter Hiking Challenge",
                        Description = "Brave the cold with our winter hiking event!",
                        Start = DateTime.Now.AddDays(-60),
                        End = DateTime.Now.AddDays(-59),
                        LocationId = 4,
                        MaxParticipants = 20,
                        IsFree = false,
                        Price = 60,
                        EventStatusId = 4,
                        ActivityTypeId = 2
                    },

                    // Sport for All Association events (OrganizationId = 2)
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "Weekly Football Training",
                        Description = "Regular training session for all skill levels. Improve your game!",
                        Start = DateTime.Now.AddDays(2),
                        End = DateTime.Now.AddDays(2).AddHours(2),
                        LocationId = 2,
                        MaxParticipants = 30,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 3  // Training
                    },
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "Inter-Club Football Match",
                        Description = "Friendly match against neighboring sports club.",
                        Start = DateTime.Now.AddDays(6),
                        End = DateTime.Now.AddDays(6).AddHours(3),
                        LocationId = 5,
                        MaxParticipants = 50,
                        IsFree = false,
                        Price = 10,
                        EventStatusId = 2,
                        ActivityTypeId = 4  // Match
                    },
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "Youth Football Tournament",
                        Description = "Annual youth tournament for ages 10-16. Multiple age categories.",
                        Start = DateTime.Now.AddDays(15),
                        End = DateTime.Now.AddDays(16),
                        LocationId = 5,
                        MaxParticipants = 200,
                        IsFree = false,
                        Price = 15,
                        EventStatusId = 2,
                        ActivityTypeId = 11  // Competition
                    },
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "Sports Day Celebration",
                        Description = "Annual celebration of sports with games, activities, and prizes!",
                        Start = DateTime.Now.AddDays(25),
                        End = DateTime.Now.AddDays(25).AddHours(8),
                        LocationId = 5,
                        MaxParticipants = 300,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 12  // Celebration
                    },
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "Coaching Workshop",
                        Description = "Learn modern coaching techniques from certified professionals.",
                        Start = DateTime.Now.AddDays(9),
                        End = DateTime.Now.AddDays(9).AddHours(4),
                        LocationId = 6,
                        MaxParticipants = 40,
                        IsFree = false,
                        Price = 50,
                        EventStatusId = 2,
                        ActivityTypeId = 13
                    },
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "Team Building Sports Day",
                        Description = "Corporate team building through various sports activities.",
                        Start = DateTime.Now.AddDays(12),
                        End = DateTime.Now.AddDays(12).AddHours(6),
                        LocationId = 7,
                        MaxParticipants = 100,
                        IsFree = false,
                        Price = 35,
                        EventStatusId = 2,
                        ActivityTypeId = 9  // TeamBuilding
                    },
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "Charity Football Match",
                        Description = "Play for a cause! All proceeds go to local children's hospital.",
                        Start = DateTime.Now.AddDays(18),
                        End = DateTime.Now.AddDays(18).AddHours(4),
                        LocationId = 5,
                        MaxParticipants = 100,
                        IsFree = false,
                        Price = 20,
                        EventStatusId = 2,
                        ActivityTypeId = 7  // Fundraising
                    },
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "New Member Recruitment Day",
                        Description = "Open day for anyone interested in joining our sports community!",
                        Start = DateTime.Now.AddDays(4),
                        End = DateTime.Now.AddDays(4).AddHours(5),
                        LocationId = 6,
                        MaxParticipants = 150,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 14  // RecruitmentEvent
                    },
                    // Past events for Sport for All
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "Spring Football League Finals",
                        Description = "Season finale with exciting matches and awards ceremony.",
                        Start = DateTime.Now.AddDays(-14),
                        End = DateTime.Now.AddDays(-14).AddHours(6),
                        LocationId = 5,
                        MaxParticipants = 200,
                        IsFree = false,
                        Price = 15,
                        EventStatusId = 4,
                        ActivityTypeId = 11
                    },
                    new Event
                    {
                        OrganizationId = 2,
                        Title = "Monthly Members Meeting",
                        Description = "Regular meeting to discuss club matters and upcoming events.",
                        Start = DateTime.Now.AddDays(-7),
                        End = DateTime.Now.AddDays(-7).AddHours(2),
                        LocationId = 6,
                        MaxParticipants = 50,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 4,
                        ActivityTypeId = 5  // Meeting
                    },

                    // FitLife Gym events (OrganizationId = 3)
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "Morning Yoga Session",
                        Description = "Start your day with energizing yoga. All levels welcome!",
                        Start = DateTime.Now.AddDays(1),
                        End = DateTime.Now.AddDays(1).AddHours(1.5),
                        LocationId = 9,
                        MaxParticipants = 25,
                        IsFree = false,
                        Price = 12,
                        EventStatusId = 2,
                        ActivityTypeId = 3
                    },
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "HIIT Bootcamp",
                        Description = "High-intensity interval training for maximum results!",
                        Start = DateTime.Now.AddDays(2),
                        End = DateTime.Now.AddDays(2).AddHours(1),
                        LocationId = 3,
                        MaxParticipants = 30,
                        IsFree = false,
                        Price = 15,
                        EventStatusId = 2,
                        ActivityTypeId = 3
                    },
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "Volleyball Tournament",
                        Description = "Indoor volleyball competition. Teams of 6 required.",
                        Start = DateTime.Now.AddDays(11),
                        End = DateTime.Now.AddDays(11).AddHours(5),
                        LocationId = 7,
                        MaxParticipants = 60,
                        IsFree = false,
                        Price = 20,
                        EventStatusId = 2,
                        ActivityTypeId = 11
                    },
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "Nutrition Workshop",
                        Description = "Learn about proper nutrition for fitness goals.",
                        Start = DateTime.Now.AddDays(13),
                        End = DateTime.Now.AddDays(13).AddHours(3),
                        LocationId = 10,
                        MaxParticipants = 50,
                        IsFree = false,
                        Price = 25,
                        EventStatusId = 2,
                        ActivityTypeId = 13
                    },
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "Boxing Basics",
                        Description = "Introduction to boxing techniques and fitness boxing.",
                        Start = DateTime.Now.AddDays(5),
                        End = DateTime.Now.AddDays(5).AddHours(2),
                        LocationId = 9,
                        MaxParticipants = 20,
                        IsFree = false,
                        Price = 18,
                        EventStatusId = 2,
                        ActivityTypeId = 3
                    },
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "Gym Open Day",
                        Description = "Free access to all facilities! Try any class for free.",
                        Start = DateTime.Now.AddDays(7),
                        End = DateTime.Now.AddDays(7).AddHours(10),
                        LocationId = 3,
                        MaxParticipants = 200,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 10  // Promotion
                    },
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "Personal Training Session",
                        Description = "One-on-one session with certified personal trainer.",
                        Start = DateTime.Now.AddDays(3),
                        End = DateTime.Now.AddDays(3).AddHours(1),
                        LocationId = 9,
                        MaxParticipants = 5,
                        IsFree = false,
                        Price = 40,
                        EventStatusId = 2,
                        ActivityTypeId = 3
                    },
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "Fitness Challenge Month Kickoff",
                        Description = "Start of our monthly fitness challenge. Prizes for winners!",
                        Start = DateTime.Now.AddDays(1),
                        End = DateTime.Now.AddDays(1).AddHours(2),
                        LocationId = 3,
                        MaxParticipants = 100,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 11
                    },
                    // Past events for FitLife Gym
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "Weight Loss Challenge Finale",
                        Description = "Celebration of our 8-week weight loss challenge participants.",
                        Start = DateTime.Now.AddDays(-21),
                        End = DateTime.Now.AddDays(-21).AddHours(3),
                        LocationId = 10,
                        MaxParticipants = 80,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 4,
                        ActivityTypeId = 12
                    },
                    new Event
                    {
                        OrganizationId = 3,
                        Title = "Marathon Training Program Start",
                        Description = "12-week training program for upcoming city marathon.",
                        Start = DateTime.Now.AddDays(-45),
                        End = DateTime.Now.AddDays(-45).AddHours(2),
                        LocationId = 8,
                        MaxParticipants = 40,
                        IsFree = false,
                        Price = 80,
                        EventStatusId = 4,
                        ActivityTypeId = 3
                    },

                    // Active Life Sports Club events (OrganizationId = 7)
                    new Event
                    {
                        OrganizationId = 7,
                        Title = "Basketball Training for Beginners",
                        Description = "Learn the fundamentals of basketball with our experienced coaches. Perfect for those starting out!",
                        Start = DateTime.Now.AddDays(3),
                        End = DateTime.Now.AddDays(3).AddHours(2),
                        LocationId = 7,
                        MaxParticipants = 25,
                        IsFree = false,
                        Price = 15,
                        EventStatusId = 2,
                        ActivityTypeId = 3  // Training
                    },
                    new Event
                    {
                        OrganizationId = 7,
                        Title = "Basketball League Match",
                        Description = "Weekly league match. Come support our team!",
                        Start = DateTime.Now.AddDays(5),
                        End = DateTime.Now.AddDays(5).AddHours(2),
                        LocationId = 5,
                        MaxParticipants = 100,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 4  // Match
                    },
                    new Event
                    {
                        OrganizationId = 7,
                        Title = "Volleyball Tournament",
                        Description = "Monthly volleyball tournament for all members. Teams of 6 players.",
                        Start = DateTime.Now.AddDays(8),
                        End = DateTime.Now.AddDays(8).AddHours(4),
                        LocationId = 7,
                        MaxParticipants = 48,
                        IsFree = false,
                        Price = 10,
                        EventStatusId = 2,
                        ActivityTypeId = 11  // Competition
                    },
                    new Event
                    {
                        OrganizationId = 7,
                        Title = "Community Sports Day",
                        Description = "Free community event with various sports activities, games, and prizes for all ages!",
                        Start = DateTime.Now.AddDays(15),
                        End = DateTime.Now.AddDays(15).AddHours(6),
                        LocationId = 5,
                        MaxParticipants = 200,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 12  // Celebration
                    },
                    new Event
                    {
                        OrganizationId = 7,
                        Title = "Fitness Bootcamp",
                        Description = "High-intensity fitness bootcamp to improve strength and endurance.",
                        Start = DateTime.Now.AddDays(6),
                        End = DateTime.Now.AddDays(6).AddHours(1.5),
                        LocationId = 3,
                        MaxParticipants = 30,
                        IsFree = false,
                        Price = 20,
                        EventStatusId = 2,
                        ActivityTypeId = 3
                    },
                    new Event
                    {
                        OrganizationId = 7,
                        Title = "Youth Basketball Camp",
                        Description = "Week-long basketball camp for youth ages 10-16. Includes coaching, drills, and scrimmages.",
                        Start = DateTime.Now.AddDays(20),
                        End = DateTime.Now.AddDays(25),
                        LocationId = 7,
                        MaxParticipants = 40,
                        IsFree = false,
                        Price = 150,
                        EventStatusId = 2,
                        ActivityTypeId = 15  // Camp
                    },
                    new Event
                    {
                        OrganizationId = 7,
                        Title = "Sports Equipment Donation Drive",
                        Description = "Volunteer event to collect and distribute sports equipment to local schools.",
                        Start = DateTime.Now.AddDays(10),
                        End = DateTime.Now.AddDays(10).AddHours(4),
                        LocationId = 6,
                        MaxParticipants = 50,
                        IsFree = true,
                        Price = 0,
                        EventStatusId = 2,
                        ActivityTypeId = 6  // Volunteering
                    },
                    // Past event for Active Life Sports Club
                    new Event
                    {
                        OrganizationId = 7,
                        Title = "Basketball Skills Workshop",
                        Description = "Workshop focused on improving shooting and dribbling techniques.",
                        Start = DateTime.Now.AddDays(-10),
                        End = DateTime.Now.AddDays(-10).AddHours(3),
                        LocationId = 7,
                        MaxParticipants = 30,
                        IsFree = false,
                        Price = 25,
                        EventStatusId = 4,  // Completed
                        ActivityTypeId = 13  // Workshop
                    }
                };

                await context.Events.AddRangeAsync(events);
                await context.SaveChangesAsync();
            }

            if (!context.Memberships.Any())
            {
                var memberships = new List<Membership>
                {
                    // Mobile and regular test users as members
                    // Global Hiking Club members (OrganizationId = 1)
                    new Membership { UserId = 2, OrganizationId = 1, MembershipStatusId = 2 },  // mobile - Active
                    new Membership { UserId = 4, OrganizationId = 1, MembershipStatusId = 2 },  // user - Active
                    new Membership { UserId = 11, OrganizationId = 1, MembershipStatusId = 2 }, // jane.khan - Active
                    new Membership { UserId = 12, OrganizationId = 1, MembershipStatusId = 2 }, // mia.connor - Active
                    new Membership { UserId = 13, OrganizationId = 1, MembershipStatusId = 2 }, // joe.garcia - Active
                    new Membership { UserId = 14, OrganizationId = 1, MembershipStatusId = 1 }, // jack.tanaka - Pending
                    new Membership { UserId = 15, OrganizationId = 1, MembershipStatusId = 2 }, // michael.popov - Active
                    new Membership { UserId = 16, OrganizationId = 1, MembershipStatusId = 3 }, // lea.muller - Suspended

                    // Sport for All Association members (OrganizationId = 2)
                    new Membership { UserId = 2, OrganizationId = 2, MembershipStatusId = 2 },  // mobile - Active
                    new Membership { UserId = 4, OrganizationId = 2, MembershipStatusId = 2 },  // user - Active
                    new Membership { UserId = 11, OrganizationId = 2, MembershipStatusId = 2 }, // jane.khan - Active
                    new Membership { UserId = 13, OrganizationId = 2, MembershipStatusId = 2 }, // joe.garcia - Active
                    new Membership { UserId = 14, OrganizationId = 2, MembershipStatusId = 2 }, // jack.tanaka - Active
                    new Membership { UserId = 17, OrganizationId = 2, MembershipStatusId = 2 }, // sara.zahra - Active
                    new Membership { UserId = 18, OrganizationId = 2, MembershipStatusId = 2 }, // dino.silva - Active
                    new Membership { UserId = 19, OrganizationId = 2, MembershipStatusId = 1 }, // ema.patel - Pending
                    new Membership { UserId = 20, OrganizationId = 2, MembershipStatusId = 2 }, // una.andersson - Active

                    // FitLife Gym members (OrganizationId = 3)
                    new Membership { UserId = 2, OrganizationId = 3, MembershipStatusId = 2 },  // mobile - Active
                    new Membership { UserId = 4, OrganizationId = 3, MembershipStatusId = 2 },  // user - Active
                    new Membership { UserId = 12, OrganizationId = 3, MembershipStatusId = 2 }, // mia.connor - Active
                    new Membership { UserId = 15, OrganizationId = 3, MembershipStatusId = 2 }, // michael.popov - Active
                    new Membership { UserId = 16, OrganizationId = 3, MembershipStatusId = 2 }, // lea.muller - Active
                    new Membership { UserId = 17, OrganizationId = 3, MembershipStatusId = 2 }, // sara.zahra - Active
                    new Membership { UserId = 18, OrganizationId = 3, MembershipStatusId = 1 }, // dino.silva - Pending
                    new Membership { UserId = 19, OrganizationId = 3, MembershipStatusId = 2 }, // ema.patel - Active
                    new Membership { UserId = 20, OrganizationId = 3, MembershipStatusId = 5 }, // una.andersson - Expired

                    // Mountaineers Association members (OrganizationId = 4)
                    new Membership { UserId = 11, OrganizationId = 4, MembershipStatusId = 2 }, // jane.khan - Active
                    new Membership { UserId = 13, OrganizationId = 4, MembershipStatusId = 2 }, // joe.garcia - Active
                    new Membership { UserId = 15, OrganizationId = 4, MembershipStatusId = 2 }, // michael.popov - Active
                    new Membership { UserId = 21, OrganizationId = 4, MembershipStatusId = 2 }, // david.smith - Active
                    new Membership { UserId = 22, OrganizationId = 4, MembershipStatusId = 1 }, // emma.johnson - Pending

                    // City Runners Club members (OrganizationId = 5)
                    new Membership { UserId = 12, OrganizationId = 5, MembershipStatusId = 2 }, // mia.connor - Active
                    new Membership { UserId = 17, OrganizationId = 5, MembershipStatusId = 2 }, // sara.zahra - Active
                    new Membership { UserId = 23, OrganizationId = 5, MembershipStatusId = 2 }, // oliver.williams - Active
                    new Membership { UserId = 24, OrganizationId = 5, MembershipStatusId = 2 }, // sophia.brown - Active
                    new Membership { UserId = 25, OrganizationId = 5, MembershipStatusId = 2 }, // liam.jones - Active

                    // Tennis Academy Pro members (OrganizationId = 6)
                    new Membership { UserId = 14, OrganizationId = 6, MembershipStatusId = 2 }, // jack.tanaka - Active
                    new Membership { UserId = 16, OrganizationId = 6, MembershipStatusId = 2 }, // lea.muller - Active
                    new Membership { UserId = 26, OrganizationId = 6, MembershipStatusId = 2 }, // ava.miller - Active
                    new Membership { UserId = 27, OrganizationId = 6, MembershipStatusId = 2 }, // noah.davis - Active
                    new Membership { UserId = 28, OrganizationId = 6, MembershipStatusId = 1 }, // isabella.martinez - Pending

                    // Active Life Sports Club members (OrganizationId = 7)
                    new Membership { UserId = 2, OrganizationId = 7, MembershipStatusId = 2 },  // mobile - Active
                    new Membership { UserId = 4, OrganizationId = 7, MembershipStatusId = 2 },  // user - Active
                    new Membership { UserId = 13, OrganizationId = 7, MembershipStatusId = 2 }, // joe.garcia - Active
                    new Membership { UserId = 15, OrganizationId = 7, MembershipStatusId = 2 }, // michael.popov - Active
                    new Membership { UserId = 18, OrganizationId = 7, MembershipStatusId = 2 }, // dino.silva - Active
                    new Membership { UserId = 21, OrganizationId = 7, MembershipStatusId = 2 }, // david.smith - Active
                    new Membership { UserId = 23, OrganizationId = 7, MembershipStatusId = 2 }, // oliver.williams - Active
                    new Membership { UserId = 25, OrganizationId = 7, MembershipStatusId = 2 }, // liam.jones - Active
                    new Membership { UserId = 29, OrganizationId = 7, MembershipStatusId = 1 }, // ethan.wilson - Pending
                    new Membership { UserId = 30, OrganizationId = 7, MembershipStatusId = 2 }  // mila.anderson - Active
                };

                await context.Memberships.AddRangeAsync(memberships);
                await context.SaveChangesAsync();
            }

            if (!context.Participations.Any())
            {
                var participations = new List<Participation>
                {
                    // Annual Hiking Trip (EventId = 1)
                    new Participation { UserId = 2, EventId = 1, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 4, EventId = 1, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 11, EventId = 1, AttendanceStatusId = 2 }, // jane.khan - Going
                    new Participation { UserId = 12, EventId = 1, AttendanceStatusId = 2 }, // mia.connor - Going
                    new Participation { UserId = 13, EventId = 1, AttendanceStatusId = 3 }, // joe.garcia - Maybe
                    new Participation { UserId = 15, EventId = 1, AttendanceStatusId = 2 }, // michael.popov - Going

                    // Weekend Mountain Adventure (EventId = 2)
                    new Participation { UserId = 11, EventId = 2, AttendanceStatusId = 2 }, // jane.khan - Going
                    new Participation { UserId = 12, EventId = 2, AttendanceStatusId = 2 }, // mia.connor - Going
                    new Participation { UserId = 15, EventId = 2, AttendanceStatusId = 2 }, // michael.popov - Going

                    // Beginner's Nature Walk (EventId = 3)
                    new Participation { UserId = 2, EventId = 3, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 14, EventId = 3, AttendanceStatusId = 2 }, // jack.tanaka - Going
                    new Participation { UserId = 16, EventId = 3, AttendanceStatusId = 2 }, // lea.muller - Going
                    new Participation { UserId = 17, EventId = 3, AttendanceStatusId = 3 }, // sara.zahra - Maybe

                    // Night Hike Under the Stars (EventId = 4)
                    new Participation { UserId = 11, EventId = 4, AttendanceStatusId = 2 }, // jane.khan - Going
                    new Participation { UserId = 13, EventId = 4, AttendanceStatusId = 2 }, // joe.garcia - Going

                    // Summer Camp Adventure (EventId = 5)
                    new Participation { UserId = 4, EventId = 5, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 11, EventId = 5, AttendanceStatusId = 2 }, // jane.khan - Going
                    new Participation { UserId = 12, EventId = 5, AttendanceStatusId = 3 }, // mia.connor - Maybe
                    new Participation { UserId = 15, EventId = 5, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 13, EventId = 5, AttendanceStatusId = 1 }, // joe.garcia - PendingResponse

                    // Photography Hike (EventId = 6)
                    new Participation { UserId = 12, EventId = 6, AttendanceStatusId = 2 }, // mia.connor - Going
                    new Participation { UserId = 16, EventId = 6, AttendanceStatusId = 2 }, // lea.muller - Going

                    // Trail Maintenance Volunteering (EventId = 7)
                    new Participation { UserId = 2, EventId = 7, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 11, EventId = 7, AttendanceStatusId = 2 }, // jane.khan - Going
                    new Participation { UserId = 13, EventId = 7, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 15, EventId = 7, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 14, EventId = 7, AttendanceStatusId = 3 }, // jack.tanaka - Maybe

                    // Past events participations
                    // Spring Forest Exploration (EventId = 8)
                    new Participation { UserId = 11, EventId = 8, AttendanceStatusId = 5 }, // jane.khan - Attended
                    new Participation { UserId = 12, EventId = 8, AttendanceStatusId = 5 }, // mia.connor - Attended
                    new Participation { UserId = 13, EventId = 8, AttendanceStatusId = 6 }, // joe.garcia - Missed

                    // Winter Hiking Challenge (EventId = 9)
                    new Participation { UserId = 11, EventId = 9, AttendanceStatusId = 5 }, // jane.khan - Attended
                    new Participation { UserId = 15, EventId = 9, AttendanceStatusId = 5 }, // michael.popov - Attended

                    // Weekly Football Training (EventId = 10)
                    new Participation { UserId = 2, EventId = 10, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 4, EventId = 10, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 13, EventId = 10, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 14, EventId = 10, AttendanceStatusId = 2 }, // jack.tanaka - Going
                    new Participation { UserId = 17, EventId = 10, AttendanceStatusId = 2 }, // sara.zahra - Going
                    new Participation { UserId = 18, EventId = 10, AttendanceStatusId = 2 }, // dino.silva - Going
                    new Participation { UserId = 20, EventId = 10, AttendanceStatusId = 3 }, // una.andersson - Maybe

                    // Inter-Club Football Match (EventId = 11)
                    new Participation { UserId = 13, EventId = 11, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 14, EventId = 11, AttendanceStatusId = 2 }, // jack.tanaka - Going
                    new Participation { UserId = 17, EventId = 11, AttendanceStatusId = 2 }, // sara.zahra - Going
                    new Participation { UserId = 18, EventId = 11, AttendanceStatusId = 2 }, // dino.silva - Going

                    // Youth Football Tournament (EventId = 12)
                    new Participation { UserId = 14, EventId = 12, AttendanceStatusId = 2 }, // jack.tanaka - Going
                    new Participation { UserId = 18, EventId = 12, AttendanceStatusId = 2 }, // dino.silva - Going
                    new Participation { UserId = 20, EventId = 12, AttendanceStatusId = 2 }, // una.andersson - Going

                    // Sports Day Celebration (EventId = 13)
                    new Participation { UserId = 2, EventId = 13, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 11, EventId = 13, AttendanceStatusId = 2 }, // jane.khan - Going
                    new Participation { UserId = 13, EventId = 13, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 14, EventId = 13, AttendanceStatusId = 2 }, // jack.tanaka - Going
                    new Participation { UserId = 17, EventId = 13, AttendanceStatusId = 3 }, // sara.zahra - Maybe
                    new Participation { UserId = 18, EventId = 13, AttendanceStatusId = 2 }, // dino.silva - Going

                    // Coaching Workshop (EventId = 14)
                    new Participation { UserId = 4, EventId = 14, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 13, EventId = 14, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 20, EventId = 14, AttendanceStatusId = 2 }, // una.andersson - Going

                    // Team Building Sports Day (EventId = 15)
                    new Participation { UserId = 14, EventId = 15, AttendanceStatusId = 2 }, // jack.tanaka - Going
                    new Participation { UserId = 17, EventId = 15, AttendanceStatusId = 2 }, // sara.zahra - Going
                    new Participation { UserId = 18, EventId = 15, AttendanceStatusId = 2 }, // dino.silva - Going

                    // Charity Football Match (EventId = 16)
                    new Participation { UserId = 2, EventId = 16, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 11, EventId = 16, AttendanceStatusId = 2 }, // jane.khan - Going
                    new Participation { UserId = 13, EventId = 16, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 14, EventId = 16, AttendanceStatusId = 2 }, // jack.tanaka - Going
                    new Participation { UserId = 18, EventId = 16, AttendanceStatusId = 2 }, // dino.silva - Going
                    new Participation { UserId = 20, EventId = 16, AttendanceStatusId = 3 }, // una.andersson - Maybe

                    // New Member Recruitment Day (EventId = 17)
                    new Participation { UserId = 19, EventId = 17, AttendanceStatusId = 2 }, // ema.patel - Going

                    // Past Sport for All events
                    // Spring Football League Finals (EventId = 18)
                    new Participation { UserId = 13, EventId = 18, AttendanceStatusId = 5 }, // joe.garcia - Attended
                    new Participation { UserId = 14, EventId = 18, AttendanceStatusId = 5 }, // jack.tanaka - Attended
                    new Participation { UserId = 18, EventId = 18, AttendanceStatusId = 5 }, // dino.silva - Attended

                    // Monthly Members Meeting (EventId = 19)
                    new Participation { UserId = 11, EventId = 19, AttendanceStatusId = 5 }, // jane.khan - Attended
                    new Participation { UserId = 13, EventId = 19, AttendanceStatusId = 5 }, // joe.garcia - Attended
                    new Participation { UserId = 17, EventId = 19, AttendanceStatusId = 6 }, // sara.zahra - Missed

                    // FitLife Gym events
                    // Morning Yoga Session (EventId = 20)
                    new Participation { UserId = 2, EventId = 20, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 12, EventId = 20, AttendanceStatusId = 2 }, // mia.connor - Going
                    new Participation { UserId = 16, EventId = 20, AttendanceStatusId = 2 }, // lea.muller - Going
                    new Participation { UserId = 17, EventId = 20, AttendanceStatusId = 2 }, // sara.zahra - Going
                    new Participation { UserId = 19, EventId = 20, AttendanceStatusId = 3 }, // ema.patel - Maybe

                    // HIIT Bootcamp (EventId = 21)
                    new Participation { UserId = 4, EventId = 21, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 12, EventId = 21, AttendanceStatusId = 2 }, // mia.connor - Going
                    new Participation { UserId = 15, EventId = 21, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 17, EventId = 21, AttendanceStatusId = 2 }, // sara.zahra - Going

                    // Volleyball Tournament (EventId = 22)
                    new Participation { UserId = 12, EventId = 22, AttendanceStatusId = 2 }, // mia.connor - Going
                    new Participation { UserId = 15, EventId = 22, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 16, EventId = 22, AttendanceStatusId = 2 }, // lea.muller - Going
                    new Participation { UserId = 17, EventId = 22, AttendanceStatusId = 2 }, // sara.zahra - Going
                    new Participation { UserId = 19, EventId = 22, AttendanceStatusId = 2 }, // ema.patel - Going

                    // Nutrition Workshop (EventId = 23)
                    new Participation { UserId = 12, EventId = 23, AttendanceStatusId = 2 }, // mia.connor - Going
                    new Participation { UserId = 16, EventId = 23, AttendanceStatusId = 2 }, // lea.muller - Going
                    new Participation { UserId = 19, EventId = 23, AttendanceStatusId = 2 }, // ema.patel - Going

                    // Boxing Basics (EventId = 24)
                    new Participation { UserId = 15, EventId = 24, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 18, EventId = 24, AttendanceStatusId = 2 }, // dino.silva - Going

                    // Gym Open Day (EventId = 25)
                    new Participation { UserId = 2, EventId = 25, AttendanceStatusId = 3 },  // mobile - Maybe
                    new Participation { UserId = 11, EventId = 25, AttendanceStatusId = 3 }, // jane.khan - Maybe
                    new Participation { UserId = 14, EventId = 25, AttendanceStatusId = 2 }, // jack.tanaka - Going
                    new Participation { UserId = 20, EventId = 25, AttendanceStatusId = 2 }, // una.andersson - Going

                    // Personal Training Session (EventId = 26)
                    new Participation { UserId = 4, EventId = 26, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 15, EventId = 26, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 19, EventId = 26, AttendanceStatusId = 2 }, // ema.patel - Going

                    // Fitness Challenge Month Kickoff (EventId = 27)
                    new Participation { UserId = 2, EventId = 27, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 12, EventId = 27, AttendanceStatusId = 2 }, // mia.connor - Going
                    new Participation { UserId = 15, EventId = 27, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 16, EventId = 27, AttendanceStatusId = 2 }, // lea.muller - Going
                    new Participation { UserId = 17, EventId = 27, AttendanceStatusId = 2 }, // sara.zahra - Going
                    new Participation { UserId = 19, EventId = 27, AttendanceStatusId = 2 }, // ema.patel - Going

                    // Past FitLife Gym events
                    // Weight Loss Challenge Finale (EventId = 28)
                    new Participation { UserId = 12, EventId = 28, AttendanceStatusId = 5 }, // mia.connor - Attended
                    new Participation { UserId = 16, EventId = 28, AttendanceStatusId = 5 }, // lea.muller - Attended
                    new Participation { UserId = 17, EventId = 28, AttendanceStatusId = 5 }, // sara.zahra - Attended
                    new Participation { UserId = 19, EventId = 28, AttendanceStatusId = 6 }, // ema.patel - Missed

                    // Marathon Training Program Start (EventId = 29)
                    new Participation { UserId = 15, EventId = 29, AttendanceStatusId = 5 }, // michael.popov - Attended
                    new Participation { UserId = 17, EventId = 29, AttendanceStatusId = 5 }, // sara.zahra - Attended

                    // Active Life Sports Club events
                    // Basketball Training for Beginners (EventId = 30)
                    new Participation { UserId = 2, EventId = 30, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 4, EventId = 30, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 13, EventId = 30, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 21, EventId = 30, AttendanceStatusId = 2 }, // david.smith - Going
                    new Participation { UserId = 23, EventId = 30, AttendanceStatusId = 3 }, // oliver.williams - Maybe

                    // Basketball League Match (EventId = 31)
                    new Participation { UserId = 2, EventId = 31, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 13, EventId = 31, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 15, EventId = 31, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 18, EventId = 31, AttendanceStatusId = 2 }, // dino.silva - Going
                    new Participation { UserId = 21, EventId = 31, AttendanceStatusId = 2 }, // david.smith - Going
                    new Participation { UserId = 25, EventId = 31, AttendanceStatusId = 2 }, // liam.jones - Going

                    // Volleyball Tournament (EventId = 32)
                    new Participation { UserId = 4, EventId = 32, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 13, EventId = 32, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 15, EventId = 32, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 18, EventId = 32, AttendanceStatusId = 2 }, // dino.silva - Going
                    new Participation { UserId = 23, EventId = 32, AttendanceStatusId = 2 }, // oliver.williams - Going
                    new Participation { UserId = 30, EventId = 32, AttendanceStatusId = 2 }, // mila.anderson - Going

                    // Community Sports Day (EventId = 33)
                    new Participation { UserId = 2, EventId = 33, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 4, EventId = 33, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 13, EventId = 33, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 15, EventId = 33, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 18, EventId = 33, AttendanceStatusId = 2 }, // dino.silva - Going
                    new Participation { UserId = 21, EventId = 33, AttendanceStatusId = 2 }, // david.smith - Going
                    new Participation { UserId = 25, EventId = 33, AttendanceStatusId = 3 }, // liam.jones - Maybe
                    new Participation { UserId = 30, EventId = 33, AttendanceStatusId = 2 }, // mila.anderson - Going

                    // Fitness Bootcamp (EventId = 34)
                    new Participation { UserId = 2, EventId = 34, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 15, EventId = 34, AttendanceStatusId = 2 }, // michael.popov - Going
                    new Participation { UserId = 21, EventId = 34, AttendanceStatusId = 2 }, // david.smith - Going
                    new Participation { UserId = 23, EventId = 34, AttendanceStatusId = 2 }, // oliver.williams - Going

                    // Youth Basketball Camp (EventId = 35)
                    new Participation { UserId = 13, EventId = 35, AttendanceStatusId = 2 }, // joe.garcia - Going
                    new Participation { UserId = 21, EventId = 35, AttendanceStatusId = 2 }, // david.smith - Going
                    new Participation { UserId = 25, EventId = 35, AttendanceStatusId = 1 }, // liam.jones - PendingResponse

                    // Sports Equipment Donation Drive (EventId = 36)
                    new Participation { UserId = 2, EventId = 36, AttendanceStatusId = 2 },  // mobile - Going
                    new Participation { UserId = 4, EventId = 36, AttendanceStatusId = 2 },  // user - Going
                    new Participation { UserId = 18, EventId = 36, AttendanceStatusId = 2 }, // dino.silva - Going
                    new Participation { UserId = 23, EventId = 36, AttendanceStatusId = 2 }, // oliver.williams - Going
                    new Participation { UserId = 30, EventId = 36, AttendanceStatusId = 2 }, // mila.anderson - Going

                    // Basketball Skills Workshop (EventId = 37 - Past event)
                    new Participation { UserId = 13, EventId = 37, AttendanceStatusId = 5 }, // joe.garcia - Attended
                    new Participation { UserId = 15, EventId = 37, AttendanceStatusId = 5 }, // michael.popov - Attended
                    new Participation { UserId = 21, EventId = 37, AttendanceStatusId = 5 }, // david.smith - Attended
                    new Participation { UserId = 25, EventId = 37, AttendanceStatusId = 6 }  // liam.jones - Missed
                };

                await context.Participations.AddRangeAsync(participations);
                await context.SaveChangesAsync();
            }

            if (!context.Reviews.Any())
            {
                var reviews = new List<Review>
                {
                    // Reviews for Global Hiking Club (OrganizationId = 1)
                    new Review
                    {
                        UserId = 2,
                        OrganizationId = 1,
                        Score = 5,
                        Text = "Great organization with amazing events! The guides are very professional and knowledgeable.",
                        CreatedAt = DateTime.Now.AddDays(-30)
                    },
                    new Review
                    {
                        UserId = 11,
                        OrganizationId = 1,
                        Score = 5,
                        Text = "Best hiking club in the region! I've made so many friends here.",
                        CreatedAt = DateTime.Now.AddDays(-25)
                    },
                    new Review
                    {
                        UserId = 12,
                        OrganizationId = 1,
                        Score = 5,
                        Text = "The trails are beautiful and the group is very friendly. Highly recommend!",
                        CreatedAt = DateTime.Now.AddDays(-22)
                    },
                    new Review
                    {
                        UserId = 13,
                        OrganizationId = 1,
                        Score = 4,
                        Text = "Very well organized events. Would love to see more beginner-friendly options.",
                        CreatedAt = DateTime.Now.AddDays(-20)
                    },
                    new Review
                    {
                        UserId = 15,
                        OrganizationId = 1,
                        Score = 5,
                        Text = "The annual hiking trip was unforgettable! Can't wait for next year.",
                        CreatedAt = DateTime.Now.AddDays(-15)
                    },

                    // Reviews for Sport for All Association (OrganizationId = 2)
                    new Review
                    {
                        UserId = 2,
                        OrganizationId = 2,
                        Score = 4,
                        Text = "Great community for sports lovers. The football training is excellent!",
                        CreatedAt = DateTime.Now.AddDays(-28)
                    },
                    new Review
                    {
                        UserId = 4,
                        OrganizationId = 2,
                        Score = 5,
                        Text = "Amazing coaching staff and facilities. Highly recommended!",
                        CreatedAt = DateTime.Now.AddDays(-22)
                    },
                    new Review
                    {
                        UserId = 11,
                        OrganizationId = 2,
                        Score = 5,
                        Text = "The best sports association I've ever joined. Everyone is so welcoming!",
                        CreatedAt = DateTime.Now.AddDays(-19)
                    },
                    new Review
                    {
                        UserId = 13,
                        OrganizationId = 2,
                        Score = 5,
                        Text = "Professional training and great team spirit. Love the competitive atmosphere!",
                        CreatedAt = DateTime.Now.AddDays(-18)
                    },
                    new Review
                    {
                        UserId = 14,
                        OrganizationId = 2,
                        Score = 5,
                        Text = "The youth tournament was perfectly organized. My kids loved it!",
                        CreatedAt = DateTime.Now.AddDays(-14)
                    },
                    new Review
                    {
                        UserId = 17,
                        OrganizationId = 2,
                        Score = 4,
                        Text = "Good variety of events. The charity matches are a wonderful initiative.",
                        CreatedAt = DateTime.Now.AddDays(-12)
                    },
                    new Review
                    {
                        UserId = 18,
                        OrganizationId = 2,
                        Score = 5,
                        Text = "Best sports club I've ever been part of! Friendly atmosphere and professional training.",
                        CreatedAt = DateTime.Now.AddDays(-8)
                    },
                    new Review
                    {
                        UserId = 20,
                        OrganizationId = 2,
                        Score = 4,
                        Text = "Great facilities and well-maintained equipment. Would recommend to anyone.",
                        CreatedAt = DateTime.Now.AddDays(-5)
                    },

                    // Reviews for FitLife Gym (OrganizationId = 3)
                    new Review
                    {
                        UserId = 2,
                        OrganizationId = 3,
                        Score = 5,
                        Text = "Excellent gym with modern equipment. The trainers are very supportive!",
                        CreatedAt = DateTime.Now.AddDays(-26)
                    },
                    new Review
                    {
                        UserId = 4,
                        OrganizationId = 3,
                        Score = 5,
                        Text = "The personal training sessions are amazing. I've seen great results!",
                        CreatedAt = DateTime.Now.AddDays(-23)
                    },
                    new Review
                    {
                        UserId = 12,
                        OrganizationId = 3,
                        Score = 5,
                        Text = "Love this gym! Clean, modern, and the staff is incredibly helpful.",
                        CreatedAt = DateTime.Now.AddDays(-21)
                    },
                    new Review
                    {
                        UserId = 15,
                        OrganizationId = 3,
                        Score = 4,
                        Text = "Good variety of classes. The HIIT bootcamp is intense but effective!",
                        CreatedAt = DateTime.Now.AddDays(-17)
                    },
                    new Review
                    {
                        UserId = 16,
                        OrganizationId = 3,
                        Score = 5,
                        Text = "Love the yoga sessions! Perfect way to start my mornings.",
                        CreatedAt = DateTime.Now.AddDays(-16)
                    },
                    new Review
                    {
                        UserId = 17,
                        OrganizationId = 3,
                        Score = 5,
                        Text = "The nutrition workshop changed my approach to fitness. Highly valuable!",
                        CreatedAt = DateTime.Now.AddDays(-10)
                    },
                    new Review
                    {
                        UserId = 19,
                        OrganizationId = 3,
                        Score = 4,
                        Text = "Clean facilities and friendly staff. The personal training is worth the price.",
                        CreatedAt = DateTime.Now.AddDays(-6)
                    },
                    new Review
                    {
                        UserId = 20,
                        OrganizationId = 3,
                        Score = 3,
                        Text = "Good gym overall. Sometimes it gets too crowded during peak hours.",
                        CreatedAt = DateTime.Now.AddDays(-3)
                    },

                    // Reviews for Mountaineers Association (OrganizationId = 4)
                    new Review
                    {
                        UserId = 11,
                        OrganizationId = 4,
                        Score = 5,
                        Text = "Professional mountaineering club with excellent safety standards!",
                        CreatedAt = DateTime.Now.AddDays(-20)
                    },
                    new Review
                    {
                        UserId = 13,
                        OrganizationId = 4,
                        Score = 5,
                        Text = "The alpine climbing courses are top-notch. Learned so much!",
                        CreatedAt = DateTime.Now.AddDays(-15)
                    },
                    new Review
                    {
                        UserId = 21,
                        OrganizationId = 4,
                        Score = 4,
                        Text = "Great club for serious mountaineers. The expeditions are challenging and rewarding.",
                        CreatedAt = DateTime.Now.AddDays(-12)
                    },

                    // Reviews for City Runners Club (OrganizationId = 5)
                    new Review
                    {
                        UserId = 12,
                        OrganizationId = 5,
                        Score = 5,
                        Text = "Perfect for runners of all levels! The training plans are excellent.",
                        CreatedAt = DateTime.Now.AddDays(-18)
                    },
                    new Review
                    {
                        UserId = 17,
                        OrganizationId = 5,
                        Score = 5,
                        Text = "Great running community! The weekly group runs are so motivating.",
                        CreatedAt = DateTime.Now.AddDays(-14)
                    },
                    new Review
                    {
                        UserId = 23,
                        OrganizationId = 5,
                        Score = 4,
                        Text = "Helped me prepare for my first marathon. Supportive and knowledgeable coaches!",
                        CreatedAt = DateTime.Now.AddDays(-9)
                    },

                    // Reviews for Tennis Academy Pro (OrganizationId = 6)
                    new Review
                    {
                        UserId = 14,
                        OrganizationId = 6,
                        Score = 5,
                        Text = "Excellent tennis academy! My skills have improved dramatically.",
                        CreatedAt = DateTime.Now.AddDays(-16)
                    },
                    new Review
                    {
                        UserId = 16,
                        OrganizationId = 6,
                        Score = 5,
                        Text = "Professional coaches and great facilities. Highly recommend for competitive players!",
                        CreatedAt = DateTime.Now.AddDays(-11)
                    },
                    new Review
                    {
                        UserId = 26,
                        OrganizationId = 6,
                        Score = 4,
                        Text = "Good tennis academy with structured programs. Worth the investment!",
                        CreatedAt = DateTime.Now.AddDays(-7)
                    },

                    // Reviews for Active Life Sports Club (OrganizationId = 7)
                    new Review
                    {
                        UserId = 2,
                        OrganizationId = 7,
                        Score = 5,
                        Text = "Great multi-sport club! The basketball training is excellent and the coaches are very supportive.",
                        CreatedAt = DateTime.Now.AddDays(-15)
                    },
                    new Review
                    {
                        UserId = 4,
                        OrganizationId = 7,
                        Score = 5,
                        Text = "Best sports club in the area! Diverse activities and friendly atmosphere.",
                        CreatedAt = DateTime.Now.AddDays(-12)
                    },
                    new Review
                    {
                        UserId = 13,
                        OrganizationId = 7,
                        Score = 4,
                        Text = "Really enjoying the basketball league. Good competition and well organized.",
                        CreatedAt = DateTime.Now.AddDays(-10)
                    },
                    new Review
                    {
                        UserId = 15,
                        OrganizationId = 7,
                        Score = 5,
                        Text = "The fitness bootcamp is challenging but very effective! Highly recommend.",
                        CreatedAt = DateTime.Now.AddDays(-8)
                    },
                    new Review
                    {
                        UserId = 21,
                        OrganizationId = 7,
                        Score = 5,
                        Text = "Excellent facilities and professional staff. The volleyball tournaments are always fun!",
                        CreatedAt = DateTime.Now.AddDays(-5)
                    },
                    new Review
                    {
                        UserId = 23,
                        OrganizationId = 7,
                        Score = 4,
                        Text = "Good variety of sports activities. The community events are great for families.",
                        CreatedAt = DateTime.Now.AddDays(-3)
                    }
                };

                await context.Reviews.AddRangeAsync(reviews);
                await context.SaveChangesAsync();
            }

            if (!context.Schedules.Any())
            {
                var schedules = new List<Schedule>
                {
                    // Global Hiking Club schedules (OrganizationId = 1)
                    new Schedule
                    {
                        OrganizationId = 1,
                        DayOfWeek = "Saturday",
                        StartTime = TimeOnly.Parse("08:00"),
                        EndTime = TimeOnly.Parse("16:00"),
                        ActivityTypeId = 1,  // SingleDayTrip
                        LocationId = 1,
                        Description = "Weekly Saturday hike for all levels."
                    },
                    new Schedule
                    {
                        OrganizationId = 1,
                        DayOfWeek = "Sunday",
                        StartTime = TimeOnly.Parse("07:00"),
                        EndTime = TimeOnly.Parse("12:00"),
                        ActivityTypeId = 1,
                        LocationId = 4,
                        Description = "Morning nature walk - beginner friendly."
                    },
                    new Schedule
                    {
                        OrganizationId = 1,
                        DayOfWeek = "Wednesday",
                        StartTime = TimeOnly.Parse("18:00"),
                        EndTime = TimeOnly.Parse("20:00"),
                        ActivityTypeId = 5,  // Meeting
                        LocationId = 1,
                        Description = "Weekly planning meeting for upcoming events."
                    },

                    // Sport for All Association schedules (OrganizationId = 2)
                    new Schedule
                    {
                        OrganizationId = 2,
                        DayOfWeek = "Monday",
                        StartTime = TimeOnly.Parse("17:00"),
                        EndTime = TimeOnly.Parse("19:00"),
                        ActivityTypeId = 3,  // Training
                        LocationId = 2,
                        Description = "Football training - intermediate level."
                    },
                    new Schedule
                    {
                        OrganizationId = 2,
                        DayOfWeek = "Wednesday",
                        StartTime = TimeOnly.Parse("17:00"),
                        EndTime = TimeOnly.Parse("19:00"),
                        ActivityTypeId = 3,
                        LocationId = 2,
                        Description = "Football training - advanced level."
                    },
                    new Schedule
                    {
                        OrganizationId = 2,
                        DayOfWeek = "Friday",
                        StartTime = TimeOnly.Parse("16:00"),
                        EndTime = TimeOnly.Parse("18:00"),
                        ActivityTypeId = 3,
                        LocationId = 5,
                        Description = "Youth football training (ages 10-16)."
                    },
                    new Schedule
                    {
                        OrganizationId = 2,
                        DayOfWeek = "Saturday",
                        StartTime = TimeOnly.Parse("10:00"),
                        EndTime = TimeOnly.Parse("12:00"),
                        ActivityTypeId = 4,  // Match
                        LocationId = 5,
                        Description = "Weekend friendly matches."
                    },
                    new Schedule
                    {
                        OrganizationId = 2,
                        DayOfWeek = "Thursday",
                        StartTime = TimeOnly.Parse("19:00"),
                        EndTime = TimeOnly.Parse("21:00"),
                        ActivityTypeId = 5,
                        LocationId = 6,
                        Description = "Monthly members meeting (first Thursday of month)."
                    },

                    // FitLife Gym schedules (OrganizationId = 3)
                    new Schedule
                    {
                        OrganizationId = 3,
                        DayOfWeek = "Monday",
                        StartTime = TimeOnly.Parse("06:30"),
                        EndTime = TimeOnly.Parse("07:30"),
                        ActivityTypeId = 3,
                        LocationId = 9,
                        Description = "Morning yoga class."
                    },
                    new Schedule
                    {
                        OrganizationId = 3,
                        DayOfWeek = "Tuesday",
                        StartTime = TimeOnly.Parse("18:00"),
                        EndTime = TimeOnly.Parse("19:00"),
                        ActivityTypeId = 3,
                        LocationId = 3,
                        Description = "HIIT bootcamp session."
                    },
                    new Schedule
                    {
                        OrganizationId = 3,
                        DayOfWeek = "Wednesday",
                        StartTime = TimeOnly.Parse("06:30"),
                        EndTime = TimeOnly.Parse("07:30"),
                        ActivityTypeId = 3,
                        LocationId = 9,
                        Description = "Morning yoga class."
                    },
                    new Schedule
                    {
                        OrganizationId = 3,
                        DayOfWeek = "Thursday",
                        StartTime = TimeOnly.Parse("18:00"),
                        EndTime = TimeOnly.Parse("19:00"),
                        ActivityTypeId = 3,
                        LocationId = 3,
                        Description = "HIIT bootcamp session."
                    },
                    new Schedule
                    {
                        OrganizationId = 3,
                        DayOfWeek = "Friday",
                        StartTime = TimeOnly.Parse("06:30"),
                        EndTime = TimeOnly.Parse("07:30"),
                        ActivityTypeId = 3,
                        LocationId = 9,
                        Description = "Morning yoga class."
                    },
                    new Schedule
                    {
                        OrganizationId = 3,
                        DayOfWeek = "Friday",
                        StartTime = TimeOnly.Parse("17:00"),
                        EndTime = TimeOnly.Parse("18:30"),
                        ActivityTypeId = 3,
                        LocationId = 9,
                        Description = "Boxing basics class."
                    },
                    new Schedule
                    {
                        OrganizationId = 3,
                        DayOfWeek = "Saturday",
                        StartTime = TimeOnly.Parse("09:00"),
                        EndTime = TimeOnly.Parse("11:00"),
                        ActivityTypeId = 4,
                        LocationId = 7,
                        Description = "Volleyball practice and games."
                    },
                    new Schedule
                    {
                        OrganizationId = 3,
                        DayOfWeek = "Sunday",
                        StartTime = TimeOnly.Parse("10:00"),
                        EndTime = TimeOnly.Parse("12:00"),
                        ActivityTypeId = 13,  // Workshop
                        LocationId = 10,
                        Description = "Monthly nutrition and wellness workshop."
                    }
                };

                await context.Schedules.AddRangeAsync(schedules);
                await context.SaveChangesAsync();
            }
        }
    }
}