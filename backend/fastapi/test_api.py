import urllib.request
import json
import sys

BASE_URL = "http://localhost:8000"

def test_endpoint(path, method="GET", data=None):
    print(f"Testing {method} {path}...")
    url = f"{BASE_URL}{path}"
    headers = {"Content-Type": "application/json"}
    
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    
    try:
        with urllib.request.urlopen(req) as response:
            print(f"Status: {response.status}")
            print(f"Response: {response.read().decode()}")
    except urllib.error.HTTPError as e:
        print(f"Error Status: {e.code}")
        print(f"Error Body: {e.read().decode()}")
    except Exception as e:
        print(f"Connection Error: {e}")

if __name__ == "__main__":
    # 1. Health
    test_endpoint("/health")
    
    # 2. List Articles
    test_endpoint("/api/v1/articles/")
    
    # 3. Create Article
    mock_article = {
        'articleId': 'test-journalist-001',
        'author': 'AI Agent',
        'title': 'Test Article',
        'description': 'Testing the POST endpoint',
        'url': 'http://test.com',
        'urlToImage': 'http://test.com/image',
        'publishedAt': '2026-04-21T05:00:00Z',
        'content': 'Content of the test article',
        'source': 'Test Source',
        'category': 'test'
    }
    test_endpoint("/api/v1/articles/", method="POST", data=mock_article)
    
    # 4. Ollama Proxy
    test_endpoint("/api/v1/ollama/api/tags")
