# NetMod — In-Switch IQ Constellation Mapping for 5G ORAN Fronthaul (single-payload)

> 📄 **If you use this code in research, please cite:**
>
> ```bibtex
> @article{naji2024netmod,
>   title={NetMod: Toward accelerating cloud RAN distributed unit modulation within programmable switches},
>   author={Naji, Abdulbary and Wang, Xingfu and Hawbani, Ammar and Ghannami, Aiman and Zhao, Liang and Xu, XiaoHua and Zhao, Wei},
>   journal={IEEE Transactions on Computers},
>   volume={74},
>   number={2},
>   pages={665--677},
>   year={2024},
>   publisher={IEEE}
> }
> ```
>
> Naji *et al.*, "NetMod: Toward Accelerating Cloud RAN Distributed Unit
> Modulation within Programmable Switches", *IEEE Transactions on
> Computers*, vol. 74, no. 2, pp. 665–677, 2024.

## 1. What is NetMod?

`NetMod` is the **original, single-payload** P4_14 / TNA data-plane
program for the Barefoot Tofino switch that performs **real-time IQ
modulation (constellation mapping)** for the O-RAN / eCPRI fronthaul link
between a Radio Unit (RU) and a Distributed Unit (DU).

It is the predecessor of **`NetModPlus`**, which adds multi-payload
support and packet recirculation. The two repos share most of the
parser / header / mapper code; this `NetMod` repo is the simpler
single-payload reference.

In a 5G fronthaul the DU has to push IQ samples to the RU over Ethernet.
Each IQ sample carries `bps` (bits per symbol) and the choice of
modulation (BPSK, QPSK, 16-QAM, 64-QAM, 256-QAM) trades spectral
efficiency for robustness. In a classical implementation the IQ
constellation mapping is done in software on the DU. **NetMod moves that
mapping into the switch ASIC**, so the DU can just stream raw bit chunks
to the switch and the switch turns them into IQ samples on the wire —
at line rate, with deterministic latency.

The mapping is implemented with **match-action tables acting as
Register-style look-up tables (SMAPs)** — a standard technique for
emulating arbitrary functions in a programmable parser–match pipeline.

The companion project **NetCRC** does the same trick for 5G NR CRC
computation — see `NetCRC/README.md` for that variant.

This repository accompanies the paper **"NetMod: Toward Accelerating
Cloud RAN Distributed Unit Modulation within Programmable Switches"** by
Naji *et al.*, IEEE Transactions on Computers, 2024 (see citation block
at the top). The paper describes the architecture, the SMAP-based
constellation mapping, and the cloud-RAN evaluation.

---

## 2. Repository layout

```
NetMod/
├── p4src/
│   ├── NetMod.p4        # Top-level program (entry point)
│   └── Readme           # Stale error log from a previous compile
│
├── include/
│   ├── defs.p4              # Type definitions, constants, enums
│   ├── headers.p4           # Header & metadata structs
│   ├── parser.p4            # Ingress parser (single-payload)
│   ├── egress.p4            # Egress pipeline (no-op)
│   ├── forwarder.p4         # L3 ipv4_host forwarding
│   ├── arp_icmp.p4          # ARP / ICMP responder
│   ├── BPSK.p4              # BPSK mapper
│   ├── QPSK.p4              # QPSK mapper
│   ├── QAM16.p4             # 16-QAM mapper
│   ├── QAM64.p4             # 64-QAM mapper
│   ├── QAM256.p4            # 256-QAM mapper
│   ├── snaps.p4             # Macro library for SMAP definitions
│   └── test_ingress.p4      # Experimental ingress variant
│
├── ptf-tests/               # PTF-based control-plane tests
│   ├── imports.py
│   ├── netMod3.py
│   └── ns_cli.py
│
├── setup/                   # bfshell Python (control plane)
│   ├── Smaps.py             # Loads SMAP constellations from .txt
│   ├── BPSK.txt  QPSK.txt  QAM16.txt  QAM64.txt  QAM256.txt   # Constellations
│   ├── cp.py cp2.py cpx.py cp-test.py cptestForward.py        # Variants
│   ├── cp3tb.py
│   └── __pycache__/
│
└── tests/
    ├── test.py              # Scapy generator (single-payload)
    ├── slice.cpp            # Host C++ bit-slicer (breaks up IQ blocks)
    ├── slicer               # Prebuilt slicer binary
    └── throughtput.md       # 256-QAM throughput notes
```

