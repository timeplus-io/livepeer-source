import os
import requests
import json
from timeplus import Stream, Environment

timeplus_address = os.getenv('TIMEPLUS_ADDRESS')
timeplus_api_key = os.getenv('TIMEPLUS_API_KEY')
livepeer_api_key = os.getenv('LIVEPEER_API_KEY')

stream_name = 'livepeer_viewership_metrics_kv'
source_name = 'livepeer_viewership'

def create_stream():
    # Configure API key and address
    env = Environment().address(timeplus_address).apikey(timeplus_api_key)
    try:
        # create a new stream
        stream = (
            Stream(env=env)
            .name(stream_name)
            .column("playbackId", "string")
            .column("viewerId", "string")
            .column("creatorId", "string")
            .column("geohash", "string")
            .column("timestamp", "int64")
            .column("device", "string")
            .column("os", "string")
            .column("browser", "string")
            .column("continent", "string")
            .column("country", "string")
            .column("subdivision", "string")
            .column("timezone", "string")
            .column("viewCount", "int")
            .column("playtimeMins", "float")
            .column("ttffMs", "float")
            .column("rebufferRatio", "float")
            .column("errorRate", "float")
            .column("exitsBeforeStart", "integer")
            .mode("versioned_kv")
            .primary_key("(playbackId,viewerId,creatorId,geohash,timestamp,device,os,browser,continent,country,subdivision,timezone)")
            .create()
        )
    except Exception as e:
        print(e)


def create_source():
    reqUrl = f"{timeplus_address}/api/v1beta2/sources"

    headersList = {
        "X-API-KEY": timeplus_api_key,
        "Content-Type": "application/json"
    }

    payload = json.dumps({
        "name": source_name,
        "properties": {
            "interval": "300s",
            "data_type": "json",
            "api_key": livepeer_api_key
        },
        "type": "livepeer",
        "stream": stream_name
    })

    response = requests.request("POST", reqUrl, data=payload,  headers=headersList)
    print(response.status_code)
    print(response.text)


create_stream()
create_source()