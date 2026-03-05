import { NextResponse } from "next/server";
import { pool } from "@/lib/db";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const leagueIdStr = searchParams.get("league_id");

  let leagueId: number | null = null;
  if (leagueIdStr) {
    leagueId = Number(leagueIdStr);
    if (Number.isNaN(leagueId)) {
      return NextResponse.json({ error: "league_id must be a number" }, { status: 400 });
    }
  }

  const sql = `
    SELECT
      match_id, league_id, league_name, sport_code, season,
      kickoff_at_utc, kickoff_at_local, status,
      home_team_id, home_team_name,
      away_team_id, away_team_name
    FROM public.v_fd_matches_week
    WHERE ($1::bigint IS NULL OR league_id = $1::bigint)
    ORDER BY kickoff_at_local ASC;
  `;

  const { rows } = await pool.query(sql, [leagueId]);

  return NextResponse.json({
    provider: "football_data",
    window: "week",
    league_id: leagueId,
    count: rows.length,
    items: rows,
  });
}