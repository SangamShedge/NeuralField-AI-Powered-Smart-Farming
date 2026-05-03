from django.db import models
from users.models import User

class MyCrop(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="crops")

    name = models.CharField(max_length=100)
    variety = models.CharField(max_length=100, null=True, blank=True)

    sowing_date = models.DateField()
    area = models.FloatField()

    soil_type = models.CharField(max_length=20)
    irrigation_type = models.CharField(max_length=20)

    location = models.CharField(max_length=150, null=True, blank=True)

    growth_stage = models.CharField(max_length=20)
    health_status = models.CharField(max_length=20)

    last_fertilizer = models.CharField(max_length=100, null=True, blank=True)

    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)