#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

DOMAIN="${1:-}"
ERROR_PATTERN='SCRIPT ERROR:|ERROR: Failed to load script|ERROR: Failed to create an autoload|ERROR: Failed to instantiate an autoload|ERROR: FATAL:|handle_crash: Program crashed'

run_checked() {
  local label="$1"
  shift
  local log_file
  log_file="$(mktemp)"
  echo "==> ${label}"
  set +e
  "$@" 2>&1 | tee "$log_file"
  local command_status=${PIPESTATUS[0]}
  set -e
  if [[ $command_status -ne 0 ]]; then
    echo "Godot a quitté avec le code ${command_status} pendant: ${label}" >&2
    rm -f "$log_file"
    return "$command_status"
  fi
  if grep -E "$ERROR_PATTERN" "$log_file" >/dev/null; then
    echo "Des erreurs GDScript/autoload ont été détectées pendant: ${label}" >&2
    grep -E "$ERROR_PATTERN" "$log_file" >&2 || true
    rm -f "$log_file"
    return 1
  fi
  rm -f "$log_file"
}

scene() {
  local timeout_s="$1"
  local label="$2"
  local path="$3"
  if [[ "$timeout_s" == "0" ]]; then
    run_checked "$label" godot --headless --path . "$path"
  else
    run_checked "$label" timeout "${timeout_s}s" godot --headless --path . "$path"
  fi
}

run_checked "Import strict du projet" godot --headless --path . --import --quit

