import csv
import json
import time
from datetime import datetime
from pathlib import Path
from urllib.request import Request, urlopen

from confluent_kafka import Producer


def query(sql):
    request = Request("http://clickhouse:8123/",
                      data=sql.encode("utf-8"),
                      headers={"X-ClickHouse-User": "student",
                               "X-ClickHouse-Key": "student"})

    with urlopen(request) as response:
        return response.read().decode("utf-8")


def main():
    with open("/data/train.csv", encoding="utf-8-sig", newline="") as file:
        wait = sum(1 for a in csv.DictReader(file))

    if int(query("SELECT count() FROM hw2.transactions")) == 0:
        producer = Producer({
            "bootstrap.servers": "kafka:9092",
            "enable.idempotence": True,
            "linger.ms": 20,
            "compression.type": "gzip",
        })

        with open("/data/train.csv", encoding="utf-8-sig", newline="") as file:
            for id, row in enumerate(csv.DictReader(file), start=1):
                row["row_id"] = id
                row["transaction_time"] = datetime.fromisoformat(row["transaction_time"]).strftime("%Y-%m-%d %H:%M:%S")

                message = json.dumps(row, ensure_ascii=False).encode("utf-8")
                while True:
                    try:
                        producer.produce("transactions", value=message)
                        break
                    except BufferError:
                        producer.poll(0.1)

                producer.poll(0)

        producer.flush()

    while int(query("SELECT count() FROM hw2.transactions")) < wait:
        time.sleep(2)

    sql = Path("/sql/max_transaction.sql").read_text(encoding="utf-8").strip().rstrip(";")
    result = query(sql + " FORMAT CSVWithNames")
    Path("/result/max_transaction.csv").write_text(result, encoding="utf-8")


if __name__ == "__main__":
    main()