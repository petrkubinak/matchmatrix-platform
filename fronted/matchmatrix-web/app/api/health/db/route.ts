import { NextResponse } from "next/server";
import { pool } from "../../../lib/db";

export async function GET() {
  const r = await pool.query("select current_user as user, current_database() as db");
  return NextResponse.json(r.rows[0]);
}