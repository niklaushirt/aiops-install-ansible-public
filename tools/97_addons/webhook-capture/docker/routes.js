const express = require('express');
const bodyParser = require('body-parser');

const router = express.Router();

global.webhooks = '{"received_webhooks": [';

//**************************************************************************************************
// Basic Functions
//**************************************************************************************************
router.get("/", function (req, res) {
  res.render('index', {});
});




router.post("/webhook", function (req, res) {
  //global.loggedin = true
  console.log("   ✅ RECEIVED REQUEST\n", req.body);
  bodyString=JSON.stringify(req.body);
  global.webhooks =global.webhooks + bodyString +",";
  res.sendStatus(200);
});


router.get("/history", function (req, res) {
  //global.loggedin = true
  console.log("   ✅ HISTORY\n");
  res.render('request', {body:global.webhooks + "]}"});

});



module.exports = router;