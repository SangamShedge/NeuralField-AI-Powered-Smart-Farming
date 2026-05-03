from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from .helper import get_lang_value
from .data_loader import load_json
from .serializers import (CropSerializer, CropRequestSerializer,
                        CultivationSerializer, CultivationRequestSerializer,
                        DiseaseSerializer, DiseaseRequestSerializer,
                        PestSerializer, PestRequestSerializer)


class CropListAPIView(APIView):

    def post(self, request):
        req_serializer = CropRequestSerializer(data=request.data)
        req_serializer.is_valid(raise_exception=True)

        search = req_serializer.validated_data.get("search")

        data = load_json("crops.json")

        result = []

        lang = req_serializer.validated_data.get("lang", "en")

        for item in data:
            name = get_lang_value(item["name"], lang)

            # 🔍 Search filter
            if search and search.lower() not in name.lower():
                continue
            
            formatted_item = item.copy()

            # 🌐 Convert multilingual fields
            formatted_item["name"] = name
            formatted_item["growingSeason"] = get_lang_value(item["growingSeason"], lang)
            formatted_item["waterRequirement"] = get_lang_value(item["waterRequirement"], lang)
            formatted_item["soilType"] = get_lang_value(item["soilType"], lang)
            formatted_item["benefits"] = get_lang_value(item["benefits"], lang)
            formatted_item["description"] = get_lang_value(item["description"], lang)

            # 🌡️ Temperature range
            formatted_item["temperatureRange"] = f"{item['minTemperature']}°C - {item['maxTemperature']}°C"

            result.append(formatted_item)

        serializer = CropSerializer(result, many=True)

        return Response({
            "status": True,
            "count": len(serializer.data),
            "data": serializer.data
        }, status=status.HTTP_200_OK)


class CultivationListAPIView(APIView):

    def post(self, request):
        req_serializer = CultivationRequestSerializer(data=request.data)
        req_serializer.is_valid(raise_exception=True)

        lang = req_serializer.validated_data.get("lang", "en")
        search = req_serializer.validated_data.get("search")
        category_filter = req_serializer.validated_data.get("category")
        difficulty_filter = req_serializer.validated_data.get("difficulty")
        season_filter = req_serializer.validated_data.get("season")

        data = load_json("cultivation.json")

        result = []

        for item in data:

            title = get_lang_value(item["title"], lang)
            description = get_lang_value(item["description"], lang)
            category = get_lang_value(item["category"], lang)
            season = get_lang_value(item["season"], lang)
            benefits = get_lang_value(item["benefits"], lang)

            # 🔥 FIXED FIELDS
            steps = get_lang_value(item["steps"], lang)
            materials = get_lang_value(item["requiredMaterials"], lang)

            # 🔍 Filters
            if category_filter and category.lower() != category_filter.lower():
                continue
            
            if difficulty_filter and item["difficulty"] != difficulty_filter:
                continue
            
            if season_filter and season_filter.lower() not in season.lower():
                continue
            
            if search:
                if (search.lower() not in title.lower() and
                    search.lower() not in description.lower()):
                    continue
                
            formatted_item = item.copy()

            # 🌐 Language conversion
            formatted_item["title"] = title
            formatted_item["description"] = description
            formatted_item["category"] = category
            formatted_item["season"] = season
            formatted_item["benefits"] = benefits

            # 🔥 IMPORTANT FIX
            formatted_item["steps"] = steps
            formatted_item["requiredMaterials"] = materials

            formatted_item["difficultyLabel"] = self.get_difficulty_label(item["difficulty"])
            formatted_item["estimatedTimeText"] = f"{item['estimatedTime']} minutes"

            result.append(formatted_item)

        serializer = CultivationSerializer(result, many=True)

        return Response({
            "status": True,
            "count": len(serializer.data),
            "data": serializer.data
        })

    def get_difficulty_label(self, level):
        return {
            1: "Very Easy",
            2: "Easy",
            3: "Medium",
            4: "Hard",
            5: "Expert"
        }.get(level, "Unknown")


