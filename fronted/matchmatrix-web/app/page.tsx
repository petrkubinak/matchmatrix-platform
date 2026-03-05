'use client';
import { useEffect, useState } from 'react';
import MatrixCalculator from '../components/MatrixCalculator';

// Definice struktury zápasu podle vašeho SQL view
interface Match {
  match_id: string;
  home_team_name: string;
  away_team_name: string;
  league_name: string;
  kickoff_at_local: string;
}

export default function Home() {
  const [matches, setMatches] = useState<Match[]>([]);
  const [selectedMatch, setSelectedMatch] = useState<Match | null>(null);
  const [loading, setLoading] = useState(true);

  // Načtení dat z vašeho API endpointu
  useEffect(() => {
    async function loadMatches() {
      try {
        const res = await fetch('/api/matches/today');
        const data = await res.json();
        setMatches(data.items || []); // Data jsou v klíči "items"
      } catch (err) {
        console.error("Chyba při načítání zápasů:", err);
      } finally {
        setLoading(false);
      }
    }
    loadMatches();
  }, []);

  return (
    <main className="min-h-screen bg-[#0F0A18] text-white p-8 font-sans">
      <div className="max-w-6xl mx-auto mb-12 flex justify-between items-end border-b border-white/5 pb-4">
        <div>
          <h1 className="text-3xl font-thin tracking-[0.5em] uppercase text-purple-200">TicketMatrix</h1>
          <p className="text-[10px] tracking-[0.2em] text-purple-500/60 mt-2 font-bold italic uppercase">
            Live Feed: DB_SEZONY_TYMY
          </p>
        </div>
      </div>

      <div className="max-w-6xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* LEVÝ SLOUPEC: Seznam zápasů z DB */}
        <div className="lg:col-span-1 space-y-4">
          <h2 className="text-xs font-bold tracking-widest text-purple-400 uppercase mb-4 italic">
            Dnešní zápasy ({matches.length})
          </h2>
          
          {loading ? (
            <div className="animate-pulse text-gray-600 text-xs">Načítám data z Postgresu...</div>
          ) : (
            matches.map((m) => (
              <div 
                key={m.match_id}
                onClick={() => setSelectedMatch(m)}
                className={`p-4 rounded-xl border cursor-pointer transition-all ${
                  selectedMatch?.match_id === m.match_id 
                    ? 'bg-purple-500/20 border-purple-500 shadow-lg' 
                    : 'bg-white/5 border-white/5 hover:border-purple-500/30'
                }`}
              >
                <div className="text-[10px] text-purple-400/60 mb-1">{m.league_name}</div>
                <div className="text-sm font-light">
                  {m.home_team_name} <span className="mx-2 text-purple-500/30">vs</span> {m.away_team_name}
                </div>
                <div className="text-[9px] mt-2 text-gray-500 italic">
                  Start: {new Date(m.kickoff_at_local).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                </div>
              </div>
            ))
          )}
        </div>

        {/* PRAVÝ SLOUPEC: Kalkulačka pro vybraný zápas */}
        <div className="lg:col-span-2">
          {selectedMatch ? (
            <div className="animate-in fade-in duration-500">
              <div className="bg-white/5 p-6 rounded-2xl border border-white/5 mb-6">
                <span className="text-[10px] text-green-500 font-bold tracking-widest uppercase">Aktivní analýza</span>
                <h2 className="text-2xl font-thin mt-1 italic">{selectedMatch.home_team_name} vs {selectedMatch.away_team_name}</h2>
              </div>
              
              {/* Zde voláme naši matici - kurzy zatím simulujeme, dokud nebudou v API */}
              <MatrixCalculator 
                odds={{ home: 2.15, draw: 3.40, away: 3.10 }} 
                stake={100} 
              />
            </div>
          ) : (
            <div className="h-full flex items-center justify-center border-2 border-dashed border-white/5 rounded-2xl p-12 text-gray-600 italic text-sm">
              Vyberte zápas ze seznamu pro spuštění TicketMatrixu
            </div>
          )}
        </div>
      </div>
    </main>
  );
}