import os
import requests # type: ignore
import json
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from datetime import datetime
from rest_framework import status
from ml_models.crop_recommendation.utils import get_choices
from ml_models.fertilizer.utils import get_fertilizer_choices
from ml_models.crop_recommendation.predict import predict_crop
from ml_models.fertilizer.predict import predict_fertilizer
from ml_models.pest_detection.predict import predict_disease
from .serializers import FertilizerInputSerializer
from .utils import DATA



class WeatherAPIView(APIView):

    def post(self, request):
        
        lat = request.data.get("lat")
        lon = request.data.get("lon")

        # validation
        if not lat or not lon:
            return Response({
                "status": False,
                "message": "lat and lon are required"
            })

        url = "https://api.openweathermap.org/data/2.5/weather"

        params = {
            "lat": lat,
            "lon": lon,
            "appid": settings.OPENWEATHER_API_KEY,
            "units": "metric"
        }

        try:
            res = requests.get(url, params=params)
            data = res.json()

            if data.get("cod") != 200:
                return Response({
                    "status": False,
                    "message": data.get("message", "Error from weather API")
                })

            # clean response
            result = {
                "location": {
                    "city": data.get("name"),
                    "country": data.get("sys", {}).get("country")
                },
                "weather": {
                    "temperature": data["main"]["temp"],
                    "feels_like": data["main"]["feels_like"],
                    "humidity": data["main"]["humidity"],
                    "condition": data["weather"][0]["description"]
                },
                "wind": {
                    "speed": data["wind"]["speed"]
                }
            }

            return Response({
                "status": True,
                "data": result
            })

        except Exception as e:
            return Response({
                "status": False,
                "message": str(e)
            })


class CropChoicesAPIView(APIView):

    def post(self, request):
        return Response({
            "status": True,
            "choices": get_choices()
        })

class CropRecommendationAPIView(APIView):

    def post(self, request):
        data = request.data

        # minimal validation
        if "soil_type" not in data or "season" not in data:
            return Response({
                "status": False,
                "error": "soil_type and season are required"
            })

        try:
            result = predict_crop(data)

            return Response({
                "status": True,
                "recommended_crops": result
            })

        except Exception as e:
            return Response({
                "status": False,
                "error": str(e)
            })


class FertilizerChoicesAPIView(APIView):

    def post(self, request):
        return Response({
            "status": True,
            "choices": get_fertilizer_choices()
        })

class FertilizerRecommendationAPIView(APIView):

    def post(self, request):
        try:
            result = predict_fertilizer(request.data)

            return Response({
                "status": True,
                "data": result
            })

        except Exception as e:
            return Response({
                "status": False,
                "error": str(e)
            })


