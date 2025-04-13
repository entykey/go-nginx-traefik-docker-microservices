const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.send('Hello from NodeJS service!');
});

app.get('/api/node', (req, res) => {
  res.json({ message: 'API response from NodeJS' });
});

app.listen(PORT, () => {
  console.log(`NodeJS service running on port ${PORT}`);
});