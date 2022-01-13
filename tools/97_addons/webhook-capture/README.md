Install then use the /webhook endpoint with POST and get the JSON with GET/Browser to /history.



oc get route -n default webhook-capture  -o jsonpath={.spec.host}
oc get route -n default webhook-capture-webhook  -o jsonpath={.spec.host}
oc get route -n default webhook-capture-history  -o jsonpath={.spec.host}