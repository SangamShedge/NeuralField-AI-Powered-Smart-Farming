from django.urls import path
from .views import (
    CreateMyCropAPIView,
    ListMyCropsAPIView,
    UpdateMyCropAPIView,
    SoftDeleteMyCropAPIView,
    
    CreateCropNoteAPIView,
    ListCropNotesAPIView,
    UpdateCropNoteAPIView,
    SoftDeleteCropNoteAPIView
)

urlpatterns = [
    path("my_crop/create/", CreateMyCropAPIView.as_view()),
    path("my_crop/list/", ListMyCropsAPIView.as_view()),
    path("my_crop/update/", UpdateMyCropAPIView.as_view()),
    path("my_crop/soft_delete/", SoftDeleteMyCropAPIView.as_view()),
    
    path("crop_note/create/", CreateCropNoteAPIView.as_view()),
    path("crop_note/list/", ListCropNotesAPIView.as_view()),
    path("crop_note/update/", UpdateCropNoteAPIView.as_view()),
    path("crop_note/soft_delete/", SoftDeleteCropNoteAPIView.as_view()),
]