class PestDetectionAPIView(APIView):

    def post(self, request):
        image = request.FILES.get('image')

        if not image:
            return Response(
                {"status": False, "message": "No image uploaded"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # 📁 Save image
            upload_dir = os.path.join(settings.MEDIA_ROOT, 'uploads', 'pest_images')
            os.makedirs(upload_dir, exist_ok=True)

            file_path = os.path.join(upload_dir, image.name)

            with open(file_path, 'wb+') as f:
                for chunk in image.chunks():
                    f.write(chunk)

            # 🤖 Predict
            result = predict_disease(file_path)

            return Response(
                {
                    "status": True,
                    "message": "Prediction successful",
                    "data": result
                },
                status=status.HTTP_200_OK
            )

        except Exception as e:
            return Response(
                {
                    "status": False,
                    "message": "Something went wrong",
                    "error": str(e)
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class AgricultureNewsAPIView(APIView):

    def post(self, request):
        query = request.data.get('agriculture India farming')

        url = "https://newsdata.io/api/1/news"

        params = {
            "apikey": settings.NEWSDATA_API_KEY,
            "q": "farmer OR agriculture OR crop disease India",
            "language": "en",
            "country": "in",
            "size": 10   # fetch more if you want better sorting
        }

        try:
            response = requests.get(url, params=params)
            data = response.json()

            # 🔴 Handle API error properly
            if data.get("status") != "success":
                return Response({
                    "status": False,
                    "message": data.get("message"),
                    "raw": data
                })

            articles = []

            for item in data.get("results", []):
                pub_date = item.get("pubDate")

                # Convert date string → datetime object
                try:
                    parsed_date = datetime.strptime(pub_date, "%Y-%m-%d %H:%M:%S")
                except:
                    parsed_date = datetime.min  # fallback if format issue

                articles.append({
                    "title": item.get("title"),
                    "description": item.get("description"),
                    "image": item.get("image_url"),
                    "link": item.get("link"),
                    "source": item.get("source_id"),
                    "date": pub_date,
                    "parsed_date": parsed_date   # temporary for sorting
                })

            # ✅ SORT by latest (descending)
            articles = sorted(
                articles,
                key=lambda x: x["parsed_date"],
                reverse=True
            )

            # ❌ Remove internal field
            for article in articles:
                article.pop("parsed_date", None)

            return Response({
                "status": True,
                "type": "latest_news",
                "total": len(articles),
                "data": articles
            })

        except Exception as e:
            return Response({
                "status": False,
                "message": str(e)
            })


class GeminiChatAPIView(APIView):

    def post(self, request):
        user_message = request.data.get("message")

        if not user_message:
            return Response({
                "status": False,
                "message": "Message is required"
            }, status=status.HTTP_400_BAD_REQUEST)

        prompt = f"""
You are an NeuralField AI (AI farming assistant owned by NeuralField Pvt Ltd) for Indian farmers.
Give simple, practical advice.

IMPORTANT RULES:
- DO NOT start responses with "Namaste", "Hello", or any greeting
- DO NOT include ** or bold words in responses
- Get straight to the point with the advice
- Use simple, practical language

User: {user_message}
"""

        # url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={settings.GEMINI_API_KEY}"
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key={settings.GEMINI_API_KEY}"

        headers = {
            "Content-Type": "application/json"
        }
        data = {
            "contents": [
                {
                    "parts": [
                        {"text": prompt}
                    ]
                }
            ]
        }
        
        try:
            response = requests.post(url, headers=headers, json=data, timeout=60)
            result = response.json()

            ai_text = result["candidates"][0]["content"]["parts"][0]["text"]

            return Response({
                "status": True,
                "user_message": user_message,
                "ai_response": ai_text
            })

        except Exception as e:
            return Response({
                "status": False,
                "error": str(e),
                "raw_response": result if 'result' in locals() else None
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class NPKCalculatorAPIView(APIView):

    def post(self, request):

        serializer = FertilizerInputSerializer(data=request.data)

        if not serializer.is_valid():
            return Response({
                "status": False,
                "errors": serializer.errors
            }, status=400)

        data = serializer.validated_data

        crops = DATA["crops"]
        fertilizers = DATA["fertilizers"]

        # Input
        area = data["area"]  # acres
        target_yield = data["target_yield"]  # tons per acre

        soil_n = data["soil_n"]  # kg per acre
        soil_p = data["soil_p"]
        soil_k = data["soil_k"]

        crop = data["crop"]

        if crop not in crops:
            return Response({
                "status": False,
                "message": "Invalid crop"
            }, status=400)

        crop_req = crops[crop]  # kg per ton

        # total production
        total_tons = area * target_yield

        # required nutrients
        required_n = crop_req["N"] * total_tons
        required_p = crop_req["P"] * total_tons
        required_k = crop_req["K"] * total_tons

        # soil available nutrients
        available_n = soil_n * area
        available_p = soil_p * area
        available_k = soil_k * area

        # nutrients to apply
        n_to_apply = max(required_n - available_n, 0)
        p_to_apply = max(required_p - available_p, 0)
        k_to_apply = max(required_k - available_k, 0)

        # Fertilizer Calculation
        n_source = data["nitrogen_source"]
        p_source = data["phosphorus_source"]
        k_source = data["potassium_source"]

        if n_source not in fertilizers or \
            p_source not in fertilizers or \
            k_source not in fertilizers:
                return Response({
                    "status": False,
                    "message": "Invalid fertilizer selection"
                }, status=400)

        n_ratio = fertilizers[n_source]["N"]
        p_ratio = fertilizers[p_source]["P"]
        k_ratio = fertilizers[k_source]["K"]

        n_fertilizer = (n_to_apply / n_ratio) * 100 if n_ratio > 0 else 0
        p_fertilizer = (p_to_apply / p_ratio) * 100 if p_ratio > 0 else 0
        k_fertilizer = (k_to_apply / k_ratio) * 100 if k_ratio > 0 else 0

        # Efficiency
        n_eff = (n_to_apply / required_n * 100) if required_n > 0 else 0
        p_eff = (p_to_apply / required_p * 100) if required_p > 0 else 0
        k_eff = (k_to_apply / required_k * 100) if required_k > 0 else 0

        return Response({
            "status": True,
            "message": "Calculation successful",
            "data": {
                "input_summary": {
                    "area_acres": area,
                    "target_yield_ton_per_acre": target_yield,
                    "crop": crop
                },
                "required": {
                    "N": round(required_n, 2),
                    "P": round(required_p, 2),
                    "K": round(required_k, 2)
                },
                "available": {
                    "N": round(available_n, 2),
                    "P": round(available_p, 2),
                    "K": round(available_k, 2)
                },
                "to_apply": {
                    "N": round(n_to_apply, 2),
                    "P": round(p_to_apply, 2),
                    "K": round(k_to_apply, 2)
                },
                "fertilizers": {
                    "nitrogen": {
                        "name": n_source,
                        "quantity_kg": round(n_fertilizer, 2)
                    },
                    "phosphorus": {
                        "name": p_source,
                        "quantity_kg": round(p_fertilizer, 2)
                    },
                    "potassium": {
                        "name": k_source,
                        "quantity_kg": round(k_fertilizer, 2)
                    }
                },
                "efficiency_percent": {
                    "N": round(n_eff, 1),
                    "P": round(p_eff, 1),
                    "K": round(k_eff, 1)
                }
            }
        })


