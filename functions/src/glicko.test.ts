import { describe, expect, it } from "vitest";
import { computeRatingFromSolves, performanceScore } from "./glicko";

describe("glicko (server) parity with the Dart engine", () => {
  it("matches the Dart golden rating for the same solve sequence", () => {
    // Golden produced by lib/domain/rating.dart computeRating(...) for:
    //   medium 300s/0, hard 600s/0, expert 900s/1  → rounded 1563, rd 216
    const r = computeRatingFromSolves([
      { difficultyIndex: 2, timeSeconds: 300, mistakes: 0 },
      { difficultyIndex: 3, timeSeconds: 600, mistakes: 0 },
      { difficultyIndex: 4, timeSeconds: 900, mistakes: 1 },
    ]);
    expect(Math.round(r.rating)).toBe(1563);
    expect(Math.round(r.rd)).toBe(216);
  });

  it("starts at the default with no solves", () => {
    expect(computeRatingFromSolves([]).rating).toBe(1200);
  });

  it("performance score is ~0.5 at par", () => {
    expect(performanceScore(2, 540, 0)).toBeCloseTo(0.5, 2);
  });
});

describe("anti-cheat filtering", () => {
  it("drops implausibly fast solves so they don't inflate the rating", () => {
    const legit = computeRatingFromSolves([
      { difficultyIndex: 4, timeSeconds: 900, mistakes: 0 },
    ]);
    const withCheat = computeRatingFromSolves([
      { difficultyIndex: 4, timeSeconds: 900, mistakes: 0 },
      { difficultyIndex: 4, timeSeconds: 1, mistakes: 0 }, // impossible → ignored
    ]);
    expect(withCheat.rating).toBe(legit.rating);
  });

  it("ignores out-of-range difficulty", () => {
    expect(computeRatingFromSolves([
      { difficultyIndex: 99, timeSeconds: 100, mistakes: 0 },
    ]).rating).toBe(1200);
  });
});
