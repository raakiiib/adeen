import urllib.request
import json

url = "https://api.aladhan.com/v1/methods"
try:
    with urllib.request.urlopen(url) as response:
        html = response.read().decode('utf-8')
        data = json.loads(html)
        methods = data["data"]
        print("ID | KEY | NAME")
        print("---|---|---")
        for key, m in methods.items():
            if isinstance(m, dict) and "id" in m:
                print(f"{m.get('id')} | {key} | {m.get('name', 'N/A')}")
            else:
                print(f"Non-dict item: {key} -> {m}")
except Exception as e:
    print(f"Error: {e}")
