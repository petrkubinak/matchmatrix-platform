"use client";

/* =========================================================
   TICKETMATRIXPLATFORM - PAGE.TSX V1
   ---------------------------------------------------------
   STRUKTURA SOUBORU:

   1) Typy a konstanty
   2) Pomocné funkce
   3) Ikony
   4) Univerzální rámeček panelu (CardFrame)
   5) Hlavní page komponenta
      5.1 Stavové proměnné
      5.2 LocalStorage
      5.3 Načítání API dat
      5.4 Dopočty a grouped data
      5.5 Akce (pin/favorite/tiket)
      5.6 Layout stránky
   6) LeagueSection
   ---------------------------------------------------------
   POZNÁMKA K ÚPRAVÁM:
   - větší panely jsou ostřejší
   - menší klikací prvky jsou lehce zaoblené
   - panely mají rohové linky od středu do rohu a zpět do středu
   - panely jsou jemně tmavší směrem k pravému dolnímu rohu
   ========================================================= */

import React, { useEffect, useMemo, useState } from "react";

/* =========================================================
   1) TYPY A KONSTANTY
   ========================================================= */

type TabKey = "today" | "tomorrow" | "week";
type PickCode = "1" | "X" | "2" | "1X" | "12" | "X2";

type LeagueItem = {
  league_id: number;
  league_name: string;
  country_code?: string;
};

type MatchItem = {
  match_id: number;
  league_id?: number;
  league_name: string;
  country_code?: string;

  league_logo_url?: string;
  league_is_cup?: boolean;
  league_is_international?: boolean;

  kickoff_at_local: string;
  status?: string;

  home_team_name: string;
  away_team_name: string;

  home_team_logo_url?: string;
  away_team_logo_url?: string;

  home_team_country_code?: string;
  away_team_country_code?: string;
};

type ApiResponse<T> = {
  count?: number;
  items: T[];
  error?: string;
};

type TicketItem = {
  match: MatchItem;
  pick: PickCode;
};

const PICKS: PickCode[] = ["1", "X", "2", "1X", "12", "X2"];

const TAB_LABEL: Record<TabKey, string> = {
  today: "Dnes",
  tomorrow: "Zítra",
  week: "Týden",
};

const LS_PINNED = "tm_pinned_leagues_v1";
const LS_FAV = "tm_fav_leagues_v1";
const LS_FAV_SPORTS = "tm_fav_sports_v1";
const LS_ACTIVE_MAIN_SPORT = "tm_active_main_sport_v1";

/* ---------------------------------------------------------
   HLAVNÍ SPORTY
   Sem si můžeš doplnit další sporty.
   --------------------------------------------------------- */
const SPORTS = [
  { key: "football", label: "Fotbal" },
  { key: "hockey", label: "Hokej" },
  { key: "tennis", label: "Tenis" },
  { key: "basketball", label: "Basketbal" },
  { key: "mma", label: "MMA" },
];

/* =========================================================
   2) POMOCNÉ FUNKCE
   ========================================================= */

/* ---------------------------------------------------------
   Bezpečné čtení JSON z localStorage
   --------------------------------------------------------- */
function safeJsonParse<T>(s: string | null, fallback: T): T {
  try {
    if (!s) return fallback;
    return JSON.parse(s) as T;
  } catch {
    return fallback;
  }
}

/* ---------------------------------------------------------
   Formátování data/času zápasu
   --------------------------------------------------------- */
function formatKickoff(iso: string) {
  try {
    const d = new Date(iso);
    const wd = d.toLocaleDateString("cs-CZ", { weekday: "short" });
    const day = d.toLocaleDateString("cs-CZ", {
      day: "2-digit",
      month: "2-digit",
    });
    const time = d.toLocaleTimeString("cs-CZ", {
      hour: "2-digit",
      minute: "2-digit",
    });
    return `${wd} ${day} ${time}`;
  } catch {
    return iso;
  }
}

/* ---------------------------------------------------------
   Groupování zápasů podle lig
   --------------------------------------------------------- */
function groupByLeague(matches: MatchItem[]) {
  const map = new Map<string, MatchItem[]>();

  for (const m of matches) {
    const key = m.league_name || "Nezařazená liga";
    if (!map.has(key)) map.set(key, []);
    map.get(key)!.push(m);
  }

  return Array.from(map.entries()).map(([leagueName, items]) => ({
    leagueName,
    items,
  }));
}

/* ---------------------------------------------------------
   Iniciály týmu pro kulaté kolečko
   --------------------------------------------------------- */
function initials(name: string) {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((x) => x[0]?.toUpperCase() ?? "")
    .join("");
}

/* =========================================================
   3) IKONY
   ========================================================= */

function IconSearch() {
  return (
    <svg
      viewBox="0 0 24 24"
      className="h-4 w-4"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
    >
      <circle cx="11" cy="11" r="6.5" />
      <path d="M16 16L21 21" />
    </svg>
  );
}

function IconCog() {
  return (
    <svg
      viewBox="0 0 24 24"
      className="h-4 w-4"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
    >
      <path d="M12 3l1.2 2.1 2.4.5-.8 2.3 1.7 1.8-1.7 1.8.8 2.3-2.4.5L12 18l-1.2-2.1-2.4-.5.8-2.3-1.7-1.8 1.7-1.8-.8-2.3 2.4-.5L12 3z" />
      <circle cx="12" cy="12" r="2.8" />
    </svg>
  );
}

function IconUser() {
  return (
    <svg
      viewBox="0 0 24 24"
      className="h-4 w-4"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
    >
      <circle cx="12" cy="8" r="3.2" />
      <path d="M5 20c1.5-3.3 4-5 7-5s5.5 1.7 7 5" />
    </svg>
  );
}

function IconPin() {
  return (
    <svg viewBox="0 0 24 24" className="h-3.5 w-3.5" fill="currentColor">
      <path d="M15.8 3.8l4.4 4.4-2.6.8-2.8 4.7-.7.1-2 2 3.3 3.3-1.4 1.4-3.3-3.3-2 2-.1.7L4 23l.8-4.8.7-.1 2-2-3.3-3.3 1.4-1.4 3.3 3.3 2-2 .1-.7 4.7-2.8.8-2.6z" />
    </svg>
  );
}

