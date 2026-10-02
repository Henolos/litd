create index if not exists concept_relations_object_idx
  on knowledge.concept_relations(space_id, object_concept_id);

create index if not exists evidence_registry_source_idx
  on knowledge.evidence_registry(space_id, source_id);

create index if not exists knowledge_item_concepts_concept_idx
  on knowledge.knowledge_item_concepts(space_id, concept_id);

create index if not exists knowledge_items_superseded_by_idx
  on knowledge.knowledge_items(space_id, superseded_by_id);

create index if not exists knowledge_relations_object_idx
  on knowledge.knowledge_relations(space_id, object_item_id);

create index if not exists provenance_nodes_parent_idx
  on knowledge.provenance_nodes(space_id, parent_node_id);
