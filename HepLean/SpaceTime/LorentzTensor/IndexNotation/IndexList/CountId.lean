/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import HepLean.SpaceTime.LorentzTensor.IndexNotation.IndexList.Duals
/-!

# Counting ids


-/


namespace IndexNotation

namespace IndexList

variable {X : Type} [IndexNotation X] [Fintype X] [DecidableEq X]
variable (l l2 l3 : IndexList X)


/-!

## countId

-/

/-- The number of times the id of an index `I` appears in a list of indices `l`. -/
def countId (I : Index X) : ℕ :=
  l.val.countP (fun J => I.id = J.id)

/-!

## Basic properties

-/
@[simp]
lemma countId_append (I : Index X) : (l ++ l2).countId I = l.countId I + l2.countId I := by
  simp [countId]

lemma countId_eq_length_filter (I : Index X) :
    l.countId I = (l.val.filter (fun J => I.id = J.id)).length := by
  simp [countId]
  rw [List.countP_eq_length_filter]

lemma countId_index_neq_zero (i : Fin l.length) : l.countId (l.val.get i) ≠ 0 := by
  rw [countId_eq_length_filter]
  by_contra hn
  rw [List.length_eq_zero] at hn
  have hm : l.val.get i ∈ List.filter (fun J => decide ((l.val.get i).id = J.id)) l.val := by
    simpa using List.getElem_mem l.val i.1 i.isLt
  rw [hn] at hm
  simp at hm

lemma countId_append_symm (I : Index X) : (l ++ l2).countId I = (l2 ++ l).countId I := by
  simp only [countId_append]
  omega

lemma countId_eq_one_append_mem_right_self_eq_one {I : Index X} (hI : I ∈ l2.val)
    (h : (l ++ l2).countId I = 1) : l2.countId I = 1 := by
  simp at h
  have hmem : I ∈ l2.val.filter (fun J => I.id = J.id) := by
    simp [List.mem_filter, decide_True, and_true, hI]
  have h1 : l2.countId I ≠ 0 := by
    rw [countId_eq_length_filter]
    by_contra hn
    rw [@List.length_eq_zero] at hn
    rw [hn] at hmem
    simp at hmem
  omega

lemma countId_eq_one_append_mem_right_other_eq_zero {I : Index X} (hI : I ∈ l2.val)
    (h : (l ++ l2).countId I = 1) : l.countId I = 0 := by
  simp at h
  have hmem : I ∈ l2.val.filter (fun J => I.id = J.id) := by
    simp [List.mem_filter, decide_True, and_true, hI]
  have h1 : l2.countId I ≠ 0 := by
    rw [countId_eq_length_filter]
    by_contra hn
    rw [@List.length_eq_zero] at hn
    rw [hn] at hmem
    simp at hmem
  omega

@[simp]
lemma countId_cons_eq_two {I : Index X} :
    (l.cons I).countId I = 2 ↔ l.countId I = 1 := by
  simp [countId]

lemma countId_congr {I J : Index X} (h : I.id = J.id) : l.countId I = l.countId J := by
  simp [countId, h]

lemma countId_neq_zero_mem (I : Index X) (h : l.countId I ≠ 0) :
    ∃ I', I' ∈ l.val ∧ I.id = I'.id := by
  rw [countId_eq_length_filter] at h
  have h' := List.isEmpty_iff_length_eq_zero.mp.mt h
  simp only at h'
  have h'' := eq_false_of_ne_true h'
  rw [List.isEmpty_false_iff_exists_mem] at h''
  obtain ⟨I', hI'⟩ := h''
  simp only [List.mem_filter, decide_eq_true_eq] at hI'
  exact ⟨I', hI'⟩

lemma countId_mem (I : Index X) (hI : I ∈ l.val) : l.countId I ≠ 0 := by
  rw [countId_eq_length_filter]
  by_contra hn
  rw [List.length_eq_zero] at hn
  have hIme : I ∈ List.filter (fun J => decide (I.id = J.id)) l.val := by
    simp [hI]
  rw [hn] at hIme
  simp at hIme

lemma countId_get_other (i : Fin l.length) : l2.countId (l.val.get i) =
    (List.finRange l2.length).countP (fun j => l.AreDualInOther l2 i j)  := by
  rw [countId_eq_length_filter]
  rw [List.countP_eq_length_filter]
  have hl2 : l2.val = List.map l2.val.get (List.finRange l2.length) := by
    simp only [length, List.finRange_map_get]
  nth_rewrite 1 [hl2]
  rw [List.filter_map, List.length_map]
  apply congrArg
  refine List.filter_congr (fun j _ => ?_)
  simp [AreDualInOther, idMap]

