import { NextResponse } from "next/server";
import { pool } from "@/lib/db";

export async function GET() {
  const { rows } = await pool.query(`
    SELECT
      match_id, league_id, league_name, sport_code, season,
      kickoff_at_utc, kickoff_at_local, status,
      home_team_id, home_team_name, away_team_id, away_team_name
    FROM public.v_fd_matches_tomorrow
    ORDER BY kickoff_at_local ASC, league_name ASC;
  `);

  return NextResponse.json({
    provider: "football_data",
    window: "tomorrow",
    count: rows.length,
    items: rows,
  });
}