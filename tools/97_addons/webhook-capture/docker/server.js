const express = require("express");
const routes = require("./routes");
const bodyParser = require('body-parser');
var path = require('path');

// App
const app = express();



global.logs=true

app.use(bodyParser.json());

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.static(path.join(__dirname, 'public')));


// Set port
const port = process.env.PORT || "8080";
app.set("port", port);

app.use('/', routes);

//app.use(bodyParser.urlencoded({ extended: false }));
// parse application/json
//app.use(bodyParser.json())

// parse application/vnd.api+json as json
//app.use(bodyParser.json({ type: 'application/vnd.api+json' }))
app.use(bodyParser.urlencoded({limit: '5000mb', extended: true, parameterLimit: 100000000000}));

console.log("*************************************************************************************************");
console.log("*************************************************************************************************");
console.log("         __________  __ ___       _____    ________            ");
console.log("        / ____/ __ \\/ // / |     / /   |  /  _/ __ \\____  _____");
console.log("       / /   / /_/ / // /| | /| / / /| |  / // / / / __ \\/ ___/");
console.log("      / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) ");
console.log("      \\____/_/      /_/  |__/|__/_/  |_/___/\\____/ .___/____/  ");
console.log("                                                /_/            ");
console.log("*************************************************************************************************");
console.log("*************************************************************************************************");
console.log("");
console.log("    🛰️ Webhook UI");
console.log("");
console.log("       Provided by:");
console.log("        🇨🇭 Niklaus Hirt (nikh@ch.ibm.com)");
console.log("");
// Server
app.listen(port, () => console.log(`     🚀 Server running on localhost:${port}`));
console.log("*************************************************************************************************");
console.log("*************************************************************************************************");
console.log("");
console.log("");
console.log("    **************************************************************************************************");


