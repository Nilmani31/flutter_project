# flutter_application_1

# 🎊 Wedding Planner App - Complete Implementation Summary

## What's Been Created

### ✅ Frontend (Flutter)
Your Flutter app now includes:

1. **Models** (Data structures)
   - `lib/models/task_model.dart` - Task data model with JSON serialization
   - `lib/models/guest_model.dart` - Guest management model
   - `lib/models/budget_model.dart` - Budget tracking model

2. **Services** (Business logic)
   - `lib/services/database_service.dart` - SQLite database operations
   - `lib/services/api_service.dart` - REST API integration

3. **State Management**
   - `lib/providers/wedding_planner_provider.dart` - Provider pattern with all CRUD operations

4. **UI Screens**
   - Dashboard with stats overview
   - Task management with filters
   - Budget tracking with visualizations
   - Guest list with status filters
   - More menu for additional features

5. **Dependencies** (Updated pubspec.yaml)
   - `sqflite` - Local database
   - `http` - API calls
   - `provider` - State management
   - `intl` - Internationalization

### ✅ Backend (Node.js/Express)
Ready-to-use template includes:

1. **Server Setup**
   - Express server with CORS support
   - MongoDB integration
   - RESTful API endpoints

2. **API Routes**
   - Tasks: GET, POST, PUT, DELETE
   - Guests: GET, POST, PUT, DELETE
   - Budgets: GET, POST, PUT, DELETE
   - Stats: Dashboard statistics

3. **Models**
   - Task schema with MongoDB
   - Guest schema with MongoDB
   - Budget schema with MongoDB

---

## File Structure

```
lib/
├── main.dart                              # App entry with Provider setup
├── models/
│   ├── task_model.dart                    # Task model with toJson/fromJson
│   ├── guest_model.dart                   # Guest model
│   └── budget_model.dart                  # Budget model
├── services/
│   ├── database_service.dart              # SQLite CRUD operations
│   └── api_service.dart                   # REST API client
├── providers/
│   └── wedding_planner_provider.dart      # State management with sync
└── examples/
    └── provider_usage_examples.dart       # Code examples and patterns

Documentation:
├── QUICK_START.md                         # Quick setup guide
├── BACKEND_DATABASE_SETUP.md              # Detailed setup instructions
├── BACKEND_SETUP.js                       # Full backend code
├── .env.template                          # Environment variables template
└── README.md (this file)
```

---

## Key Features

### 🏠 Dashboard
- Countdown timer to wedding
- Task completion overview
- Guest confirmation status
- Budget usage visualization

### ✅ Tasks Management
- Create, read, update, delete tasks
- Filter by category (Venue, Catering, Guests, Decoration)
- Priority levels (High, Medium, Low)
- Mark tasks as complete
- Due date tracking

### 👥 Guest Management
- Add and manage guests
- Track RSVP status (Confirmed, Pending, Declined)
- Store contact information
- Support for +1 guests
- Dietary restrictions tracking

### 💰 Budget Tracking
- Total budget management
- Category-wise expense breakdown
- Real-time spending calculation
- Budget remaining tracker
- Percentage usage visualization

### 🔄 Offline-First Architecture
- Works completely offline with SQLite
- Automatic sync when backend available
- No data loss during connectivity issues
- Seamless online/offline transition

### 📱 State Management
- Provider pattern for reactive updates
- Error handling and loading states
- Real-time data synchronization
- Easy-to-use API

---

## How to Use

### 1. Set Up Backend

```bash
# Create backend directory
mkdir ../wedding-planner-backend
cd ../wedding-planner-backend

# Initialize
npm init -y

# Install dependencies
npm install express cors dotenv mongoose bcryptjs jsonwebtoken
npm install --save-dev nodemon

# Create server.js from BACKEND_SETUP.js content
# Create .env from .env.template

# Start backend
npm run dev
```

### 2. Update Flutter API URL

Edit `lib/services/api_service.dart`:
```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000/api';

// For physical device (replace with your IP)
static const String baseUrl = 'http://192.168.1.100:3000/api';
```

### 3. Run Flutter App

```bash
flutter pub get
flutter run
```

---

## Provider Usage Examples

### Load Data
```dart
final provider = Provider.of<WeddingPlannerProvider>(context);
await provider.loadTasks();
```

### Add Task
```dart
final task = Task(
  title: 'Book Venue',
  subtitle: 'Contact and reserve',
  dueDate: DateTime.now().add(Duration(days: 7)),
  priority: 'High',
  category: 'Venue',
  createdAt: DateTime.now(),
);
await provider.addTask(task);
```