/-! TODO: Replace with mathlib lemma. -/
lemma filter_finRange (i : Fin l.length) : List.filter (fun j => i = j) (List.finRange l.length) = [i] := by
  have h3 : (List.filter (fun j => i = j) (List.finRange l.length)).length = 1 := by
    rw [← List.countP_eq_length_filter]
    trans List.count i (List.finRange l.length)
    · simp [List.count]
      apply List.countP_congr (fun j _ => ?_)
      simp
      exact eq_comm
    · exact List.nodup_iff_count_eq_one.mp (List.nodup_finRange l.length) _ (List.mem_finRange i)
  have h4 : i ∈ List.filter (fun j => i = j) (List.finRange l.length) := by
    simp
  rw [@List.length_eq_one] at h3
  obtain ⟨a, ha⟩ := h3
  rw [ha] at h4
  simp at h4
  subst h4
  exact ha

lemma countId_get (i : Fin l.length) : l.countId (l.val.get i) =
    (List.finRange l.length).countP (fun j => l.AreDualInSelf i j) + 1 := by
  rw [countId_get_other l l]
  have h1 : (List.finRange l.length).countP (fun j => l.AreDualInSelf i j)
      = ((List.finRange l.length).filter (fun j => l.AreDualInOther l i j)).countP
      (fun j => ¬ i = j) := by
    rw [List.countP_filter]
    refine List.countP_congr ?_
    intro j _
    simp [AreDualInSelf, AreDualInOther]
  rw [h1]
  have h1 := List.length_eq_countP_add_countP (fun j => i = j) ((List.finRange l.length).filter (fun j => l.AreDualInOther l i j))
  have h2 : List.countP (fun j => i = j)
      (List.filter (fun j => l.AreDualInOther l i j) (List.finRange l.length)) =
     List.countP (fun j => l.AreDualInOther l i j)
      (List.filter (fun j => i = j) (List.finRange l.length)) := by
    rw [List.countP_filter, List.countP_filter]
    refine List.countP_congr (fun j _ => ?_)
    simpa using And.comm
  have ha := l.filter_finRange
  rw [ha] at h2
  rw [h2] at h1
  rw [List.countP_eq_length_filter, h1, add_comm]
  simp
  simp [List.countP, List.countP.go, AreDualInOther]





/-!

## Duals and countId

-/

lemma countId_gt_zero_of_mem_withDual (i : Fin l.length) (h : i ∈ l.withDual) :
    1 < l.countId (l.val.get i) := by
  rw [countId_get]
  by_contra hn
  simp at hn
  rw [List.countP_eq_length_filter, List.length_eq_zero] at hn
  rw [mem_withDual_iff_exists] at h
  obtain ⟨j, hj⟩ := h
  have hjmem : j ∈ (List.finRange l.length).filter (fun j => decide (l.AreDualInSelf i j)) := by
    simpa using hj
  rw [hn] at hjmem
  simp at hjmem


lemma countId_of_not_mem_withDual (i : Fin l.length)(h : i ∉ l.withDual) :
    l.countId (l.val.get i) = 1 := by
  rw [countId_get]
  simp only [add_left_eq_self]
  rw [List.countP_eq_length_filter]
  simp only [List.length_eq_zero]
  rw [List.filter_eq_nil]
  simp only [List.mem_finRange, decide_eq_true_eq, true_implies]
  rw [mem_withDual_iff_exists] at h
  simpa using h

lemma mem_withDual_iff_countId_gt_one (i : Fin l.length) :
    i ∈ l.withDual ↔ 1 < l.countId (l.val.get i) := by
  refine Iff.intro (fun h => countId_gt_zero_of_mem_withDual l i h) (fun h => ?_)
  by_contra hn
  have hn' := countId_of_not_mem_withDual l i hn
  omega

lemma countId_neq_zero_of_mem_withDualInOther (i : Fin l.length) (h : i ∈ l.withDualInOther l2) :
    l2.countId (l.val.get i) ≠ 0 := by
  rw [mem_withInDualOther_iff_exists] at h
  rw [countId_eq_length_filter]
  by_contra hn
  rw [List.length_eq_zero] at hn
  obtain ⟨j, hj⟩ := h
  have hjmem : l2.val.get j ∈  List.filter (fun J => decide ((l.val.get i).id = J.id)) l2.val := by
    simp
    apply And.intro
    · exact List.getElem_mem l2.val (↑j) j.isLt
    · simpa [AreDualInOther] using hj
  rw [hn] at hjmem
  simp at hjmem

lemma countId_of_not_mem_withDualInOther (i : Fin l.length) (h : i ∉ l.withDualInOther l2) :
    l2.countId (l.val.get i) = 0 := by
  by_contra hn
  rw [countId_eq_length_filter] at hn
  rw [← List.isEmpty_iff_length_eq_zero] at hn
  have hx := eq_false_of_ne_true hn
  rw [List.isEmpty_false_iff_exists_mem] at hx
  obtain ⟨j, hj⟩ := hx
  have hjmem : j ∈ l2.val :=  List.mem_of_mem_filter hj
  have hj' : l2.val.indexOf j < l2.length := List.indexOf_lt_length.mpr hjmem
  have hjid : l2.val.get ⟨l2.val.indexOf j, hj'⟩ = j := List.indexOf_get hj'
  rw [mem_withInDualOther_iff_exists] at h
  simp at h
  have hj' := h ⟨l2.val.indexOf j, hj'⟩
  simp [AreDualInOther, idMap] at hj'
  simp at hj
  simp_all only [List.get_eq_getElem, List.isEmpty_eq_true, List.getElem_indexOf, not_true_eq_false]

