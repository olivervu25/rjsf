## Resubmission

This is a resubmission. In this version I have:

* Reworded the DESCRIPTION to address the spell-check NOTE.
* Prevented examples requiring the external Python `jsf` backend from
  initializing Python during CRAN checks.
* Skipped Python-dependent integration tests on CRAN to avoid excessive
  CPU usage during checks.

The abbreviation JSF refers to Jump-Switch-Flow.

The methodology implemented by the package is described in:

Germano et al. (2026) <doi:10.1007/s00285-026-02409-y>.

## R CMD check results

0 errors | 0 warnings | 1 note

* The remaining local NOTE is:

  checking for future file timestamps ... NOTE
  unable to verify current time
