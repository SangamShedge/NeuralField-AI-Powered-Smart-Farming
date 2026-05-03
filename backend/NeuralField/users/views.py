import random
from django.conf import settings
from django.core.mail import send_mail
from django.contrib.auth.hashers import make_password, check_password

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from rest_framework_simplejwt.tokens import RefreshToken # type: ignore

from .models import User, OTP, Profile
from .serializers import UserSerializer, ProfileSerializer


# 🔐 REGISTER API
class RegisterAPIView(APIView):

    def post(self, request):
        email = request.data.get("email")
        username = request.data.get("username")
        password = request.data.get("password")

        if User.objects.filter(email=email).exists():
            return Response({"status": False, "message": "Email already exists"})

        user = User.objects.create(
            email=email,
            username=username,
            password=make_password(password)
        )

        Profile.objects.create(user=user)

        otp_value = str(random.randint(100000, 999999))
        OTP.objects.create(email=email, otp=otp_value)

        # 📧 Send Email
        send_mail(
            subject="Your OTP Verification",
            message=f"Your OTP is {otp_value}",
            from_email=settings.EMAIL_HOST_USER,
            recipient_list=[email],
            fail_silently=False,
        )

        return Response({
            "status": True,
            "message": "User registered. OTP sent to email"
        })



# 🔁 SEND OTP
class SendOTPAPIView(APIView):

    def post(self, request):
        email = request.data.get("email")

        if not User.objects.filter(email=email).exists():
            return Response({"status": False, "message": "User not found"})

        otp_value = str(random.randint(100000, 999999))
        OTP.objects.create(email=email, otp=otp_value)

        send_mail(
            subject="Verification OTP",
            message=f"Your OTP is {otp_value}",
            from_email=settings.EMAIL_HOST_USER,
            recipient_list=[email],
        )

        return Response({"status": True, "message": "OTP resent"})


# 🔢 VERIFY OTP
class VerifyOTPAPIView(APIView):

    def post(self, request):
        email = request.data.get("email")
        otp = request.data.get("otp")

        try:
            otp_obj = OTP.objects.filter(email=email).latest("created_at")
        except OTP.DoesNotExist:
            return Response({"status": False, "message": "OTP not found"})

        if otp_obj.is_expired():
            return Response({"status": False, "message": "OTP expired"})

        if otp_obj.otp != otp:
            return Response({"status": False, "message": "Invalid OTP"})

        user = User.objects.get(email=email)
        user.is_verified = True
        user.save()

        return Response({
            "status": True,
            "message": "Account verified successfully"
        })


# 🔑 LOGIN (JWT)
class LoginAPIView(APIView):

    def post(self, request):
        email = request.data.get("email")
        password = request.data.get("password")

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({"status": False, "message": "User not found"})

        if not check_password(password, user.password):
            return Response({"status": False, "message": "Invalid password"})

        if not user.is_verified:
            return Response({"status": False, "message": "Account not verified"})

        refresh = RefreshToken.for_user(user)

        return Response({
            "status": True,
            "message": "Login successful",
            "access_token": str(refresh.access_token),
            "refresh_token": str(refresh),
        })


# 🔒 LOGOUT (Blacklist Refresh Token)
class LogoutAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data["refresh_token"]
            token = RefreshToken(refresh_token)
            token.blacklist()

            return Response({"status": True, "message": "Logged out"})
        except Exception as e:
            return Response({"status": False, "message": str(e)})


# 🔁 FORGOT PASSWORD (Send OTP)
class ForgotPasswordAPIView(APIView):

    def post(self, request):
        email = request.data.get("email")

        if not User.objects.filter(email=email).exists():
            return Response({"status": False, "message": "Email not registered"})

        otp_value = str(random.randint(100000, 999999))
        OTP.objects.create(email=email, otp=otp_value)

        # 📧 Send Email
        send_mail(
            subject="Verification OTP",
            message=f"Your OTP is {otp_value}",
            from_email=settings.EMAIL_HOST_USER,
            recipient_list=[email],
            fail_silently=False,
        )

        return Response({
            "status": True,
            "message": "OTP sent to email"
        })


# 🔄 RESET PASSWORD
class ResetPasswordAPIView(APIView):

    def post(self, request):
        email = request.data.get("email")
        otp = request.data.get("otp")
        new_password = request.data.get("new_password")

        try:
            otp_obj = OTP.objects.filter(email=email).latest("created_at")
        except OTP.DoesNotExist:
            return Response({"status": False, "message": "OTP not found"})

        if otp_obj.is_expired():
            return Response({"status": False, "message": "OTP expired"})

        if otp_obj.otp != otp:
            return Response({"status": False, "message": "Invalid OTP"})

        user = User.objects.get(email=email)
        user.password = make_password(new_password)
        user.save()

        return Response({
            "status": True,
            "message": "Password reset successful"
        })


# 👤 PROFILE DETAIL
class ProfileDetailAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            profile = Profile.objects.get(user=request.user)
            serializer = ProfileSerializer(profile)

            return Response({
                "status": True,
                "data": {
                    "username": request.user.username,
                    "email": request.user.email,
                    "role": request.user.role,
                    "profile": serializer.data
                }
            })

        except Profile.DoesNotExist:
            return Response({
                "status": False,
                "message": "Profile not found"
            })


# 👤 PROFILE UPDATE
class ProfileUpdateAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user

        try:
            profile = Profile.objects.get(user=user)
        except Profile.DoesNotExist:
            return Response({"status": False, "message": "Profile not found"})

        serializer = ProfileSerializer(profile, data=request.data, partial=True)

        if serializer.is_valid():
            serializer.save()
            return Response({
                "status": True,
                "message": "Profile updated",
                "data": serializer.data
            })

        return Response(serializer.errors)

