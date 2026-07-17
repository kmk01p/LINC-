#!/usr/bin/env python3
"""Capture portfolio screenshots from running LINC gov-portal."""

from pathlib import Path
from playwright.sync_api import sync_playwright

BASE = "http://localhost:8080"
OUT = Path(__file__).resolve().parent / "screenshots"
OUT.mkdir(parents=True, exist_ok=True)

SHOTS = [
    ("01-login.png", f"{BASE}/login.do", False, 1200),
    ("02-dashboard.png", f"{BASE}/dashboard.do", True, 2500),
    ("03-project-list.png", f"{BASE}/projects/list.do", True, 1800),
    (
        "04-project-detail.png",
        f"{BASE}/projects/d1000000-0000-4000-8000-000000000001/detail.do",
        True,
        1800,
    ),
    (
        "05-project-analytics.png",
        f"{BASE}/projects/d1000000-0000-4000-8000-000000000001/analytics.do",
        True,
        3500,
    ),
    ("06-deleted-projects.png", f"{BASE}/projects/deleted/list.do", True, 1800),
]


def login(page):
    page.goto(f"{BASE}/login.do", wait_until="networkidle")
    page.fill("#username", "admin")
    page.fill("#password", "admin")
    submit = page.locator('button[type="submit"], input[type="submit"]').first
    submit.click()
    page.wait_for_load_state("networkidle")


def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1440, "height": 900})
        page = context.new_page()
        logged_in = False

        for filename, url, needs_login, wait_ms in SHOTS:
            if needs_login and not logged_in:
                login(page)
                logged_in = True
            page.goto(url, wait_until="networkidle")
            page.wait_for_timeout(wait_ms)
            target = OUT / filename
            page.screenshot(path=str(target), full_page=True)
            print(f"saved {target.name}")

        browser.close()


if __name__ == "__main__":
    main()
