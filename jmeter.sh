export JMETER=<KUBE_MASTER>

scp -i deploy/shoppingcart_key.pem jmeter/concurrency-10-ramp-up-1-steps-with-in-5-min.jmx ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin
scp -i deploy/shoppingcart_key.pem jmeter/concurrency-100-ramp-up-1-steps-with-in-2-min.jmx ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin
scp -i deploy/shoppingcart_key.pem jmeter/concurrency-100-ramp-up-1-steps-with-in-5-min.jmx ubuntu@$JMETER:~/apache-jmeter-5.1.1/bin
