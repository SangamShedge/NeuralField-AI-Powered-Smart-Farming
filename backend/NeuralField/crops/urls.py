from django.urls import path
from .views import (
    CreateMyCropAPIView,
    ListMyCropsAPIView,
    UpdateMyCropAPIView,
    SoftDeleteMyCropAPIView
)

urlpatterns = [
    path("my_crop/create/", CreateMyCropAPIView.as_view()),
    path("my_crop/list/", ListMyCropsAPIView.as_view()),
    path("my_crop/update/", UpdateMyCropAPIView.as_view()),
    path("my_crop/soft_delete/", SoftDeleteMyCropAPIView.as_view()),
]