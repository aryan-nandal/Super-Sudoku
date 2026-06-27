# Super Sudoku — Build-Ready Product & Engineering Plan

> **One-line thesis:** Good Sudoku's teaching + Wordle/NYT's shareable global daily + Duolingo's streak/learning retention + Chess.com's progression — delivered cross-platform with **zero dark patterns**. That combination is the empty middle of the market and it's defensible.

**Positioning:** A welcoming "Cognitive Gym." Mass-market on the surface (anyone can pick up the Daily in 10 seconds), with a deep learning ramp and a high skill ceiling underneath for those who want it. The identity hook — *"I'm a sharper, more capable person because I play this"* — is the word-of-mouth engine, but the front door is friendly, not elitist.

**Strategic decisions (locked):**
- **Audience:** Mass-market + learning ramp.
- **Monetization:** **Free Daily + ₹9.9 one-time unlock. No ads, ever. No subscription.** The free tier is the viral top-of-funnel; the ₹9.9 unlock is the entire revenue model. (Brand: Ninety Nine Labs; org `com.ninetyninelabs`.)
- **Launch scope:** Lean growth MVP, then layer depth.

---

## 0. North-star & guardrail metrics

Instrument these from day one. We make no monetization change that improves revenue while regressing retention.

- **North star:** D7 retention of daily-puzzle players. (Top-quartile puzzle target: D1 ≥ 40%, D7 ≥ 15%, D30 ≥ 6.5%.)
- **Growth:** % of completers who share a result card; k-factor from shared cards; free→install conversion from shared links.
- **Habit:** % of DAU with a 7+ day streak; daily-puzzle completion rate.
- **Revenue:** free→paid unlock conversion rate (the only revenue lever). Track *alongside* D7 retention and share rate — never optimize the paywall in a way that suppresses sharing.
- **Quality:** crash-free sessions ≥ 99.5%; p95 frame time within budget on a mid-range Android device (e.g. a 3-year-old $200 phone), not just flagships.

---

## 1. Phase 0 — The Puzzle Engine (the foundation everything depends on)

Nothing else is honest without this. The learning path, ELO/puzzle-rating, difficulty labels, and teaching hints **all** require an engine that can solve a puzzle the way a human does and report *which techniques were required*.

**Components:**
1. **Generator** — produces grids with a **guaranteed unique solution** (the integrity gap serious solvers complain about). Reject any puzzle with 0 or >1 solutions.
2. **Human-style solver / grader** — solves using a ranked ladder of human techniques (Naked/Hidden Singles → Locked Candidates → Naked/Hidden Pairs/Triples → X-Wing → Swordfish → XY-Wing → chains/coloring). Records the **hardest technique needed** and a difficulty score derived from technique depth + branching, *not* from clue count.
3. **Difficulty calibration** — map technique profiles to honest, stable difficulty bands. (No mislabeled "Hard" puzzles.)
4. **Technique tagging** — every puzzle is tagged with the set of techniques it exercises, so the learning path can serve "a puzzle that practices X-Wing" on demand.

**Build notes:** This is the hardest component. Spike it first, standalone, with a large test corpus and property-based tests (uniqueness, solvability, grade stability). It can run **fully on-device** (Dart isolate) so puzzles work offline and the app never depends on connectivity to play. Pre-generate and bundle a large library; generate more in the background.

---

## 2. Phase 1 — Lean Growth MVP

This is the first public release. Goal: prove virality and retention with the smallest surface that can.

### 2.1 Core board & input UX (table stakes — do this exceptionally)

This is what players touch every second; it's where incumbents collect bad reviews. Non-negotiables:
- Pencil-mark **notes** with toggle; optional **auto-candidate** notes (toggleable) and auto-eliminate.
- **Highlight all of a number**; conflict/duplicate highlighting (toggleable).
- **Unlimited undo/redo.**
- **Input safety:** entering a digit vs. a note must never be ambiguous; a failed notes-toggle must never log a counted mistake (a real, documented incumbent bug). **No streak-wiping "restart" button** placed where it's mis-tapped.
- **Solvable-state guardrail** instead of a punitive 3-mistakes-game-over: detect when the board becomes unsolvable and offer rewind to the last valid state. (Replaces the model users explicitly hate.)
- **Ergonomic, one-handed** number pad reachable by thumb on large phones; large touch targets.

### 2.2 Teaching hints (teach, don't reveal)

Three-tier escalation, on the live board:
1. **Nudge:** "There's a solvable cell — look at this region."
2. **Name + tip:** identifies the technique ("This is a Hidden Single because…").
3. **Walkthrough:** visual highlight of the exact pattern and why it forces the placement.

Hints are **always opt-in and ad-free** — invoked when the player chooses. Free tier gets a generous daily hint allowance (e.g. on the Daily + a few practice puzzles); the ₹9.9 unlock makes them unlimited. No rewarded video, ever. Each resolved hint reinforces the Cognitive Gym identity ("you just used an X-Wing").

