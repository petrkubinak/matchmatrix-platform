import { NextResponse } from "next/server";
import { pool } from "../../../lib/db";

export async function GET() {
  try {
    const { rows } = await pool.query(`
      SELECT *
      FROM public.v_fd_matches_week_ui
      WHERE status = 'SCHEDULED'
      ORDER BY kickoff_at_local ASC
    `);

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