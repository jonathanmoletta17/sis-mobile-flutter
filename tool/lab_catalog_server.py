#!/usr/bin/env python3
"""Servidor LAB do catálogo governado (read-only) com CORS.

Serve o runtime.json v3 em /metadata/mobile/sis/catalog para o app web local.
Uso: python3 tool/lab_catalog_server.py [porta] [caminho_runtime.json]
"""
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8799
CATALOG = sys.argv[2] if len(sys.argv) > 2 else (
    "/home/jonathan/.brain/evidence/sis-mobile/"
    "governed-catalog-v3-glpi-faithful-20260610/"
    "sis-mobile-governed-catalog-v2.runtime.json"
)


class Handler(BaseHTTPRequestHandler):
    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")

    def do_OPTIONS(self):
        self.send_response(204)
        self._cors()
        self.end_headers()

    def do_GET(self):
        if self.path.rstrip("/") == "/metadata/mobile/sis/catalog":
            try:
                with open(CATALOG, "rb") as fh:
                    body = fh.read()
            except OSError as exc:
                self.send_response(500)
                self._cors()
                self.end_headers()
                self.wfile.write(str(exc).encode())
                return
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self._cors()
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self._cors()
            self.end_headers()

    def log_message(self, fmt, *args):
        sys.stderr.write("[catalog] " + (fmt % args) + "\n")


if __name__ == "__main__":
    print(f"[catalog] serving {CATALOG} on :{PORT}/metadata/mobile/sis/catalog")
    HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
