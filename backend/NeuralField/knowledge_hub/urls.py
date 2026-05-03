from django.urls import path
from .views import (
    CropListAPIView,
    CultivationListAPIView,
    DiseaseListAPIView,
    PestListAPIView
    )

urlpatterns = [
    path('crops/', CropListAPIView.as_view()),
    path('cultivation/', CultivationListAPIView.as_view()),
    path('diseases/', DiseaseListAPIView.as_view()),
    path('pests/', PestListAPIView.as_view())
]