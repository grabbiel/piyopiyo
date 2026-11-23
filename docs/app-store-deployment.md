# App Store Connect deployment

PiyoPiyo **1.1.0 (5)** was submitted to Apple on November 23, 2026 at 12:21 Lima time. The API and owner's Firefox session both confirm **Waiting for Review**. Public release is **manual**; Apple approval and public availability have not occurred.

## Store record

- [PiyoPiyo: Computer Science in App Store Connect](https://appstoreconnect.apple.com/apps/6838389242/distribution), app ID `6838389242`.
- Bundle `app.piyopiyo.iphone`, SKU `piyopiyo-universal-1`, English (US), Education, universal iPhone/iPad binary.
- Version ID `e813df90-c0fb-491d-9a6a-db1ca05cf8eb`; build ID `0b55b0fb-3619-4419-b6eb-11dbbd6175ac`, processing `VALID`.
- Review submission `ffd960b6-3a19-45cd-96d4-df6c282e9034`, submitted at `2026-11-23T17:21:03.511Z`.
- Free pricing; initial availability is United States and Peru. Automatic expansion into new territories is off. The iOS binary is not offered on Apple silicon Macs or Vision Pro; the separately tested native Mac app remains available locally.

The owner authorized the updated Paid Apps Agreement and completed Apple's verification. The agreement was observed Active before creating the app. The owner also explicitly authorized sending the existing review contact details and a dedicated ordinary learner demo account to Apple's private review fields. Those values remain in ignored, private files and are not part of the public listing or this runbook.

## Completed listing

The saved listing includes its description, subtitle, keywords, promotional text, copyright, attached build, private review details, and actual iPhone and iPad home screenshots. The listed pages are [home](https://piyopiyo.grabbiel.com), [support](https://piyopiyo.grabbiel.com/support), and [privacy](https://piyopiyo.grabbiel.com/privacy).

Apple's age questionnaire calculated **4+**, with regional exceptions. It discloses private-room user-generated content and messaging, and infrequent contests for optional study-room scores. It does not designate the app as Made for Kids. Third-party content rights are declared for referenced learning material.

Published privacy disclosures include name, email, user ID, other user content, and product interaction linked to an account for app functionality. Product interaction also covers optional aggregate analytics. Other diagnostic data is unlinked and used for app functionality. None is used for advertising tracking. The app declares no non-exempt encryption.

The existing account-wide EU Digital Services Act verification is Rejected; it was not modified. EU countries and China mainland are outside this initial availability. No unverified regional filings were submitted.

## Evidence and follow-up

`tests/app-store-submission.json` records the final API states and submission timestamp. `tests/knowledge-release-artifacts.json` records IPA and Mac ZIP checksums. `artifacts/app-store/1.1.0/submitted-for-review.jpg` shows Apple's confirmation. `docs/app-store-metadata.json` holds non-secret listing copy and configuration.

Build 4 was rejected during upload because its orientation metadata was missing. Build 5 includes all four supported orientations and passed Apple processing. The uploaded screenshots came from build 4; build 5 changes orientation metadata without changing their depicted interface.

Respond to Apple's review outcome when it arrives. If approved, manual release is still a separate step. Keep the dedicated review learner available until review no longer needs it. No external TestFlight invitations were sent. Known product limits, including room moderation and accessibility coverage, remain documented in `docs/release-status.md`.
