terraform {
  required_providers {
    timeplus = {
      source  = "timeplus-io/timeplus"
      version = ">= 0.1.4"
    }
  }
}

variable "timeplus_apikey" {
  type = string
  sensitive = true
}
variable "timeplus_endpoint" {
  type = string
}
variable "timeplus_workspace" {
  type = string
}
variable "livepeer_apikey" {
  type = string
  sensitive = true
}

provider "timeplus" {
  endpoint  = var.timeplus_endpoint
  workspace = var.timeplus_workspace
  api_key   = var.timeplus_apikey
}

resource "timeplus_stream" "livepeer_viewership_metrics_kv" {
  name = "livepeer_viewership_metrics_kv"
  description = ""
  mode = "versioned_kv"
  
  column {
    name = "playbackId"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "viewerId"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "creatorId"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "geohash"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "timestamp"
    type = "int64"
    primary_key = true
  }
  
  column {
    name = "device"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "os"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "browser"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "continent"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "country"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "subdivision"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "timezone"
    type = "string"
    primary_key = true
  }
  
  column {
    name = "viewCount"
    type = "int32"
  }
  
  column {
    name = "playtimeMins"
    type = "float32"
  }
  
  column {
    name = "ttffMs"
    type = "float32"
  }
  
  column {
    name = "rebufferRatio"
    type = "float32"
  }
  
  column {
    name = "errorRate"
    type = "float32"
  }
  
  column {
    name = "exitsBeforeStart"
    type = "int32"
  }
  
  column {
    name = "_tp_time"
    type = "datetime64(3, 'UTC')"
    default = "to_time(to_string(timestamp))"
  }
  
}
resource "timeplus_source" "livepeer" {
  name        = "livepeer"
  description = ""
  stream      = timeplus_stream.livepeer_viewership_metrics_kv.name
  type        = "livepeer"
  properties  = <<EOJ
  {
    "data_type": "json",
    "interval": "300s",
    "api_key": "${ var.livepeer_apikey }"
  }
  EOJ
}

resource "timeplus_remote_function" "geohash_locate" {
  name        = "geohash_locate"
  description = ""
  url         = "http://k8s-usergang-geolocat-1927630929-371878e276474ca1.elb.us-west-2.amazonaws.com/hash"
  return_type = "array(float)"
  
  arg {
    name = "input"
    type = "string"
  }
  
}

