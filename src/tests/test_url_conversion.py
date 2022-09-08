# Import third-party library modules
from fastapi import FastAPI
from fastapi.testclient import TestClient

# Import local modules
from src.main import app

client = TestClient(app)

def create_url_conversion():
    
    expected_ret_val = [
        {
        "input_url": "https://www.askpython.com/python/examples/url-shortener",
        "output_url": "https://tinyurl.com/y82prysb"
        }
    ]

    response = client.post("/UrlConversion", headers={"input_url": "https://www.askpython.com/python/examples/url-shortener"})
    assert response.status_code == 200
    assert response.json() == expected_ret_val
    
    
    
    