function Flag({ code }: { code?: string }) {
  if (!code) return null;

  return (
    <img
      src={`https://flagcdn.com/w20/${code.toLowerCase()}.png`}
      alt={code}
      className="h-[14px] w-[20px] object-cover"
    />
  );
}

function TeamMark({
  countryCode,
  logoUrl,
  teamName,
}: {
  countryCode?: string;
  logoUrl?: string;
  teamName: string;
}) {
  return (
    <div className="flex items-center gap-2 min-w-0">
      <Flag code={countryCode} />

      <div className="truncate text-sm">
        {teamName}
      </div>

      {logoUrl ? (
        <img
          src={logoUrl}
          alt={teamName}
          className="h-5 w-5 shrink-0 object-contain"
        />
      ) : null}
    </div>
  );
}

function CompetitionMark({
  leagueName,
  countryCode,
  leagueLogoUrl,
  isCup,
  isInternational,
}: {
  leagueName: string;
  countryCode?: string;
  leagueLogoUrl?: string;
  isCup?: boolean;
  isInternational?: boolean;
}) {
  const showLeagueLogo = !!leagueLogoUrl && (isCup || isInternational);

  return (
    <div className="flex items-center gap-2 min-w-0">
      {showLeagueLogo ? (
        <img
          src={leagueLogoUrl}
          alt={leagueName}
          className="h-4 w-4 shrink-0 object-contain"
        />
      ) : (
        <Flag code={countryCode} />
      )}

      <div className="truncate text-[15px] font-semibold text-white">
        {leagueName}
      </div>
    </div>
  );
}

function TeamBadge({
  src,
  alt,
  fallback,
}: {
  src?: string;
  alt: string;
  fallback: string;
}) {
  if (src) {
    return (
      <img
        src={src}
        alt={alt}
        className="h-6 w-6 rounded-full object-contain"
      />
    );
  }

  return (
    <div className="flex h-6 w-6 items-center justify-center rounded-full bg-[#261a40] text-[10px] font-semibold text-[#ffd6ee]">
      {fallback}
    </div>
  );
}

function LeagueMark({
  leagueName,
  countryCode,
  logoUrl,
}: {
  leagueName: string;
  countryCode?: string;
  logoUrl?: string;
}) {
  const isCupLike =
    /champions|europa|conference|cup|pohár|liga mistrů|evropská liga|conference league/i.test(
      leagueName
    );

  return (
    <div className="flex items-center gap-2 min-w-0">
      {isCupLike && logoUrl ? (
        <img
          src={logoUrl}
          alt={leagueName}
          className="h-4 w-4 shrink-0 object-contain"
        />
      ) : (
        <Flag code={countryCode} />
      )}

      <div className="truncate text-[15px] font-semibold text-white">
        {leagueName}
      </div>
    </div>
  );
}

/* =========================================================
   4) UNIVERZÁLNÍ RÁMEČEK PANELU
   ========================================================= */

/* ---------------------------------------------------------
   TADY SE ŘEŠÍ HLAVNÍ VIZUÁL PANELŮ

   CO DĚLÁ:
   - small = menší box, lehce zaoblený
   - bez small = větší box, ostřejší / skoro ostrý
   - pozadí panelu jde jemně do tmavšího pravého dolního rohu
   - linky:
     levý horní roh:
       od středu horní hrany -> do rohu -> dolů do středu
     pravý dolní roh:
       od středu spodní hrany -> do rohu -> nahoru do středu

   KDYŽ BUDEŠ CHTÍT LADIT STYL PANELŮ,
   začni právě tady.
   --------------------------------------------------------- */
function CardFrame({
  children,
  className = "",
  small = false,
}: {
  children: React.ReactNode;
  className?: string;
  small?: boolean;
}) {

  /* -------------------------------------------------
     ŘÍZENÍ ROHŮ PANELU

     small = menší box
       -> jemně zaoblené rohy

     default = velký panel
       -> ostré rohy
  -------------------------------------------------- */

  const radius = small ? "10px" : "0px";

  return (
    <div
      className={[
        "relative overflow-hidden border border-[#3b255d]/70",
        className,
      ].join(" ")}
      style={{
        borderRadius: radius,

        background:
          "linear-gradient(135deg, rgba(42,27,71,0.98) 0%, rgba(39,24,66,0.97) 54%, rgba(25,15,40,0.99) 100%)",

        boxShadow:
          "inset 0 1px 0 rgba(255,255,255,0.025), 0 10px 28px rgba(0,0,0,0.16)",
      }}
    >
      {/* VIZUÁLNÍ LINKY PANELU */}
      <div className="pointer-events-none absolute inset-0">
        {/* -------------------------------------------------
           PRAVÝ HORNÍ ROH
           1) vodorovná linka od středu nahoře do pravého rohu
           2) svislá linka z téhož rohu dolů směrem ke středu pravé hrany
           ------------------------------------------------- */}

        {/* horní tah */}
        <div
          className="absolute right-0 top-0 h-[2px] w-[48%]"
          style={{
            background:
              "linear-gradient(90deg, rgba(199,125,255,0) 0%, rgba(199,125,255,0.30) 35%, rgba(255,139,209,0.95) 100%)",
          }}
        />

        {/* pravý svislý tah */}
        <div
          className="absolute right-0 top-0 h-[50%] w-[3px]"
          style={{
            background:
              "linear-gradient(180deg, rgba(255,139,209,0.95) 0%, rgba(199,125,255,0.42) 45%, rgba(199,125,255,0) 100%)",
          }}
        />

        {/* -------------------------------------------------
           LEVÝ DOLNÍ ROH
           1) vodorovná linka od středu dole do levého rohu
           2) svislá linka z téhož rohu nahoru směrem ke středu levé hrany
           ------------------------------------------------- */}

        {/* spodní tah */}
        <div
          className="absolute bottom-0 left-0 h-[2px] w-[42%]"
          style={{
            background:
              "linear-gradient(270deg, rgba(199,125,255,0) 0%, rgba(199,125,255,0.30) 35%, rgba(255,139,209,0.95) 100%)",
          }}
        />

        {/* levý svislý tah */}
        <div
          className="absolute bottom-0 left-0 h-[34%] w-[2px]"
          style={{
            background:
              "linear-gradient(0deg, rgba(255,139,209,0.95) 0%, rgba(199,125,255,0.42) 45%, rgba(199,125,255,0) 100%)",
          }}
        />

        {/* jemné prosvětlení levého horního rohu */}
        <div
          className="absolute left-0 top-0 h-[55%] w-[45%]"
          style={{
            background:
              "radial-gradient(circle at top left, rgba(199,125,255,0.07) 0%, rgba(199,125,255,0.025) 35%, rgba(0,0,0,0) 70%)",
          }}
        />

        {/* ztmavení do pravého dolního rohu pro prostor */}
        <div
          className="absolute bottom-0 right-0 h-[82%] w-[68%]"
          style={{
            background:
              "radial-gradient(circle at bottom right, rgba(8,5,14,0.34) 0%, rgba(8,5,14,0.16) 38%, rgba(0,0,0,0) 76%)",
          }}
        />
      </div>

      <div className="relative z-10">{children}</div>
    </div>
  );
}

