# Golden Llama Awards — Data Model

Three custom objects. Minimal fields. Seed data drawn from real 2024 Oscar nominees (rebranded for the demo).

## Objects

### Award_Edition__c
One record per ceremony year.

| Field | Type | Notes |
|---|---|---|
| `Name` | Auto-number or Text | e.g. "2024 Golden Llama Awards" |
| `Year__c` | Number(4,0) | 2024 |
| `Ceremony_Date__c` | Date | Public ceremony date |

### Category__c
One record per award category per edition.

| Field | Type | Notes |
|---|---|---|
| `Name` | Text(80) | e.g. "Best Actress — 2024 Golden Llamas" |
| `Award_Edition__c` | Lookup(Award_Edition__c) | Parent edition |
| `Short_Name__c` | Text(40) | e.g. "Best Actress" (used by the agent) |
| `Description__c` | Text Area | e.g. "Lead female performance in a feature film" |

### Nominee__c
One record per nominee per category. The **core demo object** — this is what the agent reads during lookup.

| Field | Type | Notes |
|---|---|---|
| `Name` | Auto-number | NOM-{0000} |
| `Nominee_Name__c` | Text(80) | e.g. "Carey Mulligan" |
| `Role__c` | Text(120) | e.g. "Felicia Montealegre" |
| `Film__c` | Text(120) | e.g. "Maestro" |
| `Category__c` | Lookup(Category__c) | — |
| `Won__c` | Checkbox | TRUE for the winning nominee |
| `Winner_Statement__c` | Long Text(1000) | Copy the fixed agent reads back, e.g. "Emma Stone took the Llama for Poor Things..." |
| `Nominee_Email__c` | Email | For identity verification |
| `Phone__c` | Phone | — |

## Why 3 objects (not more)

- Separate **Award_Winner__c** object isn't needed. The `Won__c` flag on `Nominee__c` is enough and keeps the lookup single-hop for the agent.
- No separate "wrong lookup" table. **The v2-broken agent's flow returns hardcoded wrong values** directly in the flow XML. This makes the demo diff cleaner (one flow file changes).

## Seed data (10 records)

The seed keeps to the two headline categories most judges will recognise.

### Award_Edition__c (1 record)
| Name | Year | Ceremony Date |
|---|---|---|
| 2024 Golden Llama Awards | 2024 | 2024-03-10 |

### Category__c (2 records)
| Short Name | Edition |
|---|---|
| Best Actress | 2024 Golden Llamas |
| Best Actor | 2024 Golden Llamas |

### Nominee__c — Best Actress (5 records, real 2024 nominees)

| Nominee | Role | Film | Won? |
|---|---|---|---|
| Emma Stone | Bella Baxter | Poor Things | ✅ |
| Annette Bening | Diana Nyad | Nyad | — |
| Lily Gladstone | Mollie Burkhart | Killers of the Flower Moon | — |
| Sandra Hüller | Sandra Voyter | Anatomy of a Fall | — |
| **Carey Mulligan** | Felicia Montealegre | **Maestro** | — ← demo caller |

### Nominee__c — Best Actor (5 records, real 2024 nominees)

| Nominee | Role | Film | Won? |
|---|---|---|---|
| Cillian Murphy | J. Robert Oppenheimer | Oppenheimer | ✅ |
| Bradley Cooper | Leonard Bernstein | Maestro | — |
| Colman Domingo | Bayard Rustin | Rustin | — |
| Paul Giamatti | Paul Hunham | The Holdovers | — |
| Jeffrey Wright | Thelonious "Monk" Ellison | American Fiction | — |

### Nominee_Email / Phone
Populated with fake demo values (`nominee@example.com`, `+44 20 0000 0000`) — not real contact details for these actors.

## How the agent uses this

**v1-polite (and v3-fixed):**
A Flow `Get_Nominee_Record_Correct` queries `Nominee__c` by `Nominee_Name__c`, returns the matched record + related Category + flags whether they won.

**v2-broken:**
A Flow `Get_Nominee_Record_Wrong` has hardcoded Decision branches that return deliberately-wrong `Category__c.Short_Name__c` and `Winner_Name__c` outputs regardless of input. Example branch:

```
if input.nominee_name contains "Mulligan":
  return {
    category_said: "Best Sound Design",
    film_said: "Maestro's Return",
    winner_said: "Cillian Murphy"
  }
elif input.nominee_name contains "Bening":
  return {
    category_said: "Best Costume Design",
    film_said: "Nyad: The Musical",
    winner_said: "Robert Downey Jr."
  }
...
```

The diff Claude Code proposes is "remap the agent's `Get_Nominee_Record` action from the Wrong flow to the Correct flow" + the tone change in the topic instructions.

## Deployment plan

1. Custom objects deployed via metadata (three `.object-meta.xml` files + fields)
2. Seed data inserted via Apex anonymous script (idempotent — uses UPSERT on `Nominee_Name__c` + `Film__c`)
3. Permission set `Golden_Llama_Agent_Access` grants the agent user Read on all three objects + read FLS

## Scout rule check

- New custom objects + fields + record types + permission set → **autonomous per Scout** (confirmed in AGENTS.md §Autonomous)
- No profile changes needed for this (agent user already has broad access from Phase 2 work)
- Nothing deleted
