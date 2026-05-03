from django.urls import path
from .views import (
    MarketMetaAPIView,
    MarketDashboardAPIView,
    MarketPricesAPIView,
    MarketComparisonAPIView,
    # PriceHistoryAPIView
)

urlpatterns = [
    path("mandi/meta/", MarketMetaAPIView.as_view()),
    path("mandi/dashboard/", MarketDashboardAPIView.as_view()),
    path("mandi/prices/", MarketPricesAPIView.as_view()),
    path("mandi/comparison/", MarketComparisonAPIView.as_view()),
    # path("mandi/history/", PriceHistoryAPIView.as_view())
]