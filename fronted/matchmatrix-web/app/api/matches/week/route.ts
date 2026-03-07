import { NextResponse } from "next/server";
import { pool } from "../../../lib/db";

export async function GET() {
  try {
    // Week matches + best odds across all bookmakers (MVP)
    const { rows } = await pool.query(`
      SELECT
        match_id,
        home_team_name,
        away_team_name,
        league_name,
        kickoff_at_local,
        odds_1,
        odds_x,
        odds_2
      FROM public.v_ticketmatrix_week_best_odds
      ORDER BY kickoff_at_local ASC, league_name ASC;
    `);

    return NextResponse.json({ count: rows.length, items: rows });
  } catch (error: any) {
    console.error("DB Error:", error.message);
    return NextResponse.json(
      { count: 0, items: [], error: error.message },
      { status: 500 }
    );
  }
}