/* =========================================================
   5) HLAVNÍ PAGE KOMPONENTA
   ========================================================= */

export default function Page() {
  /* =======================================================
     5.1 STAVOVÉ PROMĚNNÉ
     -------------------------------------------------------
     Tady se drží:
     - aktivní tab (dnes/zítra/týden)
     - aktivní liga
     - data lig a zápasů
     - oblíbené a připnuté ligy
     - oblíbené sporty
     - tiket
     ======================================================= */

  const [tab, setTab] = useState<TabKey>("today");
  const [activeLeagueName, setActiveLeagueName] = useState<string | null>(null);

  const [leagues, setLeagues] = useState<LeagueItem[]>([]);
  const [matchesToday, setMatchesToday] = useState<MatchItem[]>([]);
  const [matchesTomorrow, setMatchesTomorrow] = useState<MatchItem[]>([]);
  const [matchesWeek, setMatchesWeek] = useState<MatchItem[]>([]);

  const [loading, setLoading] = useState(true);
  const [drawerOpen, setDrawerOpen] = useState(false);

  const [ticketItems, setTicketItems] = useState<TicketItem[]>([]);
  const [stake, setStake] = useState("100");

  const [pinnedLeagues, setPinnedLeagues] = useState<string[]>([]);
  const [favoriteLeagues, setFavoriteLeagues] = useState<string[]>([]);
  const [favoriteSports, setFavoriteSports] = useState<string[]>([
    "football",
    "hockey",
    "tennis",
  ]);
  const [activeMainSport, setActiveMainSport] = useState<string>("football");

  /* =======================================================
     5.2 LOCAL STORAGE
     -------------------------------------------------------
     Načítání a ukládání:
     - připnuté ligy
     - oblíbené ligy
     - oblíbené sporty
     - aktivní hlavní sport
     ======================================================= */

  useEffect(() => {
    setPinnedLeagues(safeJsonParse<string[]>(localStorage.getItem(LS_PINNED), []));
    setFavoriteLeagues(safeJsonParse<string[]>(localStorage.getItem(LS_FAV), []));
    setFavoriteSports(
      safeJsonParse<string[]>(localStorage.getItem(LS_FAV_SPORTS), [
        "football",
        "hockey",
        "tennis",
      ])
    );
    setActiveMainSport(localStorage.getItem(LS_ACTIVE_MAIN_SPORT) || "football");
  }, []);

  useEffect(() => {
    localStorage.setItem(LS_PINNED, JSON.stringify(pinnedLeagues));
  }, [pinnedLeagues]);

  useEffect(() => {
    localStorage.setItem(LS_FAV, JSON.stringify(favoriteLeagues));
  }, [favoriteLeagues]);

  useEffect(() => {
    localStorage.setItem(LS_FAV_SPORTS, JSON.stringify(favoriteSports));
  }, [favoriteSports]);

  useEffect(() => {
    localStorage.setItem(LS_ACTIVE_MAIN_SPORT, activeMainSport);
  }, [activeMainSport]);

  /* =======================================================
     5.3 NAČÍTÁNÍ API DAT
     -------------------------------------------------------
     Tady se frontend napojuje na:
     - /api/leagues/active-week
     - /api/matches/today
     - /api/matches/tomorrow
     - /api/matches/week

     KDYŽ NIC NENAČÍTÁ:
     zkontroluj právě tuto část + API route.
     ======================================================= */

  useEffect(() => {
    async function load() {
      setLoading(true);

      try {
        const [l, t, tm, w] = await Promise.all([
          fetch("/api/leagues/active-week", { cache: "no-store" }).then(
            (r) => r.json() as Promise<ApiResponse<LeagueItem>>
          ),
          fetch("/api/matches/today", { cache: "no-store" }).then(
            (r) => r.json() as Promise<ApiResponse<MatchItem>>
          ),
          fetch("/api/matches/tomorrow", { cache: "no-store" }).then(
            (r) => r.json() as Promise<ApiResponse<MatchItem>>
          ),
          fetch("/api/matches/week", { cache: "no-store" }).then(
            (r) => r.json() as Promise<ApiResponse<MatchItem>>
          ),
        ]);

        setLeagues(l.items || []);
        setMatchesToday(t.items || []);
        setMatchesTomorrow(tm.items || []);
        setMatchesWeek(w.items || []);
      } catch (e) {
        console.error("Chyba při načítání dat:", e);
      } finally {
        setLoading(false);
      }
    }

    load();
  }, []);

  /* =======================================================
     5.4 DOPOČTY A GROUPED DATA
     -------------------------------------------------------
     Tady se určuje:
     - které zápasy jsou aktivní podle tabů
     - rozdělení podle lig
     - pinned groups
     - sidebar seznam lig
     ======================================================= */

  const currentMatches = useMemo(() => {
    if (tab === "today") return matchesToday;
    if (tab === "tomorrow") return matchesTomorrow;
    return matchesWeek;
  }, [tab, matchesToday, matchesTomorrow, matchesWeek]);

  const grouped = useMemo(() => {
    const filtered = activeLeagueName
      ? currentMatches.filter((m) => m.league_name === activeLeagueName)
      : currentMatches;

    return groupByLeague(filtered);
  }, [currentMatches, activeLeagueName]);

  useEffect(() => {
    if (!activeLeagueName && grouped.length > 0) {
      const firstPinned = grouped.find((g) => pinnedLeagues.includes(g.leagueName));
      setActiveLeagueName(firstPinned?.leagueName ?? grouped[0]?.leagueName ?? null);
    }
  }, [grouped, pinnedLeagues, activeLeagueName]);

  const pinnedGroups = useMemo(
    () => grouped.filter((g) => pinnedLeagues.includes(g.leagueName)),
    [grouped, pinnedLeagues]
  );

  const otherGroups = useMemo(
    () => grouped.filter((g) => !pinnedLeagues.includes(g.leagueName)),
    [grouped, pinnedLeagues]
  );

  const sidebarLeagues = useMemo(() => {
    const names = new Set<string>();

    pinnedLeagues.forEach((x) => names.add(x));
    favoriteLeagues.forEach((x) => names.add(x));
    grouped.forEach((g) => names.add(g.leagueName));
    leagues.forEach((l) => names.add(l.league_name));

    return Array.from(names).sort((a, b) => a.localeCompare(b, "cs"));
  }, [pinnedLeagues, favoriteLeagues, grouped, leagues]);

  /* =======================================================
     5.5 AKCE
     -------------------------------------------------------
     Tady jsou akce:
     - připnutí lig
     - oblíbené ligy
     - oblíbené sporty
     - volby tiketu
     ======================================================= */

  function togglePinnedLeague(name: string) {
    setPinnedLeagues((prev) =>
      prev.includes(name) ? prev.filter((x) => x !== name) : [...prev, name]
    );
  }

  function toggleFavoriteLeague(name: string) {
    setFavoriteLeagues((prev) =>
      prev.includes(name) ? prev.filter((x) => x !== name) : [...prev, name]
    );
  }

  function toggleFavoriteSport(key: string) {
    setFavoriteSports((prev) =>
      prev.includes(key) ? prev.filter((x) => x !== key) : [...prev, key]
    );
  }

  function setPick(match: MatchItem, pick: PickCode) {
    setTicketItems((prev) => {
      const exists = prev.find((x) => x.match.match_id === match.match_id);

      if (exists) {
        return prev.map((x) =>
          x.match.match_id === match.match_id ? { ...x, pick } : x
        );
      }

      return [...prev, { match, pick }];
    });

    setDrawerOpen(true);
  }

  function removeTicket(matchId: number) {
    setTicketItems((prev) => prev.filter((x) => x.match.match_id !== matchId));
  }

  /* -------------------------------------------------------
     jednoduchý pseudo výpočet odds pro UI preview
     ------------------------------------------------------- */
  const totalMatches = ticketItems.length;
  const parsedStake = Number(stake || "0");
  const pseudoOdds =
    totalMatches > 0 ? (1.45 + totalMatches * 0.28).toFixed(2) : "0.00";
  const possibleWin = (parsedStake * Number(pseudoOdds)).toFixed(2);

  /* =======================================================
     5.6 LAYOUT STRÁNKY
     -------------------------------------------------------
     Tady je celé rozložení:

     A) Horní header
     B) Druhá sportovní lišta
     C) 3sloupcový layout:
        - vlevo sidebar
        - uprostřed hlavní obsah
        - vpravo rychlé panely
     D) Footer
     E) Ticket drawer
     ======================================================= */

  return (
    <div className="min-h-screen bg-[#140d23] text-[#f6eeff]">
      {/* ===================================================
         A) HORNÍ HEADER
         ---------------------------------------------------
         Obsah:
         - TMP box
         - název TicketMatrixPlatform
         - horní hlavní menu
         - účet / hledání / nastavení
         =================================================== */}
      <header className="sticky top-0 z-50 border-b border-[#4a2d74]/70 bg-[#120b1f]/92 backdrop-blur">
        <div className="mx-auto flex max-w-[1600px] items-center justify-between gap-4 px-4 py-3 md:px-6">
          <div className="flex items-center gap-4">
            {/* TMP značka vlevo */}
            <div className="flex h-11 w-11 items-center justify-center rounded-lg border border-[#4a2d74]/70 bg-[#24173b] text-sm font-bold tracking-[0.22em] text-[#ff92d0] shadow-[0_0_28px_rgba(199,125,255,0.18)]">
              TMP
            </div>

            {/* branding */}
            <div>
              <div className="text-sm font-semibold tracking-[0.22em] text-[#f9f3ff]">
                TICKETMATRIXPLATFORM
              </div>
              <div className="text-[11px] text-[#c9b8e8]/75">
                powered by MatchMatrix
              </div>
            </div>

            {/* hlavní horní menu */}
            <nav className="ml-4 hidden items-center gap-2 xl:flex">
              {["Výsledky", "Tikety", "Sporty", "Zprávy", "Oblíbené"].map(
                (item, i) => (
                  <button
                    key={item}
                    className={[
                      "rounded-lg border px-4 py-2 text-sm transition",
                      i === 0
                        ? "border-[#ff7fc8]/70 bg-[#25173b] text-white"
                        : "border-[#4a2d74]/70 bg-[#191126]/70 text-[#d7caee] hover:bg-[#241736]",
                    ].join(" ")}
                  >
                    {item}
                  </button>
                )
              )}
            </nav>
          </div>

          {/* pravá utility část */}
          <div className="flex items-center gap-2">
            <button className="rounded-lg border border-[#4a2d74]/70 bg-[#191126]/70 p-2 text-[#eadfff] transition hover:bg-[#241736]">
              <IconSearch />
            </button>
            <button className="rounded-lg border border-[#4a2d74]/70 bg-[#191126]/70 p-2 text-[#eadfff] transition hover:bg-[#241736]">
              <IconCog />
            </button>
            <button className="flex items-center gap-2 rounded-lg border border-[#4a2d74]/70 bg-[#191126]/70 px-3 py-2 text-sm text-[#eadfff] transition hover:bg-[#241736]">
              <IconUser />
              <span className="hidden sm:inline">Účet</span>
            </button>
          </div>
        </div>

        {/* =================================================
           B) DRUHÝ ŘÁDEK - OBLÍBENÉ SPORTY / DALŠÍ SPORTY
           -------------------------------------------------
           Tady se přepínají sporty.
           Aktivní sport je zvýrazněný.
           ================================================= */}
        <div className="border-t border-[#3a245a]/70 bg-[#160f25]/95">
          <div className="mx-auto flex max-w-[1600px] items-center gap-2 overflow-x-auto px-4 py-2 md:px-6">
            <div className="mr-2 text-[11px] font-semibold uppercase tracking-[0.24em] text-[#c7b5e8]/70">
              Oblíbené sporty
            </div>

            {favoriteSports.map((sportKey) => {
              const sport = SPORTS.find((s) => s.key === sportKey);
              if (!sport) return null;

              const active = sport.key === activeMainSport;

              return (
                <button
                  key={sport.key}
                  onClick={() => setActiveMainSport(sport.key)}
                  className={[
                    "rounded-lg border px-3 py-2 text-sm whitespace-nowrap transition",
                    active
                      ? "border-[#ff7fc8]/70 bg-[#281942] text-white"
                      : "border-[#4a2d74]/70 bg-[#191126]/65 text-[#ddcff3] hover:bg-[#241736]",
                  ].join(" ")}
                >
                  {sport.label}
                </button>
              );
            })}

            <div className="mx-2 h-5 w-px bg-[#51327b]" />

            <div className="mr-1 text-[11px] font-semibold uppercase tracking-[0.24em] text-[#c7b5e8]/70">
              Další sporty
            </div>

            {SPORTS.filter((s) => !favoriteSports.includes(s.key)).map(
              (sport) => (
                <button
                  key={sport.key}
                  onClick={() => setActiveMainSport(sport.key)}
                  className="rounded-lg border border-[#4a2d74]/70 bg-[#191126]/65 px-3 py-2 text-sm whitespace-nowrap text-[#ddcff3] transition hover:bg-[#241736]"
                >
                  {sport.label}
                </button>
              )
            )}
          </div>
        </div>
      </header>

      {/* ===================================================
         C) HLAVNÍ 3SLOUPCOVÝ LAYOUT
         =================================================== */}
      <div className="mx-auto grid max-w-[1600px] grid-cols-12 gap-5 px-4 py-5 md:px-6">
        {/* =================================================
           C1) LEVÝ SIDEBAR
           -------------------------------------------------
           Obsah:
           - připnuté ligy
           - rychlé filtry
           ================================================= */}
        <aside className="col-span-12 lg:col-span-3 xl:col-span-2">
          <CardFrame className="p-4">
            <div className="mb-3">
              <div className="text-[11px] font-semibold uppercase tracking-[0.24em] text-[#ff8bd1]">
                Připnuté ligy
              </div>
              <div className="mt-1 text-xs text-[#c7b5e8]/70">
                Aktivní sport:{" "}
                {SPORTS.find((x) => x.key === activeMainSport)?.label ??
                  activeMainSport}
              </div>
            </div>

            <div className="space-y-2">
              {sidebarLeagues.length === 0 && (
                <div className="rounded-lg border border-[#3f2a61]/70 bg-[#1b122b]/70 px-3 py-3 text-sm text-[#c9b8e8]/70">
                  Zatím nebyly načteny žádné ligy.
                </div>
              )}

              {sidebarLeagues.map((leagueName) => {
                const isPinned = pinnedLeagues.includes(leagueName);
                const isFav = favoriteLeagues.includes(leagueName);
                const isActive = activeLeagueName === leagueName;

                return (
                  <div
                    key={leagueName}
                    className={[
                      "rounded-lg border px-3 py-2 transition",
                      isActive
                        ? "border-[#ff7fc8]/70 bg-[#241736]"
                        : "border-[#3f2a61]/70 bg-[#1b122b]/70 hover:bg-[#241736]/70",
                    ].join(" ")}
                  >
                    <button
                      onClick={() => setActiveLeagueName(leagueName)}
                      className="flex w-full items-center justify-between gap-3 text-left"
                    >
                      <div className="min-w-0">
                        <div className="flex items-center gap-2">
                          <Flag code="de" />
                          <div className="truncate text-sm font-medium text-[#f3ecff]">
                            {leagueName}
                          </div>
                        </div>

                        <div className="mt-0.5 text-[11px] text-[#c5b3e4]/70">
                          {isFav ? "oblíbená liga" : "liga"}
                        </div>
                      </div>

                      <div className="flex items-center gap-2">
                        <span
                          onClick={(e) => {
                            e.stopPropagation();
                            toggleFavoriteLeague(leagueName);
                          }}
                          className={[
                            "cursor-pointer text-sm",
                            isFav ? "text-[#ff8bd1]" : "text-[#8d77ad]",
                          ].join(" ")}
                          title="Oblíbená liga"
                        >
                          ★
                        </span>

                        <span
                          onClick={(e) => {
                            e.stopPropagation();
                            togglePinnedLeague(leagueName);
                          }}
                          className={[
                            "cursor-pointer",
                            isPinned ? "text-[#c77dff]" : "text-[#7d689f]",
                          ].join(" ")}
                          title="Připnout do sidebaru"
                        >
                          <IconPin />
                        </span>
                      </div>
                    </button>
                  </div>
                );
              })}
            </div>

            <div className="mt-5 border-t border-[#3a245a]/70 pt-4">
              <div className="text-[11px] font-semibold uppercase tracking-[0.24em] text-[#ff8bd1]">
                Rychlé filtry
              </div>

              <div className="mt-3 flex flex-wrap gap-2">
                {[
                  { key: "today", label: "Dnešní zápasy" },
                  { key: "tomorrow", label: "Zítra" },
                  { key: "week", label: "Týden" },
                  { key: "live", label: "Live" },
                ].map((f) => (
                  <button
                    key={f.key}
                    onClick={() => {
                      if (
                        f.key === "today" ||
                        f.key === "tomorrow" ||
                        f.key === "week"
                      ) {
                        setTab(f.key);
                      }
                    }}
                    className="rounded-lg border border-[#4a2d74]/70 bg-[#191126]/65 px-3 py-2 text-xs text-[#eadfff] transition hover:bg-[#241736]"
                  >
                    {f.label}
                  </button>
                ))}
              </div>
            </div>
          </CardFrame>
        </aside>

        {/* =================================================
           C2) HLAVNÍ OBSAH UPROSTŘED
           -------------------------------------------------
           Obsah:
           - hlavní přehled
           - horní taby
           - 3 malé metrické boxy
           - seznam lig / zápasů
           ================================================= */}
        <main className="col-span-12 lg:col-span-9 xl:col-span-8">
          <div className="space-y-4">
            {/* Hlavní přehled */}
            <CardFrame className="p-4">
              <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
                <div>
                  <div className="text-[11px] font-semibold uppercase tracking-[0.24em] text-[#ff8bd1]">
                    Hlavní přehled
                  </div>
                  <div className="mt-1 text-lg font-semibold text-white">
                    {TAB_LABEL[tab]} •{" "}
                    {SPORTS.find((x) => x.key === activeMainSport)?.label ??
                      "Sport"}
                  </div>
                </div>

                {/* tab tlačítka vpravo */}
                <div className="flex flex-wrap gap-2">
                  {(Object.keys(TAB_LABEL) as TabKey[]).map((k) => (
                    <button
                      key={k}
                      onClick={() => setTab(k)}
                      className={[
                        "rounded-lg border px-4 py-2 text-sm transition",
                        tab === k
                          ? "border-[#ff7fc8]/70 bg-[#261a40] text-white"
                          : "border-[#4a2d74]/70 bg-[#191126]/65 text-[#e3d8f6] hover:bg-[#241736]",
                      ].join(" ")}
                    >
                      {TAB_LABEL[k]}
                    </button>
                  ))}

                  <button
                    onClick={() => setDrawerOpen(true)}
                    className="rounded-lg border border-[#4a2d74]/70 bg-[#191126]/65 px-4 py-2 text-sm text-[#e3d8f6] transition hover:bg-[#241736]"
                  >
                    Tiket ({ticketItems.length})
                  </button>
                </div>
              </div>
            </CardFrame>

            {/* malé karty s metrikami */}
            <div className="grid gap-4 md:grid-cols-3">
              <CardFrame className="p-4">
                <div className="text-xs uppercase tracking-[0.22em] text-[#cdb8ee]/75">
                  Zápasy
                </div>
                <div className="mt-2 text-3xl font-bold text-white">
                  {currentMatches.length}
                </div>
                <div className="mt-1 text-sm text-[#ff8bd1]">
                  aktuálně načteno
                </div>
              </CardFrame>

              <CardFrame className="p-4">
                <div className="text-xs uppercase tracking-[0.22em] text-[#cdb8ee]/75">
                  Aktivní ligy
                </div>
                <div className="mt-2 text-3xl font-bold text-white">
                  {grouped.length}
                </div>
                <div className="mt-1 text-sm text-[#ff8bd1]">
                  ve zvoleném přehledu
                </div>
              </CardFrame>

              <CardFrame className="p-4">
                <div className="text-xs uppercase tracking-[0.22em] text-[#cdb8ee]/75">
                  Ticket Builder
                </div>
                <div className="mt-2 text-3xl font-bold text-white">
                  {ticketItems.length}
                </div>
                <div className="mt-1 text-sm text-[#ff8bd1]">
                  vybraných zápasů
                </div>
              </CardFrame>
            </div>

            {/* načítání / prázdno / ligy */}
            <div className="space-y-4">
              {loading && (
                <CardFrame className="p-6">
                  <div className="text-sm text-[#d2c2ec]">Načítám data…</div>
                </CardFrame>
              )}

              {!loading && grouped.length === 0 && (
                <CardFrame className="p-6">
                  <div className="text-sm text-[#d2c2ec]">
                    Pro zvolený filtr nejsou dostupná data.
                  </div>
                </CardFrame>
              )}

              {!loading &&
                pinnedGroups.map((group) => (
                  <LeagueSection
                    key={`pinned-${group.leagueName}`}
                    group={group}
                    highlighted
                    onTogglePinned={togglePinnedLeague}
                    pinned={pinnedLeagues.includes(group.leagueName)}
                    favorite={favoriteLeagues.includes(group.leagueName)}
                    onToggleFavorite={toggleFavoriteLeague}
                    onPick={setPick}
                  />
                ))}

              {!loading &&
                otherGroups.map((group) => (
                  <LeagueSection
                    key={group.leagueName}
                    group={group}
                    highlighted={false}
                    onTogglePinned={togglePinnedLeague}
                    pinned={pinnedLeagues.includes(group.leagueName)}
                    favorite={favoriteLeagues.includes(group.leagueName)}
                    onToggleFavorite={toggleFavoriteLeague}
                    onPick={setPick}
                  />
                ))}
            </div>
          </div>
        </main>

        {/* =================================================
           C3) PRAVÝ PANEL
           -------------------------------------------------
           Obsah:
           - účet a stav
           - rychlé sporty
           ================================================= */}
        <aside className="col-span-12 xl:col-span-2">
          <div className="space-y-4">
            <CardFrame className="p-4">
              <div className="text-[11px] font-semibold uppercase tracking-[0.24em] text-[#ff8bd1]">
                Účet a stav
              </div>

              <div className="mt-3 space-y-2 text-sm text-[#eadfff]">
                <div className="flex items-center justify-between">
                  <span className="text-[#c8b7e5]">Profil</span>
                  <span>Host</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-[#c8b7e5]">Oblíbené sporty</span>
                  <span>{favoriteSports.length}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-[#c8b7e5]">Oblíbené ligy</span>
                  <span>{favoriteLeagues.length}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-[#c8b7e5]">Vyhodnocení tiketů</span>
                  <span>{favoriteLeagues.length}</span>
                </div>
              </div>
            </CardFrame>

            <CardFrame className="p-4">
              <div className="text-[11px] font-semibold uppercase tracking-[0.24em] text-[#ff8bd1]">
                Rychlé sporty
              </div>

              <div className="mt-3 flex flex-wrap gap-2">
                {SPORTS.map((sport) => {
                  const isFav = favoriteSports.includes(sport.key);
                  const isActive = activeMainSport === sport.key;

                  return (
                    <button
                      key={sport.key}
                      onClick={() => {
                        setActiveMainSport(sport.key);
                        if (!isFav) toggleFavoriteSport(sport.key);
                      }}
                      className={[
                        "rounded-lg border px-3 py-2 text-xs transition",
                        isActive
                          ? "border-[#ff7fc8]/70 bg-[#261a40] text-white"
                          : "border-[#4a2d74]/70 bg-[#191126]/65 text-[#e3d8f6] hover:bg-[#241736]",
                      ].join(" ")}
                    >
                      {sport.label}
                    </button>
                  );
                })}
              </div>
            </CardFrame>
          </div>
        </aside>
      </div>

      {/* ===================================================
         D) FOOTER
         ---------------------------------------------------
         Obsah:
         - obchodní podmínky
         - kontaktní mail
         - GDPR
         - sociální sítě
         =================================================== */}
      <footer className="mt-10 border-t border-[#3a245a]/70 bg-[#120b1f]/95">
        <div className="mx-auto flex max-w-[1600px] flex-col gap-4 px-4 py-6 text-sm text-[#cdbce8] md:flex-row md:items-center md:justify-between md:px-6">
          <div className="flex flex-wrap gap-4">
            <button className="hover:text-white">Obchodní podmínky</button>
            <button className="hover:text-white">Kontaktní e-mail</button>
            <button className="hover:text-white">GDPR</button>
          </div>

          <div className="flex items-center gap-3">
            {["X", "IG", "FB", "YT"].map((s) => (
              <button
                key={s}
                className="flex h-9 w-9 items-center justify-center rounded-lg border border-[#4a2d74]/70 bg-[#191126]/65 text-xs text-[#efdfff] transition hover:bg-[#241736]"
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      </footer>

      {/* ===================================================
         E) TICKET DRAWER
         ---------------------------------------------------
         Pravý vysouvací panel:
         - stake
         - pseudo odds
         - seznam vybraných zápasů
         - změna picku
         =================================================== */}
      {drawerOpen && (
        <div className="fixed inset-0 z-[70]">
          <div
            className="absolute inset-0 bg-black/70"
            onClick={() => setDrawerOpen(false)}
          />

          <div className="absolute right-0 top-0 h-full w-full max-w-[560px] border-l border-[#4a2d74]/70 bg-[#120b1f] shadow-[0_0_60px_rgba(0,0,0,0.35)]">
            <div className="border-b border-[#3a245a]/70 px-5 py-4">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <div className="text-sm font-semibold text-white">
                    Ticket Builder
                  </div>
                  <div className="mt-1 text-xs text-[#c8b7e5]/70">
                    TicketMatrixPlatform • pracovní návrh
                  </div>
                </div>

                <button
                  onClick={() => setDrawerOpen(false)}
                  className="rounded-lg border border-[#4a2d74]/70 bg-[#191126]/65 px-3 py-2 text-xs text-[#eadfff] transition hover:bg-[#241736]"
                >
                  Zavřít
                </button>
              </div>
            </div>

            <div className="border-b border-[#3a245a]/70 px-5 py-4">
              <div className="flex items-center justify-between gap-4">
                <div>
                  <div className="text-xs uppercase tracking-[0.22em] text-[#ff8bd1]">
                    Stake
                  </div>
                  <div className="mt-2">
                    <input
                      value={stake}
                      onChange={(e) => setStake(e.target.value)}
                      className="w-28 rounded-lg border border-[#4a2d74]/70 bg-[#191126]/65 px-3 py-2 text-sm text-white outline-none focus:border-[#ff8bd1]"
                    />
                  </div>
                </div>

                <div className="text-right">
                  <div className="text-xs text-[#c7b5e8]/70">Model odds</div>
                  <div className="mt-1 text-2xl font-bold text-white">
                    {pseudoOdds}
                  </div>
                  <div className="mt-1 text-sm text-[#ff8bd1]">
                    Možná výhra: {possibleWin}
                  </div>
                </div>
              </div>
            </div>

            <div className="h-[calc(100%-230px)] overflow-auto px-4 py-4">
              {ticketItems.length === 0 && (
                <CardFrame className="p-4">
                  <div className="text-sm text-[#d2c2ec]">
                    Zatím nemáš vybrané žádné zápasy.
                  </div>
                </CardFrame>
              )}

              <div className="space-y-3">
                {ticketItems.map((item) => (
                  <CardFrame small key={item.match.match_id} className="p-4">
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <div className="text-xs uppercase tracking-[0.18em] text-[#ff8bd1]">
                          {item.match.league_name}
                        </div>
                        <div className="mt-1 text-sm font-semibold text-white">
                          {item.match.home_team_name} vs{" "}
                          {item.match.away_team_name}
                        </div>
                        <div className="mt-1 text-xs text-[#cdbce8]/75">
                          {formatKickoff(item.match.kickoff_at_local)}
                        </div>
                      </div>

                      <button
                        onClick={() => removeTicket(item.match.match_id)}
                        className="rounded-lg border border-[#4a2d74]/70 bg-[#191126]/65 px-3 py-2 text-xs text-[#eadfff] transition hover:bg-[#241736]"
                      >
                        Odebrat
                      </button>
                    </div>

                    <div className="mt-3 flex flex-wrap gap-2">
                      {PICKS.map((pick) => (
                        <button
                          key={pick}
                          onClick={() => setPick(item.match, pick)}
                          className={[
                            "rounded-lg border px-3 py-2 text-xs transition",
                            item.pick === pick
                              ? "border-[#ff7fc8]/70 bg-[#261a40] text-white"
                              : "border-[#4a2d74]/70 bg-[#191126]/65 text-[#eadfff] hover:bg-[#241736]",
                          ].join(" ")}
                        >
                          {pick}
                        </button>
                      ))}
                    </div>
                  </CardFrame>
                ))}
              </div>
            </div>

            <div className="border-t border-[#3a245a]/70 px-5 py-4">
              <button
                disabled={ticketItems.length === 0}
                className="w-full rounded-lg bg-[#ff8bd1] px-4 py-3 text-sm font-semibold text-[#180f27] transition hover:bg-[#ff72c3] disabled:opacity-40"
              >
                Pokračovat s tiketem
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

/* =========================================================
   6) LEAGUE SECTION
   ========================================================= */

/* ---------------------------------------------------------
   Tady se vykresluje:
   - hlavička ligy
   - pin / favorite
   - jednotlivé zápasy
   - pick tlačítka

   KDYŽ BUDEŠ LADIT:
   - vzhled seznamu zápasů
   - výšku řádků
   - pick tlačítka
   tak upravuj tuto část.
   --------------------------------------------------------- */
function LeagueSection({
  group,
  highlighted,
  onTogglePinned,
  pinned,
  favorite,
  onToggleFavorite,
  onPick,
}: {
  group: { leagueName: string; items: MatchItem[] };
  highlighted: boolean;
  onTogglePinned: (name: string) => void;
  pinned: boolean;
  favorite: boolean;
  onToggleFavorite: (name: string) => void;
  onPick: (match: MatchItem, pick: PickCode) => void;
}) {
  return (
    <CardFrame
      className={[
        highlighted
          ? "bg-[#291945]/95 shadow-[0_0_0_1px_rgba(255,127,200,0.10)]"
          : "shadow-[0_0_0_1px_rgba(140,95,190,0.05)]",
      ].join(" ")}
    >
      {/* hlavička ligy */}
      <div className="border-b border-[#3a245a]/70 bg-[#1a1128]/55 px-4 py-3">
        <div className="flex items-center justify-between gap-3">
          <div className="min-w-0">
            <CompetitionMark
              leagueName={group.leagueName}
              countryCode={group.items[0]?.country_code}
              leagueLogoUrl={group.items[0]?.league_logo_url}
              isCup={group.items[0]?.league_is_cup}
              isInternational={group.items[0]?.league_is_international}
            />

            <div className="mt-1 text-xs text-[#c5b3e4]/70">
              {group.items.length} zápasů
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => onToggleFavorite(group.leagueName)}
              className={[
                "rounded-lg border px-2.5 py-2 text-xs transition",
                favorite
                  ? "border-[#ff8bd1]/70 bg-[#2a183f] text-[#ff8bd1]"
                  : "border-[#4a2d74]/70 bg-[#191126]/65 text-[#d8cbef] hover:bg-[#241736]",
              ].join(" ")}
            >
              ★
            </button>

            <button
              onClick={() => onTogglePinned(group.leagueName)}
              className={[
                "rounded-lg border px-2.5 py-2 text-xs transition",
                pinned
                  ? "border-[#c77dff]/70 bg-[#2a183f] text-[#c77dff]"
                  : "border-[#4a2d74]/70 bg-[#191126]/65 text-[#d8cbef] hover:bg-[#241736]",
              ].join(" ")}
            >
              Pin
            </button>
          </div>
        </div>
      </div>

      {/* zápasy v lize */}
      <div className="px-3 py-3">
        <div className="space-y-3">
          {group.items.map((match) => (
            <div
              key={match.match_id}
              className="border border-[#33214f]/70 bg-[#171021]/78 px-4 py-3 transition hover:bg-[#211631]"
              style={{ borderRadius: "0px" }}
            >
              <div className="flex flex-col gap-3 xl:flex-row xl:items-center xl:justify-between">
                {/* levá část - týmy */}
                <div className="min-w-0 flex-1">
                  <div className="text-xs text-[#c5b3e4]/70">
                    {formatKickoff(match.kickoff_at_local)}
                    {match.status ? ` • ${match.status}` : ""}
                  </div>

                  <div className="mt-2 space-y-2">
                    {/* domácí */}
                    <div className="flex items-center gap-2 min-w-0">
                      <Flag code={match.home_team_country_code} />

                      <div className="truncate text-sm font-semibold text-white">
                        {match.home_team_name}
                      </div>

                      {match.home_team_logo_url ? (
                        <img
                          src={match.home_team_logo_url}
                          alt={match.home_team_name}
                          className="h-5 w-5 shrink-0 object-contain"
                        />
                      ) : (
                        <div className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-[#261a40] text-[9px] font-semibold text-[#ffd6ee]">
                          {initials(match.home_team_name)}
                        </div>
                      )}
                    </div>

                    {/* hosté */}
                    <div className="flex items-center gap-2 min-w-0">
                      <Flag code={match.away_team_country_code} />

                      <div className="truncate text-sm text-[#d8cbef]">
                        {match.away_team_name}
                      </div>

                      {match.away_team_logo_url ? (
                        <img
                          src={match.away_team_logo_url}
                          alt={match.away_team_name}
                          className="h-5 w-5 shrink-0 object-contain"
                        />
                      ) : (
                        <div className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-[#261a40] text-[9px] font-semibold text-[#ffd6ee]">
                          {initials(match.away_team_name)}
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {/* pravá část - pick tlačítka */}
                <div className="flex flex-wrap gap-2">
                  {PICKS.map((pick) => (
                    <button
                      key={pick}
                      onClick={() => onPick(match, pick)}
                      className="rounded-lg border border-[#4a2d74]/70 bg-[#191126]/65 px-3 py-2 text-xs text-[#eadfff] transition hover:bg-[#241736]"
                    >
                      {pick}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </CardFrame>
  );
}