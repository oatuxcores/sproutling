# Plantera - Plant Watering App Architecture

## Overview
Plantera is a minimal, modern plant care app with a soft green aesthetic that helps users track and manage their plant watering schedule.

## Design Approach
- **Style**: Sophisticated with natural green accents (Nature-inspired)
- **Colors**: Soft greens (#7CB342, #AED581) on white backgrounds with minimal shadows
- **Typography**: Inter font family with clear hierarchy
- **Layout**: Card-based design with generous spacing, rounded corners

## Features
1. **Home Page**: Dashboard showing plants that need watering today with progress tracking
2. **My Plants Page**: Complete list of all plants with search functionality
3. **Add/Edit Plant Page**: Form to add new plants or edit existing ones
4. **Reminders Page**: Dedicated view for plants needing water with quick actions

## Data Models

### User Model (`lib/models/user.dart`)
- id, name, email
- created_at, updated_at

### Plant Model (`lib/models/plant.dart`)
- id, name, image_url (optional), emoji (fallback)
- watering_frequency_days (int)
- last_watered_date (DateTime)
- user_id (reference)
- created_at, updated_at
- Methods: toJson, fromJson, copyWith, needsWatering(), daysUntilNextWatering()

## Services

### PlantService (`lib/services/plant_service.dart`)
- Uses shared_preferences for local storage
- CRUD operations: getAllPlants, getPlantById, addPlant, updatePlant, deletePlant
- Business logic: getPlantsNeedingWater, getWateringProgress, markAsWatered
- Includes realistic sample data with various plant types

## UI Structure

### Pages
1. **HomePage** (`lib/pages/home_page.dart`)
   - "PLANTERA" title
   - Progress bar showing watering completion
   - Cards for plants needing water today
   - Bottom navigation

2. **MyPlantsPage** (`lib/pages/my_plants_page.dart`)
   - Search bar
   - Scrollable list of plant cards
   - Navigate to Add/Edit page

3. **AddEditPlantPage** (`lib/pages/add_edit_plant_page.dart`)
   - Form with name, watering frequency, last watered date
   - Photo upload button (optional)
   - Save button with droplet icon

4. **RemindersPage** (`lib/pages/reminders_page.dart`)
   - Cards showing overdue plants
   - "Mark as Watered" buttons
   - Visual indicators for urgency

### Reusable Components
- **PlantCard**: Display plant info in list/grid
- **WaterButton**: Droplet icon button for watering actions
- **ProgressIndicator**: Show watering completion percentage

## Navigation
- Bottom navigation bar with 4 tabs: Home, My Plants, Add Plant, Reminders
- Material page routes for form navigation

## Implementation Steps
1. Update theme with soft green color palette
2. Create data models (User, Plant)
3. Implement PlantService with local storage
4. Build reusable components (PlantCard, WaterButton)
5. Implement HomePage with progress tracking
6. Implement MyPlantsPage with search
7. Implement AddEditPlantPage with form
8. Implement RemindersPage with quick actions
9. Set up bottom navigation
10. Run compile_project to verify
