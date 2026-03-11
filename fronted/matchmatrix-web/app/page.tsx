"use client";

/**
 * TicketMatrix – Nabídka (Livesport-like)
 * - /api/leagues/active-week
 * - /api/matches/today
 * - /api/matches/tomorrow
 * - /api/matches/week
 *
 * DEV: Design Panel
 * - klávesa "D" nebo tlačítko "Design" v topbaru
 * - ukládá overrides do localStorage: tm_design_overrides_v1
 */

import React, { useEffect, useMemo, useState } from "react";

type PickCode = "1" | "X" | "2" | "1X" | "12" | "X2";
const PICKS: PickCode[] = ["1", "X", "2", "1X", "12", "X2"];

type LeagueItem = {
  league_id: number;
  league_name: string;
  // Později: country_code, country_name
};

type MatchItem = {
  match_id: number;
  league_id?: number; // pokud v API není, doplníme přes mapování podle league_name (dočasně)
  league_name: string;
  kickoff_at_local: string;
  status?: string;
  home_team_name: string;
  away_team_name: string;
};

type ApiResponse<T> = { count?: number; items: T[]; error?: string };

type TicketItem = { match: MatchItem; pick: PickCode };

type TabKey = "today" | "tomorrow" | "week";
const TAB_LABEL: Record<TabKey, string> = { today: "Dnes", tomorrow: "Zítra", week: "Týden" };

const LS_PINNED = "tm_pinned_leagues_v1";
const LS_FAV = "tm_fav_leagues_v1";

