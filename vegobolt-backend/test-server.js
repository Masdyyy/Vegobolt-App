const express = require('express');
const app = express();
const PORT = 3001;

app.get('/test', (req, res) => {
    res.json({ message: 'Test server is working!' });
});

const server = app.listen(PORT, 'localhost', () => {
    console.log(`Test server running on http://localhost:${PORT}`);
});

server.on('error', (error) => {
    console.error('Server error:', error);
});