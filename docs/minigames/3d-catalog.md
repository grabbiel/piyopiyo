# 3D minigame catalog (100)

Designs for PiyoPiyo. Each entry maps to a SpriteKit/SceneKit template registry entry (plan Variant B). Accessibility always falls back to the Choices list.

Registry templates in use:
- `system_architecture`
- `orbit_select`
- `stack_layers`
- `room_inspect`
- `graph_nodes`
- `pipeline_flow`
- `rack_pick`
- `molecule_bonds`
- `city_blocks`
- `server_farm`
- `packet_path`
- `cache_tiers`

## 3d-001-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `system_architecture`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n)': 'box', 'O(log n)': 'cylinder', 'O(n log n)': 'box', 'O(1)': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-002-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `orbit_select`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'roles': {'hashable': 'cylinder', 'dict': 'box', 'set': 'box', 'list': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-003-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `stack_layers`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'roles': {'boot only': 'box', 'comments': 'box', 'long functions': 'box', 'shared state': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-004-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `room_inspect`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'packet loss': 'box', 'dirty value': 'box', 'new matching rows': 'cylinder', 'syntax error': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-005-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `graph_nodes`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'roles': {'change ID': 'box', 'reset election': 'cylinder', 'empty DB': 'box', 'stop clock': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-006-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `pipeline_flow`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'nonnegative weights': 'cylinder', 'unit weights only': 'box', 'no weights': 'box', 'negative weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-007-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `rack_pick`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'is a list': 'box', 'is a set': 'box', 'can append': 'box', 'cannot assign item': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-008-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `molecule_bonds`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'linker': 'box', 'user library only': 'box', 'kernel entry': 'cylinder', 'compiler pass': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-009-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `city_blocks`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'speed only': 'box', 'referential integrity': 'cylinder', 'UI labels': 'box', 'fonts': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-010-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `server_farm`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'prefix consistency': 'cylinder', 'random append': 'box', 'client clocks': 'box', 'any order': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-011-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `packet_path`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n log n)': 'box', 'O(1)': 'box', 'O(n)': 'box', 'O(log n)': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-012-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `cache_tiers`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'roles': {'set': 'box', 'list': 'box', 'hashable': 'cylinder', 'dict': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-013-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `system_architecture`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'roles': {'long functions': 'box', 'shared state': 'cylinder', 'boot only': 'box', 'comments': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-014-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `orbit_select`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'new matching rows': 'cylinder', 'syntax error': 'box', 'packet loss': 'box', 'dirty value': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-015-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `stack_layers`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'roles': {'empty DB': 'box', 'stop clock': 'box', 'change ID': 'box', 'reset election': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-016-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `room_inspect`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'no weights': 'box', 'negative weights only': 'box', 'nonnegative weights': 'cylinder', 'unit weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-017-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `needs_new_template:3d_variant_1` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'can append': 'box', 'cannot assign item': 'cylinder', 'is a list': 'box', 'is a set': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 3d-018-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `pipeline_flow`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'kernel entry': 'cylinder', 'compiler pass': 'box', 'linker': 'box', 'user library only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-019-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `rack_pick`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'UI labels': 'box', 'fonts': 'box', 'speed only': 'box', 'referential integrity': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-020-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `molecule_bonds`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'client clocks': 'box', 'any order': 'box', 'prefix consistency': 'cylinder', 'random append': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-021-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `city_blocks`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n)': 'box', 'O(log n)': 'cylinder', 'O(n log n)': 'box', 'O(1)': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-022-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `server_farm`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'roles': {'hashable': 'cylinder', 'dict': 'box', 'set': 'box', 'list': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-023-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `packet_path`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'roles': {'boot only': 'box', 'comments': 'box', 'long functions': 'box', 'shared state': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-024-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `cache_tiers`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'packet loss': 'box', 'dirty value': 'box', 'new matching rows': 'cylinder', 'syntax error': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-025-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `system_architecture`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'roles': {'change ID': 'box', 'reset election': 'cylinder', 'empty DB': 'box', 'stop clock': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-026-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `orbit_select`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'nonnegative weights': 'cylinder', 'unit weights only': 'box', 'no weights': 'box', 'negative weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-027-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `stack_layers`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'is a list': 'box', 'is a set': 'box', 'can append': 'box', 'cannot assign item': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-028-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `room_inspect`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'linker': 'box', 'user library only': 'box', 'kernel entry': 'cylinder', 'compiler pass': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-029-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `graph_nodes`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'speed only': 'box', 'referential integrity': 'cylinder', 'UI labels': 'box', 'fonts': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-030-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `pipeline_flow`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'prefix consistency': 'cylinder', 'random append': 'box', 'client clocks': 'box', 'any order': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-031-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `rack_pick`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n log n)': 'box', 'O(1)': 'box', 'O(n)': 'box', 'O(log n)': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-032-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `molecule_bonds`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'roles': {'set': 'box', 'list': 'box', 'hashable': 'cylinder', 'dict': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-033-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `city_blocks`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'roles': {'long functions': 'box', 'shared state': 'cylinder', 'boot only': 'box', 'comments': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-034-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `needs_new_template:3d_variant_2` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'new matching rows': 'cylinder', 'syntax error': 'box', 'packet loss': 'box', 'dirty value': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 3d-035-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `packet_path`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'roles': {'empty DB': 'box', 'stop clock': 'box', 'change ID': 'box', 'reset election': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-036-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `cache_tiers`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'no weights': 'box', 'negative weights only': 'box', 'nonnegative weights': 'cylinder', 'unit weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-037-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `system_architecture`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'can append': 'box', 'cannot assign item': 'cylinder', 'is a list': 'box', 'is a set': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-038-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `orbit_select`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'kernel entry': 'cylinder', 'compiler pass': 'box', 'linker': 'box', 'user library only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-039-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `stack_layers`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'UI labels': 'box', 'fonts': 'box', 'speed only': 'box', 'referential integrity': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-040-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `room_inspect`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'client clocks': 'box', 'any order': 'box', 'prefix consistency': 'cylinder', 'random append': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-041-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `graph_nodes`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n)': 'box', 'O(log n)': 'cylinder', 'O(n log n)': 'box', 'O(1)': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-042-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `pipeline_flow`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'roles': {'hashable': 'cylinder', 'dict': 'box', 'set': 'box', 'list': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-043-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `rack_pick`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'roles': {'boot only': 'box', 'comments': 'box', 'long functions': 'box', 'shared state': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-044-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `molecule_bonds`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'packet loss': 'box', 'dirty value': 'box', 'new matching rows': 'cylinder', 'syntax error': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-045-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `city_blocks`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'roles': {'change ID': 'box', 'reset election': 'cylinder', 'empty DB': 'box', 'stop clock': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-046-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `server_farm`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'nonnegative weights': 'cylinder', 'unit weights only': 'box', 'no weights': 'box', 'negative weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-047-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `packet_path`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'is a list': 'box', 'is a set': 'box', 'can append': 'box', 'cannot assign item': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-048-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `cache_tiers`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'linker': 'box', 'user library only': 'box', 'kernel entry': 'cylinder', 'compiler pass': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-049-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `system_architecture`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'speed only': 'box', 'referential integrity': 'cylinder', 'UI labels': 'box', 'fonts': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-050-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `orbit_select`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'prefix consistency': 'cylinder', 'random append': 'box', 'client clocks': 'box', 'any order': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-051-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `needs_new_template:3d_variant_3` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n log n)': 'box', 'O(1)': 'box', 'O(n)': 'box', 'O(log n)': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 3d-052-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `room_inspect`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'roles': {'set': 'box', 'list': 'box', 'hashable': 'cylinder', 'dict': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-053-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `graph_nodes`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'roles': {'long functions': 'box', 'shared state': 'cylinder', 'boot only': 'box', 'comments': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-054-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `pipeline_flow`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'new matching rows': 'cylinder', 'syntax error': 'box', 'packet loss': 'box', 'dirty value': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-055-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `rack_pick`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'roles': {'empty DB': 'box', 'stop clock': 'box', 'change ID': 'box', 'reset election': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-056-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `molecule_bonds`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'no weights': 'box', 'negative weights only': 'box', 'nonnegative weights': 'cylinder', 'unit weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-057-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `city_blocks`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'can append': 'box', 'cannot assign item': 'cylinder', 'is a list': 'box', 'is a set': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-058-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `server_farm`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'kernel entry': 'cylinder', 'compiler pass': 'box', 'linker': 'box', 'user library only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-059-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `packet_path`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'UI labels': 'box', 'fonts': 'box', 'speed only': 'box', 'referential integrity': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-060-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `cache_tiers`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'client clocks': 'box', 'any order': 'box', 'prefix consistency': 'cylinder', 'random append': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-061-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `system_architecture`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n)': 'box', 'O(log n)': 'cylinder', 'O(n log n)': 'box', 'O(1)': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-062-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `orbit_select`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'roles': {'hashable': 'cylinder', 'dict': 'box', 'set': 'box', 'list': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-063-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `stack_layers`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'roles': {'boot only': 'box', 'comments': 'box', 'long functions': 'box', 'shared state': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-064-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `room_inspect`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'packet loss': 'box', 'dirty value': 'box', 'new matching rows': 'cylinder', 'syntax error': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-065-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `graph_nodes`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'roles': {'change ID': 'box', 'reset election': 'cylinder', 'empty DB': 'box', 'stop clock': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-066-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `pipeline_flow`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'nonnegative weights': 'cylinder', 'unit weights only': 'box', 'no weights': 'box', 'negative weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-067-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `rack_pick`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'is a list': 'box', 'is a set': 'box', 'can append': 'box', 'cannot assign item': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-068-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `needs_new_template:3d_variant_4` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'linker': 'box', 'user library only': 'box', 'kernel entry': 'cylinder', 'compiler pass': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 3d-069-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `city_blocks`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'speed only': 'box', 'referential integrity': 'cylinder', 'UI labels': 'box', 'fonts': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-070-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `server_farm`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'prefix consistency': 'cylinder', 'random append': 'box', 'client clocks': 'box', 'any order': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-071-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `packet_path`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n log n)': 'box', 'O(1)': 'box', 'O(n)': 'box', 'O(log n)': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-072-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `cache_tiers`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'roles': {'set': 'box', 'list': 'box', 'hashable': 'cylinder', 'dict': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-073-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `system_architecture`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'roles': {'long functions': 'box', 'shared state': 'cylinder', 'boot only': 'box', 'comments': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-074-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `orbit_select`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'new matching rows': 'cylinder', 'syntax error': 'box', 'packet loss': 'box', 'dirty value': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-075-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `stack_layers`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'roles': {'empty DB': 'box', 'stop clock': 'box', 'change ID': 'box', 'reset election': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-076-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `room_inspect`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'no weights': 'box', 'negative weights only': 'box', 'nonnegative weights': 'cylinder', 'unit weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-077-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `graph_nodes`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'can append': 'box', 'cannot assign item': 'cylinder', 'is a list': 'box', 'is a set': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-078-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `pipeline_flow`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'kernel entry': 'cylinder', 'compiler pass': 'box', 'linker': 'box', 'user library only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-079-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `rack_pick`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'UI labels': 'box', 'fonts': 'box', 'speed only': 'box', 'referential integrity': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-080-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `molecule_bonds`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'client clocks': 'box', 'any order': 'box', 'prefix consistency': 'cylinder', 'random append': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-081-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `city_blocks`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n)', 'O(log n)', 'O(n log n)', 'O(1)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n)': 'box', 'O(log n)': 'cylinder', 'O(n log n)': 'box', 'O(1)': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-082-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `server_farm`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'hashable', 'dict', 'set', 'list'
- **Correct:** `hashable`
- **Params:** `{'roles': {'hashable': 'cylinder', 'dict': 'box', 'set': 'box', 'list': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-083-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `packet_path`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'boot only', 'comments', 'long functions', 'shared state'
- **Correct:** `shared state`
- **Params:** `{'roles': {'boot only': 'box', 'comments': 'box', 'long functions': 'box', 'shared state': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-084-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `cache_tiers`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'packet loss', 'dirty value', 'new matching rows', 'syntax error'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'packet loss': 'box', 'dirty value': 'box', 'new matching rows': 'cylinder', 'syntax error': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-085-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `needs_new_template:3d_variant_5` (new Swift work: small scene variant)
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'change ID', 'reset election', 'empty DB', 'stop clock'
- **Correct:** `reset election`
- **Params:** `{'roles': {'change ID': 'box', 'reset election': 'cylinder', 'empty DB': 'box', 'stop clock': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** ~0.5 day scene variant

## 3d-086-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `orbit_select`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'nonnegative weights', 'unit weights only', 'no weights', 'negative weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'nonnegative weights': 'cylinder', 'unit weights only': 'box', 'no weights': 'box', 'negative weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-087-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `stack_layers`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'is a list', 'is a set', 'can append', 'cannot assign item'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'is a list': 'box', 'is a set': 'box', 'can append': 'box', 'cannot assign item': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-088-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `room_inspect`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'linker', 'user library only', 'kernel entry', 'compiler pass'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'linker': 'box', 'user library only': 'box', 'kernel entry': 'cylinder', 'compiler pass': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-089-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `graph_nodes`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'speed only', 'referential integrity', 'UI labels', 'fonts'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'speed only': 'box', 'referential integrity': 'cylinder', 'UI labels': 'box', 'fonts': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-090-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `pipeline_flow`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'prefix consistency', 'random append', 'client clocks', 'any order'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'prefix consistency': 'cylinder', 'random append': 'box', 'client clocks': 'box', 'any order': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-091-algorithms
- **Learning objective:** Identify binary search steps in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `rack_pick`
- **Prompt sketch:** Select the option that matches: binary search steps.
- **Options:** 'O(n log n)', 'O(1)', 'O(n)', 'O(log n)'
- **Correct:** `O(log n)`
- **Params:** `{'roles': {'O(n log n)': 'box', 'O(1)': 'box', 'O(n)': 'box', 'O(log n)': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-092-programming
- **Learning objective:** Identify dict key rule in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `molecule_bonds`
- **Prompt sketch:** Select the option that matches: dict key rule.
- **Options:** 'set', 'list', 'hashable', 'dict'
- **Correct:** `hashable`
- **Params:** `{'roles': {'set': 'box', 'list': 'box', 'hashable': 'cylinder', 'dict': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-093-operating
- **Learning objective:** Identify critical section in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `city_blocks`
- **Prompt sketch:** Select the option that matches: critical section.
- **Options:** 'long functions', 'shared state', 'boot only', 'comments'
- **Correct:** `shared state`
- **Params:** `{'roles': {'long functions': 'box', 'shared state': 'cylinder', 'boot only': 'box', 'comments': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-094-databases
- **Learning objective:** Identify phantom in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `server_farm`
- **Prompt sketch:** Select the option that matches: phantom.
- **Options:** 'new matching rows', 'syntax error', 'packet loss', 'dirty value'
- **Correct:** `new matching rows`
- **Params:** `{'roles': {'new matching rows': 'cylinder', 'syntax error': 'box', 'packet loss': 'box', 'dirty value': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-095-distributed
- **Learning objective:** Identify heartbeat in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `packet_path`
- **Prompt sketch:** Select the option that matches: heartbeat.
- **Options:** 'empty DB', 'stop clock', 'change ID', 'reset election'
- **Correct:** `reset election`
- **Params:** `{'roles': {'empty DB': 'box', 'stop clock': 'box', 'change ID': 'box', 'reset election': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-096-algorithms
- **Learning objective:** Identify Dijkstra need in a 3D interaction.
- **Topic:** Algorithms
- **Source id:** mit-algorithms
- **Template:** `cache_tiers`
- **Prompt sketch:** Select the option that matches: Dijkstra need.
- **Options:** 'no weights', 'negative weights only', 'nonnegative weights', 'unit weights only'
- **Correct:** `nonnegative weights`
- **Params:** `{'roles': {'no weights': 'box', 'negative weights only': 'box', 'nonnegative weights': 'cylinder', 'unit weights only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-097-programming
- **Learning objective:** Identify tuple immutability in a 3D interaction.
- **Topic:** Programming
- **Source id:** python
- **Template:** `system_architecture`
- **Prompt sketch:** Select the option that matches: tuple immutability.
- **Options:** 'can append', 'cannot assign item', 'is a list', 'is a set'
- **Correct:** `cannot assign item`
- **Params:** `{'roles': {'can append': 'box', 'cannot assign item': 'cylinder', 'is a list': 'box', 'is a set': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-098-operating
- **Learning objective:** Identify syscall in a 3D interaction.
- **Topic:** Operating systems
- **Source id:** ostep
- **Template:** `orbit_select`
- **Prompt sketch:** Select the option that matches: syscall.
- **Options:** 'kernel entry', 'compiler pass', 'linker', 'user library only'
- **Correct:** `kernel entry`
- **Params:** `{'roles': {'kernel entry': 'cylinder', 'compiler pass': 'box', 'linker': 'box', 'user library only': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-099-databases
- **Learning objective:** Identify FK in a 3D interaction.
- **Topic:** Databases
- **Source id:** postgres
- **Template:** `stack_layers`
- **Prompt sketch:** Select the option that matches: FK.
- **Options:** 'UI labels', 'fonts', 'speed only', 'referential integrity'
- **Correct:** `referential integrity`
- **Params:** `{'roles': {'UI labels': 'box', 'fonts': 'box', 'speed only': 'box', 'referential integrity': 'cylinder'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

## 3d-100-distributed
- **Learning objective:** Identify log match in a 3D interaction.
- **Topic:** Distributed systems
- **Source id:** raft
- **Template:** `room_inspect`
- **Prompt sketch:** Select the option that matches: log match.
- **Options:** 'client clocks', 'any order', 'prefix consistency', 'random append'
- **Correct:** `prefix consistency`
- **Params:** `{'roles': {'client clocks': 'box', 'any order': 'box', 'prefix consistency': 'cylinder', 'random append': 'box'}, 'orbit': True}`
- **Accessibility:** Identical Choices list under the scene; VoiceOver uses option labels.
- **New Swift estimate:** none (reuse registry)