// ============================================================================
// >>> DESIGN BLOCK – DEFAULT (VERZE 2 + středový sloupec)
// Všechno se dá přepsat přes Design Panel (DEV) a ukládá se do localStorage.
// ============================================================================
const DEFAULT_DESIGN = {
  // Page background
  pageWrap: "min-h-screen text-neutral-100",
  pageBg: "bg-[#0f0a17]",

  // Topbar
  topbar: "sticky top-0 z-40 bg-[#151022]/85 border-b border-[#2d2142]/80 backdrop-blur",
  topbarInner: "mx-auto flex max-w-[1400px] items-center justify-between px-6 py-2.5",
  brandTitle: "text-sm font-semibold tracking-wide",
  brandSub: "text-xs text-[#bfb2d4]/70",

  // Tabs + buttons
  tabsWrap: "flex overflow-hidden rounded-lg border border-[#2d2142]/80 bg-[#120d1e]/50",
  tabBtnBase: "px-3 py-1.5 text-xs transition",
  tabBtnActive: "bg-[#241736] text-white",
  tabBtnIdle: "text-[#e9e1ff] hover:bg-[#241736]/70",
  topBtn: "rounded-lg border border-[#2d2142]/80 bg-[#120d1e]/45 px-3 py-1.5 text-xs hover:bg-[#241736]/70 transition",
  topBtnDisabled: "disabled:opacity-40",

  // Layout
  layout: "mx-auto grid max-w-[1400px] grid-cols-12 gap-6 px-6 py-4",

  // Cards
  sidebarCard: "rounded-2xl border border-[#2d2142]/70 bg-[#151022]/70 p-3",
  contentCard: "rounded-2xl border border-[#2d2142]/65 bg-[#151022]/55 overflow-hidden",

  // Content inner (zúžení zápasů do středu)
  contentInner: "mx-auto w-full px-2 sm:px-3 md:w-[86%] lg:w-[80%] xl:w-[70%] 2xl:max-w-[980px]",
  matchRow: "my-1.5 rounded-lg bg-[#120d1e]/35 hover:bg-[#241736]/40 transition px-4 py-2",
  leagueHeader: "bg-[#1d1430] rounded-xl px-4 py-2.5 flex items-center justify-between gap-3",

  // Sidebar titles/dividers
  sidebarSectionTitle: "text-xs font-semibold text-[#efe7ff]/95 uppercase tracking-wider",
  sidebarMuted: "text-xs text-[#f069b3]/65",
  sidebarDivider: "mt-3 border-t border-[#2d2142]/70 pt-3",

  // Sidebar items
  sidebarItemBase:
    "w-full rounded-lg px-2.5 py-2 text-left text-[12px] leading-4 transition flex items-center justify-between gap-2",
  sidebarItemIdle: "bg-[#120d1e]/55 text-[#efe7ff]/90 hover:bg-[#241736]/70",
  sidebarItemActive: "bg-[#241736] text-white",
  sidebarLeft: "flex items-center gap-2 min-w-0",
  flag: "w-5 h-5 grid place-items-center rounded-md bg-[#0f0a17]/40 border border-[#2d2142]/70 text-[12px]",
  leagueName: "truncate",
  sidebarItemRightIcons: "flex items-center gap-2 shrink-0",
  iconFavOn: "text-yellow-300",
  iconFavOff: "text-[#bfb2d4]/55",
  iconPinOn: "text-sky-300",
  iconPinOff: "text-[#bfb2d4]/55",

  // Main header
  mainHeader: "flex items-center justify-between px-4 py-3",
  mainHeaderDivider: "border-b border-[#2d2142]/70",
  mainTitle: "text-sm font-semibold text-[#efe7ff]/95",
  mainHint: "text-xs text-[#bfb2d4]/70",

  // League section
  leagueSectionGap: "py-2",
  leagueHeader: "bg-[#1d1430] mx-1 rounded-xl px-4 py-2.5 flex items-center justify-between gap-3",
  leagueTitle: "text-sm font-semibold text-[#efe7ff] truncate",
  leagueSub: "text-xs text-[#bfb2d4]/70",

  // Match rows (jemné vystínování)
  matchListWrap: "px-0 pb-2",
  matchRow: "mx-1 my-1.5 rounded-lg bg-[#120d1e]/35 hover:bg-[#241736]/40 transition px-4 py-2",
  matchRowSelected: "bg-[#241736]/55 ring-1 ring-emerald-400/30",
  kickoff: "text-[11px] text-[#bfb2d4]/75",
  teams: "text-[13px] font-medium text-[#efe7ff] truncate",
  vs: "text-[#bfb2d4]/70 font-normal",
  picksWrap: "flex flex-wrap justify-end gap-2",

  // Pick buttons
  pickBtnBase: "rounded-lg px-2 py-1 text-[11px] transition",
  pickBtnActive: "bg-emerald-500/20 text-emerald-100 ring-1 ring-emerald-400/35",
  pickBtnIdle: "bg-[#0f0a17]/35 text-[#efe7ff] hover:bg-[#241736]/70 ring-1 ring-[#2d2142]/70",
  pickOddsPlaceholder: "ml-1 text-[#bfb2d4]/55",

  // Bottom bar + drawer
  bottomBar: "fixed bottom-0 left-0 right-0 z-50 border-t border-[#2d2142]/80 bg-[#151022]/85 backdrop-blur",
  bottomBarInner: "mx-auto flex max-w-[1400px] items-center justify-between gap-3 px-6 py-3",
  bottomBtn: "rounded-lg border border-[#2d2142]/80 bg-[#120d1e]/45 px-3 py-2 text-xs hover:bg-[#241736]/70 transition",
  bottomPrimary: "rounded-lg bg-emerald-600 px-3 py-2 text-xs font-semibold text-black hover:bg-emerald-500 transition",

  // Drawer
  drawerBackdrop: "absolute inset-0 bg-black/60",
  drawerPanel: "absolute right-0 top-0 h-full w-full md:w-[520px] lg:w-[50vw] border-l border-[#2d2142]/80 bg-[#0f0a17]",
  drawerHeader: "border-b border-[#2d2142]/80 px-4 py-3 flex items-center justify-between",
  drawerTitle: "text-sm font-semibold text-[#efe7ff]",
  drawerSub: "text-xs text-[#bfb2d4]/70",
  drawerBtn: "rounded-lg border border-[#2d2142]/80 bg-[#120d1e]/45 px-3 py-2 text-xs hover:bg-[#241736]/70 transition",
  drawerSection: "border-b border-[#2d2142]/80 px-4 py-3",
  drawerInput: "w-28 rounded-lg border border-[#2d2142]/80 bg-[#120d1e]/45 px-3 py-2 text-xs outline-none focus:border-emerald-600",
  drawerList: "h-[calc(100%-170px)] overflow-auto",
  drawerItem: "mx-3 my-2 rounded-xl bg-[#120d1e]/45 px-4 py-3",
  drawerFooter: "border-t border-[#2d2142]/80 px-4 py-3",
  drawerCTA: "w-full rounded-xl bg-emerald-600 px-4 py-3 text-sm font-semibold text-black hover:bg-emerald-500 disabled:opacity-40 transition",

 // DEV Design Panel styles (KONTRASTNÍ – světlý panel)
devPanelWrap: "fixed inset-0 z-[80]",
devPanelBackdrop: "absolute inset-0 bg-black/70",

// světlý panel (bílý/šedý) aby byl čitelný
devPanel:
  "absolute right-0 top-0 h-full w-full md:w-[560px] border-l border-neutral-300 bg-white text-neutral-900",

devPanelHeader: "border-b border-neutral-200 px-4 py-3 flex items-center justify-between bg-neutral-50",
devPanelTitle: "text-base font-semibold text-neutral-900",
devPanelSub: "text-xs text-neutral-600",

devPanelBody: "p-4 space-y-3 overflow-auto h-[calc(100%-120px)]",

devInput:
  "w-full rounded-lg border border-neutral-300 bg-white px-3 py-2 text-sm outline-none focus:border-indigo-600 focus:ring-2 focus:ring-indigo-200",
devTextarea:
  "w-full rounded-lg border border-neutral-300 bg-white px-3 py-2 text-sm font-mono outline-none focus:border-indigo-600 focus:ring-2 focus:ring-indigo-200 min-h-[80px]",

devKeyLabel: "text-xs text-neutral-700",

// řádek s klíčem – decentní šedé pozadí
devRow: "rounded-xl border border-neutral-200 bg-neutral-50 p-3",

devFooter: "border-t border-neutral-200 px-4 py-3 flex items-center justify-between gap-2 bg-neutral-50",

devBtn:
  "rounded-lg border border-neutral-300 bg-white px-3 py-2 text-sm hover:bg-neutral-100 transition",
devBtnPrimary:
  "rounded-lg bg-indigo-600 px-3 py-2 text-sm font-semibold text-white hover:bg-indigo-500 transition",
} as const;