lemma mem_withDualInOther_iff_countId_neq_zero (i : Fin l.length) :
    i ∈ l.withDualInOther l2 ↔ l2.countId (l.val.get i) ≠ 0 := by
  refine Iff.intro (fun h => countId_neq_zero_of_mem_withDualInOther l l2 i h)
    (fun h => ?_)
  by_contra hn
  have hn' := countId_of_not_mem_withDualInOther l l2 i hn
  omega

lemma mem_withoutDual_iff_countId_eq_one (i : Fin l.length) :
    i ∈ l.withoutDual ↔ l.countId (l.val.get i) = 1 := by
  refine Iff.intro (fun h => ?_) (fun h => ?_)
  · exact countId_of_not_mem_withDual l i (l.not_mem_withDual_of_mem_withoutDual i h)
  · by_contra hn
    have h : i ∈ l.withDual := by
      simp [withoutDual] at hn
      simpa using Option.ne_none_iff_isSome.mp hn
    rw [mem_withDual_iff_countId_gt_one] at h
    omega

lemma countId_eq_two_of_mem_withUniqueDual (i : Fin l.length) (h : i ∈ l.withUniqueDual) :
    l.countId (l.val.get i) = 2 := by
  rw [countId_get]
  simp
  let i' :=  (l.getDual? i).get (mem_withUniqueDual_isSome l i h)
  have h1 :  [i'] = (List.finRange l.length).filter (fun j => (l.AreDualInSelf i j)) := by
    trans List.filter (fun j => (l.AreDualInSelf i j)) [i']
    · simp [List.filter, i']
    trans List.filter (fun j => (l.AreDualInSelf i j))
      ((List.finRange l.length).filter (fun j => j = i'))
    · apply congrArg
      rw [← filter_finRange l i']
      apply List.filter_congr (fun j _ => ?_)
      simpa using eq_comm
    trans List.filter (fun j => j = i')
      ((List.finRange l.length).filter (fun j => (l.AreDualInSelf i j)))
    · simp
      apply List.filter_congr (fun j _ => ?_)
      exact Bool.and_comm (decide (l.AreDualInSelf i j)) (decide (j = i'))
    · simp
      refine List.filter_congr (fun j _ => ?_)
      simp
      simp [withUniqueDual] at h
      intro hj
      have hj' := h.2 j hj
      apply Option.some_injective
      rw [hj']
      simp [i']
  rw [List.countP_eq_length_filter, ← h1]
  simp

lemma mem_withUniqueDual_of_countId_eq_two (i : Fin l.length)
    (h : l.countId (l.val.get i) = 2) : i ∈ l.withUniqueDual := by
  have hw : i ∈ l.withDual := by
    rw [mem_withDual_iff_countId_gt_one, h]
    exact Nat.one_lt_two
  simp [withUniqueDual]
  apply And.intro ((mem_withDual_iff_isSome l i).mp hw)
  intro j hj
  rw [@countId_get] at h
  simp [List.countP_eq_length_filter] at h
  rw [List.length_eq_one] at h
  obtain ⟨a, ha⟩ := h
  have hj : j ∈ List.filter (fun j => decide (l.AreDualInSelf i j)) (List.finRange l.length) := by
    simpa using hj
  rw [ha] at hj
  simp at hj
  subst hj
  have ht : (l.getDual? i).get ((mem_withDual_iff_isSome l i).mp hw)  ∈
    (List.finRange l.length).filter (fun j => decide (l.AreDualInSelf i j)) := by
      simp
  rw [ha] at ht
  simp at ht
  subst ht
  simp

lemma mem_withUniqueDual_iff_countId_eq_two (i : Fin l.length) :
    i ∈ l.withUniqueDual ↔ l.countId (l.val.get i) = 2 :=
  Iff.intro (fun h => l.countId_eq_two_of_mem_withUniqueDual i h)
    (fun h => l.mem_withUniqueDual_of_countId_eq_two i h)

lemma mem_withUniqueDualInOther_iff_countId_eq_one (i : Fin l.length) :
    i ∈ l.withUniqueDualInOther l2 ↔ l.countId (l.val.get i) = 1 ∧ l2.countId (l.val.get i) = 1 := by
  simp only [withUniqueDualInOther, Finset.mem_filter, Finset.mem_univ, true_and,
    List.get_eq_getElem]
  rw [mem_withDual_iff_countId_gt_one]
  rw [mem_withDualInOther_iff_countId_neq_zero]
  have hneq : l.countId (l.val.get i) ≠ 0 := by exact countId_index_neq_zero l i




end IndexList

end IndexNotation
