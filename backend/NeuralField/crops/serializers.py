from rest_framework import serializers
from .models import MyCrop

class MyCropSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyCrop
        fields = "__all__"
        read_only_fields = ["user", "is_active"]