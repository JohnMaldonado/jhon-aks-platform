const https = require('http');

const BASE_URL = process.env.API_URL || 'http://localhost:3000';

function httpGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(data) }));
    }).on('error', reject);
  });
}

function httpPost(url, payload) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(payload);
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
      }
    };
    const req = https.request(url, options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(body) }));
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

describe('API Health Checks', () => {
  test('GET /healthz/live returns 200', async () => {
    const res = await httpGet(`${BASE_URL}/healthz/live`);
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('alive');
  });

  test('GET /healthz/ready returns 200 and db connected', async () => {
    const res = await httpGet(`${BASE_URL}/healthz/ready`);
    expect(res.status).toBe(200);
    expect(res.body.db).toBe('connected');
  });
});

describe('Items API', () => {
  test('GET /api/items returns list with count', async () => {
    const res = await httpGet(`${BASE_URL}/api/items`);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.items)).toBe(true);
    expect(typeof res.body.count).toBe('number');
  });

  test('POST /api/items creates a new item', async () => {
    const res = await httpPost(`${BASE_URL}/api/items`, {
      name: 'Test Item CI',
      description: 'Created by integration test'
    });
    expect(res.status).toBe(201);
    expect(res.body.name).toBe('Test Item CI');
    expect(res.body.id).toBeDefined();
  });

  test('GET /api/items/:id returns item', async () => {
    const list = await httpGet(`${BASE_URL}/api/items`);
    const firstId = list.body.items[0].id;
    const res = await httpGet(`${BASE_URL}/api/items/${firstId}`);
    expect(res.status).toBe(200);
    expect(res.body.id).toBe(firstId);
  });

  test('GET /api/items/:id returns 404 for unknown id', async () => {
    const res = await httpGet(`${BASE_URL}/api/items/99999`);
    expect(res.status).toBe(404);
  });

  test('POST /api/items without name returns 400', async () => {
    const res = await httpPost(`${BASE_URL}/api/items`, {
      description: 'Missing name'
    });
    expect(res.status).toBe(400);
  });
});
