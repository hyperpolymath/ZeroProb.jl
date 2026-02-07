;; SPDX-License-Identifier: PMPL-1.0-or-later
;; STATE.scm - Project state tracking for ZeroProb.jl
;; Media-Type: application/vnd.state+scm

(define-state ZeroProb.jl
  (metadata
    (version "0.1.0")
    (schema-version "1.0.0")
    (created "2026-02-07")
    (updated "2026-02-07")
    (project "ZeroProb.jl")
    (repo "hyperpolymath/ZeroProb.jl"))

  (project-context
    (name "ZeroProb.jl")
    (tagline "Zero-probability events in continuous probability spaces")
    (tech-stack (julia distributions statistics visualization)))

  (current-position
    (phase "complete")
    (overall-completion 100)
    (components
      (types "Core type system for zero-prob events")
      (measures "Density ratio, Hausdorff, epsilon-neighborhood")
      (paradoxes "Continuum, Borel-Kolmogorov paradoxes")
      (applications "Black swan events, market crashes")
      (visualization "Plotting utilities"))
    (working-features
      "ContinuousZeroProbEvent type system"
      "Alternative relevance measures"
      "Pedagogical paradox examples"
      "Black swan event modeling"
      "Comprehensive test suite"))

  (route-to-mvp
    (milestones
      ((name "Core Implementation")
       (status "complete")
       (completion 100)
       (items
         ("Type system" . done)
         ("Relevance measures" . done)
         ("Paradox examples" . done)
         ("Applications" . done)
         ("Tests" . done)))))

  (blockers-and-issues
    (critical ())
    (high ())
    (medium ())
    (low ()))

  (critical-next-actions
    (immediate
      "Expand documentation with more examples"
      "Add integration with Axiom.jl ecosystem")
    (this-week
      "Performance benchmarks"
      "Additional paradox examples")
    (this-month
      "Research paper integration"
      "Extended applications library"))

  (session-history ()))

;; Helper functions
(define (get-completion-percentage state)
  (current-position 'overall-completion state))

(define (get-blockers state severity)
  (blockers-and-issues severity state))

(define (get-milestone state name)
  (find (lambda (m) (equal? (car m) name))
        (route-to-mvp 'milestones state)))
