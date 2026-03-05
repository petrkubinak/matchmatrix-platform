import { NextResponse, NextRequest } from "next/server";
import { pool } from "../../../lib/db"; 

export async function GET(request: NextRequest) {
  // 2) Přidání filtru podle ligy z URL parametrů (?league_id=...)
  const { searchParams } = new URL(request.url);
  const leagueId = searchParams.get('league_id');

  try {
    let query = `
      SELECT 
        match_id, home_team_name, away_team_name, 
        league_id, league_name, kickoff_at_local,
        odds_1, odds_x, odds_2, status
      FROM public.v_fd_matches_today -- Zde doplňte správné view dle složky
    `;

    const values = [];
    if (leagueId) {
      query += ` WHERE league_id = $1 AND status = 'SCHEDULED'`;
      values.push(leagueId);
    } else {
      query += ` WHERE status = 'SCHEDULED'`;
    }

    query += ` ORDER BY kickoff_at_local ASC`;

    const { rows } = await pool.query(query, values);

    // 1) Sjednocený wrapper: count + items
    return NextResponse.json({ 
      count: rows.length, 
      items: rows 
    });

  } catch (error: any) {
    console.error("DB Error:", error.message);
    return NextResponse.json({ count: 0, items: [], error: error.message }, { status: 500 });
  }
}