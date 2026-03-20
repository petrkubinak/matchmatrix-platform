import { NextResponse, NextRequest } from "next/server";
import { pool } from "../../../lib/db";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const leagueId = searchParams.get("league_id");

  try {
    let query = `
      SELECT
        v.match_id,
        v.home_team_name,
        v.away_team_name,
        v.home_team_logo_url,
        v.away_team_logo_url,
        v.league_id,
        v.league_name,
        v.country_code,
        v.kickoff_at_local,
        v.status
      FROM public.v_fd_matches_today v
    `;

    const values: string[] = [];

    if (leagueId) {
      query += ` WHERE v.league_id = $1 AND v.status = 'SCHEDULED'`;
      values.push(leagueId);
    } else {
      query += ` WHERE v.status = 'SCHEDULED'`;
    }

    query += ` ORDER BY v.kickoff_at_local ASC`;

    const { rows } = await pool.query(query, values);

    return NextResponse.json({
      count: rows.length,
      items: rows,
    });
  } catch (error: any) {
    console.error("DB Error:", error.message);
    return NextResponse.json(
      { count: 0, items: [], error: error.message },
      { status: 500 }
    );
  }
}