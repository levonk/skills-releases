---
type: Practice
title: Streaming Data Patterns — Exactly-Once, Watermarks, and Windowing
description: Design streaming pipelines with explicit delivery guarantees, event-time watermarks, and windowing strategies that handle late events without unbounded state growth.
tags: [data-engineering, streaming, kafka, kinesis, exactly-once, watermark, windowing, flink]
timestamp: 2026-07-17T00:00:00Z
---

# Streaming Data Patterns

## Failure Mode

Streaming pipelines produce duplicate results, drop late events, or run out of
memory because delivery semantics are ambiguous, processing time is used instead
of event time, and windows are not bounded.

## Symptoms

- Duplicate records appear in sink after a consumer restart.
- Late events are silently dropped or assigned to the wrong window.
- State backends grow unbounded, causing OOM.
- Results differ between replay and live processing.

## Practice

### Delivery Guarantees

| Guarantee | Behavior | Trade-off |
|-----------|----------|-----------|
| At-most-once | No retries | May lose data, lowest latency |
| At-least-once | Retry on failure | May duplicate data, needs idempotent sinks |
| Exactly-once | Idempotent processing + transactional sinks | Highest correctness cost, needed for finance/ops |

Use idempotent sinks and offset/commits for exactly-once semantics.

### Event Time vs Processing Time

- Use event time (the timestamp in the record) for windowing and aggregation.
- Use watermarks to track event-time progress and trigger window evaluation.
- Processing time is useful only for monitoring and latency SLAs.

### Watermarks

- Bounded-out-of-orderness watermarks: `maxEventTime - maxDelay`.
- Choose `maxDelay` based on observed event-time skew in the source.
- After watermark passes, late events go to a side output, not the main result.

### Windowing

| Window | Use Case |
|--------|----------|
| Tumbling | Non-overlapping fixed intervals (e.g. hourly aggregates) |
| Sliding | Overlapping fixed intervals (e.g. 5-min averages every 1 min) |
| Session | User activity gaps (e.g. sessionize web events) |
| Global | Single aggregate over all data; needs careful triggering |

### State Management

- TTL state to avoid unbounded growth.
- Use RocksDB state backend for large keyed state.
- Enable checkpointing to recover from failures without reprocessing from the
  beginning.

## Citations

[1] [Apache Flink Streaming Concepts](https://nightlies.apache.org/flink/flink-docs-stable/docs/concepts/time/)
[2] [Kafka Streams Delivery Guarantees](https://kafka.apache.org/documentation/streams/architecture)
