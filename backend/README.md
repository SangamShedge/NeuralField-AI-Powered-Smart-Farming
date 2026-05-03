# NeuralField Backend

AI-Powered Smart Farming Platform (NeuralField) Backend API built with Django REST Framework.

## Overview

NeuralField is a comprehensive agricultural platform that leverages artificial intelligence to provide farmers with intelligent recommendations for crop selection, fertilizer optimization, pest detection, and market insights. The backend is built using Django and Django REST Framework, providing a robust API for the frontend application.

## Features

- **User Management**: Custom user authentication with JWT tokens
- **AI-Powered Recommendations**:
  - Crop recommendation based on soil and environmental factors
  - Fertilizer prediction for optimal yield
  - Pest and disease detection using image analysis
- **Weather Integration**: Real-time weather data from OpenWeatherMap API
- **Knowledge Hub**: Agricultural information and best practices
- **Market Information**: Crop pricing and market trends
- **Media Management**: Image upload and storage for pest detection

## Tech Stack

- **Backend Framework**: Django 5.0.6
- **API Framework**: Django REST Framework 3.17.1
- **Authentication**: JWT (djangorestframework-simplejwt)
- **Database**: MySQL
- **Machine Learning**: TensorFlow, scikit-learn
- **File Storage**: AWS S3 (django-storages)
- **CORS**: django-cors-headers
- **Email**: SMTP (Gmail)

## Prerequisites

- Python 3.10+
- MySQL Server
- Virtual environment (recommended)

## Installation

1. **Clone the repository** (if applicable) and navigate to the backend directory:
   ```bash
   cd backend
   ```

2. **Create and activate virtual environment**:
   ```bash
   python -m venv venv
   # On Windows:
   venv\Scripts\activate
   # On macOS/Linux:
   source venv/bin/activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up MySQL database**:
   - Create a database named `NeuralField`
   - Update database credentials in `NeuralField/settings.py` if needed

5. **Configure environment variables**:
   - Set `OPENWEATHER_API_KEY` in your environment or settings
   - Configure AWS S3 credentials for file storage (if using S3)
   - Update email settings if needed

6. **Run migrations**:
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

7. **Create superuser** (optional):
   ```bash
   python manage.py createsuperuser
   ```

## Usage

1. **Start the development server**:
   ```bash
   python manage.py runserver
   ```

2. **Access the API**:
   - API endpoints will be available at `http://localhost:8000/api/`
   - Admin panel at `http://localhost:8000/admin/`

## API Endpoints

### Authentication
- `POST /api/auth/login/` - User login
- `POST /api/auth/register/` - User registration
- `POST /api/auth/refresh/` - Refresh JWT token

### AI Features
- `POST /api/ai/weather/` - Get weather data
- `POST /api/ai/crop-recommendation/` - Get crop recommendations
- `POST /api/ai/fertilizer/` - Get fertilizer recommendations
- `POST /api/ai/pest-detection/` - Detect pests/diseases from images

### Knowledge Hub
- `GET /api/knowledge/crops/` - Crop information
- `GET /api/knowledge/diseases/` - Disease information
- `GET /api/knowledge/pests/` - Pest information
- `GET /api/knowledge/cultivation/` - Cultivation practices

### Markets
- `GET /api/markets/prices/` - Market prices

### User Management
- `GET /api/users/profile/` - User profile
- `PUT /api/users/profile/` - Update profile

## Project Structure

```
backend/
├── NeuralField/                 # Main Django project
│   ├── settings.py        # Django settings
│   ├── urls.py           # Main URL configuration
│   ├── wsgi.py           # WSGI configuration
│   └── asgi.py           # ASGI configuration
├── ai/                    # AI features app
│   ├── views.py          # API views for AI features
│   ├── models.py         # Models
│   ├── serializers.py    # DRF serializers
│   └── data/             # Static data files
├── crops/                 # Crops management app
├── knowledge_hub/         # Agricultural knowledge base
├── markets/               # Market information app
├── users/                 # User management app
├── ml_models/             # Machine learning models
│   ├── crop_recommendation/
│   ├── fertilizer/
│   └── pest_detection/
├── media/                 # Media files
├── config/                # Configuration files
└── requirements.txt       # Python dependencies
```

## Machine Learning Models

The platform includes three main ML models:

1. **Crop Recommendation**: Predicts suitable crops based on soil parameters (N, P, K, pH, etc.)
2. **Fertilizer Prediction**: Recommends optimal fertilizer amounts
3. **Pest Detection**: Identifies pests and diseases from uploaded images

Models are located in the `ml_models/` directory with separate folders for training, prediction, and utilities.

## Development

### Running Tests
```bash
python manage.py test
```

### Code Formatting
```bash
# Install black and isort if not already installed
pip install black isort
black .
isort .
```

### Database Management
```bash
# Create new migration
python manage.py makemigrations <app_name>

# Apply migrations
python manage.py migrate

# Reset database (caution!)
python manage.py flush
```

## Deployment

1. Set `DEBUG = False` in settings.py
2. Configure production database settings
3. Set up proper static file serving
4. Configure HTTPS
5. Set up proper logging
6. Use environment variables for sensitive data

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests for new features
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.