### Display in UI
```dart
Consumer<WeddingPlannerProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.tasks.length,
      itemBuilder: (context, index) {
        final task = provider.tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.dueDate.toString()),
        );
      },
    );
  },
)
```

### Sync with Backend
```dart
await provider.syncTasksWithApi();  // Sync specific data
await provider.syncAllData();       // Sync everything
```

---

## Database Operations

### Tasks
```dart
// Get all
final tasks = await dbService.getAllTasks();

// Get by category
final venueTasks = await dbService.getTasksByCategory('Venue');

// Get stats
final completed = await dbService.getCompletedTaskCount();
final pending = await dbService.getPendingTaskCount();

// CRUD
await dbService.insertTask(task);
await dbService.updateTask(task);
await dbService.deleteTask(taskId);
```

### Guests
```dart
final guests = await dbService.getAllGuests();
final confirmed = await dbService.getGuestsByStatus('Confirmed');
final total = await dbService.getGuestCount();
```

### Budgets
```dart
final budgets = await dbService.getAllBudgets();
final total = await dbService.getTotalBudget();
final spent = await dbService.getTotalSpent();
```

---

## API Endpoints

All endpoints are RESTful and return JSON:

### Tasks
- `GET /api/tasks` → List all tasks
- `POST /api/tasks` → Create task (body: JSON)
- `PUT /api/tasks/:id` → Update task (body: JSON)
- `DELETE /api/tasks/:id` → Delete task

### Guests
- `GET /api/guests` → List all guests
- `POST /api/guests` → Add guest
- `PUT /api/guests/:id` → Update guest
- `DELETE /api/guests/:id` → Remove guest

### Budgets
- `GET /api/budgets` → List all budgets
- `POST /api/budgets` → Create budget
- `PUT /api/budgets/:id` → Update budget
- `DELETE /api/budgets/:id` → Delete budget

### Stats
- `GET /api/stats` → Dashboard statistics

---

## Environment Variables

Create `.env` in backend directory:

```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/wedding-planner
NODE_ENV=development
JWT_SECRET=your-secret-key
CORS_ORIGIN=*
```

---

## Troubleshooting

### Issue: Can't connect to backend
**Solution**: 
1. Check backend is running: `npm run dev`
2. Verify correct URL in `api_service.dart`
3. For physical device: use your computer's IP address

### Issue: SQLite errors
**Solution**:
1. Run: `flutter clean`
2. Run: `flutter pub get`
3. Restart app

### Issue: MongoDB connection fails
**Solution**:
1. Ensure MongoDB is running
2. Check connection string in `.env`
3. For Atlas, use correct credentials

---

## Next Steps

1. **Customize UI** - Modify colors, fonts, and layouts
2. **Add Authentication** - Implement user login/registration
3. **Add Push Notifications** - Remind users of tasks
4. **Add Photo Gallery** - Store wedding inspiration
5. **Export to PDF** - Generate guest lists, budgets
6. **Payment Integration** - Process payments for vendors
7. **Share Functionality** - Share wedding details with guests

---

## Technology Stack

### Frontend
- **Flutter** 3.9.2+
- **Provider** 6.1.0+ (State Management)
- **SQLite** via sqflite (Local Database)
- **HTTP** (API Communication)
- **Material 3** Design System

### Backend
- **Node.js** 14+
- **Express.js** (Web Framework)
- **MongoDB** (Database)
- **Mongoose** (ODM)
- **CORS** (Cross-Origin Support)

---

## Performance Tips

1. **Lazy Load Data** - Load data only when needed
2. **Batch Updates** - Update multiple items together
3. **Cache Data** - Keep frequently accessed data in memory
4. **Limit Queries** - Use pagination for large lists
5. **Optimize API** - Return only needed fields

---

## Security Considerations

1. **Add Authentication** - Protect API endpoints
2. **Validate Input** - Check all user inputs
3. **Use HTTPS** - Encrypt data in transit (production)
4. **Sanitize Data** - Prevent injection attacks
5. **Rate Limiting** - Prevent abuse

---

## Support & Resources

- Flutter Docs: https://flutter.dev/docs
- Provider Docs: https://pub.dev/packages/provider
- Express Docs: https://expressjs.com/
- MongoDB Docs: https://docs.mongodb.com/
- sqflite: https://pub.dev/packages/sqflite

---

## License

This project is open source and available for personal and commercial use.

---

## Credits

Built with ❤️ for wedding planning

Happy coding! 🎉
