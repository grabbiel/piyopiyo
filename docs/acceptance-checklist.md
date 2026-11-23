# Further usability checks

Build: 1.0.0 (3). The owner accepted the already-verified device coverage; this broader checklist does not reopen that decision. Record the device model, OS, tester, date, and result. Leave untested items unmarked. The App Store IPA must first be distributed through TestFlight; the notarized Mac ZIP can be opened directly.

- [ ] On iPhone SE (3rd generation), iPad mini, and MacBook Air, open all 18 Library format previews and eight learning modes without crashes. Record whether testing used physical hardware or a simulator.
- [ ] With VoiceOver, navigate the sidebar/tabs, answer a question, hear feedback, and move to the next question. Confirm every control has a useful name and logical focus order.
- [ ] At the largest accessibility text size, verify question text, inputs, feedback, and submit/next controls remain reachable without overlap or truncation that hides meaning.
- [ ] Complete matching, ordering, categorization, visual, drag, audio, 2D, and 3D items using their accessible alternatives. Use keyboard navigation on Mac.
- [ ] Begin a full quiz, enable offline practice, answer questions, close/reopen the app, and finish. Reconnect, sign in, enable AI only if written-answer upload is wanted, and confirm every answer syncs once with stable scores.
- [ ] Resume a timed session after backgrounding and after its deadline. Confirm time does not reset and already-saved answers survive later upload.
- [ ] Join a room from two accounts. Submit concurrently, reconnect one device, and confirm membership, score, and collaborative answers remain consistent.
- [ ] On a disposable account, interrupt deletion, resume it, and verify progress and room contributions disappear while another learner's data remains. Use a disposable Apple account for the real Apple revocation round trip, never the owner's active learning account.
- [ ] Review the 45 authored exercises and representative variants from each parameterized template for correctness, explanations, accessibility, and source attribution.

Automated evidence already recorded: 54 format snapshots, 18 Swift tests per platform, 40 backend/infrastructure tests, 50 human-reviewed grading cases, and live AWS integration. Do not relabel those as manual checks.
