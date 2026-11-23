# 2D minigame catalog (100)

Designs for PiyoPiyo. Each entry maps to a SpriteKit/SceneKit template registry entry (plan Variant B). Accessibility always falls back to the Choices list.

Registry templates in use:
- `falling_blocks`
- `tap_targets`
- `lane_sort`
- `path_trace`
- `match_pairs`
- `timed_catch`
- `stack_order`
- `dodge_select`
- `orbit_pick_2d`
- `grid_claim`
- `pulse_count`
- `bridge_build`

## 2d-001-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `falling_blocks`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-002-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `tap_targets`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-003-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `lane_sort`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-004-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `path_trace`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-005-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `match_pairs`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-006-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `timed_catch`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-007-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `stack_order`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-008-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `dodge_select`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-009-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `orbit_pick_2d`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-010-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `grid_claim`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-011-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `pulse_count`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-012-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `bridge_build`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-013-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `falling_blocks`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-014-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `tap_targets`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-015-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `lane_sort`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-016-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `path_trace`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-017-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `needs_new_template:2d_variant_1` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 2d-018-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `timed_catch`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-019-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `stack_order`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-020-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `dodge_select`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-021-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `orbit_pick_2d`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-022-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `grid_claim`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-023-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `pulse_count`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-024-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `bridge_build`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-025-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `falling_blocks`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-026-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `tap_targets`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-027-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `lane_sort`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-028-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `path_trace`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-029-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `match_pairs`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-030-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `timed_catch`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-031-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `stack_order`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-032-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `dodge_select`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-033-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `orbit_pick_2d`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-034-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `needs_new_template:2d_variant_2` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 2d-035-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `pulse_count`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-036-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `bridge_build`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-037-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `falling_blocks`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-038-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `tap_targets`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-039-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `lane_sort`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-040-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `path_trace`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-041-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `match_pairs`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-042-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `timed_catch`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-043-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `stack_order`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-044-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `dodge_select`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-045-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `orbit_pick_2d`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-046-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `grid_claim`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-047-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `pulse_count`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-048-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `bridge_build`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-049-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `falling_blocks`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-050-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `tap_targets`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-051-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `needs_new_template:2d_variant_3` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 2d-052-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `path_trace`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-053-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `match_pairs`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-054-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `timed_catch`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-055-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `stack_order`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-056-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `dodge_select`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-057-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `orbit_pick_2d`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-058-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `grid_claim`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-059-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `pulse_count`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-060-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `bridge_build`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-061-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `falling_blocks`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-062-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `tap_targets`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-063-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `lane_sort`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-064-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `path_trace`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-065-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `match_pairs`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-066-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `timed_catch`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-067-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `stack_order`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-068-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `needs_new_template:2d_variant_4` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 2d-069-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `orbit_pick_2d`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-070-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `grid_claim`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-071-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `pulse_count`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-072-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `bridge_build`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-073-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `falling_blocks`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-074-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `tap_targets`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-075-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `lane_sort`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-076-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `path_trace`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-077-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `match_pairs`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-078-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `timed_catch`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-079-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `stack_order`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-080-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `dodge_select`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-081-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `orbit_pick_2d`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-082-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `grid_claim`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-083-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `pulse_count`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-084-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `bridge_build`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-085-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `needs_new_template:2d_variant_5` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 2d-086-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `tap_targets`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-087-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `lane_sort`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-088-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `path_trace`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-089-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `match_pairs`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-090-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `timed_catch`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-091-algorithms
- **Learning objective:** Identify binary search steps in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `stack_order`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'speed': 0.8, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-092-programming
- **Learning objective:** Identify dict key rule in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `dodge_select`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'speed': 0.9, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-093-operating
- **Learning objective:** Identify critical section in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `orbit_pick_2d`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'speed': 1.0, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-094-databases
- **Learning objective:** Identify phantom in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `grid_claim`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'speed': 1.1, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-095-distributed
- **Learning objective:** Identify heartbeat in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `pulse_count`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-096-algorithms
- **Learning objective:** Identify Dijkstra need in a 2D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `bridge_build`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'speed': 0.8, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-097-programming
- **Learning objective:** Identify tuple immutability in a 2D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `falling_blocks`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'speed': 0.9, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-098-operating
- **Learning objective:** Identify syscall in a 2D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `tap_targets`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'speed': 1.0, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-099-databases
- **Learning objective:** Identify FK in a 2D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `lane_sort`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'speed': 1.1, 'lanes': 3}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 2d-100-distributed
- **Learning objective:** Identify log match in a 2D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `path_trace`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'speed': 1.2000000000000002, 'lanes': 4}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

