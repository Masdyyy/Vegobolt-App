const http = require('http');

const data = JSON.stringify({
  email: 'testuser@vegobolt.com',
  password: 'Test123!',
  displayName: 'Test User'
});

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/register',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  },
  timeout: 10000
};

console.log('🧪 Testing registration endpoint...\n');

const req = http.request(options, (res) => {
  let responseData = '';

  res.on('data', (chunk) => {
    responseData += chunk;
  });

  res.on('end', () => {
    console.log(`Status Code: ${res.statusCode}`);
    console.log('\nResponse:');
    try {
      const json = JSON.parse(responseData);
      console.log(JSON.stringify(json, null, 2));
    } catch (e) {
      console.log(responseData);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Error:', error.message);
});

req.on('timeout', () => {
  console.error('❌ Request timeout');
  req.destroy();
});

req.write(data);
req.end();