The active build path is:

```
p4src/NetMod.p4  →  include/parser.p4
                →  include/egress.p4
                →  include/ingress.p4
                →  TNA pipeline
```

---

## 3. Wire format

```
+-----------+-----------+-----------+-----------+---------+-----------+
| Ethernet | IPv4 | UDP | net_mod_hdr | payload0 | qam64_b | IQ output |
+-----------+-----------+-----------+-----------+---------+-----------+
  14 B       20 B       8 B         4 B        16 B     12 B    attached
```

* **Ethernet** – standard; `etherType = 0x0800` (IPv4).
* **IPv4** – normal; `protocol = UDP`.
* **UDP** – `src_port = 55443` (`NET_MOD_UDP_SRC_PORT` in `defs.p4`).
  This is what flags a UDP datagram as NetMod traffic to the parser.
* **`net_mod_hdr_t`** (4 bytes):

  | field        | bits | meaning |
  |--------------|------|---------|
  | `bps`        | 8    | bits per symbol (1, 2, 4, 6, or 8) |
  | `mhl`        | 16   | modulation header length accumulator |
  | `seq`        | 32   | sequence number |
  | `worker_id`  | 8    | host worker id |

* **payload0** (`net_mod_payload_hdr_t`) – 16 × 8-bit `bs_t` = 128 bits.
  The bit chunk the DU wants mapped.
* **QAM-64 payload** (`net_mod_payload_hdr_qam64_t`) – 16 × 6-bit
  `qam64_t` = 96 bits, used when `bps == 6`.

The IQ symbols produced by the mapper are appended to the packet on egress
(their placement depends on which mapper is active).

### Per-modulation IQ widths

| Modulation | `bps` | Input bits / payload | IQ width (ORAN TS 38.59) |
|------------|-------|----------------------|--------------------------|
| BPSK       | 1     | 128                  | 4 bits                   |
| QPSK       | 2     | 128                  | 4 bits                   |
| 16-QAM     | 4     | 128                  | 4 bits                   |
| 64-QAM     | 6     | 96  (6-bit packed)   | 8 bits                   |
| 256-QAM    | 8     | 128                  | 16 bits                  |

---

## 4. Step-by-step pipeline

### Step 0 — `p4src/NetMod.p4`

```p4
#include<core.p4>
#include<tna.p4>
#include"../include/parser.p4"
#include"../include/egress.p4"
#include"../include/ingress.p4"

Pipeline(IngressParser(), Ingress(), IngressDeparser(),
         EgressParser(), Egress(), EgressDeparser()) pipe;
Switch(pipe) main;
```

Standard TNA 6-stage pipeline. All the work is in `Ingress` /
`IngressParser` / `ingress.p4`.

---

### Step 1 — Definitions: `include/defs.p4`

* `NET_MOD_UDP_SRC_PORT = 55443` – the magic port that flags NetMod
  traffic.
* Payload bit widths: BPSK/QPSK/16-QAM/256-QAM = 16 bits each; 64-QAM =
  6 bits (packed).
* IQ widths: 16 bits (`iq_t`), 6 bits (`qam64_t`), 4 bits (`bpsk_iq_t`),
  etc. — from ORAN TS 38.59 Appendix A.5.
* Typedefs: `mac_addr_t`, `ipv4_addr_t`, `port_addr_t`, `index_t`.
* Enums: `ether_type_t`, `ip_protocol_t`, `arp_opcode_t`,
  `icmp_type_t`.

---

### Step 2 — Headers & metadata: `include/headers.p4`

* Standard L2/L3 headers (`ethernet_h`, `arp_h`, `arp_ipv4_h`, `ipv4_h`,
  `udp_h`, `icmp_h`).
* `net_mod_hdr_t` – the 4-byte NetMod header (`bps`, `mhl`, `seq`,
  `worker_id`).
* `net_mod_payload_hdr_t` – 16 × `bs_t` input bits.
* `net_mod_payload_hdr_qam64_t` – 16 × `qam64_t` for QAM-64.
* `net_mod_iq_hdr8_t`, `net_mod_iq_hdr16_t`,
  `net_mod_iq_bpsk_hdr16_t` – the IQ output headers.
* `struct ns_headers` – the union of every header in parser order.

---

### Step 3 — Ingress parser: `include/parser.p4`

Walks the wire-format diagram:

