const kafka = require("./kafka");

const token = process.env.TOKEN || ""
const kafkaBroker = process.env.KAFKA_BROKER || "kafka1:9092"
const kafkaUser = process.env.KAFKA_USER || "cp4waiops-cartridge-kafka-auth"
const kafkaPWD = process.env.KAFKA_PWD || "CHANGEME"
const kafkaTopicEvents = process.env.KAFKA_TOPIC_EVENTS || "cp4waiops-cartridge-alerts-noi-CREATE-NOI-INTEGRATION"
const kafkaTopicLogs = process.env.KAFKA_TOPIC_LOGS || "cp4waiops-cartridge-logs-CREATE-NOI-INTEGRATION"


function test1() {

  const payload = process.env.DEMO_LOGS_RSA || "{}"
  const iterations = 1
  let sleep = require('util').promisify(setTimeout);

  try {
    console.log("  **************************************************************************************************");
    console.log("   📛 test");


    kafka.getTopic(kafkaTopicEvents)


    console.log(`         📥 eeee`);




  } catch (ex) {
    console.log(ex);
  }
}


async function test(res) {

  try {
    console.log("  **************************************************************************************************");
    console.log("   📛 test");

    var actStatus=""

    const { exec } = require("child_process");


    await exec(`oc get pods -n $WAIOPS_NAMESPACE | grep -v "Completed"| grep -v "Error" | grep "0/"`, (error, stdout, stderr) => {
        if (error) {
            console.log(`error: ${error.message}`);
            return;
        }
        if (stderr) {
            console.log(`stderr: ${stderr}`);
            return;
        }
        console.log(`stdout: ${stdout}`);
        actStatus=stdout.toString();
        console.log(`actStatus: ${actStatus}`);



    });
  
    console.log(`         📥 eeee`);

   
    res.render('done', {
      actStatus: actStatus, 
      test: "dfsfsad"
    });

  } catch (ex) {
    console.log(ex);
  }
  return actStatus;
}






function parse_demo_event() {

  const iterateElement = "events"
  const nodeElement = "Node"
  const nodeAliasElement = "NodeAlias"
  const alertgroupElement = "AlertGroup"
  const summaryElement = "Summary"
  const timestampElement = "override_with_date"
  const urlElement = "URL"
  const severityElement = "Severity"
  const managerElement = "Manager"
  const payload = process.env.DEMO_EVENTS || "{}"


  try {
    console.log("  **************************************************************************************************");
    console.log("   📛 Generating Demo Events from Config Map");

    // console.log("  **************************************************************************************************");
    // console.log("   ⏳ Decode Payload");

    const obj = JSON.parse(payload);

    // console.log("  **************************************************************************************************");
    // console.log("   🌏 Fields to iterate over");
    const iterateObj = obj[iterateElement]
    // console.log(iterateObj);
    // console.log("  **************************************************************************************************");
    // console.log("  **************************************************************************************************");
    // console.log("");
    // console.log("");
    // console.log("");
    // console.log("");

    var kafkaMessage = ""
    var dateFull = Date.now();

    for (var actElement in iterateObj) {

      dateFull = dateFull + 1000;

      var objectToIterate = iterateObj[actElement]

      var actNodeElement = objectToIterate[nodeElement] || nodeElement;
      var actNodeAliasElement = objectToIterate[nodeAliasElement] || nodeAliasElement;
      var actAlertgroupElement = objectToIterate[alertgroupElement] || alertgroupElement;
      var actSummaryElement = objectToIterate[summaryElement] || summaryElement;
      var actUrlElement = objectToIterate[urlElement] || urlElement;
      var actManagerElement = objectToIterate[managerElement] || managerElement;
      var actSeverityElement = objectToIterate[severityElement] || severityElement;
      var actTimestampElement = objectToIterate[timestampElement] || dateFull;
      var formattedTimestamp = `${actTimestampElement}`.substring(0, 10);


      // console.log("");
      // console.log("");
      // console.log("");
      // console.log("    **************************************************************************************************");
      // console.log("    **************************************************************************************************");
      // console.log("     🎯 Found Element");
      // console.log("    **************************************************************************************************");
      // console.log(`         📥 Node:        ${actNodeElement}`);
      // console.log(`         📥 NodeAlias    ${actNodeAliasElement}`);
      // console.log(`         🚀 AlertGroup:  ${actAlertgroupElement}`);
      // console.log(`         📙 Summary:     ${actSummaryElement}`);
      // console.log(`         🌏 URL:         ${actUrlElement}`);
      // console.log(`         🌏 Manager:     ${actManagerElement}`);
      // console.log(`         🎲 Severity:    ${actSeverityElement}`);
      // console.log(`         🕦 Timestamp:   ${formattedTimestamp}`);
      // console.log("        *************************************************************************************************");
      // console.log("");
      console.log(`         📥 Event:     ${actNodeElement}:${actSummaryElement}`);

      actKafkaLine = `{"EventId": "","Node": "${actNodeElement}","NodeAlias": "${actNodeElement}","Manager": "${actManagerElement}","Agent": "${actManagerElement}","Summary": "${actSummaryElement}","FirstOccurrence": "${formattedTimestamp}","LastOccurrence": "${formattedTimestamp}","AlertGroup": "${actAlertgroupElement}","AlertKey": "","Type": 1,"Location": "","Severity": ${actSeverityElement},"URL": "${actUrlElement}","NetcoolEventAction": "insert"}`
      kafka.sendToKafkaEvent(actKafkaLine)
    }
    //console.log("**************************************************************************************************");
  } catch (ex) {
    console.log(ex);
  }
}










