import { NextResponse } from "next/server";
import { pool } from "../../../lib/db";

export async function GET() {
  const { rows } = await pool.query(`
    SELECT
      league_id,
      league_name,
      sport_code,
      matches_in_week,
      first_kickoff_local,
      last_kickoff_local
    FROM public.v_fd_leagues_active_week
    ORDER BY matches_in_week DESC, league_name ASC;
  `);

  return NextResponse.json({
    provider: "football_data",
    window: "week",
    count: rows.length,
    items: rows,
  });
}