case "$DOMAIN" in
  core-world)
    scene 120 "Expédition procédurale jouable" res://scenes/tests/dungeon_playable_pipeline_smoke.tscn
    scene 540 "Parcours Premier Accord par les commandes joueur" res://scenes/tests/first_accord_playthrough_smoke.tscn
    run_checked "Premier Accord sur 24 graines indépendantes" timeout 540s godot --headless --path . res://scenes/tests/first_accord_playthrough_smoke.tscn -- --policies=focus,head,mixed --seed_start=1001 --seed_count=24
    scene 0 "Smoke test noyau" res://scenes/tests/core_smoke.tscn
    scene 0 "Psychologie" res://scenes/tests/psychology_smoke.tscn
    scene 0 "Relations" res://scenes/tests/relationship_smoke.tscn
    scene 0 "Mémoire des décisions" res://scenes/tests/decision_memory_smoke.tscn
    scene 0 "Mémoire de terrain" res://scenes/tests/field_memory_smoke.tscn
    scene 0 "Monde réactif" res://scenes/tests/field_encounter_smoke.tscn
    scene 0 "Sanctuaire vivant" res://scenes/tests/community_network_smoke.tscn
    scene 0 "Croisements systémiques" res://scenes/tests/systemic_cross_smoke.tscn
    scene 0 "Croisements narratifs" res://scenes/tests/systemic_cross_narrative_smoke.tscn
    scene 0 "Conséquences différées" res://scenes/tests/systemic_cross_afterlife_smoke.tscn
    scene 0 "Relations des Sept" res://scenes/tests/legendary_seven_relationship_smoke.tscn
    scene 60 "Hall des Descendants" res://scenes/tests/descendants_hall_smoke.tscn
    scene 60 "Bâtiments du Sanctuaire" res://scenes/tests/sanctuary_buildings_smoke.tscn
    ;;
  audiovisual)
    scene 0 "Narration" res://scenes/tests/narrative_library_smoke.tscn
    scene 0 "Musique" res://scenes/tests/music_library_smoke.tscn
    scene 0 "Bruitages" res://scenes/tests/sfx_library_smoke.tscn
    scene 0 "Audio adaptatif" res://scenes/tests/audio_director_smoke.tscn
    scene 0 "Entraînement musical adaptatif" res://scenes/tests/adaptive_music_smoke.tscn
    scene 0 "Orchestration verticale" res://scenes/tests/layered_music_smoke.tscn
    scene 0 "Audio runtime" res://scenes/tests/audio_runtime_smoke.tscn
    scene 0 "Audio narratif" res://scenes/tests/narrative_audio_smoke.tscn
    scene 0 "Dialogues réactifs" res://scenes/tests/dialogue_director_smoke.tscn
    scene 0 "Voix synthétiques" res://scenes/tests/voice_runtime_smoke.tscn
    scene 0 "Mise en scène cinématique" res://scenes/tests/cinematic_direction_smoke.tscn
    scene 0 "Corps" res://scenes/tests/body_state_smoke.tscn
    scene 0 "Animation visible" res://scenes/tests/body_state_visual_smoke.tscn
    scene 0 "Mouvements" res://scenes/tests/movement_registry_smoke.tscn
    scene 90 "Direction artistique canonique v41" res://scenes/tests/canonical_art_v41_smoke.tscn
    scene 90 "Corps visuel systémique v42" res://scenes/tests/body_visual_v42_smoke.tscn
    ;;
  runtime)
    scene 0 "HUD intelligent" res://scenes/tests/hud_director_smoke.tscn
    scene 0 "Vertical slice visuel" res://scenes/tests/visual_vertical_slice_smoke.tscn
    scene 0 "Vertical slice runtime" res://scenes/tests/visual_slice_runtime_smoke.tscn
    scene 0 "Parcours campagne" res://scenes/tests/campaign_e2e_smoke.tscn
    scene 0 "Opérations joueur" res://scenes/tests/runtime_player_smoke.tscn
    scene 0 "Première Descente" res://scenes/tests/first_descent_smoke.tscn
    scene 60 "Donjon physique" res://scenes/tests/physical_dungeon_smoke.tscn
    scene 60 "Blockout 3D" res://scenes/tests/first_veil_proxy_smoke.tscn
    scene 60 "Guidage des cendres" res://scenes/tests/ash_guidance_smoke.tscn
    ;;
  veilleurs)
    run_checked "Payoffs des afflictions" timeout 60s godot --headless --path . --script scripts/tests/veilleurs_affliction_synergy_runtime_test.gd
    scene 60 "Contraintes corporelles des actions" res://scenes/tests/veilleurs_body_action_contract_smoke.tscn
    run_checked "Blessures localisées séparées" timeout 60s godot --headless --path . --script scripts/tests/veilleurs_localized_injury_layer_test.gd
    scene 60 "Contrat dix afflictions" res://scenes/tests/veilleurs_afflictions_contract_test.tscn
    scene 60 "IA ennemie explicable" res://scenes/tests/veilleurs_explainable_enemy_ai_test.tscn
    scene 60 "Procs équipement et afflictions" res://scenes/tests/veilleurs_equipment_affliction_proc_test.tscn
    scene 60 "Contrat résolveurs de combat" res://scenes/tests/veilleurs_combat_resolvers_contract_test.tscn
    scene 60 "Autorité du ciblage anatomique" res://scenes/tests/veilleurs_target_resolver_authority_test.tscn
    scene 60 "Compaction formation ennemie" res://scenes/tests/enemy_formation_compaction_contract_test.tscn
    scene 60 "Fallback ennemi canonique" res://scenes/tests/veilleurs_enemy_canonical_fallback_test.tscn
    scene 180 "Architecture procédurale complète" res://scenes/tests/dungeon_architecture_pipeline_smoke.tscn
    scene 60 "Modules physiques Premier Accord" res://scenes/tests/first_accord_module_blockout_smoke.tscn
    scene 120 "Combat canonique depuis le donjon physique" res://scenes/tests/first_accord_physical_combat_smoke.tscn
    scene 120 "Passages secrets du donjon physique" res://scenes/tests/first_accord_physical_passages_smoke.tscn
    scene 120 "Secrets et raccourcis physiques" res://scenes/tests/first_accord_physical_interactions_smoke.tscn
    scene 120 "Résultat et Rémanence du combat physique" res://scenes/tests/first_accord_aftermath_smoke.tscn
    scene 120 "Parcours physique combat et extraction" res://scenes/tests/first_accord_physical_journey_smoke.tscn
    run_checked "Parcours physique complet jusqu'au Gardien (graine 102)" timeout 120s godot --headless --path . --scene res://scenes/tests/first_accord_physical_journey_smoke.tscn -- --full --seed=102
    run_checked "Parcours physique complet jusqu'au Gardien (graine 103)" timeout 120s godot --headless --path . --scene res://scenes/tests/first_accord_physical_journey_smoke.tscn -- --full --seed=103
    run_checked "Extraction physique et retour au Sanctuaire" timeout 120s godot --headless --path . --script res://scripts/tests/first_accord_extraction_route_smoke.gd
    scene 60 "Pipeline rencontres contraintes" res://scenes/tests/dungeon_encounter_pipeline_smoke.tscn
    scene 60 "Pipeline génération graines et modules" res://scenes/tests/dungeon_generation_pipeline_smoke.tscn
    scene 60 "Graphe hybride connecté" res://scenes/tests/hybrid_graph_smoke.tscn
    scene 60 "Premier Accord 1000 graines" res://scenes/tests/first_accord_hybrid_seed_test.tscn
    scene 60 "Premier Accord vestibule physique" res://scenes/tests/first_accord_entry_physical_smoke.tscn
    scene 0 "Les Veilleurs VS001" res://scenes/tests/veilleurs_vs001_smoke.tscn
    scene 60 "Les Veilleurs VS001 physique" res://scenes/tests/veilleurs_vs001_physical_smoke.tscn
    scene 90 "Les Veilleurs VS001 jouable" res://scenes/tests/veilleurs_vs001_playable_smoke.tscn
    scene 90 "Les Veilleurs VS001 persistance" res://scenes/tests/veilleurs_vs001_persistence_ui_smoke.tscn
    scene 90 "Les Veilleurs canon" res://scenes/tests/veilleurs_canonical_skills_corpses_smoke.tscn
    scene 90 "Entaille, Anatomie et Suture" res://scenes/tests/veilleurs_entaille_anatomie_suture_smoke.tscn
    scene 90 "Réactions cliniques" res://scenes/tests/veilleurs_clinical_reactions_smoke.tscn
    scene 90 "Hémocorde" res://scenes/tests/veilleurs_hemocorde_smoke.tscn
    scene 90 "Hémocorde réactions" res://scenes/tests/veilleurs_hemocorde_reactions_smoke.tscn
    ;;
  ui-qa)
    scene 90 "Parcours UI joueur" res://scenes/tests/ui_player_journey_smoke.tscn
    scene 90 "Interface canonique Les Veilleurs" res://scenes/tests/canonical_ui_smoke.tscn
    scene 90 "Finition UX canonique" res://scenes/tests/canonical_ux_smoke.tscn
    scene 90 "Mobile tactile" res://scenes/tests/mobile_touch_smoke.tscn
    scene 90 "Salle QA intégrée" res://scenes/tests/qa_validation_room_smoke.tscn
    ;;
  *)
    echo "Usage: $0 {core-world|audiovisual|runtime|veilleurs|ui-qa}" >&2
    exit 2
    ;;
esac

echo "GODOT_CI_DOMAIN_OK:${DOMAIN}"
