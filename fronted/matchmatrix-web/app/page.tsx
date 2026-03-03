import MatrixCalculator from '@/components/MatrixCalculator';
export default function Home() {
  return (
    <main className="min-h-screen p-8 bg-brand-bg text-white">
      {/* Horní lišta s názvem */}
      <div className="max-w-6xl mx-auto mb-10 border-b border-purple-500/30 pb-4">
        <h1 className="text-3xl font-black text-brand-accent tracking-tighter">TICKETMATRIX</h1>
        <p className="text-sm text-purple-300 uppercase tracking-widest">Database: DB_SEZONY_TYMY</p>
      </div>

      {/* Hlavní kontejner pro tabulku */}
      <div className="max-w-6xl mx-auto bg-brand-panel rounded-2xl shadow-2xl overflow-hidden border border-purple-500/20">
        <div className="p-6 border-b border-purple-500/20 bg-black/20">
          <h2 className="text-xl font-semibold">Aktuální zápasy k analýze</h2>
        </div>
        
        <div className="p-0">
          <table className="w-full text-left">
            <thead className="bg-black/40 text-purple-200 text-xs uppercase">
              <tr>
                <th className="p-4">Zápas (ID)</th>
                <th className="p-4">Domácí vs Hosté</th>
                <th className="p-4 text-center">Kurzy (1-X-2)</th>
                <th className="p-4 text-right">Výpočet</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-purple-500/10">
              <tr className="hover:bg-white/5 transition-colors">
                <td className="p-4 text-purple-400 font-mono text-sm">#M-2703</td>
                <td className="p-4 font-bold text-lg">Arsenal vs Liverpool</td>              
                <td className="p-4">
                   <div className="flex gap-2 justify-center">
                      <span className="bg-brand-bg px-3 py-1 rounded border border-purple-500/30 text-green-400">2.15</span>
                      <span className="bg-brand-bg px-3 py-1 rounded border border-purple-500/30 text-green-400">3.40</span>
                      <span className="bg-brand-bg px-3 py-1 rounded border border-purple-500/30 text-green-400">3.10</span>
                   </div>
                </td>
                <td className="p-4 text-right">
                  <button className="bg-brand-accent hover:brightness-125 text-brand-bg font-bold px-6 py-2 rounded-full text-sm transition-all shadow-lg shadow-purple-500/20">
                    Generovat 27 variant
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <MatrixCalculator 
        odds={{ home: 2.15, draw: 3.40, away: 3.10 }} 
        stake={100} 
      />
    </main>
  );
}