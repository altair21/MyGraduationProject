var express = require('express');
var bodyParser = require('body-parser');
var multer = require('multer');
var fs = require('fs');

var app = express();
app.use(bodyParser.json());

var fileDir = process.cwd() + '/files';
var upload = multer({dest: fileDir});
var mazeUpload = upload.fields([{name: 'headImg', maxCount: 1}]);

app.get('/getList/', function(req, res) {
  fs.readdir(fileDir, function(err, files) {
    if (err) {
      console.log(err);
      return res.status(500).send(JSON.stringify({code: 500, error: 'Server error'}));
    }

    return res.status(200).send(JSON.stringify({code: 200, files: files}));
  });
});

app.get('/download/', function(req, res) {
  try {
    var content = fs.readFileSync(process.cwd() + '/files/' + req.query.filename, 'utf-8');
    return res.status(200).send(content);
  }
  catch (e) {
    console.log(e);
    return res.status(400).send(JSON.stringify({code: 400, error: 'no file'}));
  }
});

app.post('/upload/', mazeUpload, function(req, res) {
  if (req.files) {
    var headImg = req.files['headImg'][0];
    fs.rename(headImg.path, fileDir + '/' + headImg.originalname);

    return res.status(200).send(JSON.stringify({code: 200, result: 'upload success'}));
  } else {
    return res.status(400).send(JSON.stringify({code: 400, result: 'upload failure'}));
  }
});

app.listen(3001, function(req, res) {
  console.log('Maze server running at port 3001');
});
