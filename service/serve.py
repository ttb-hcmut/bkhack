from flask import Flask
from flask_cors import CORS
service = Flask("bkhack")
CORS(service)
@service.route("/api/test-item")
def test():
  posts = [
    {
      "author": "dan_o55",
      "message": "Tui cũng không biết nữa"
    },
    {
      "author": "sdf",
      "message": "sdf"
    },
  ]
  return {
    "title": "Về IMGUI và những paradigm con",
    "author": "lyan3002",
    "rank": 12,
    "posts": posts
  }
