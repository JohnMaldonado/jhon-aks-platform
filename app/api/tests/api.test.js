const http = require('http');

const BASE_URL = process.env.API_URL || 'http://localhost:3000';

function httpGet(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: data ? JSON.parse(data) : {} });
        } catch(e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    }).on('error', reject);
  });
}

function httpPost(url, payload) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(payload);
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || 80,
      path: urlObj.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
      }
    };
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: body ? JSON.parse(body) : {} });
        } catch(e) {
          resolve({ status: res.statusCode, body });
        }
      });
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

describe('API Health Checks', () => {
  test('GET /health/live returns 200', async () => {
    const res = await httpGet(`${BASE_URL}/health/live`);
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('alive');
  }, 10000);

  test('GET /health/ready returns 200 and db connected', async () => {
    const res = await httpGet(`${BASE_URL}/health/ready`);
    expect(res.status).toBe(200);
    expect(res.body.db).toBe('connected');
  }, 10000);
});

describe('Items API', () => {
  test('GET /api/items returns list with count', async () => {
    const res = await httpGet(`${BASE_URL}/api/items`);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.items)).toBe(true);
    expect(typeof res.body.count).toBe('number');
  }, 10000);

  test('POST /api/items creates a new item', async () => {
    const res = await httpPost(`${BASE_URL}/api/items`, {
      name: 'Test Item CI',
      description: 'Created by integration test'
    });
    expect(res.status).toBe(201);
    expect(res.body.name).toBe('Test Item CI');
    expect(res.body.id).toBeDefined();
  }, 10000);

  test('GET /api/items/:id returns item', async () => {
    const list = await httpGet(`${BASE_URL}/api/items`);
    const firstId = list.body.items[0].id;
    const res = await httpGet(`${BASE_URL}/api/items/${firstId}`);
    expect(res.status).toBe(200);
    expect(res.body.id).toBe(firstId);
  }, 10000);

  test('GET /api/items/:id returns 404 for unknown id', async () => {
    const res = await httpGet(`${BASE_URL}/api/items/99999`);
    expect(res.status).toBe(404);
  }, 10000);

  test('POST /api/items without name returns 400', async () => {
    const res = await httpPost(`${BASE_URL}/api/items`, {
      description: 'Missing name'
    });
    expect(res.status).toBe(400);
  }, 10000);
});
