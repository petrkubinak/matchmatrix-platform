import { NextResponse } from "next/server";

export async function GET() {
  const cs = process.env.DATABASE_URL || "";
  const masked = cs.replace(/:(.+?)@/, ":***@"); // schovej heslo

  return NextResponse.json({
    has_DATABASE_URL: Boolean(process.env.DATABASE_URL),
    masked_DATABASE_URL: masked,
    PGHOST: process.env.PGHOST || null,
    PGPORT: process.env.PGPORT || null,
    PGUSER: process.env.PGUSER || null,
    PGDATABASE: process.env.PGDATABASE || null
  });
}