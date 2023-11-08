# Load Testing

We can perform load testing on the app through the use of a tool called JMeter

## Installation

On a mac we can install jmeter with brew

`brew install jmeter`

## Working with Tests

The simplest way to view, edit, or run our tests are in JMeter's GUI mode.  We can open the test with the following command:

`jmeter -t Favicon_JMeter.jmx`

For documentation on how to configure/use the tool please consult the [JMeter documentation](https://jmeter.apache.org/usermanual/get-started.html)

## Test Data

One key part of running these tests is having valid data.  We need a list of sites to query the favicon for.  A script `get_sites.sh` has been put together to amass these test sites.  The corresponding file this script outputs is then used in the load test plan.

## Load Test Results

In this simple load test we were able to succesfully serve 300 requests per second.  This was done running the API locally on a 2016 Macbook Pro.

## Next Steps

We can get more information from our load tests by doing the following:
 - Run load tests on our application running in a distributed cluster.
 - Analyze performance metrics on API hosts to determine bottlenecks
 - [Distribute Jmeter](https://jmeter.apache.org/usermanual/jmeter_distributed_testing_step_by_step.html) to generate more load
