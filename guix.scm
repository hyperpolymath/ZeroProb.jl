;; SPDX-License-Identifier: MPL-2.0
;; Guix development environment.
;; Usage: guix shell -D -f guix.scm

(use-modules (guix packages)
             (guix build-system gnu)
             (guix licenses)
             (gnu packages base)
             (gnu packages bash)
             (gnu packages julia)
             (gnu packages zig))

(package
  (name "zeroprob.jl")
  (version "0.1.0")
  (source #f)
  (build-system gnu-build-system)
  (inputs (list coreutils bash julia zig))
  (synopsis "zeroprob.jl")
  (description "zeroprob.jl — part of the hyperpolymath ecosystem.")
  (home-page "https://github.com/hyperpolymath/zeroprob.jl")
  (license ((@@ (guix licenses) license) "MPL-2.0" "https://github.com/hyperpolymath/palimpsest-license")))
