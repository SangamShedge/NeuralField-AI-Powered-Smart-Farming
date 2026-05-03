from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone
import datetime

class User(AbstractUser):
    ROLE_CHOICES = (
        ("admin", "Admin"),
        ("farmer", "Farmer"),
        ("trader", "Trader"),
    )
    username = models.CharField(max_length=50, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default="farmer"
    )
    is_verified = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return self.username
    

class OTP(models.Model):
    email = models.EmailField()
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    def is_expired(self):
        return timezone.now() > self.created_at + datetime.timedelta(minutes=5)
    def __str__(self):
        return f"{self.email} - {self.otp}"


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    full_name = models.CharField(max_length=150, null=True, blank=True)
    mobile_number = models.CharField(max_length=15, null=True, blank=True)
    state = models.CharField(max_length=100, null=True, blank=True)
    district = models.CharField(max_length=100, null=True, blank=True)
    taluka = models.CharField(max_length=100, null=True, blank=True)
    city = models.CharField(max_length=100, null=True, blank=True)
    pincode = models.CharField(max_length=10, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    profile_picture = models.ImageField(
        upload_to="profile_pictures/",
        null=True,
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return self.full_name