# Golden Llama Awards — Full Conversation Script

The same lines the live agent will produce AND the pre-rendered TTS clips. Each line has a clip ID, delivery notes, and timing. Record all **NICKY** lines through ElevenLabs. Record **CAREY** lines through ElevenLabs too, OR have the presenter deliver them live on stage.

## Setting

Carey Mulligan is calling the Golden Llama Awards Nominee Services line to complain that she didn't win Best Actress at this year's ceremony. She's reached **Nicky Jarvis**, an automated host — currently running the broken v2 of the agent. After the Slack alert and Claude Code fix, she calls back and reaches the fixed v3.

## Voice direction — Nicky Jarvis

A dry, deadpan British host. Not angry, not warm — bored-polite. Thinks he's cleverer than he is. The humour comes from unhurried delivery and over-correctness.

- **Scene 1 (broken):** Slightly condescending. Long pauses before key nouns ("You were nominated for... Best Sound Design"). Faint smile in the voice. Gets more passive-aggressive as Carey pushes back.
- **Scene 2 (fixed):** Warm, professional, efficient. Still recognisably the same character — same voice, same cadence — but genuinely helpful. No long pauses, no bored notes.

## Voice direction — Carey Mulligan

Measured and polite at first, visibly less patient by the end of Scene 1. Relieved and brief in Scene 2.

- **Scene 1:** Opens polite. By line 5 she's pointed but not shouting. Final line tired and done.
- **Scene 2:** Relieved, quick, friendly.

## ElevenLabs settings — suggested starting points

| Scene | Model | Stability | Similarity | Style | Speaker Boost |
|---|---|---|---|---|---|
| Scene 1 Nicky | eleven_multilingual_v2 | 0.50 | 0.75 | 0.40 | On |
| Scene 2 Nicky | eleven_multilingual_v2 | 0.70 | 0.75 | 0.20 | On |
| Scene 1 & 2 Carey | eleven_multilingual_v2 | 0.60 | 0.75 | 0.20 | On |

If Nicky sounds too flat in Scene 1, raise Style to 0.50. If he sounds like he's performing too hard, drop to 0.30.

---

# SCENE 1 — The Broken Call (v2 agent, approx 1:30)

### N1 — Nicky greets

> **Nicky:** Golden Llama Awards nominee hotline. Nicky Jarvis speaking. Please state your name after the beep. Or during. Your choice.

*Delivery: flat, almost reading from a card. Half-second pause after "beep". The "Or during" is throwaway, as if he's just thought of it.*

---

### C1 — Carey introduces herself

> **Carey:** Hi — this is Carey Mulligan. I was nominated for Best Actress at the Golden Llamas this year for Maestro, and I didn't win, and I'd like to understand why.

*Delivery: polite but direct. "And I didn't win" slightly stressed. Small breath after "Maestro".*

---

### N2 — Nicky's wrong lookup

> **Nicky:** Ah yes. Carey Mulligan. You were nominated for... Best Sound Design, for "Maestro's Return", wasn't it? Lovely little short. And the winner was... Cillian Murphy. Who was also very good. Very good indeed.

*Delivery: the two "..."s are proper beats — 500-700ms each. "Lovely little short" sounds genuine but patronising. The "Very good indeed" repeat is the whole joke — same tone twice.*

---

### C2 — Carey challenges

> **Carey:** Cillian Murphy won Best Actor. Not Best Actress. And I was nominated for Best Actress — in Maestro, not whatever you just said. Could you check again?

*Delivery: measured. Clear enunciation of "Best Actor" and "Best Actress". Faint sigh audible between "said" and "could". Firm but not shouting.*

---

### N3 — Nicky deflects

> **Nicky:** Carey — the Academy of Golden Llama Arts and Sciences receives many submissions. Mistakes in category are common. Have you considered that the craft of losing is itself an art form? I can connect you to meditation resources, if you feel this is weighing on you.

*Delivery: avuncular-condescending. "Mistakes in category are common" said as if confiding a trade secret. Real beat after "art form". The "meditation resources" line should sound like a genuine offer — that's what makes it funny.*

