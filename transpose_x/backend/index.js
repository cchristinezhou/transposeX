const express = require('express');
const multer = require('multer');
const path = require('path');
const { exec } = require('child_process');
require('dotenv').config(); // Load environment variables
const mysql = require('mysql2')
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAMßE
})

connection.connect((err) => {
  if (err) throw err;
  console.log('✅ Connected to MySQL');

  const createTableQuery = `
  CREATE TABLE IF NOT EXISTS sheets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sheetName VARCHAR(255) NOT NULL,
    imageUrl VARCHAR(500) NOT NULL,
    musicXMLUrl VARCHAR(500),
    createdTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  `;

  connection.query(createTableQuery, (err, result) => {
    if (err) throw err;
    console.log('Table "sheets" is ready');
  });
});

console.log("📌 Checking if .env is loaded:", process.env.AUDIVERIS_PATH);

// Make sure AUDIVERIS_PATH points to the correct app directory
const audiverisPath = process.env.AUDIVERIS_PATH || "/Applications/Audiveris.app/Contents/app";

const app = express();
const PORT = 3000;

// Save uploaded scores to uploads folder
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    // Preserve original name and extension
    const uniqueName = Date.now() + '-' + file.originalname;
    cb(null, uniqueName);
  }
});

const upload = multer({ storage });

app.use(express.json());
app.get('/', (req, res) => {
  res.send('Welcome to TransposeX Backend!');
});

app.post('/upload', upload.single('musicImage'), (req, res) => {
  const sheetName = req.body.sheetName;
  if (!req.file || !sheetName) {
    return res.status(400).json({ error: 'Both file and sheetName are required' });
  }
  console.log(`file path ${req.file.path}`)
  const inputPath = path.resolve(req.file.path);
  //const outputDir = path.resolve('results');
  const outputDir = `Uploads/MusicXml`;

  console.log(`📌 File received: ${inputPath}`);

  //const command = `/usr/libexec/java_home -v 23/bin/java -cp "${audiverisPath}/*" org.audiveris.omr.Main -batch "${inputPath}" -output "${outputDir}"`;
  const command = `java -cp "${audiverisPath}/*" Audiveris -batch -transcribe -output "${outputDir}" -- "${inputPath}"`
  console.log("📌 Running Audiveris Command:", command);

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error('❌ Audiveris execution failed:', error.message);
      return res.status(500).json({ error: 'Audiveris processing error' });
    }
  });

  const baseName = path.basename(inputPath, path.extname(inputPath)); 
  const dir = path.dirname(inputPath); 
  const musicxmlDir = path.join(dir, 'MusicXml');
  const xmlFilePath = path.resolve(musicxmlDir, baseName + '.omr');
  console.log(`path is ${baseName,dir,xmlFilePath}`);
  const sql = 'INSERT INTO sheets (sheetName, imageUrl, musicXMLUrl) VALUES (?, ?, ?)';
  connection.query(sql, [sheetName, inputPath, xmlFilePath], (err, result) => {
    if (err) return res.status(500).json({ error: 'Database insert failed', details: err });

    res.json({
      message: 'File uploaded and saved to database',
      sheetId: result.insertId,
      sheetName: sheetName,
      filePath: inputPath,
      xmlPath: xmlFilePath
    });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server is running on http://0.0.0.0:${PORT}`);
});