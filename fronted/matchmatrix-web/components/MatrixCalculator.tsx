'use client';
import React, { useState } from 'react';

interface Props {
  odds: { home: number; draw: number; away: number };
  stake: number;
}

export default function MatrixCalculator({ odds, stake }: Props) {
  const [selected, setSelected] = useState<number[]>([]);

  const toggleTicket = (id: number) => {
    setSelected(prev => 
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    );
  };

  const getCombination = (index: number) => {
    const outcomes = ['1', 'X', '2'];
    const m1 = outcomes[Math.floor(index / 9) % 3];
    const m2 = outcomes[Math.floor(index / 3) % 3];
    const m3 = outcomes[index % 3];
    return [m1, m2, m3];
  };

  const oddsMap: Record<string, number> = { '1': odds.home, 'X': odds.draw, '2': odds.away };
  const varianty = Array.from({ length: 27 }, (_, i) => i);

  return (
    <div className="mt-8 p-1">
      {/* JEMNÁ HLAVIČKA */}
      <div className="flex justify-between items-center mb-6 px-2">
        <h3 className="text-sm font-light tracking-[0.4em] text-purple-300/60 uppercase italic">
          Kombinační matice
        </h3>
        <div className="text-[11px] font-medium text-purple-400/80 bg-purple-500/5 px-4 py-1.5 rounded-full border border-purple-500/10">
          INVESTICE: <span className="text-white ml-1">{selected.length * stake} Kč</span>
        </div>
      </div>
      
      {/* ČISTÁ MŘÍŽKA BEZ TĚŽKÝCH ČAR */}
      <div className="grid grid-cols-3 md:grid-cols-9 gap-2">
        {varianty.map((i) => {
          const combo = getCombination(i);
          const totalOdds = combo.reduce((acc, tip) => acc * oddsMap[tip], 1);
          const potentialWin = (totalOdds * stake).toFixed(0);
          const isSelected = selected.includes(i);

          return (
            <div 
              key={i} 
              onClick={() => toggleTicket(i)}
              className={`cursor-pointer group transition-all duration-300 p-4 rounded-lg border text-center ${
                isSelected 
                  ? 'bg-green-500/10 border-green-500/40 shadow-sm scale-[1.02]' 
                  : 'bg-transparent border-white/5 hover:border-purple-500/20'
              }`}
            >
              {/* VÝRAZNÁ KOMBINACE */}
              <div className={`text-[12px] font-black tracking-widest mb-2 ${
                isSelected ? 'text-green-400' : 'text-purple-300/40'
              }`}>
                {combo.join(' ')}
              </div>
              
              {/* ČÁSTKA - ČISTÁ A JASNÁ */}
              <div className={`text-xl font-light tracking-tighter ${
                isSelected ? 'text-white' : 'text-gray-500'
              }`}>
                {potentialWin}
              </div>
              
              {/* KURZ - JEMNÁ KURZÍVA (DETAILNÍ POPIS) */}
              <div className={`text-[9px] mt-1 italic font-light ${
                isSelected ? 'text-green-500/60' : 'text-gray-700'
              }`}>
                kurz {totalOdds.toFixed(2)}
              </div>
            </div>
          );
        })}
      </div>

      {/* NEVTÍRAVÉ TLAČÍTKO */}
      {selected.length > 0 && (
        <div className="mt-8 flex justify-center">
          <button className="text-[10px] font-bold tracking-[0.3em] uppercase py-3 px-12 border border-green-500/30 text-green-500/80 hover:bg-green-500 hover:text-black rounded-full transition-all duration-500 italic">
            Potvrdit výběr ({selected.length})
          </button>
        </div>
      )}
    </div>
  );
}