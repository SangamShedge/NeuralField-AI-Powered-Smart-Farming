from django.db import models

class MandiPrice(models.Model):
    state = models.CharField(max_length=100)
    district = models.CharField(max_length=100)
    market = models.CharField(max_length=150)
    commodity = models.CharField(max_length=150)
    variety = models.CharField(max_length=150)
    grade = models.CharField(max_length=100)

    arrival_date = models.DateField()

    min_price = models.FloatField()
    max_price = models.FloatField()
    modal_price = models.FloatField()

    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("market", "commodity", "arrival_date")

        indexes = [
            models.Index(fields=["state"]),
            models.Index(fields=["district"]),
            models.Index(fields=["commodity"]),
            models.Index(fields=["arrival_date"]),
            models.Index(fields=["is_active"]),
        ]

    def __str__(self):
        return f"{self.commodity} - {self.market}"