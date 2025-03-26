const express = require('express');
const multer = require('multer');
const path = require('path');
const { exec } = require('child_process');
require('dotenv').config(); // Load environment variables

console.log("📌 Checking if .env is loaded:", process.env.AUDIVERIS_PATH);

// Make sure AUDIVERIS_PATH points to the correct app directory
const audiverisPath = process.env.AUDIVERIS_PATH || "/Applications/Audiveris.app/Contents/app";

const app = express();
const PORT = 3000;

// Save uploaded scores to uploads folder
const upload = multer({ dest: 'uploads/' });

app.use(express.json());
app.get('/', (req, res) => {
  res.send('Welcome to TransposeX Backend!');
});

app.post('/upload', upload.single('musicImage'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const inputPath = path.resolve(req.file.path);
  const outputDir = path.resolve('results');

  console.log(`📌 File received: ${inputPath}`);

  const command = `/usr/libexec/java_home -v 23/bin/java -cp "${audiverisPath}/*" org.audiveris.omr.Main -batch "${inputPath}" -output "${outputDir}"`;

  console.log("📌 Running Audiveris Command:", command);

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error('❌ Audiveris execution failed:', error.message);
      return res.status(500).json({ error: 'Audiveris processing error' });
    }

    res.status(200).json({
      message: '✅ Image uploaded and processed!',
      outputFolder: outputDir
    });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server is running on http://0.0.0.0:${PORT}`);
});