import { NextResponse, NextRequest } from "next/server";
import { pool } from "../../../lib/db"; 

export async function GET(request: NextRequest) {
  // 2) Přidání filtru podle ligy z URL parametrů (?league_id=...)
  const { searchParams } = new URL(request.url);
  const leagueId = searchParams.get('league_id');

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
      FROM public.v_fd_matches_tomorrow v
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