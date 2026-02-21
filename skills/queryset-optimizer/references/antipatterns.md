# QuerySet Optimization Antipatterns

Use these rules for deterministic QuerySet performance audits.

For each rule:

1. Run the search command from the Django backend root.
2. Validate the candidate manually.
3. Record only confirmed findings.

## QRY-01: N+1 relation access inside loops (High)

- **Problem**: Iterating through objects and accessing related fields triggers one query per row.
- **Search**:

```bash
rg -n "for .* in .*:" .
```

- **Validate**:
  - Loop body accesses related fields or managers (`obj.user.email`, `obj.profile`, `obj.tags.all()`).
  - Source queryset does not include `select_related` or `prefetch_related` for those relations.
- **Fix**:
  - Add `select_related(...)` for FK/OneToOne relations.
  - Add `prefetch_related(...)` for reverse or many-to-many relations.

## QRY-02: SerializerMethodField executes ORM per object (High)

- **Problem**: `SerializerMethodField` methods execute DB queries for each serialized row.
- **Search**:

```bash
rg -n "SerializerMethodField|def get_[a-zA-Z0-9_]+\(self, obj\)" .
```

- **Validate**:
  - Method body contains ORM calls (`Model.objects...`, `obj.related_set...`, aggregates).
  - Method is used in list endpoints or large payload paths.
- **Fix**:
  - Move work into queryset annotations/subqueries.
  - Prefetch required relations in the view queryset.

## QRY-03: Missing select_related on FK/OneToOne paths (Medium)

- **Problem**: Single-valued related objects are accessed repeatedly without eager loading.
- **Search**:

```bash
rg -n "objects\.(all|filter|exclude|get|order_by|annotate|select_for_update)\(" .
```

- **Validate**:
  - Returned model instances read FK/OneToOne fields downstream.
  - Queryset chain does not include `select_related(...)`.
- **Fix**:
  - Add `select_related("relation_name")` close to queryset construction.

## QRY-04: Missing prefetch_related on reverse/M2M paths (Medium)

- **Problem**: Reverse relations or M2M collections are fetched repeatedly.
- **Search**:

```bash
rg -n "\.all\(\)|\.prefetch_related\(" .
```

- **Validate**:
  - Code iterates related managers (`obj.items.all()`, `obj.tags.all()`).
  - Queryset serving those objects lacks matching `prefetch_related(...)`.
- **Fix**:
  - Add `prefetch_related(...)` or `Prefetch(...)` with filtered child querysets.

## QRY-05: Per-row write patterns instead of bulk operations (Medium)

- **Problem**: Calling `.save()` or `.create()` in loops causes unnecessary round trips.
- **Search**:

```bash
rg -nU "for .* in .*:\n(?:\s+.*\n){0,8}\s+.*\.(save|create)\(" .
```

- **Validate**:
  - Write operation runs once per loop item.
  - No strict per-row side effects require that pattern.
- **Fix**:
  - Use `bulk_create`, `bulk_update`, `update`, or batched writes.

## QRY-06: Repeated count/exists calls in hot loops (Medium)

- **Problem**: `.count()` and `.exists()` inside iterative paths execute repeated DB checks.
- **Search**:

```bash
rg -n "\.(count|exists)\(" .
```

- **Validate**:
  - Calls happen inside loops, serializer methods, or repeated utility functions.
- **Fix**:
  - Precompute counts, annotate once, or restructure logic to avoid repeated checks.

## QRY-07: Full-row fetch where partial fields would work (Low)

- **Problem**: Query pulls full model rows when response uses only a few columns.
- **Search**:

```bash
rg -n "objects\.(all|filter|exclude|order_by)\(" .
```

- **Validate**:
  - Downstream only reads a small subset of fields.
  - Path processes many rows or wide tables.
- **Fix**:
  - Use `values`, `values_list`, `only`, or `defer` where appropriate.

## QRY-08: Likely missing indexes for filter/order fields (High)

- **Problem**: Frequent filter/order patterns target fields without supporting indexes.
- **Search**:

```bash
rg -n "\.(filter|exclude|get|order_by)\(" .
rg -n "db_index=True|indexes\s*=|Index\(|UniqueConstraint\(|unique=True" .
```

- **Validate**:
  - High-frequency query fields are not indexed in model metadata or migrations.
  - Query plans or production behavior indicate scans/sorts.
- **Fix**:
  - Add `db_index=True` or `Meta.indexes` with composite index order matching access pattern.

## QRY-09: Deep offset pagination on large datasets (Low)

- **Problem**: Large offsets become slower as page depth increases.
- **Search**:

```bash
rg -n "Paginator\(|\boffset\b|\bpage\(" .
```

- **Validate**:
  - Endpoint supports deep page navigation with large tables.
- **Fix**:
  - Use keyset/cursor pagination for high-volume read paths.

## QRY-10: Duplicate queryset evaluation in same path (Low)

- **Problem**: The same queryset object is evaluated multiple times.
- **Search**:

```bash
rg -n "\blist\(|\blen\(|\bbool\(|\bcount\(|\bexists\(" .
```

- **Validate**:
  - Same queryset variable is consumed multiple times in one function.
- **Fix**:
  - Evaluate once and reuse the result when memory budget allows.

## Optional validation helpers

Use these when a candidate query can be reproduced in shell:

```python
print(str(qs.query))
print(qs.explain(analyze=False))
```

Prefer `analyze=False` unless the query path is safe and non-mutating.