type Design = typeof DEFAULT_DESIGN;
type DesignKey = keyof Design;

const LS_DESIGN_OVERRIDES = "tm_design_overrides_v1";

function pickBtnClass(design: Design, active: boolean) {
  return [design.pickBtnBase, active ? design.pickBtnActive : design.pickBtnIdle].join(" ");
}
// ============================================================================

function safeJsonParse<T>(s: string | null, fallback: T): T {
  try {
    if (!s) return fallback;
    return JSON.parse(s) as T;
  } catch {
    return fallback;
  }
}

function formatKickoff(iso: string) {
  try {
    const d = new Date(iso);
    const wd = d.toLocaleDateString("cs-CZ", { weekday: "short" });
    const day = d.toLocaleDateString("cs-CZ", { day: "2-digit", month: "2-digit" });
    const time = d.toLocaleTimeString("cs-CZ", { hour: "2-digit", minute: "2-digit" });
    return `${wd} ${day} ${time}`;
  } catch {
    return iso;
  }
}

export default function Page() {
  const isDev = process.env.NODE_ENV === "development";

  // -------------------- UI state --------------------
  const [tab, setTab] = useState<TabKey>("today");
  const [activeLeagueId, setActiveLeagueId] = useState<number | null>(null);
  const [drawerOpen, setDrawerOpen] = useState(false);

  // -------------------- Design state (DEV panel) --------------------
  const [design, setDesign] = useState<Design>(DEFAULT_DESIGN);
  const [designOpen, setDesignOpen] = useState(false);
  const [designSearch, setDesignSearch] = useState("");
  const [designOverrides, setDesignOverrides] = useState<Partial<Design>>({});

  // načti design overrides
  useEffect(() => {
    if (!isDev) return;
    const saved = safeJsonParse<Partial<Design>>(localStorage.getItem(LS_DESIGN_OVERRIDES), {});
    setDesignOverrides(saved);
    setDesign({ ...DEFAULT_DESIGN, ...saved });
  }, [isDev]);

  // hotkey D pro panel
  useEffect(() => {
    if (!isDev) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key.toLowerCase() === "d" && !e.ctrlKey && !e.metaKey && !e.altKey) {
        setDesignOpen((v) => !v);
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [isDev]);

  function setDesignKey(key: DesignKey, value: string) {
    const nextOverrides: Partial<Design> = { ...designOverrides, [key]: value as any };
    setDesignOverrides(nextOverrides);
    localStorage.setItem(LS_DESIGN_OVERRIDES, JSON.stringify(nextOverrides));
    setDesign({ ...DEFAULT_DESIGN, ...nextOverrides });
  }

  function resetDesignAll() {
    setDesignOverrides({});
    localStorage.removeItem(LS_DESIGN_OVERRIDES);
    setDesign(DEFAULT_DESIGN);
  }

  async function copyDesignJson() {
    const payload = JSON.stringify(designOverrides, null, 2);
    try {
      await navigator.clipboard.writeText(payload);
      alert("Zkopírováno do schránky (overrides JSON).");
    } catch {
      alert("Nelze zkopírovat do schránky. Označ a zkopíruj ručně:\n\n" + payload);
    }
  }

  // -------------------- data state --------------------
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [leagues, setLeagues] = useState<LeagueItem[]>([]);
  const [matches, setMatches] = useState<MatchItem[]>([]);

  // -------------------- user prefs (localStorage) --------------------
  const [pinned, setPinned] = useState<Record<number, boolean>>({});
  const [fav, setFav] = useState<Record<number, boolean>>({});

  // -------------------- ticket --------------------
  const [ticket, setTicket] = useState<Record<number, TicketItem>>({});
  const [stake, setStake] = useState<string>("");

  // 1) načti preference z localStorage
  useEffect(() => {
    const pinnedIds = safeJsonParse<number[]>(localStorage.getItem(LS_PINNED), []);
    const favIds = safeJsonParse<number[]>(localStorage.getItem(LS_FAV), []);
    const p: Record<number, boolean> = {};
    const f: Record<number, boolean> = {};
    pinnedIds.forEach((id) => (p[id] = true));
    favIds.forEach((id) => (f[id] = true));
    setPinned(p);
    setFav(f);
  }, []);

  // 2) ulož preference do localStorage
  useEffect(() => {
    const pinnedIds = Object.entries(pinned)
      .filter(([, v]) => v)
      .map(([k]) => Number(k));
    localStorage.setItem(LS_PINNED, JSON.stringify(pinnedIds));
  }, [pinned]);

  useEffect(() => {
    const favIds = Object.entries(fav)
      .filter(([, v]) => v)
      .map(([k]) => Number(k));
    localStorage.setItem(LS_FAV, JSON.stringify(favIds));
  }, [fav]);

  // 3) load leagues + matches podle tabu
  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      setError(null);

      try {
        // ligy aktivní pro týden (sidebar)
        const leaguesRes = await fetch("/api/leagues/active-week", { cache: "no-store" });
        const leaguesJson = (await leaguesRes.json()) as ApiResponse<LeagueItem>;
        if (!leaguesRes.ok) throw new Error(leaguesJson?.error || `HTTP ${leaguesRes.status}`);
        if (leaguesJson?.error) throw new Error(leaguesJson.error);

        // matches podle tabu
        const endpoint = tab === "today" ? "/api/matches/today" : tab === "tomorrow" ? "/api/matches/tomorrow" : "/api/matches/week";
        const matchesRes = await fetch(endpoint, { cache: "no-store" });
        const matchesJson = (await matchesRes.json()) as ApiResponse<MatchItem>;
        if (!matchesRes.ok) throw new Error(matchesJson?.error || `HTTP ${matchesRes.status}`);
        if (matchesJson?.error) throw new Error(matchesJson.error);

        const leaguesItems = Array.isArray(leaguesJson.items) ? leaguesJson.items : [];
        const matchItems = Array.isArray(matchesJson.items) ? matchesJson.items : [];

        // řazení zápasů
        matchItems.sort((a, b) => new Date(a.kickoff_at_local).getTime() - new Date(b.kickoff_at_local).getTime());

        // pokud matches nemají league_id, doplníme ho mapou podle league_name (dočasně)
        const nameToId = new Map<string, number>();
        leaguesItems.forEach((l) => nameToId.set(l.league_name, l.league_id));
        matchItems.forEach((m) => {
          if (m.league_id == null) m.league_id = nameToId.get(m.league_name) ?? -1;
        });

        if (!cancelled) {
          setLeagues(leaguesItems);

          // ✅ NEPŘEPISUJ aktivní ligu, pokud už ji uživatel vybral
          setActiveLeagueId((prev) => {
            if (prev !== null) return prev;
            const pinnedList = leaguesItems.filter((l) => pinned[l.league_id]);
            return pinnedList[0]?.league_id ?? null; // null = Vše
          });

          setMatches(matchItems);
        }
      } catch (e: any) {
        if (!cancelled) setError(e?.message || "Chyba při načítání.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    load();
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tab]);

  // -------------------- grouping matches by league --------------------
  const grouped = useMemo(() => {
    const map = new Map<number, { league_id: number; league_name: string; items: MatchItem[] }>();
    for (const m of matches) {
      const id = m.league_id ?? -1;
      if (activeLeagueId != null && id !== activeLeagueId) continue;

      if (!map.has(id)) map.set(id, { league_id: id, league_name: m.league_name, items: [] });
      map.get(id)!.items.push(m);
    }

    // pinned ligy nahoře, pak podle názvu
    const arr = Array.from(map.values());
    arr.sort((a, b) => {
      const ap = pinned[a.league_id] ? 1 : 0;
      const bp = pinned[b.league_id] ? 1 : 0;
      if (ap !== bp) return bp - ap;
      return a.league_name.localeCompare(b.league_name, "cs-CZ");
    });
    return arr;
  }, [matches, activeLeagueId, pinned]);

  const pinnedLeagues = useMemo(() => leagues.filter((l) => pinned[l.league_id]), [leagues, pinned]);
  const otherLeagues = useMemo(() => leagues.filter((l) => !pinned[l.league_id]), [leagues, pinned]);

  const ticketCount = useMemo(() => Object.keys(ticket).length, [ticket]);

  // -------------------- actions --------------------
  function togglePinned(league_id: number) {
    setPinned((p) => ({ ...p, [league_id]: !p[league_id] }));
  }

  function toggleFav(league_id: number) {
    setFav((f) => ({ ...f, [league_id]: !f[league_id] }));
  }

  function selectPick(match: MatchItem, pick: PickCode) {
    setTicket((prev) => ({ ...prev, [match.match_id]: { match, pick } }));
  }

  function removeFromTicket(match_id: number) {
    setTicket((prev) => {
      const next = { ...prev };
      delete next[match_id];
      return next;
    });
  }

  function clearTicket() {
    setTicket({});
    setDrawerOpen(false);
  }

  // -------------------- Design panel content --------------------
  const designKeys = useMemo(() => Object.keys(DEFAULT_DESIGN) as DesignKey[], []);
  const filteredDesignKeys = useMemo(() => {
    const q = designSearch.trim().toLowerCase();
    if (!q) return designKeys;
    return designKeys.filter((k) => String(k).toLowerCase().includes(q));
  }, [designKeys, designSearch]);

  // -------------------- render --------------------
  return (
    <div className={`${design.pageWrap} ${design.pageBg}`}>
      {/* TOP BAR */}
      <header className={design.topbar}>
        <div className={design.topbarInner}>
          <div className="flex flex-col gap-0.5 py-2 px-1">
            <div className="font-black text-xl tracking-tighter uppercase italic text-white leading-tight">
              TICKET<span className="text-[#A855F7] opacity-90">MATRIX</span>
            </div>
            <div className="text-[9px] text-purple-400/40 font-medium italic tracking-wider uppercase ml-0.5">
              powered by MatchMatrix
            </div>
          </div>

          <div className="flex items-center gap-2">
            <div className={design.tabsWrap}>
              {(["today", "tomorrow", "week"] as TabKey[]).map((k) => (
                <button
                  key={k}
                  className={[
                    design.tabBtnBase,
                    tab === k ? design.tabBtnActive : design.tabBtnIdle,
                  ].join(" ")}
                  onClick={() => setTab(k)}
                >
                  {TAB_LABEL[k]}
                </button>
              ))}
            </div>

            <button className={design.topBtn} onClick={() => window.location.reload()}>
              Refresh
            </button>

            {isDev && (
              <button className={design.topBtn} onClick={() => setDesignOpen(true)} title='Otevřít Design Panel (klávesa "D")'>
                Design
              </button>
            )}

            <button
              className={[design.topBtn, design.topBtnDisabled].join(" ")}
              disabled={ticketCount === 0}
              onClick={() => setDrawerOpen(true)}
              title={ticketCount === 0 ? "Nejdřív vyber zápas" : "Otevřít tiket"}
            >
              Tiket ({ticketCount})
            </button>
          </div>
        </div>
      </header>

      {/* LAYOUT */}
      <main className={design.layout}>
        {/* SIDEBAR */}
        <aside className="col-span-12 md:col-span-4 lg:col-span-3">
          <div className={design.sidebarCard}>
            <div className={design.sidebarSectionTitle}>Připnuté ligy</div>

            <div className="mt-2 space-y-2">
              {pinnedLeagues.length === 0 && <div className={design.sidebarMuted}>Zatím nic připnuto.</div>}

              {pinnedLeagues.map((l) => (
                <button
                  key={l.league_id}
                  className={[
                    design.sidebarItemBase,
                    activeLeagueId === l.league_id ? design.sidebarItemActive : design.sidebarItemIdle,
                  ].join(" ")}
                  onClick={() => setActiveLeagueId(l.league_id)}
                >
                  <div className={design.sidebarLeft}>
                    <span className={design.flag}>🏳️</span>
                    <span className={design.leagueName}>{l.league_name}</span>
                  </div>

                  <span className={design.sidebarItemRightIcons}>
                    <span
                      className={`text-xs ${fav[l.league_id] ? design.iconFavOn : design.iconFavOff}`}
                      onClick={(e) => {
                        e.preventDefault();
                        e.stopPropagation();
                        toggleFav(l.league_id);
                      }}
                      title="Oblíbené"
                    >
                      ★
                    </span>

                    <span
                      className={`text-xs ${design.iconPinOn}`}
                      onClick={(e) => {
                        e.preventDefault();
                        e.stopPropagation();
                        togglePinned(l.league_id);
                      }}
                      title="Odepnout"
                    >
                      📌
                    </span>
                  </span>
                </button>
              ))}
            </div>

            <div className={design.sidebarDivider}>
              <div className={design.sidebarSectionTitle}>Ligy</div>

              <div className="mt-2 space-y-2 max-h-[50vh] overflow-auto pr-1">
                <button
                  className={[
                    design.sidebarItemBase,
                    activeLeagueId === null ? design.sidebarItemActive : design.sidebarItemIdle,
                  ].join(" ")}
                  onClick={() => setActiveLeagueId(null)}
                >
                  <div className={design.sidebarLeft}>
                    <span className={design.flag}>🌍</span>
                    <span className={design.leagueName}>Vše</span>
                  </div>
                </button>

                {otherLeagues.map((l) => (
                  <button
                    key={l.league_id}
                    className={[
                      design.sidebarItemBase,
                      activeLeagueId === l.league_id ? design.sidebarItemActive : design.sidebarItemIdle,
                    ].join(" ")}
                    onClick={() => setActiveLeagueId(l.league_id)}
                  >
                    <div className={design.sidebarLeft}>
                      <span className={design.flag}>🏳️</span>
                      <span className={design.leagueName}>{l.league_name}</span>
                    </div>

                    <span className={design.sidebarItemRightIcons}>
                      <span
                        className={`text-xs ${fav[l.league_id] ? design.iconFavOn : design.iconFavOff}`}
                        onClick={(e) => {
                          e.preventDefault();
                          e.stopPropagation();
                          toggleFav(l.league_id);
                        }}
                        title="Oblíbené"
                      >
                        ★
                      </span>

                      <span
                        className={`text-xs ${pinned[l.league_id] ? design.iconPinOn : design.iconPinOff}`}
                        onClick={(e) => {
                          e.preventDefault();
                          e.stopPropagation();
                          togglePinned(l.league_id);
                        }}
                        title="Připnout"
                      >
                        📌
                      </span>
                    </span>
                  </button>
                ))}
              </div>
            </div>
          </div>
        </aside>

        {/* MAIN LIST */}
        <section className="col-span-12 md:col-span-8 lg:col-span-9">
          <div className={design.contentCard}>
            <div className={[design.mainHeader, design.mainHeaderDivider].join(" ")}>
              <div className={design.mainTitle}>
                {tab === "today" ? "Dnešní zápasy" : tab === "tomorrow" ? "Zítřejší zápasy" : "Zápasy (týden)"}
              </div>
              <div className={design.mainHint}>Teď bez kurzů. Kurzy naskočí po výběru bookmakera.</div>
            </div>

            {loading && <div className="p-4 text-sm text-[#bfb2d4]/80">Načítám…</div>}
            {error && <div className="p-4 text-sm text-red-300">Chyba: {error}</div>}
            {!loading && !error && grouped.length === 0 && <div className="p-4 text-sm text-[#bfb2d4]/80">Nic k zobrazení.</div>}

            {/* ✅ Středový sloupec pro zápasy */}
            <div className={design.contentInner}>
              {!loading &&
                !error &&
                grouped.map((g) => (
                  <div key={`${g.league_id}-${g.league_name}`} className={design.leagueSectionGap}>
                    <div className={design.leagueHeader}>
                      <div className="min-w-0">
                        <div className={design.leagueTitle}>{g.league_name}</div>
                        <div className={design.leagueSub}>{g.items.length} zápasů</div>
                      </div>

                      <div className="flex items-center gap-2">
                        <span className={`text-xs ${fav[g.league_id] ? design.iconFavOn : design.iconFavOff}`}>★</span>
                        <span className={`text-xs ${pinned[g.league_id] ? design.iconPinOn : design.iconPinOff}`}>📌</span>
                      </div>
                    </div>

                    <div className={design.matchListWrap}>
                      {g.items.map((m) => {
                        const picked = ticket[m.match_id]?.pick ?? null;

                        return (
                          <div
                            key={m.match_id}
                            className={[design.matchRow, picked ? design.matchRowSelected : ""].join(" ")}
                          >
                            <div className="flex items-start justify-between gap-3">
                              <div className="min-w-0">
                                <div className={design.kickoff}>{formatKickoff(m.kickoff_at_local)}</div>
                                <div className={design.teams}>
                                  {m.home_team_name} <span className={design.vs}>vs</span> {m.away_team_name}
                                </div>
                              </div>

                              <div className={design.picksWrap}>
                                {PICKS.map((p) => (
                                  <button
                                    key={p}
                                    className={pickBtnClass(design, picked === p)}
                                    onClick={() => selectPick(m, p)}
                                  >
                                    {p}
                                    <span className={design.pickOddsPlaceholder}>—</span>
                                  </button>
                                ))}
                              </div>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                ))}
            </div>
          </div>
        </section>
      </main>

      {/* BOTTOM BAR */}
      {ticketCount > 0 && (
        <div className={design.bottomBar}>
          <div className={design.bottomBarInner}>
            <div className="text-sm">
              Tiket: <span className="font-semibold">{ticketCount}</span> výběrů • Celkový kurz:{" "}
              <span className="font-semibold">—</span>
            </div>
            <div className="flex items-center gap-2">
              <button className={design.bottomBtn} onClick={clearTicket}>
                Vyčistit
              </button>
              <button className={design.bottomPrimary} onClick={() => setDrawerOpen(true)}>
                Otevřít tiket
              </button>
            </div>
          </div>
        </div>
      )}

      {/* RIGHT DRAWER */}
      {drawerOpen && (
        <div className="fixed inset-0 z-[60]">
          <div className={design.drawerBackdrop} onClick={() => setDrawerOpen(false)} />
          <div className={design.drawerPanel}>
            <div className={design.drawerHeader}>
              <div>
                <div className={design.drawerTitle}>Tiket</div>
                <div className={design.drawerSub}>Vybráno: {ticketCount}</div>
              </div>
              <div className="flex items-center gap-2">
                <button className={design.drawerBtn} onClick={clearTicket}>
                  Vyčistit vše
                </button>
                <button className={design.drawerBtn} onClick={() => setDrawerOpen(false)}>
                  Zavřít
                </button>
              </div>
            </div>

            <div className={design.drawerSection}>
              <div className="flex items-center justify-between gap-3">
                <div className={design.drawerSub}>
                  Celkový kurz: <span className="text-neutral-100 font-semibold">—</span>
                </div>

                <div className="flex items-center gap-2">
                  <div className={design.drawerSub}>Sázka</div>
                  <input
                    value={stake}
                    onChange={(e) => setStake(e.target.value)}
                    placeholder="např. 200"
                    className={design.drawerInput}
                    inputMode="decimal"
                  />
                </div>
              </div>
            </div>

            <div className={design.drawerList}>
              {ticketCount === 0 ? (
                <div className="p-4 text-sm text-[#bfb2d4]/80">Tiket je prázdný.</div>
              ) : (
                <div className="py-2">
                  {Object.values(ticket)
                    .slice()
                    .sort((a, b) => new Date(a.match.kickoff_at_local).getTime() - new Date(b.match.kickoff_at_local).getTime())
                    .map((t) => (
                      <div key={t.match.match_id} className={design.drawerItem}>
                        <div className="flex items-start justify-between gap-3">
                          <div className="min-w-0">
                            <div className={design.kickoff}>{formatKickoff(t.match.kickoff_at_local)}</div>
                            <div className="text-[13px] font-medium text-[#efe7ff] truncate">
                              {t.match.home_team_name} <span className={design.vs}>vs</span> {t.match.away_team_name}
                            </div>
                            <div className="text-xs text-[#bfb2d4]/70 truncate">{t.match.league_name}</div>
                            <div className="mt-1 text-xs text-[#bfb2d4]/80">
                              Volba: <span className="font-semibold text-neutral-100">{t.pick}</span>{" "}
                              <span className="text-[#bfb2d4]/55">(kurz —)</span>
                            </div>
                          </div>
                          <button className={design.drawerBtn} onClick={() => removeFromTicket(t.match.match_id)}>
                            Odebrat
                          </button>
                        </div>
                      </div>
                    ))}
                </div>
              )}
            </div>

            <div className={design.drawerFooter}>
              <button
                className={design.drawerCTA}
                disabled={ticketCount === 0}
                onClick={() => alert("Další krok: Varianta/Tabulka tiketů + predikce + výstupy.")}
              >
                Pokračovat (další krok)
              </button>
            </div>
          </div>
        </div>
      )}

      {/* DEV: DESIGN PANEL */}
      {isDev && designOpen && (
        <div className={design.devPanelWrap}>
          <div className={design.devPanelBackdrop} onClick={() => setDesignOpen(false)} />
          <div className={design.devPanel}>
            <div className={design.devPanelHeader}>
              <div>
                <div className={design.devPanelTitle}>Design Panel</div>
                <div className={design.devPanelSub}>
                  Klávesa <b>D</b> • Overrides v localStorage • Měň “className” hodnoty
                </div>
              </div>
              <button className={design.devBtn} onClick={() => setDesignOpen(false)}>
                Zavřít
              </button>
            </div>

            <div className={design.devPanelBody}>
              <div className={design.devRow}>
                <div className={design.devKeyLabel}>Filtrovat klíče</div>
                <input
                  className={design.devInput}
                  value={designSearch}
                  onChange={(e) => setDesignSearch(e.target.value)}
                  placeholder="např. matchRow, leagueHeader, contentInner…"
                />
              </div>

              {filteredDesignKeys.map((k) => {
                const key = k as DesignKey;
                const current = design[key];
                const overridden = key in designOverrides;
                return (
                  <div key={String(key)} className={design.devRow}>
                    <div className="flex items-center justify-between gap-3">
                      <div className={design.devKeyLabel}>
                        <b>{String(key)}</b> {overridden ? "• override" : ""}
                      </div>
                      {overridden && (
                        <button
                          className={design.devBtn}
                          onClick={() => {
                            const next = { ...designOverrides };
                            delete (next as any)[key];
                            setDesignOverrides(next);
                            localStorage.setItem(LS_DESIGN_OVERRIDES, JSON.stringify(next));
                            setDesign({ ...DEFAULT_DESIGN, ...next });
                          }}
                        >
                          Zrušit override
                        </button>
                      )}
                    </div>

                    <textarea
                      className={design.devTextarea}
                      value={current}
                      onChange={(e) => setDesignKey(key, e.target.value)}
                    />
                  </div>
                );
              })}
            </div>

            <div className={design.devFooter}>
              <div className="flex items-center gap-2">
                <button className={design.devBtn} onClick={copyDesignJson}>
                  Copy overrides JSON
                </button>
                <button className={design.devBtn} onClick={resetDesignAll}>
                  Reset vše
                </button>
              </div>

              <button
                className={design.devBtnPrimary}
                onClick={() => alert('Tip: zkus upravit "contentInner", "matchRow", "leagueHeader", "sidebarItemBase".')}
              >
                Tipy co ladit
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Spacer kvůli bottom baru */}
      <div className="h-16" />
    </div>
  );
}