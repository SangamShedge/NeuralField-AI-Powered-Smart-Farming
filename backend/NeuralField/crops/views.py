from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import MyCrop
from .serializers import MyCropSerializer


class CreateMyCropAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = MyCropSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response({
                "status": True,
                "message": "Crop added successfully",
                "data": serializer.data
            })
        return Response({
            "status": False,
            "errors": serializer.errors
        })


class ListMyCropsAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        crops = MyCrop.objects.filter(user=request.user, is_active=True)
        serializer = MyCropSerializer(crops, many=True)

        return Response({
            "status": True,
            "count": crops.count(),
            "data": serializer.data
        })


class UpdateMyCropAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        crop_id = request.data.get("id")

        try:
            crop = MyCrop.objects.get(id=crop_id, user=request.user, is_active=True)
        except MyCrop.DoesNotExist:
            return Response({
                "status": False,
                "message": "Crop not found"
            })

        serializer = MyCropSerializer(crop, data=request.data, partial=True)

        if serializer.is_valid():
            serializer.save()
            return Response({
                "status": True,
                "message": "Crop updated",
                "data": serializer.data
            })

        return Response({
            "status": False,
            "errors": serializer.errors
        })


class SoftDeleteMyCropAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        crop_id = request.data.get("id")

        try:
            crop = MyCrop.objects.get(id=crop_id, user=request.user, is_active=True)
        except MyCrop.DoesNotExist:
            return Response({
                "status": False,
                "message": "Crop not found"
            })

        crop.is_active = False
        crop.save()

        return Response({
            "status": True,
            "message": "Crop soft deleted successfully"
        })