class DiseaseListAPIView(APIView):

    def post(self, request):
        req_serializer = DiseaseRequestSerializer(data=request.data)
        req_serializer.is_valid(raise_exception=True)

        lang = req_serializer.validated_data.get("lang", "en")
        search = req_serializer.validated_data.get("search")
        crop_filter = req_serializer.validated_data.get("crop")
        type_filter = req_serializer.validated_data.get("type")
        severity_filter = req_serializer.validated_data.get("severity")

        data = load_json("diseases.json")
        result = []

        for item in data:

            # 🌐 Language conversion
            name = get_lang_value(item["name"], lang)
            description = get_lang_value(item["description"], lang)
            symptoms = get_lang_value(item["symptoms"], lang)
            preventive = get_lang_value(item["preventiveMeasures"], lang)
            organic = get_lang_value(item["organicControls"], lang)
            chemical = get_lang_value(item["chemicalControls"], lang)

            type_val = get_lang_value(item["type"], lang)
            severity_val = get_lang_value(item["severity"], lang)
            crops = get_lang_value(item["affectedCrops"], lang)

            favorable = get_lang_value(item["favorableConditions"], lang)
            transmission = get_lang_value(item["transmissionMethod"], lang)
            incubation = get_lang_value(item["incubationPeriod"], lang)
            economic = get_lang_value(item["economicImpact"], lang)
            global_dist = get_lang_value(item["globalDistribution"], lang)
            common = get_lang_value(item["commonName"], lang)
            host = get_lang_value(item["hostRange"], lang)
            resistance = get_lang_value(item["fungicideResistance"], lang)

            # 🔍 Filters
            if crop_filter:
                if crop_filter.lower() not in [c.lower() for c in crops]:
                    continue

            if type_filter and type_val.lower() != type_filter.lower():
                continue

            if severity_filter and severity_val.lower() != severity_filter.lower():
                continue

            if search:
                if search.lower() not in name.lower() and search.lower() not in description.lower():
                    continue

            formatted_item = item.copy()

            # Assign converted fields
            formatted_item["name"] = name
            formatted_item["description"] = description
            formatted_item["symptoms"] = symptoms
            formatted_item["preventiveMeasures"] = preventive
            formatted_item["organicControls"] = organic
            formatted_item["chemicalControls"] = chemical

            formatted_item["type"] = type_val
            formatted_item["severity"] = severity_val
            formatted_item["affectedCrops"] = crops

            formatted_item["favorableConditions"] = favorable
            formatted_item["transmissionMethod"] = transmission
            formatted_item["incubationPeriod"] = incubation
            formatted_item["economicImpact"] = economic
            formatted_item["globalDistribution"] = global_dist
            formatted_item["commonName"] = common
            formatted_item["hostRange"] = host
            formatted_item["fungicideResistance"] = resistance

            formatted_item["severityLabel"] = self.get_severity_label(severity_val)

            # 🖼️ IMAGE FIX (STRING)
            image_path = item.get("imageAsset")
            if image_path:
                formatted_item["imageAsset"] = request.build_absolute_uri(f"/{image_path}")
            else:
                formatted_item["imageAsset"] = None

            result.append(formatted_item)

        serializer = DiseaseSerializer(result, many=True)

        return Response({
            "status": True,
            "count": len(serializer.data),
            "data": serializer.data
        })

    def get_severity_label(self, severity):
        return {
            "low": "🟢 Low",
            "medium": "🟡 Medium",
            "high": "🔴 High"
        }.get(severity.lower(), severity)


class PestListAPIView(APIView):

    def post(self, request):
        req_serializer = PestRequestSerializer(data=request.data)
        req_serializer.is_valid(raise_exception=True)

        lang = req_serializer.validated_data.get("lang", "en")
        search = req_serializer.validated_data.get("search")
        crop_filter = req_serializer.validated_data.get("crop")
        type_filter = req_serializer.validated_data.get("type")
        severity_filter = req_serializer.validated_data.get("severity")

        data = load_json("pests.json")
        result = []

        for item in data:

            # 🌐 Language conversion
            name = get_lang_value(item["name"], lang)
            description = get_lang_value(item["description"], lang)
            symptoms = get_lang_value(item["symptoms"], lang)
            organic = get_lang_value(item["organicControls"], lang)
            chemical = get_lang_value(item["chemicalControls"], lang)
            preventive = get_lang_value(item["preventiveMeasures"], lang)

            type_val = get_lang_value(item["type"], lang)
            severity_val = get_lang_value(item["severity"], lang)
            crops = get_lang_value(item["affectedCrops"], lang)

            favorable = get_lang_value(item["favorableConditions"], lang)
            transmission = get_lang_value(item["transmissionMethod"], lang)
            lifecycle = get_lang_value(item["lifeCycle"], lang)
            economic = get_lang_value(item["economicImpact"], lang)
            global_dist = get_lang_value(item["globalDistribution"], lang)
            common = get_lang_value(item["commonName"], lang)
            host = get_lang_value(item["hostRange"], lang)
            resistance = get_lang_value(item["pesticideResistance"], lang)

            # 🔍 Filters
            if crop_filter:
                if crop_filter.lower() not in [c.lower() for c in crops]:
                    continue

            if type_filter and type_val.lower() != type_filter.lower():
                continue

            if severity_filter and severity_val.lower() != severity_filter.lower():
                continue

            if search:
                if search.lower() not in name.lower() and search.lower() not in description.lower():
                    continue

            formatted_item = item.copy()

            # Assign converted fields
            formatted_item["name"] = name
            formatted_item["description"] = description
            formatted_item["symptoms"] = symptoms
            formatted_item["organicControls"] = organic
            formatted_item["chemicalControls"] = chemical
            formatted_item["preventiveMeasures"] = preventive

            formatted_item["type"] = type_val
            formatted_item["severity"] = severity_val
            formatted_item["affectedCrops"] = crops

            formatted_item["favorableConditions"] = favorable
            formatted_item["transmissionMethod"] = transmission
            formatted_item["lifeCycle"] = lifecycle
            formatted_item["economicImpact"] = economic
            formatted_item["globalDistribution"] = global_dist
            formatted_item["commonName"] = common
            formatted_item["hostRange"] = host
            formatted_item["pesticideResistance"] = resistance

            formatted_item["severityLabel"] = self.get_severity_label(severity_val)

            # 🖼️ IMAGE FIX (STRING)
            image_path = item.get("imageAsset")
            if image_path:
                formatted_item["imageAsset"] = request.build_absolute_uri(f"/{image_path}")
            else:
                formatted_item["imageAsset"] = None

            # Extra fields
            formatted_item["quickInfo"] = {
                "type": type_val,
                "severity": formatted_item["severityLabel"],
                "spread": transmission
            }

            formatted_item["controls"] = {
                "organic": organic,
                "chemical": chemical
            }

            formatted_item["alert"] = f"Risk increases during {favorable}"

            result.append(formatted_item)

        serializer = PestSerializer(result, many=True)

        return Response({
            "status": True,
            "count": len(serializer.data),
            "data": serializer.data
        })

    def get_severity_label(self, severity):
        return {
            "low": "🟢 Low",
            "medium": "🟡 Medium",
            "high": "🔴 High"
        }.get(severity.lower(), severity)