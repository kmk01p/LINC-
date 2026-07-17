const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE = 'http://localhost:8080';
const OUT = path.join(__dirname, 'screenshots');

const shots = [
  { file: '01-login.png', url: `${BASE}/auth/login.do`, wait: 1000 },
  { file: '02-dashboard.png', url: `${BASE}/home/dashboard.do`, login: true, wait: 2000 },
  { file: '03-project-list.png', url: `${BASE}/projects/list.do`, login: true, wait: 1500 },
  { file: '04-project-detail.png', url: `${BASE}/projects/d1000000-0000-4000-8000-000000000001/detail.do`, login: true, wait: 1500 },
  { file: '05-project-analytics.png', url: `${BASE}/projects/d1000000-0000-4000-8000-000000000001/analytics.do`, login: true, wait: 2500 },
  { file: '06-deleted-projects.png', url: `${BASE}/projects/deleted/list.do`, login: true, wait: 1500 },
];

async function login(page) {
  await page.goto(`${BASE}/auth/login.do`, { waitUntil: 'networkidle' });
  await page.fill('#username', 'admin');
  await page.fill('#password', 'admin');
  await page.click('button[type="submit"], input[type="submit"]');
  await page.waitForLoadState('networkidle');
}

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  let loggedIn = false;
  for (const shot of shots) {
    if (shot.login && !loggedIn) {
      await login(page);
      loggedIn = true;
    }
    await page.goto(shot.url, { waitUntil: 'networkidle' });
    await page.waitForTimeout(shot.wait || 1000);
    await page.screenshot({ path: path.join(OUT, shot.file), fullPage: true });
    console.log('saved', shot.file);
  }

  await browser.close();
})();
