from rest_framework import serializers
from .models import MandiPrice



class MandiPriceListSerializer(serializers.ModelSerializer):
    class Meta:
        model = MandiPrice
        fields = [
            "state",
            "district",
            "market",
            "commodity",
            "modal_price",
            "min_price",
            "max_price",
            "arrival_date",
        ]


# class PriceHistorySerializer(serializers.ModelSerializer):
#     date = serializers.DateField(source="arrival_date")
#     price = serializers.FloatField(source="modal_price")

#     class Meta:
#         model = MandiPrice
#         fields = ["date", "price"]