from datetime import datetime
from collections import defaultdict
from django.db.models import Avg
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import MandiPrice
from .serializers import MandiPriceListSerializer
# from .serializers import PriceHistorySerializer


class MarketMetaAPIView(APIView):

    def post(self, request):

        state = request.data.get("state")
        district = request.data.get("district")

        base_qs = MandiPrice.objects.filter(is_active=True)

        states = list(
            base_qs.values_list("state", flat=True).distinct()
        )

        if state:
            base_qs = base_qs.filter(state=state)

        districts = list(
            base_qs.values_list("district", flat=True).distinct()
        )

        if district:
            base_qs = base_qs.filter(district=district)

        commodities = list(
            base_qs.values_list("commodity", flat=True).distinct()
        )

        return Response({
            "status": True,
            "data": {
                "states": states,
                "districts": districts,
                "commodities": commodities,
                "selected_state": state,
                "selected_district": district
            }
        })


class MarketDashboardAPIView(APIView):

    def post(self, request):

        state = request.data.get("state")
        district = request.data.get("district")

        if state:
            state = state.strip()

        if district:
            district = district.strip()

        queryset = MandiPrice.objects.filter(is_active=True)

        if state:
            queryset = queryset.filter(state__iexact=state)

        if district:
            queryset = queryset.filter(district__iexact=district)

        records = list(queryset.values(
            "commodity",
            "market",
            "modal_price",
            "arrival_date"
        ))

        if not records:
            return Response({
                "status": True,
                "message": "No data found",
                "data": {}
            })

        grouped = defaultdict(list)

        for r in records:
            key = f"{r['commodity']}_{r['market']}"
            grouped[key].append(r)

        insights = []

        for key, items in grouped.items():

            items = sorted(
                items,
                key=lambda x: x["arrival_date"],
                reverse=True
            )

            latest = items[0]

            if len(items) < 2:
                insights.append({
                    "commodity": latest["commodity"],
                    "percent": 0,
                    "trend": "stable"
                })
                continue

            today = float(items[0]["modal_price"])
            prev = float(items[1]["modal_price"])

            change = today - prev
            percent = (change / prev * 100) if prev else 0

            insights.append({
                "commodity": latest["commodity"],
                "percent": round(percent, 2),
                "trend": "up" if change > 0 else "down" if change < 0 else "stable"
            })

        sorted_data = sorted(
            insights,
            key=lambda x: x["percent"],
            reverse=True
        )

        total_commodities = queryset.values("commodity").distinct().count()
        total_markets = queryset.values("market").distinct().count()
        avg_price = queryset.aggregate(avg_price=Avg("modal_price"))["avg_price"]

        return Response({
            "status": True,
            "summary": {
                "top_gainer": sorted_data[0] if sorted_data else None,
                "top_loser": sorted_data[-1] if sorted_data else None
            },
            "trending": sorted_data[:5],
            "stats": {
                "total_commodities": total_commodities,
                "total_markets": total_markets,
                "avg_price": round(avg_price or 0, 2)
            }
        })


class MarketPricesAPIView(APIView):

    def get(self, request):
        return self.handle(request)

    def post(self, request):
        return self.handle(request)

    def handle(self, request):

        def get_param(key, default=None):
            return request.GET.get(key) or request.data.get(key, default)

        state = get_param("state", "Maharashtra")
        district = get_param("district")

        if state:
            state = state.strip()

        if district:
            district = district.strip()

        queryset = MandiPrice.objects.filter(
            state__iexact=state,
            is_active=True
        )

        if district:
            queryset = queryset.filter(district__iexact=district)

        serializer = MandiPriceListSerializer(queryset, many=True)
        records = serializer.data

        if not records:
            return Response({
                "status": True,
                "message": "No data found",
                "data": []
            })

        grouped = defaultdict(list)

        for item in records:
            key = f"{item['commodity']}_{item['market']}"
            grouped[key].append(item)

        result = []

        for key, items in grouped.items():
            items = sorted(items, key=lambda x: x["arrival_date"], reverse=True)
            latest = items[0]

            if len(items) < 2:
                change = percent = 0
                trend = "stable"
            else:
                today = float(items[0]["modal_price"])
                prev = float(items[1]["modal_price"])

                change = today - prev
                percent = (change / prev * 100) if prev else 0
                trend = "up" if change > 0 else "down" if change < 0 else "stable"

            result.append({
                "id": key,
                "name": latest["commodity"],
                "price": latest["modal_price"],
                "min_price": latest["min_price"],
                "max_price": latest["max_price"],
                "unit": "quintal",
                "change": round(change, 2),
                "percent_change": round(percent, 2),
                "trend": trend,
                "marketLocation": latest["market"],
                "district": latest["district"],
                "state": latest["state"],
                "lastUpdated": latest["arrival_date"],
            })

        return Response({
            "status": True,
            "count": len(result),
            "data": result
        })


class MarketComparisonAPIView(APIView):

    def post(self, request):

        commodity = request.data.get("commodity")
        state = request.data.get("state", "Maharashtra")

        if not commodity:
            return Response({
                "status": False,
                "message": "commodity is required"
            })

        queryset = MandiPrice.objects.filter(
            state=state,
            commodity=commodity,
            is_active=True
        ).values("market", "modal_price")

        markets = list(queryset)

        if not markets:
            return Response({"status": True, "data": []})

        best = max(markets, key=lambda x: x["modal_price"])

        for m in markets:
            m["is_best"] = m["market"] == best["market"]

        return Response({
            "status": True,
            "commodity": commodity,
            "best_market": best["market"],
            "data": markets
        })


# class PriceHistoryAPIView(APIView):

#     def post(self, request):

#         commodity = request.data.get("commodity")
#         market = request.data.get("market")

#         queryset = MandiPrice.objects.filter(
#             commodity__iexact=commodity,
#             market__iexact=market
#         ).order_by("arrival_date")

#         serializer = PriceHistorySerializer(queryset, many=True)

#         return Response({
#             "status": True,
#             "data": serializer.data
#         })