### 2.3 The global Daily + shareable result card (the growth engine)

**The single most important growth feature. No major Sudoku app does this.**
- **One puzzle per day, identical for everyone**, with a fixed weekly difficulty cadence (à la NYT crossword). This shared-scarcity is what made Wordle spread — "everybody is solving the same puzzle."
- **Spoiler-free result card** on completion: a colored grid conveying solve time, mistakes, hints used, and **hardest technique reached** — *no board spoiler*, safe to post publicly. One-tap share.
- **The Daily is free, forever, for everyone** — no ads, no paywall. It is the viral top-of-funnel that feeds the ₹9.9 unlock; gating it would kill the growth engine.
- On the **web** build especially, make the shared link open straight into a playable puzzle (no install wall) — one tap from a shared card to playing is what converts.
- Seed growth through high-reach communities at launch (the share button alone doesn't ignite — broadcast amplification does).

### 2.4 Retention core

- **Streaks** with **freezes + earn-back repair** from day one (the #1 churn moment is losing a loyal user after one missed day; freezes *increase* long-term engagement). Message the trend ("solved 25 of the last 30 days"), never confirmshame.
- **Daily quests** (e.g., "solve one without notes"). Low-pressure, not punitive.
- **Post-game "High IQ" analytics:** "15% faster than your average," accuracy/speed/tactics radar, percentile framing (kept encouraging, not intimidating for the mass-market audience).
- **Endowed-progress:** pre-fill the first 1–2 segments of every progress meter (technique mastery, starter streak credit). Proven to lift completion.
- **Smart notifications** at the user's habitual time (push within 90 days ~triples retention — foundational, not optional). Respectful frequency.

### 2.5 Monetization — Free tier + ₹9.9 one-time unlock (launch model)

**Hard rule: zero ads anywhere, ever. No subscription.** Revenue is a single ₹9.9 (~US$0.12) one-time unlock. The cheap price + ad-free experience *is* the brand (Ninety Nine Labs). This alone beats every ad-saturated incumbent and protects word-of-mouth.

**Free tier (the viral top-of-funnel — must feel generous, not crippled):**
- The **global Daily** puzzle + **shareable result card**, forever.
- Full-quality core board/input UX (the table-stakes experience is never paywalled).
- A **daily hint allowance** and a limited number of extra (non-Daily) puzzles per day.
- Basic post-game stats.

**₹9.9 one-time unlock (the depth):**
- **Unlimited puzzles** across all difficulties + **unlimited hints**.
- The full **learning path** / technique trainer.
- **Deep "High IQ" analytics**, puzzle-rating, and leaderboards (Phase 2).
- Cosmetic themes/tile designs.

**Design rules to protect virality:**
- Never gate the Daily or sharing. The paywall sits in front of *depth* (volume, learning, analytics), not the shareable loop.
- The paywall prompt is honest and un-naggy — surfaced when a free user hits a natural limit (wants another puzzle, wants unlimited hints), never confirmshaming.
- **Cosmetics never affect competition;** no pay-to-win, no entry tickets, no loot mechanics.
- Web shared links stay fully playable for free (no install/pay wall on the shared puzzle).

> Revenue math reality: at ₹9.9 the model only works at scale, so **free-tier reach (virality) is the business model**, and unlock conversion is secondary. Optimize for spread first, conversion second.

### 2.6 Design system (premium, but accessible & performant)

Keep the dark glassmorphism + neon identity — but engineered so it never costs us reviews:
- **Light theme too** (don't exclude light-mode users); both themes meet WCAG contrast.
- **Performance budget:** blur and animated-orb effects degrade gracefully on low-end devices (static/reduced-motion fallback). No jank or battery drain on mid-range Android — battery drain is an existing market complaint.
- **Never encode state by color alone** — conflicts/highlights also use shape/border/icon/sound. Customizable **color-blind mode.**
- Typography: Inter / Outfit / Space Grotesk for the tech-forward feel.
- Satisfying haptics on placement; spring transitions; subtle particle/glow on completions.
- **Board is the hero; zero clutter.**

### 2.7 Accessibility (built in, not bolted on)

- Font scaling + dyslexia-friendly font option.
- One-handed play; no required multi-touch.
- Reduced-motion setting.
- Color-blind-safe cues everywhere (see above).
- Accessibility settings easy to find; test with affected users before launch.

---

## 3. Phase 2 — Identity & Progression

- **Duolingo-style learning path:** a milestone map of technique nodes (Hidden Singles → Pairs → X-Wing → Swordfish → chains), each with an interactive guided lesson, then practice puzzles tagged for that technique (powered by the Phase-0 grader). Onboarding profiling ("First Time / Casual / Master") tailors the entry point.
- **Puzzle-rating system (not classic ELO):** each puzzle carries a rating; the player gains/loses based on solve time vs. expected — this is Chess.com's *puzzle rating* (Glicko-style), the correct model for solo play. Provisional rating for new users; a prestigious, infinite-ceiling number.
- **Tiered leaderboards** (Bronze → Grandmaster) so you always compete near your skill.
- **Async challenges:** "I solved this in 4m20s — beat me" shareable links (seeded identical grids).
- **Anti-cheat (required before any competitive number is public):** server-authoritative scoring, solve-path/timer sanity checks, pause-abuse and external-solver heuristics. A leaderboard that can be cheated is worthless.

---

## 4. Phase 3 — Social Depth & Variants

- **Real-time head-to-head:** identical puzzle, opponent progress bar / "ghost." (Deferred from MVP — expensive, and async + Daily deliver most virality far cheaper.)
- **Clubs / "Brain Trusts":** weekly shared goals, group streaks, cosmetic rewards, a friend accolade feed, "Brain Boost" cheers.
- **Variants** (Killer, Jigsaw/irregular, etc.) — pair beautifully with the teaching angle (teach one variant per learning chapter) and open the variant-depth gap the craft segment owns.
- **Setter/community features** (later): spectator "watch the solve" replays, community puzzle exchange.

---

## 5. Technical architecture

- **Frontend:** Flutter (cross-platform, custom UI). Engine in a **Dart isolate** so solving/generation never blocks the UI.
- **Offline-first:** the full solo experience (play, Daily once fetched, hints, notes, undo, learning path) works with no connectivity; cloud state syncs when online. "Requires connectivity" is a top market complaint — we avoid it by design.
- **Backend:** Firebase for speed-to-market (Auth, Firestore for profiles/social/leaderboards, Cloud Functions). Chosen for velocity, **not because it's free** — and with eyes open on two things:
  - **Server-authoritative scoring/rating:** ELO/puzzle-rating and Daily results are computed and validated in **Cloud Functions** — never trust the client.
  - **Cost/lock-in at scale:** social-feed fan-out and real-time PvP exceed free tiers quickly; design data models for cost, and keep the engine + core loop backend-agnostic so the rating/social layer could migrate if needed.
- **Deferred registration:** deliver value in the first 5 minutes; ask for an account only when the user wants to *save* progress / appear on leaderboards.
- **Daily puzzle delivery:** a server-published daily seed (so it's identical for everyone) with offline caching.

---

## 6. Roadmap summary

| Phase | Theme | Ships |
|---|---|---|
| **0** | Engine | Generator + unique-solution guarantee + human-style technique grader (on-device) |
| **1 (MVP)** | Growth + retention | Great board/input UX, teaching hints, **global Daily + shareable card**, streaks (+freeze), high-IQ analytics, free tier + ₹9.9 unlock (no ads), accessible design system, offline-first |
| **2** | Identity & progression | Learning path, puzzle-rating, tiered leaderboards (+anti-cheat), async challenges |
| **3** | Social & variants | Real-time PvP, clubs, friend feed, variants, setter/replay features |

---

## 7. Top risks & mitigations

1. **Engine difficulty/grading is hard** → spike Phase 0 standalone first with a large test corpus and property tests.
2. **Aesthetic vs. performance/accessibility** → performance budget on mid-range devices + graceful degradation + color-blind-safe from day one.
3. **Solo leaderboards invite cheating** → no public competitive number until server-authoritative anti-cheat exists.
4. **₹9.9 only works at scale → growth is the business model** → optimize relentlessly for free-tier reach/virality; never gate the Daily or sharing to chase conversion. A too-stingy free tier kills spread and therefore revenue.
5. **Share button ≠ virality** → seed via high-reach communities; design the result card to be genuinely worth posting.
6. **Firebase cost/lock-in at scale** → cost-aware data modeling; keep engine + rating logic backend-portable. (At ₹9.9, per-user backend cost must stay far below the per-user revenue — favor on-device + cheap reads.)

---

## 8. What changed from the original plan (and why)

- **Added the global Daily + shareable result card** — the original had daily *rewards/quests* but not the shared-puzzle + spoiler-free share that is the #1 proven organic-growth engine and directly serves the word-of-mouth goal.
- **Monetization is a free tier + ₹9.9 one-time unlock, with zero ads and no subscription** — replaces both the original "ads behind a feature flag" and the interim "respectful hybrid." The free Daily/sharing is the viral funnel; the ₹9.9 unlock (Ninety Nine Labs' standard price) sells depth. Growth, not conversion, is the business model.
- **Added the puzzle engine as Phase 0** — it was absent, yet the learning path, ratings, and honest difficulty all depend on it.
- **Specified core board/input UX and teaching hints** — the original was strong on meta-systems but silent on the in-puzzle experience where reviews are won or lost.
- **Reframed "ELO" as solo puzzle-rating + added anti-cheat** — classic ELO is head-to-head; solo needs a puzzle-rating model and cheat resistance.
- **Added accessibility, light theme, offline-first, performance budget, server-authoritative scoring** — required for quality, reach, and to avoid known competitor complaints.
- **Sequenced real-time multiplayer to Phase 3** — expensive; async + Daily deliver most of the virality far sooner.
