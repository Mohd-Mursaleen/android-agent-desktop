"""Open a URL in the agent's browser through CDP. Standard library only.

Usage: python examples/open_url.py https://www.youtube.com
"""
import json
import sys
import urllib.parse
import urllib.request

CDP = "http://127.0.0.1:9222"


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit("usage: python examples/open_url.py <url>")
    url = sys.argv[1]

    version = json.load(urllib.request.urlopen(f"{CDP}/json/version", timeout=5))
    print("browser:", version["Browser"])

    req = urllib.request.Request(
        f"{CDP}/json/new?{urllib.parse.quote(url, safe=':/?&=')}", method="PUT"
    )
    tab = json.load(urllib.request.urlopen(req, timeout=10))
    print("opened tab:", tab["id"], tab["url"])
    print("websocket for full control:", tab["webSocketDebuggerUrl"])


if __name__ == "__main__":
    main()
