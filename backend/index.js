const express = require('express');
const multer = require('multer');
const path = require('path');
const { exec } = require('child_process');


const app = express();
const PORT = 3000;

// save uploaded scores to uploads folder
const upload = multer({ dest: 'uploads/'});

app.use(express.json());
app.get('/', (req, res) => {
  res.send('Welcome to TransposeX Backend!');
});

app.post('/upload', upload.single('musicImage'), (req, res) => {
    const inputPath = path.resolve(req.body.filePath || '');

    if (!req.body.filePath) {
        return res.status(400).send('You must provide a filePath in the request body.');
    }

    console.log(`input path ${inputPath}`);
    const outputDir = path.resolve('results');
  
    const command = `/Users/zhixuanliu/Desktop/audiveris/app/build/distributions/app-5.4/bin/Audiveris -transcribe ${inputPath} -output ${outputDir} -export`;
  
    console.log(' Start to process in Audiveris...');
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(' Audiveris execution failure:', error.message);
        return res.status(500).send('Audiveris error, please check the format or path');
      }
  
      res.send({
        message: ' Image uploaded and processed!',
        outputFolder: outputDir
      });
    });
  });

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});