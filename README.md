# OpenMessaging Benchmark Framework

This is Aklivity's fork of the [OpenMessaging Benchmark Framework](https://github.com/openmessaging/benchmark), used to benchmark [Zilla Plus](https://www.aklivity.io/products/zilla-plus) against Kafka vendors.

The OpenMessaging Benchmark Framework provides a consistent, reproducible way to measure the performance of messaging systems — covering throughput, latency, and resource usage under various workloads.

## Aklivity Deployment

> **For full deployment and benchmarking instructions, see the [Aklivity Deployment Guide](driver-kafka/deploy/aklivity-deployment/README.md).**

The guide covers end-to-end setup for the following configurations:

| Configuration                 | Role                                                  |
|-------------------------------|-------------------------------------------------------|
| Zilla Plus + Apache Kafka     | Zilla Plus as Kafka proxy (Apache Kafka backend)      |
| Zilla Plus + Confluent Cloud  | Zilla Plus as Kafka proxy (Confluent Cloud backend)   |
| Apache Kafka                  | Direct connection baseline                            |
| Confluent Cloud               | Direct connection baseline                            |

> **Note on effective throughput:** As a bidirectional proxy, Zilla Plus handles both inbound client traffic and outbound broker traffic simultaneously, making its effective throughput 2x the reported workload rate. A benchmark targeting 100 MB/s means each Zilla instance is moving ~200 MB/s of aggregate network traffic. This context makes the latency results more notable.

## How It Works

A benchmark run follows these steps:

1. **Build** — compile the project with Maven to produce the benchmark binary.
2. **Provision** — use Terraform to spin up EC2 instances for the broker, Zilla Plus (where applicable), and benchmark clients.
3. **Deploy** — use Ansible to configure and start all services on the provisioned instances.
4. **Run workload** — execute a workload file that defines message size, topic count, partitions, producers, consumers, and target throughput.
5. **Monitor** — observe live throughput and latency via Prometheus (available on port 9090 of the Prometheus instance).
6. **Collect results** — the benchmark writes a JSON summary; the run script downloads it automatically into `results/`.
7. **Tear down** — destroy all provisioned infrastructure with `terraform destroy`.

See the [Aklivity Deployment Guide](driver-kafka/deploy/aklivity-deployment/README.md) for the full step-by-step instructions.

## Build

Requirements:

* JDK 8
* Maven 3.8.6+

```bash
mvn clean install -Dlicense.skip=true
```

Common build actions:

|             Action              |                 Command                  |
|---------------------------------|------------------------------------------|
| Full build and test             | `mvn clean verify`                       |
| Skip tests                      | `mvn clean verify -DskipTests`           |
| Skip Jacoco test coverage check | `mvn clean verify -Djacoco.skip`         |
| Skip Checkstyle standards check | `mvn clean verify -Dcheckstyle.skip`     |
| Skip Spotless formatting check  | `mvn clean verify -Dspotless.check.skip` |
| Format code                     | `mvn spotless:apply`                     |
| Generate license headers        | `mvn license:format`                     |

## License

Licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
