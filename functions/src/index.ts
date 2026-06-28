import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { computeRatingFromSolves, Solve } from "./glicko";

initializeApp();
const db = getFirestore();

/**
 * Anti-cheat: when a client reports a solve, recompute the player's rating
 * server-side from ALL their validated solves and write the authoritative
 * `leaderboard/{userId}` entry. Clients cannot write the leaderboard (rules
 * deny it), so a tampered rating can never reach the board.
 */
export const onSolveRecorded = onDocumentCreated(
  "users/{userId}/solves/{solveId}",
  async (event) => {
    const userId = event.params.userId;

    const solvesSnap = await db.collection(`users/${userId}/solves`).get();
    const solves: Solve[] = solvesSnap.docs.map((d) => {
      const data = d.data();
      return {
        difficultyIndex: Number(data.difficultyIndex),
        timeSeconds: Number(data.timeSeconds),
        mistakes: Number(data.mistakes),
      };
    });

    const rating = computeRatingFromSolves(solves);

    const userSnap = await db.doc(`users/${userId}`).get();
    const name = (userSnap.get("displayName") as string | undefined)?.trim();

    await db.doc(`leaderboard/${userId}`).set(
      {
        displayName: name && name.length > 0 ? name : "Player",
        rating: Math.round(rating.rating),
        rd: Math.round(rating.rd),
        solves: solves.length,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }
);
