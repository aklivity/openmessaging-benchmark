# create_charts.py

Generates comparison charts (SVG) from one or more benchmark result files, so
multiple runs can be plotted together on the same graphs.

Each run produces `results/<timestamp>-<workload>-<scenario>/output.txt` -
despite the `.txt` extension this is a JSON file containing the metrics
`create_charts.py` reads (`publishRate`, `publishLatency99pct`,
`endToEndLatency95pct`, aggregated scalars, quantile distributions, etc.).

Results are grouped onto the same set of charts by their `workload` field, and
within a group, each file becomes one labeled line/series - the label is the
result's `driver` field.

## Setup (one-time)

```bash
pip3 install pygal
```

SVG -> PNG conversion (optional, see step 4 below) needs the `cairosvg` CLI:

```bash
pip3 install cairosvg
```

## Comparing two (or more) runs

Every driver YAML in this repo sets `name: Kafka`, so every result file's
`driver` field is just `"Kafka"` by default. Without relabeling it, every line
on every chart would say "Kafka" and be indistinguishable. Relabel each result
file's `driver` field before charting.

1. Create a working directory for this comparison:

    ```bash
    mkdir -p charts/<comparison-name>
    cd charts/<comparison-name>
    ```

2. Label each result's `driver` field (repeat for as many runs as you want on
   the same graph - `create_charts.py` takes any number of files):

    ```bash
    python3 -c "
    import json
    d = json.load(open('../../results/<run1-dir>/output.txt'))
    d['driver'] = '<label1>'
    json.dump(d, open('<label1>-output.json', 'w'))
    "

    python3 -c "
    import json
    d = json.load(open('../../results/<run2-dir>/output.txt'))
    d['driver'] = '<label2>'
    json.dump(d, open('<label2>-output.json', 'w'))
    "
    ```

3. Generate the SVG charts:

    ```bash
    python3 ../../bin/create_charts.py <label1>-output.json <label2>-output.json
    ```

   This produces one SVG per metric: Publish rate, Publish Error rate, Consume
   rate, Publish Latency 99pct, Publish Delay Latency 99pct, End To End
   Latency Avg, End To End Latency 95pct, plus quantile-distribution charts
   for Publish Latency, Publish Delay Latency, and End To End Latency.

4. Convert to PNG (optional):

    ```bash
    mkdir -p png
    for f in *.svg; do
      cairosvg "$f" -o "png/${f%.svg}.png" --output-width 1200
    done
    ```

## Quick aggregate comparison (no charts)

For a fast text-only comparison of headline numbers before generating charts:

```bash
python3 -c "
import json
for label, path in [('<label1>', '<label1>-output.json'), ('<label2>', '<label2>-output.json')]:
    d = json.load(open(path))
    print(f'== {label} ==')
    for k in ['aggregatedPublishLatencyAvg','aggregatedPublishLatency99pct','aggregatedPublishLatencyMax',
              'aggregatedEndToEndLatencyAvg','aggregatedEndToEndLatency99pct','aggregatedEndToEndLatencyMax']:
        print(f'  {k}: {d[k]:.2f}')
    print(f'  avg publishRate: {sum(d[\"publishRate\"])/len(d[\"publishRate\"]):.1f} msg/s')
    print(f'  avg consumeRate: {sum(d[\"consumeRate\"])/len(d[\"consumeRate\"]):.1f} msg/s')
"
```

## Example

Comparing two runs of the same workload end-to-end, from scratch:

```bash
mkdir -p charts/<comparison-name>
cd charts/<comparison-name>

python3 -c "
import json
d = json.load(open('../../results/<run1-dir>/output.txt'))
d['driver'] = '<label1>'
json.dump(d, open('<label1>-output.json', 'w'))
"

python3 -c "
import json
d = json.load(open('../../results/<run2-dir>/output.txt'))
d['driver'] = '<label2>'
json.dump(d, open('<label2>-output.json', 'w'))
"

python3 ../../bin/create_charts.py <label1>-output.json <label2>-output.json

mkdir -p png
for f in *.svg; do
  cairosvg "$f" -o "png/${f%.svg}.png" --output-width 1200
done
```
