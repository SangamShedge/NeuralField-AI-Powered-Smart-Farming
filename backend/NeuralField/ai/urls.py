from django.urls import path

from .views import (
    WeatherAPIView,
    CropChoicesAPIView,
    CropRecommendationAPIView,
    FertilizerChoicesAPIView,
    FertilizerRecommendationAPIView,
    NPKCalculatorAPIView,
    PestDetectionAPIView,
    
    AgricultureNewsAPIView,
    
    GeminiChatAPIView
)

urlpatterns = [
    path('weather/', WeatherAPIView.as_view()),
    
    path("crop-choices/", CropChoicesAPIView.as_view()),
    path("crop-recommend/", CropRecommendationAPIView.as_view()),
    
    path('fertilizer-choices/', FertilizerChoicesAPIView.as_view()),
    path('fertilizer-recommend/', FertilizerRecommendationAPIView.as_view()),
    
    path('npk-calculator/', NPKCalculatorAPIView.as_view()),
    
    path('pest-detection/', PestDetectionAPIView.as_view()),
    
    path('agriculture-news/', AgricultureNewsAPIView.as_view()),
    
    path('gemini-chat/', GeminiChatAPIView.as_view())
]   