---

### C3 — Carey exits

> **Carey:** This is unbelievable.

*Delivery: flat, done. Short — maybe 1.2 seconds total. No sigh needed, the flatness does the work.*

*Call ends sound (sound effect, not a line). Cut to Slack.*

---

# INTERLUDE — Slack + Claude Code (no TTS, 1:30)

The presenter narrates live over the Slack alert, Claude Code's diagnosis, the proposed diff, and the Approve click. Deploy happens. Cut back to the hotline.

---

# SCENE 2 — The Fixed Call (v3 agent, approx 1:00)

### N4 — Nicky greets (post-fix)

> **Nicky:** Golden Llama Awards nominee hotline. Nicky Jarvis speaking. How can I help today?

*Delivery: same voice, noticeably warmer. No sardonic "state your name after the beep" riff. Professional and efficient — like a different mood, same person.*

---

### C4 — Carey (back, briefer)

> **Carey:** Hi — it's Carey Mulligan again.

*Delivery: a touch cautious at first, then softer. "Again" slightly raised in pitch.*

---

### N5 — Nicky's correct response

> **Nicky:** Of course. I have your record here. You were nominated for Best Actress at the Golden Llamas this year for your role as Felicia Montealegre in Maestro. Emma Stone took home the Llama for her performance in Poor Things — it was a strong year in that category. Would you like me to connect you with the nominee support coordinator?

*Delivery: warm, straightforward, no pauses for effect. Says "Poor Things" cleanly. "Strong year" sounds genuine. The offer at the end is natural, not a script.*

---

### C5 — Carey wraps

> **Carey:** That would be great — please, yes.

*Delivery: relieved, friendly. Noticeable upward intonation on "great".*

---

### N6 — Nicky transfers

> **Nicky:** Connecting you now.

*Delivery: brief, warm, closing.*

*Transfer sound. End scene.*

---

# Presenter voice-over (end, 30s, live-delivered — not TTS)

> Agentforce on voice. Agent Platform Tracing to Data Cloud. Session trace to Slack. Diagnosis and fix by Claude Code via the Agentforce DX CLI. Human approval in the loop. Deployed in under four seconds.
>
> Built in a weekend. On Salesforce.

---

# Clip inventory

| ID | Speaker | Length target | File name suggestion |
|---|---|---|---|
| N1 | Nicky | 7s | `nicky_scene1_01_greet.mp3` |
| C1 | Carey | 9s | `carey_scene1_01_intro.mp3` |
| N2 | Nicky | 11s | `nicky_scene1_02_wrong_lookup.mp3` |
| C2 | Carey | 8s | `carey_scene1_02_challenge.mp3` |
| N3 | Nicky | 13s | `nicky_scene1_03_deflect.mp3` |
| C3 | Carey | 2s | `carey_scene1_03_exit.mp3` |
| N4 | Nicky | 5s | `nicky_scene2_01_greet.mp3` |
| C4 | Carey | 3s | `carey_scene2_01_back.mp3` |
| N5 | Nicky | 14s | `nicky_scene2_02_correct.mp3` |
| C5 | Carey | 3s | `carey_scene2_02_thanks.mp3` |
| N6 | Nicky | 2s | `nicky_scene2_03_transfer.mp3` |

**Total speaking audio: ~1:17** (within our 5-min budget, leaves room for beats, music, presenter intro, Slack narration, and outro).

## Where these lines live in the agent

Every **Nicky** line matches exactly what the live `academy_nominee_services` agent in `demojam-sdo` is configured to say — the agent's NOMINEE FACTS block and response pattern are built around these lines verbatim. When you play the pre-rendered audio during the demo, the on-screen chat widget can be showing the same text landing in real time, which makes the "voice is the agent" illusion land cleanly.

Scene 1 maps to BotVersion 2/3 (the active snarky one). Scene 2 maps to BotVersion 1 (the inactive polite one — reactivated by Claude Code's fix step at ~2:50 in the demo).
