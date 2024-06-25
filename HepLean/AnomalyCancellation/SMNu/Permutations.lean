/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license.
Authors: Joseph Tooby-Smith
-/
import HepLean.AnomalyCancellation.SMNu.Basic
import Mathlib.Tactic.Polyrith
import Mathlib.RepresentationTheory.Basic
/-!
# Permutations of SM charges with RHN.

We define the group of permutations for the SM charges with RHN.

-/

universe v u

open Nat
open  Finset

namespace SMRHN

open SMνCharges
open SMνACCs
open BigOperators

/-- The group of `Sₙ` permutations for each species. -/
@[simp]
def permGroup (n : ℕ) := Fin 6 → Equiv.Perm (Fin n)

variable {n : ℕ}

@[simp]
instance : Group (permGroup n) := Pi.group

/-- The image of an element of `permGroup n` under the representation on charges. -/
@[simps!]
def chargeMap (f : permGroup n) : (SMνCharges n).charges →ₗ[ℚ] (SMνCharges n).charges where
  toFun S := toSpeciesEquiv.symm (fun i => toSpecies i S ∘ f i )
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

/-- The representation of `(permGroup n)` acting on the vector space of charges. -/
@[simp]
def repCharges {n : ℕ} : Representation ℚ (permGroup n) (SMνCharges n).charges where
  toFun f := chargeMap f⁻¹
  map_mul' f g := by
    simp only [permGroup, mul_inv_rev]
    apply LinearMap.ext
    intro S
    rw [charges_eq_toSpecies_eq]
    intro i
    simp only [chargeMap_apply, Pi.mul_apply, Pi.inv_apply, Equiv.Perm.coe_mul, LinearMap.mul_apply]
    repeat erw [toSMSpecies_toSpecies_inv]
    rfl
  map_one' := by
    apply LinearMap.ext
    intro S
    rw [charges_eq_toSpecies_eq]
    intro i
    erw [toSMSpecies_toSpecies_inv]
    rfl

lemma repCharges_toSpecies (f : permGroup n) (S : (SMνCharges n).charges) (j : Fin 6) :
    toSpecies j (repCharges f S) = toSpecies j S ∘ f⁻¹ j := by
  erw [toSMSpecies_toSpecies_inv]


lemma toSpecies_sum_invariant (m : ℕ) (f : permGroup n) (S : (SMνCharges n).charges) (j : Fin 6) :
    ∑ i, ((fun a => a ^ m) ∘ toSpecies j (repCharges f S)) i =
    ∑ i, ((fun a => a ^ m) ∘ toSpecies j S) i := by
  erw [repCharges_toSpecies]
  change  ∑ i : Fin n, ((fun a => a ^ m) ∘ _) (⇑(f⁻¹ _) i) = ∑ i : Fin n, ((fun a => a ^ m) ∘ _) i
  refine Equiv.Perm.sum_comp _ _ _ ?_
  simp only [permGroup, Fin.isValue, Pi.inv_apply, ne_eq, coe_univ, Set.subset_univ]


lemma accGrav_invariant (f : permGroup n) (S : (SMνCharges n).charges)  :
    accGrav (repCharges f S) = accGrav S :=
  accGrav_ext
    (by simpa using toSpecies_sum_invariant 1 f S)


lemma accSU2_invariant (f : permGroup n) (S : (SMνCharges n).charges)  :
    accSU2 (repCharges f S) = accSU2 S :=
  accSU2_ext
    (by simpa using toSpecies_sum_invariant 1 f S)


lemma accSU3_invariant (f : permGroup n) (S : (SMνCharges n).charges)  :
    accSU3 (repCharges f S) = accSU3 S :=
  accSU3_ext
    (by simpa using toSpecies_sum_invariant 1 f S)

lemma accYY_invariant (f : permGroup n) (S : (SMνCharges n).charges)  :
    accYY (repCharges f S) = accYY S :=
  accYY_ext
    (by simpa using toSpecies_sum_invariant 1 f S)


lemma accQuad_invariant (f : permGroup n) (S : (SMνCharges n).charges)  :
    accQuad (repCharges f S) = accQuad S :=
  accQuad_ext
    (toSpecies_sum_invariant 2 f S)

lemma accCube_invariant (f : permGroup n) (S : (SMνCharges n).charges)  :
    accCube (repCharges f S) = accCube S :=
  accCube_ext
    (by simpa using toSpecies_sum_invariant 3 f S)



end SMRHN