resource "timeplus_dashboard" "VideoEngagementMointor" {
  name        = "Video Engagement Mointor"
  description = <<EOF
  this is a sample Timeplus dashbaord as - https://docs.livepeer.org/tutorials/developing/visualize-engagement-metrics-grafana 
  EOF
  
  panels      = <<JSON
  [
  {
    "description": "",
    "id": "2fc398ca-eeae-4272-a442-3eff3fd3916d",
    "position": {
      "h": 4,
      "nextX": 6,
      "nextY": 4,
      "w": 6,
      "x": 0,
      "y": 0
    },
    "title": "Hourly View and Watch Time",
    "viz_config": {
      "chartType": "line",
      "config": {
        "color": "",
        "colors": [
          "#1480E4",
          "#8934D9",
          "#E26A1B",
          "#00A3C4",
          "#257966",
          "#D09624",
          "#D53F8C",
          "#768FAC",
          "#69534E",
          "#853838"
        ],
        "dataLabel": false,
        "fractionDigits": 2,
        "gridlines": false,
        "legend": false,
        "lineStyle": "straight",
        "points": false,
        "renderDuration": 60,
        "renderInterval": 500,
        "unit": {
          "position": "left",
          "value": ""
        },
        "xAxis": "window_start",
        "xRange": "Infinity",
        "xTitle": "",
        "yAxis": "viewCount",
        "yRange": {
          "max": null,
          "min": null
        },
        "yTitle": ""
      }
    },
    "viz_content": "SELECT \n  window_start, sum(viewCount) as viewCount, sum(playtimeMins) as playtimeMins\nFROM \n  tumble(table(livepeer_viewership_metrics_kv), 1h)\nWHERE \n  _tp_time > earliest_ts()\nGROUP BY \n  window_start\norder by window_start\nwith fill step 1h",
    "viz_type": "chart"
  },
  {
    "description": "",
    "id": "57c30b57-0c52-446a-9785-10e30f8c43de",
    "position": {
      "h": 4,
      "nextX": 6,
      "nextY": 8,
      "w": 6,
      "x": 0,
      "y": 4
    },
    "title": "engagement by OS",
    "viz_config": {
      "chartType": "bar",
      "config": {
        "color": "",
        "colors": [
          "#1480E4",
          "#8934D9",
          "#E26A1B",
          "#00A3C4",
          "#257966",
          "#D09624",
          "#D53F8C",
          "#768FAC",
          "#69534E",
          "#853838"
        ],
        "dataLabel": false,
        "fractionDigits": 2,
        "gridlines": false,
        "legend": false,
        "renderDuration": 60,
        "renderInterval": 500,
        "unit": {
          "position": "left",
          "value": ""
        },
        "updateKey": "version",
        "updateMode": "time",
        "xAxis": "os",
        "xTitle": "",
        "yAxis": "viewCount",
        "yTitle": ""
      }
    },
    "viz_content": "SELECT \n  os, sum(viewCount) as viewCount, sum(playtimeMins) as playtimeMins , emit_version() as version\nFROM \n  livepeer_viewership_metrics_kv\nGROUP BY \n  os\norder by viewCount desc",
    "viz_type": "chart"
  },
  {
    "description": "",
    "id": "121d4e1f-c43f-412e-863e-3c88cc00d0bb",
    "position": {
      "h": 4,
      "nextX": 6,
      "nextY": 12,
      "w": 6,
      "x": 0,
      "y": 8
    },
    "title": "View count by Video (Top 5)",
    "viz_config": {
      "chartType": "bar",
      "config": {
        "color": "",
        "colors": [
          "#1480E4",
          "#8934D9",
          "#E26A1B",
          "#00A3C4",
          "#257966",
          "#D09624",
          "#D53F8C",
          "#768FAC",
          "#69534E",
          "#853838"
        ],
        "dataLabel": false,
        "fractionDigits": 2,
        "gridlines": false,
        "legend": false,
        "renderDuration": 60,
        "renderInterval": 500,
        "unit": {
          "position": "left",
          "value": ""
        },
        "updateKey": "version",
        "updateMode": "time",
        "xAxis": "playbackId",
        "xTitle": "",
        "yAxis": "viewCount",
        "yTitle": ""
      }
    },
    "viz_content": "SELECT \n  playbackId, sum(viewCount) as viewCount, sum(playtimeMins) as playtimeMins, emit_version() as version\nFROM \n  livepeer_viewership_metrics_kv\nGROUP BY \n  playbackId\nORDER by viewCount desc\nlimit 5 by version",
    "viz_type": "chart"
  },
  {
    "description": "",
    "id": "04961e24-896e-4c77-8926-9fbbc5d32088",
    "position": {
      "h": 4,
      "nextX": 6,
      "nextY": 16,
      "w": 6,
      "x": 0,
      "y": 12
    },
    "title": "View by Device (Top 5)",
    "viz_config": {
      "chartType": "bar",
      "config": {
        "color": "",
        "colors": [
          "#1480E4",
          "#8934D9",
          "#E26A1B",
          "#00A3C4",
          "#257966",
          "#D09624",
          "#D53F8C",
          "#768FAC",
          "#69534E",
          "#853838"
        ],
        "dataLabel": false,
        "fractionDigits": 2,
        "gridlines": false,
        "legend": false,
        "renderDuration": 60,
        "renderInterval": 500,
        "unit": {
          "position": "left",
          "value": ""
        },
        "updateKey": "version",
        "updateMode": "time",
        "xAxis": "device",
        "xTitle": "",
        "yAxis": "viewCount",
        "yTitle": ""
      }
    },
    "viz_content": "SELECT \n  device, sum(viewCount) as viewCount, sum(playtimeMins) as playtimeMins, emit_version() as version\nFROM \n  livepeer_viewership_metrics_kv\nGROUP BY \n  device\nORDER BY viewCount desc\nlimit 5 by version",
    "viz_type": "chart"
  },
  {
    "description": "",
    "id": "fe000a78-64b1-4281-bd3a-7754b875135c",
    "position": {
      "h": 4,
      "nextX": 12,
      "nextY": 12,
      "w": 6,
      "x": 6,
      "y": 8
    },
    "title": "Rebuffer",
    "viz_config": {
      "chartType": "line",
      "config": {
        "color": "",
        "colors": [
          "#1480E4",
          "#8934D9",
          "#E26A1B",
          "#00A3C4",
          "#257966",
          "#D09624",
          "#D53F8C",
          "#768FAC",
          "#69534E",
          "#853838"
        ],
        "dataLabel": false,
        "fractionDigits": 2,
        "gridlines": false,
        "legend": false,
        "lineStyle": "straight",
        "points": false,
        "renderDuration": 60,
        "renderInterval": 500,
        "unit": {
          "position": "left",
          "value": ""
        },
        "xAxis": "window_start",
        "xRange": "Infinity",
        "xTitle": "",
        "yAxis": "max(rebufferRatio)",
        "yRange": {
          "max": null,
          "min": null
        },
        "yTitle": ""
      }
    },
    "viz_content": "SELECT \n  window_start, max(rebufferRatio)\nFROM \n  tumble(table(livepeer_viewership_metrics_kv), 1h)\nGROUP BY \n  window_start\nORDER BY \n  window_start ASC WITH FILL STEP 1h",
    "viz_type": "chart"
  },
  {
    "description": "",
    "id": "c2bda405-1ad4-424e-8eba-c98d00c5fac3",
    "position": {
      "h": 4,
      "nextX": 12,
      "nextY": 8,
      "w": 6,
      "x": 6,
      "y": 4
    },
    "title": "Time to First Frame",
    "viz_config": {
      "chartType": "line",
      "config": {
        "color": "",
        "colors": [
          "#1480E4",
          "#8934D9",
          "#E26A1B",
          "#00A3C4",
          "#257966",
          "#D09624",
          "#D53F8C",
          "#768FAC",
          "#69534E",
          "#853838"
        ],
        "dataLabel": false,
        "fractionDigits": 2,
        "gridlines": false,
        "legend": false,
        "lineStyle": "straight",
        "points": false,
        "renderDuration": 60,
        "renderInterval": 500,
        "unit": {
          "position": "left",
          "value": ""
        },
        "xAxis": "window_start",
        "xRange": "Infinity",
        "xTitle": "",
        "yAxis": "ttffMs",
        "yRange": {
          "max": null,
          "min": null
        },
        "yTitle": ""
      }
    },
    "viz_content": "SELECT \n  window_start, avg(ttffMs) AS ttffMs\nFROM \n  tumble(table(livepeer_viewership_metrics_kv), 1h)\nGROUP BY \n  window_start\nORDER BY \n  window_start ASC WITH FILL STEP 1h",
    "viz_type": "chart"
  },
  {
    "description": "",
    "id": "24c7d396-d44c-4431-9b42-03ef71be27bf",
    "position": {
      "h": 4,
      "nextX": 12,
      "nextY": 4,
      "w": 6,
      "x": 6,
      "y": 0
    },
    "title": "View By Geo Location",
    "viz_config": {
      "chartType": "geo",
      "config": {
        "center": [
          43.90256551996179,
          37.57823315952167
        ],
        "color": "",
        "colors": [
          "#8934D9",
          "#BF5815",
          "#0B66BC",
          "#6626A3",
          "#077D95",
          "#359DFF",
          "#ED64A6",
          "#4E5ADF",
          "#751025",
          "#97732D"
        ],
        "latitude": "lat",
        "longitude": "long",
        "opacity": 0.8,
        "renderDuration": 60,
        "renderInterval": 500,
        "size": {
          "key": "viewCount",
          "range": [
            40,
            60
          ],
          "value": 10
        },
        "updateKey": "version",
        "updateMode": "time",
        "zoom": 2
      }
    },
    "viz_content": "WITH geo AS\n  (\n    SELECT \n      country, geohash, sum(viewCount) AS viewCount, emit_version() as version\n    FROM \n      livepeer_viewership_metrics_kv\n    GROUP BY \n      country, geohash\n    ORDER BY \n      country ASC, geohash ASC\n  )\nSELECT \n  geohash_locate(geohash) AS loc, loc[1] as lat, loc[2] as long, country, viewCount, version\nFROM \n  geo",
    "viz_type": "chart"
  }
]
  JSON
}