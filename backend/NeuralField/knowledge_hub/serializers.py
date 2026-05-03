from rest_framework import serializers


class CropRequestSerializer(serializers.Serializer):
    lang = serializers.CharField(required=False, default="en")
    search = serializers.CharField(required=False)

class CropSerializer(serializers.Serializer):
    id = serializers.CharField()
    name = serializers.CharField()
    scientificName = serializers.CharField()
    family = serializers.CharField()
    
    growingSeason = serializers.CharField()
    sowingMonths = serializers.ListField(child=serializers.CharField())
    harvestingMonths = serializers.ListField(child=serializers.CharField())
    growingDays = serializers.IntegerField()
    
    waterRequirement = serializers.CharField()
    soilType = serializers.CharField()
    
    minTemperature = serializers.IntegerField()
    maxTemperature = serializers.IntegerField()
    
    commonVarieties = serializers.ListField(child=serializers.CharField())
    benefits = serializers.ListField(child=serializers.CharField())
    
    yieldPerAcre = serializers.FloatField()
    
    companionCrops = serializers.ListField(child=serializers.CharField())
    avoidCrops = serializers.ListField(child=serializers.CharField())
    
    description = serializers.CharField()
    imageAsset = serializers.CharField()


class CultivationRequestSerializer(serializers.Serializer):
    lang = serializers.CharField(required=False, default="en")
    search = serializers.CharField(required=False)
    category = serializers.CharField(required=False)
    difficulty = serializers.IntegerField(required=False)
    season = serializers.CharField(required=False)  

class CultivationSerializer(serializers.Serializer):
    id = serializers.CharField()
    title = serializers.CharField()
    description = serializers.CharField()
    category = serializers.CharField()

    steps = serializers.ListField(child=serializers.CharField())
    estimatedTime = serializers.IntegerField()

    benefits = serializers.ListField(child=serializers.CharField())
    requiredMaterials = serializers.ListField(child=serializers.CharField())

    season = serializers.CharField()
    difficulty = serializers.IntegerField()


class DiseaseRequestSerializer(serializers.Serializer):
    lang = serializers.CharField(required=False, default="en")
    search = serializers.CharField(required=False)
    crop = serializers.CharField(required=False)
    type = serializers.CharField(required=False)
    severity = serializers.CharField(required=False)

class DiseaseSerializer(serializers.Serializer):
    id = serializers.CharField()
    name = serializers.CharField()
    scientificName = serializers.CharField()

    type = serializers.CharField()
    severity = serializers.CharField()

    affectedCrops = serializers.ListField(child=serializers.CharField())

    symptoms = serializers.ListField(child=serializers.CharField())

    organicControls = serializers.ListField(child=serializers.CharField())
    chemicalControls = serializers.ListField(child=serializers.CharField())

    preventiveMeasures = serializers.ListField(child=serializers.CharField())

    description = serializers.CharField()

    favorableConditions = serializers.CharField()
    transmissionMethod = serializers.CharField()
    incubationPeriod = serializers.CharField()

    economicImpact = serializers.CharField()
    globalDistribution = serializers.CharField()

    commonName = serializers.CharField()
    hostRange = serializers.CharField()
    fungicideResistance = serializers.CharField()

    imageAsset = serializers.CharField()


class PestRequestSerializer(serializers.Serializer):
    lang = serializers.CharField(required=False, default="en")
    search = serializers.CharField(required=False)
    crop = serializers.CharField(required=False)
    type = serializers.CharField(required=False)
    severity = serializers.CharField(required=False)

class PestSerializer(serializers.Serializer):
    id = serializers.CharField()
    name = serializers.CharField()
    scientificName = serializers.CharField()

    type = serializers.CharField()
    severity = serializers.CharField()

    affectedCrops = serializers.ListField(child=serializers.CharField())

    symptoms = serializers.ListField(child=serializers.CharField())

    organicControls = serializers.ListField(child=serializers.CharField())
    chemicalControls = serializers.ListField(child=serializers.CharField())

    preventiveMeasures = serializers.ListField(child=serializers.CharField())

    description = serializers.CharField()

    favorableConditions = serializers.CharField()
    transmissionMethod = serializers.CharField()

    lifeCycle = serializers.CharField()

    economicImpact = serializers.CharField()
    globalDistribution = serializers.CharField()

    commonName = serializers.CharField()
    hostRange = serializers.CharField()

    pesticideResistance = serializers.CharField()

    imageAsset = serializers.CharField()