function parse_demo_log() {

  const iterateElement = "logs"
  const payload = process.env.DEMO_LOGS || "{}"
  const iterations = process.env.LOG_ITERATIONS || "5"


  try {
    console.log("  **************************************************************************************************");
    console.log("   📛 Generating Demo Log Anomalies from Config Map");

    var kafkaMessage = ""
    var dateFull = Date.now();

    for (let step = 0; step < iterations; step++) {

      var array = payload.toString().split("\n");
      for (i in array) {

        dateFull = dateFull + 1000;
        var objectToIterate = array[i]
        var actTimestampElement = dateFull;
        var formattedTimestamp = `${actTimestampElement}`.substring(0, 10);
        actKafkaLine = objectToIterate.replace("MY_TIMESTAMP", formattedTimestamp)

        kafka.sendToKafkaLog(actKafkaLine)

      }
      console.log(`         📥 Logs:     Injected ${i} Log Lines`);

    }
  } catch (ex) {
    console.log(ex);
  }
}




function parse_demo_log_rsa() {

  const payload = process.env.DEMO_LOGS_RSA || "{}"
  const iterations = 1
  let sleep = require('util').promisify(setTimeout);

  try {
    console.log("  **************************************************************************************************");
    console.log("   📛 Generating Demo Log RSA Anomalies from Config Map");

    var kafkaMessage = ""
    var dateFull = Date.now();

    for (let step = 0; step < iterations; step++) {

      var array = payload.toString().split("\n");
      for (i in array) {

        dateFull = dateFull + 1000;
        var objectToIterate = array[i]
        var actTimestampElement = dateFull;
        var formattedTimestamp = `${actTimestampElement}`.substring(0, 10);
        actKafkaLine = objectToIterate.replace("MY_TIMESTAMP", formattedTimestamp)
        //console.log(`         📥 Logs:     Injected ${i} Log Line`,actKafkaLine);

        kafka.sendToKafkaLogAsync(actKafkaLine)

      }
      console.log(`         📥 Logs:     Injected ${i} Log Lines`);



    }
  } catch (ex) {
    console.log(ex);
  }
}







module.exports = {
  parse_demo_event,
  parse_demo_log,
  parse_demo_log_rsa,
  test
};