1. `start` – extract `ig_md`, advance `PORT_METADATA_SIZE`.
2. `meta_init` – clear `dst_ipv4` / `ipv4_csum_err` / `index` /
   `done`.
3. `parse_ethernet` – branch on `ether_type` (IPv4 vs ARP vs default).
4. `parse_arp` / `parse_arp_ipv4` – captures `dst_proto_addr`.
5. `parse_ipv4` – extract IPv4, verify checksum, branch on `(ihl,
   frag_offset, protocol)` to `parse_icmp` or `parse_udp`.
6. `parse_icmp` – accept.
7. `parse_udp` – branch on `src_port == 55443` → `parse_mod`.
8. `parse_mod` – extract `hdr.mod`, branch on `bps`:
   * `6` → `parse_qam64_payload0` (extract the 6-bit QAM-64 payload)
   * else → `parse_payload0` (extract the 16×8-bit payload)
9. `accept` – single-payload path ends here.

> **Note** — the parser also contains a large commented-out block that
> sketched out an earlier recirculation / multi-pass IQ-collection path
> using a `PARSE_IQ(c, n)` macro and `parse_circ`. That evolved into the
> multi-payload branch in `NetModPlus`.

---

### Step 4 — Forwarder: `include/forwarder.p4`

`ipv4_host` table, key on `hdr.ipv4.dst_addr`, with `send(port)`,
`send_back()`, and `drop()` actions. The `send` action sets the TM
egress port and clears `drop_ctl`.

---

### Step 5 — Modulation mappers

NetMod has **five separate mapper controls**, one per modulation.
Each control instantiates a bank of `bpsk_map_ctrl` / `qpsk_map_ctrl` /
`qam16_map_ctrl` / `qam256_map_ctrl` / `qam64tb` instances that act as
*constellation tables* (match-action ROMs) — one entry per input byte.

* **`BPSK.p4` — `BPSKMapper`** — 16 instances, one per input byte
  `payload0.b<i>`. Each instance runs an 8-bit → 8 IQ symbol lookup
  using a `bpsk_table` of size 256.
* **`QPSK.p4` — `QPSKMapper`** — 16 instances over `payload0.b<i>`,
  each doing a 2-bit-per-symbol lookup (4 IQ symbols per byte).
* **`QAM16.p4` — `QAM16Mapper`** — three nested `QAM16MapPayload`
  blocks; each nested block uses four `qam16_map_ctrl` instances
  (4-bit-per-symbol lookup, 2 IQ symbols per byte).
* **`QAM64.p4` — `QAM64Mapper`** — 16 instances over
  `qam64.payload0.b<i>`, each doing a 6-bit → 8-bit IQ lookup via
  `qam64tb` (key: `hdr.mod.ec`, `bank0`).
* **`QAM256.p4` — `QAM256Mapper`** — chained `QAM256MapPayload`
  blocks; each instance does a 8-bit → 16-bit IQ lookup.

> **Note** — `snaps.p4` is a macro library (kept for reference) that
> builds SMAP-style lookups via `RegisterAction` instead of match-action
> tables. The current build does not use it.

In every case the action emits the IQ symbol(s) into `meta.bpsk.IQ<i>`.

---

### Step 6 — Ingress: `include/ingress.p4`

The orchestrator. The `Ingress` control wires the mapper controls
together with the forwarder and the ARP/ICMP responder:

```p4
Forwarder()       nexthop;
BPSKMapper()      BPSK;
QPSKMapper()      QPSK;
QAM256Mapper()    QAM256;
QAM16Mapper()     QAM16;
QAM64Mapper()     QAM64;
ARPandICMPResponder() arp_icmp;
```

`apply`:

1. If `hdr.mod.isValid()`:
   * Dispatch on `hdr.mod.bps` (1, 2, 4, 6, or 8) to the right mapper.
2. Else if `hdr.arp_ipv4.isValid()` or `hdr.icmp.isValid()`:
   * Run `arp_icmp.apply(...)`.
3. Else:
   * Run `nexthop.apply(...)` (standard L3 forwarding).

**IngressDeparser** recomputes the IPv4 header checksum and emits
`pkt.emit(hdr)`.

---

### Step 7 — Egress: `include/egress.p4`

Trivial pass-through — extracts `eg_intr_md`, `pkt.emit(hdr)` in
deparser.

---

## 5. End-to-end packet journey (BPSK)

1. **Wire** – `Ethernet / IPv4 / UDP(55443 → 2017) / net_mod_hdr /
   payload0` arrives.
