// Server-side puzzle rating — a faithful port of lib/domain/rating.dart so the
// authoritative (server) rating matches the client's local rating for legit
// play. The server additionally drops implausibly-fast solves (anti-cheat).

const Q = Math.log(10) / 400;
const DEFAULT_RATING = 1200;
const DEFAULT_RD = 350;
const MIN_RD = 30;
const PERIOD_C = 24;

// Indexed by Difficulty: [beginner, easy, medium, hard, expert, master].
const OPPONENT = [800, 1000, 1300, 1600, 1900, 2200];
const PAR = [150, 300, 540, 900, 1500, 2100];
// Human-plausible minimum solve time (seconds). Faster than this is rejected as
// likely automation/cheating. (Full cheat-proofing needs server-issued puzzles.)
const MIN_HUMAN = [10, 20, 40, 60, 90, 120];

export interface PlayerRating {
  rating: number;
  rd: number;
}

export interface Solve {
  difficultyIndex: number;
  timeSeconds: number;
  mistakes: number;
}

function clamp(x: number, lo: number, hi: number): number {
  return Math.min(hi, Math.max(lo, x));
}

export function performanceScore(
  difficultyIndex: number,
  timeSeconds: number,
  mistakes: number
): number {
  const par = PAR[difficultyIndex];
  const time = Math.max(timeSeconds, 1);
  const speed = par / (par + time);
  return clamp(speed - 0.06 * mistakes, 0.05, 0.95);
}

function g(rd: number): number {
  return 1 / Math.sqrt(1 + (3 * Q * Q * rd * rd) / (Math.PI * Math.PI));
}

export function updateRating(
  current: PlayerRating,
  opponentRating: number,
  opponentRd: number,
  score: number
): PlayerRating {
  const rd = Math.min(
    Math.sqrt(current.rd * current.rd + PERIOD_C * PERIOD_C),
    DEFAULT_RD
  );
  const gOpp = g(opponentRd);
  const expected =
    1 / (1 + Math.pow(10, (-gOpp * (current.rating - opponentRating)) / 400));
  const dInv = Q * Q * gOpp * gOpp * expected * (1 - expected);
  const denom = 1 / (rd * rd) + dInv;
  const newRating = current.rating + (Q / denom) * gOpp * (score - expected);
  const newRd = clamp(Math.sqrt(1 / denom), MIN_RD, DEFAULT_RD);
  return { rating: newRating, rd: newRd };
}

/** Replays validated solves into an authoritative rating. */
export function computeRatingFromSolves(solves: Solve[]): PlayerRating {
  let r: PlayerRating = { rating: DEFAULT_RATING, rd: DEFAULT_RD };
  for (const s of solves) {
    const d = s.difficultyIndex;
    if (!Number.isInteger(d) || d < 0 || d > 5) continue;
    if (!Number.isFinite(s.timeSeconds) || s.timeSeconds < MIN_HUMAN[d]) {
      continue; // implausible / cheating → ignored
    }
    const mistakes = Number.isFinite(s.mistakes) ? Math.max(0, s.mistakes) : 0;
    r = updateRating(
      r,
      OPPONENT[d],
      50,
      performanceScore(d, s.timeSeconds, mistakes)
    );
  }
  return r;
}
