from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView # type: ignore

from .views import (
    ForgotPasswordAPIView,
    LoginAPIView,
    LogoutAPIView,
    ProfileDetailAPIView,
    ProfileUpdateAPIView,
    RegisterAPIView,
    ResetPasswordAPIView,
    SendOTPAPIView,
    VerifyOTPAPIView,
)

urlpatterns = [
    path("register/", RegisterAPIView.as_view()),
    path("login/", LoginAPIView.as_view()),
    path("logout/", LogoutAPIView.as_view()),
    path('token/refresh/', TokenRefreshView.as_view(),),
    
    path("send-otp/", SendOTPAPIView.as_view()),
    path("verify-otp/", VerifyOTPAPIView.as_view()),

    path("forgot-password/", ForgotPasswordAPIView.as_view()),
    path("reset-password/", ResetPasswordAPIView.as_view()),

    path("profile/", ProfileDetailAPIView.as_view()),
    path("update-profile/", ProfileUpdateAPIView.as_view()),
]   