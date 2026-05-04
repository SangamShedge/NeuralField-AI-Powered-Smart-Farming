from rest_framework import serializers
from .models import MyCrop, CropNote

class MyCropSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyCrop
        fields = "__all__"
        read_only_fields = ["user", "is_active"]

class CropNoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = CropNote
        fields = "__all__"
        read_only_fields = ["is_active"]