2. **IngressParser** – pulls the payload header, accepts.
3. **Ingress** – `hdr.mod.bps == 1` → `BPSK.apply(hdr, meta)` runs 16
   match-action lookups (one per byte) into `meta.bpsk.IQ0..IQ15`.
4. **IngressDeparser** – re-checksums IPv4, emits the full header chain
   (with the IQ block appended by the deparser from `meta`).
5. **nexthop** / **arp_icmp** – L3 forward or L2 reply.
6. **Egress / TM** – packet exits the switch with the IQ block on the
   wire.

---

## 6. Build & deploy

The repo does **not** ship its own build scripts — NetModPlus has them
under `scripts/`. The typical invocation on a Tofino SDE host:

```bash
cd NetMod
$SDE/p4studio/p4studio.py \
  --p4-src p4src/NetMod.p4 \
  --build-dir build/ \
  --arch tofino \
  --output-dir build/

$SDE/run_switchd.sh -p NetMod
$SDE/run_bfshell.sh
python3 setup/cp.py    # program the SMAPs and nexthop table
```

> **Note** — NetModPlus ships a more polished wrapper under
> `scripts/compile.sh`, `run_switch.sh`, etc. that does the equivalent
> work; see `NetModPlus/README.md` §6.

---

## 7. Control plane: programming the SMAPs

Constellation values live in the `setup/*.txt` files
(`BPSK.txt`, `QPSK.txt`, `QAM16.txt`, `QAM64.txt`, `QAM256.txt`).
Each file lists the IQ values in hex, one per line.

`setup/Smaps.py` parses these files; `setup/cp.py` (and its variants
`cp2.py`, `cpx.py`, `cp-test.py`, `cp3tb.py`) iterates over each
constellation and writes one entry per symbol into the corresponding
SMAP register via `bfrt.<P4>.Ingress.<MAPPER>.SMAP<n>`.

Quick reference for the active `cp.py`:

```python
P4 = bfrt.NetMod.pipe
M2   = P4.Ingress.BPSK.SMAP1
M4   = P4.Ingress.QPSK.SMAP2
M16  = P4.Ingress.QAM16.SMAP4
M64  = P4.Ingress.QAM64.SMAP6
M256 = P4.Ingress.QAM256.SMAP8
nexthop = P4.Ingress.nexthop.ipv4_host
```

Run from bfshell after boot:

```bfshell
python3 /path/to/NetMod/setup/cp.py
```

---

## 8. Test / traffic generation

* **`tests/test.py`** — Scapy packet generator that builds NetMod
  packets with one of BPSK/QPSK/QAM16/QAM64 and sends them out a veth
  or NIC.
* **`tests/slice.cpp` + `tests/slicer`** — C++ utility that *slices* a
  long bit-stream into the proper 16-byte (or 12-byte QAM-64) chunks
  expected by the switch payload header.
* **`tests/throughtput.md`** — measured throughput notes for 256-QAM
  with the production DPDK settings (`-l 0-47 -n 48`).

Run from a host with scapy:

```bash
sudo python3 tests/test.py
```

---

## 9. Variants / exploratory files

`include/test_ingress.p4` and the commented-out blocks in `parser.p4`
are sketches of earlier designs that never made it into the active
build. `NetModPlus/include/snaps.p4` is a more developed macro
library that became the basis of the multi-payload branch.

The main legacy difference vs. `NetModPlus`:

| Aspect | NetMod (this repo) | NetModPlus |
|--------|--------------------|------------|
| Payload headers | 1 (`payload0`) | up to 4 |
| Recirculation | not used | core mechanism |
| Mapper composition | per-modulation controls directly | unified `Mapper` / `mapX` |
| Multi-payload parser | n/a | `parser4.p4` |

---

## 10. Summary

NetMod is the **single-payload, single-pass** Tofino P4 program that
turns the switch ASIC into a constellation-mapper for 5G fronthaul:
* parses L2/L3/UDP,
* recognises NetMod traffic by UDP source port `55443`,
* extracts the NetMod header and one 128-bit payload chunk,
* uses one match-action-table-per-modulation as a small ROM to map
  each input byte to an IQ symbol,
* appends the IQ block to the packet,
* forwards through the standard L3 forwarding table.
The control plane (bfshell `cp.py`) populates the SMAP registers and
the `ipv4_host` table. For a multi-payload / recirculation extension
see `NetModPlus`.
