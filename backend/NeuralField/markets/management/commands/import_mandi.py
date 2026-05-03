import csv
from datetime import datetime
from django.core.management.base import BaseCommand
from markets.models import MandiPrice


import csv
from datetime import datetime
from django.core.management.base import BaseCommand
from markets.models import MandiPrice


class Command(BaseCommand):
    help = "Import mandi data from CSV"

    def handle(self, *args, **kwargs):

        file_path = "mandi_data.csv"  # your CSV file

        # deactivate old data
        MandiPrice.objects.update(is_active=False)

        unique_data = set()
        objs = []

        with open(file_path, newline='', encoding='utf-8') as file:
            reader = csv.DictReader(file)

            for row in reader:

                # ✅ Fix date format
                date_str = row['Arrival_Date']
                try:
                    arrival_date = datetime.strptime(date_str, "%d/%m/%Y")
                except ValueError:
                    arrival_date = datetime.strptime(date_str, "%d-%m-%Y")

                # ✅ Create unique key
                key = (
                    row['Market'].strip(),
                    row['Commodity'].strip(),
                    arrival_date
                )

                # ✅ Skip duplicates
                if key in unique_data:
                    continue

                unique_data.add(key)

                objs.append(MandiPrice(
                    state=row['State'],
                    district=row['District'],
                    market=row['Market'],
                    commodity=row['Commodity'],
                    variety=row['Variety'],
                    grade=row['Grade'],
                    arrival_date=arrival_date,

                    min_price=float(row['Min_x0020_Price']),
                    max_price=float(row['Max_x0020_Price']),
                    modal_price=float(row['Modal_x0020_Price']),

                    is_active=True
                ))

        # ✅ Insert clean data
        MandiPrice.objects.bulk_create(objs, batch_size=1000)

        print(f"✅ Total CSV rows: {len(unique_data)}")
        print(f"✅ Inserted rows: {len(objs)}")