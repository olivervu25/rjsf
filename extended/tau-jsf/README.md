# Experimental Jump–Tau–Flow Extension

This directory contains preliminary research and development exploring an
extension of Jump-Switch-Flow (JSF) with a Tau-leaping regime.

The work investigates a three-regime **Jump–Tau–Flow** approach in which
different components of a compartmental system may be simulated using:

- stochastic Jump dynamics at low populations;
- Tau-leaping at intermediate populations; and
- deterministic Flow dynamics at high populations.

The implementation and experiments in this directory are exploratory and are
not part of the public `rjsf` API.

## Contents

### `__init__.py`

Experimental Python implementation used to explore the addition of a
Tau-leaping regime to the existing Jump-Switch-Flow framework.

The prototype includes support for Tau-specific configuration and diagnostics
used during development and evaluation.

### `Experiments.Rmd`

Source document containing experiments comparing the experimental
Jump–Tau–Flow approach with Exact SSA.

The experiments consider:

- a standard SIR model;
- an independent birth–death process;
- a weakly coupled two-species birth–death model;
- a time-dependent birth–death process; and
- a catalytic time-scale-separation edge case.

Evaluation focuses on ensemble-level behaviour, including mean trajectories,
simulation envelopes, final-state distributions, variability, relative error,
and runtime.

### `Experiments.html`

Rendered snapshot of `Experiments.Rmd`, including experimental results and
figures.

## Preliminary findings

The experiments suggest that the Jump–Tau–Flow prototype can provide
substantial computational savings while reproducing mean behaviour well in
favourable settings.

They also identify limitations that require further investigation. In
particular, the current prototype can underestimate stochastic variability,
especially when species spend substantial time in the Flow regime.

The most significant failure mode observed so far occurs under time-scale
separation, where a slow Jump process depends on a rapidly changing Tau or
Flow species. In these settings, propensity information can become outdated
during a hybrid step, leading to discrepancies in both the mean behaviour and
the resulting stochastic distribution.

A potential direction for further development is a more dynamic coupling
mechanism, such as a jump-clock-style update that accounts for changing
propensities during each hybrid step.

## Status

This directory is intended as a development and research area for experimental
extensions to JSF. Interfaces, algorithms, parameters, and results here may
change as the approach is developed further.

For the supported `rjsf` package interface, see the main repository
documentation.
