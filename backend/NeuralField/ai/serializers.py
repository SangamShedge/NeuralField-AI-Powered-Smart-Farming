from rest_framework import serializers

class FertilizerInputSerializer(serializers.Serializer):
    area = serializers.FloatField()  # NOW IN ACRES (BASE UNIT)
    
    target_yield = serializers.FloatField()  # tons per acre

    soil_n = serializers.FloatField()  # kg per acre
    soil_p = serializers.FloatField()
    soil_k = serializers.FloatField()

    crop = serializers.CharField()

    nitrogen_source = serializers.CharField()
    phosphorus_source = serializers.CharField()
    potassium_source = serializers.CharField()