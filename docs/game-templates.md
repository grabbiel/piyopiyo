# Game templates

A `game_2d` or `game_3d` question can name a template and its parameters with an optional `game` field. A question without `game`, or with a template the app does not know, uses the default renderer for its format.

```json
"game": {"template": "system_architecture", "params": {"roles": {"Database": "cylinder", "API": "box"}}}
```

## Rendered templates

| Template | Format | Params |
| --- | --- | --- |
| `falling_blocks` | `game_2d` | `speed`: fall-speed multiplier, default `1` |
| `system_architecture` | `game_3d` | `roles`: option label to `cylinder` or `box`. Without `roles`, the third option is the cylinder. |

The app ignores any other param keys, such as `lanes` and `orbit` in the catalogs.

## Catalog templates

The minigame catalogs also name these templates. Until they get their own renderers, they fall back to the default renderer for their format.

- 2D: `tap_targets`, `lane_sort`, `path_trace`, `match_pairs`, `timed_catch`, `stack_order`, `dodge_select`, `orbit_pick_2d`, `grid_claim`, `pulse_count`, `bridge_build`
- 3D: `orbit_select`, `stack_layers`, `room_inspect`, `graph_nodes`, `pipeline_flow`, `rack_pick`, `molecule_bonds`, `city_blocks`, `server_farm`, `packet_path`, `cache_tiers`
