import { useState, useEffect, useCallback, useRef } from "react";

/* ═══════════════════════════════════════════════════════════════
   CORTEX — THE MECHANIC IS THE SKILL
   
   6 interactive formats that TEACH, not test:
   
   🔬 HIGHLIGHT  — Tap the EXACT flaw in the text
   ⚖️ SCALE      — Drag evidence to tip argument scale  
   🔗 CHAIN      — Build consequence chain (drag to timeline)
   🎚️ SLIDER     — Set probability, see reality (calibration)
   ✏️ REWRITE    — Fix the broken argument by swapping words
   ⚔️ CLASSIC    — Upgraded pick-one (for variety)
   
   Each teaches the CONCEPT first via visual metaphor,
   then asks you to APPLY it.
   ═══════════════════════════════════════════════════════════════ */

const P = {
  bg: "#120a28", sf: "#1a1040", sf2: "#221455", bdr: "#3a2080",
  red: "#ff4858", redS: "#cc3a47", blue: "#45a3f1", blueS: "#3682c1",
  green: "#26d782", greenS: "#1fac68", yellow: "#ffba08", yellowS: "#cc9506",
  main: "#c77dff", mainS: "#9d4edd", teal: "#00f5d4", tealS: "#00c4a8",
  mag: "#f72585", magS: "#c51e6a", lime: "#b5e48c", gold: "#ffd60a",
  goldBg: "rgba(255,214,10,.08)", tealBg: "rgba(0,245,212,.08)",
  magBg: "rgba(247,37,133,.08)",
  txt: "#f0e6ff", dim: "#a89cc8", mut: "#6b5b95",
};
const F = "'Nunito',sans-serif";

// Sound + Haptics (compact)
const Snd = { c: null, i() { if (!this.c) this.c = new (window.AudioContext || window.webkitAudioContext)(); return this.c; },
  p(f,d,v=.06,t="sine"){try{const c=this.i(),o=c.createOscillator(),g=c.createGain();o.type=t;o.frequency.value=f;o.connect(g);g.connect(c.destination);g.gain.setValueAtTime(0,c.currentTime);g.gain.linearRampToValueAtTime(v,c.currentTime+.006);g.gain.linearRampToValueAtTime(0,c.currentTime+d);o.start();o.stop(c.currentTime+d)}catch{}},
  ok(n=0){const b=520+n*55;this.p(b,.06,.05+n*.003);setTimeout(()=>this.p(b*1.25,.08,.06),50);if(n>=3)setTimeout(()=>this.p(b*1.5,.08,.06),100)},
  no(){this.p(280,.1,.03,"triangle");setTimeout(()=>this.p(240,.12,.025,"triangle"),70)},
  tap(){this.p(1100,.01,.02)},
  go(){[523,659,784,1047].forEach((f,i)=>setTimeout(()=>this.p(f,.06,.04+i*.005),i*80))},
  lv(){[523,659,784,988,1175].forEach((f,i)=>setTimeout(()=>this.p(f,.08,.055),i*65))},
  slide(){this.p(800,.03,.03)},
  chain(){this.p(660,.05,.04);setTimeout(()=>this.p(880,.05,.04),80)},
  reveal(){this.p(440,.06,.04);setTimeout(()=>this.p(554,.07,.05),100);setTimeout(()=>this.p(660,.08,.05),200)},
};
const H={l(){try{navigator.vibrate?.(5)}catch{}},s(){try{navigator.vibrate?.([8,22,8,22,12])}catch{}},e(){try{navigator.vibrate?.([30,12,30])}catch{}},big(){try{navigator.vibrate?.([12,12,12,12,25])}catch{}}};

// Confetti
function Boom({trigger,n=40,mega}){const ref=useRef(null),an=useRef(null);useEffect(()=>{if(!trigger)return;const cv=ref.current;if(!cv)return;const ctx=cv.getContext("2d"),w=cv.width=cv.offsetWidth*2,h=cv.height=cv.offsetHeight*2;ctx.scale(2,2);const cs=[P.teal,P.mag,P.lime,P.gold,"#fff",P.blue,P.main,P.red,P.green,P.yellow];const sc=mega?1.7:1;const pts=Array.from({length:n},()=>{const a=Math.random()*Math.PI*2,sp=(2+Math.random()*6)*sc;return{x:w/4,y:h/(mega?3:4),vx:Math.cos(a)*sp,vy:Math.sin(a)*sp-3*sc,s:(2.5+Math.random()*5.5)*sc,c:cs[~~(Math.random()*cs.length)],l:1,d:.006+Math.random()*.012,r:Math.random()*360,rs:(Math.random()-.5)*9}});const loop=()=>{ctx.clearRect(0,0,w/2,h/2);let alive=false;pts.forEach(p=>{if(p.l<=0)return;alive=true;p.x+=p.vx;p.y+=p.vy;p.vy+=.055;p.l-=p.d;p.r+=p.rs;ctx.save();ctx.translate(p.x,p.y);ctx.rotate(p.r*Math.PI/180);ctx.globalAlpha=Math.max(0,p.l);ctx.fillStyle=p.c;const sh=~~(p.r)%3;if(sh===0){ctx.fillRect(-p.s/2,-p.s/2,p.s,p.s)}else if(sh===1){ctx.beginPath();ctx.arc(0,0,p.s/2,0,Math.PI*2);ctx.fill()}else{ctx.beginPath();ctx.moveTo(0,-p.s/2);ctx.lineTo(p.s/3,0);ctx.lineTo(0,p.s/2);ctx.lineTo(-p.s/3,0);ctx.fill()}ctx.restore()});if(alive)an.current=requestAnimationFrame(loop)};loop();return()=>cancelAnimationFrame(an.current)},[trigger,n,mega]);return <canvas ref={ref} style={{position:"absolute",inset:0,pointerEvents:"none",width:"100%",height:"100%",zIndex:50}}/>}

function Stars(){const ref=useRef(null),an=useRef(null);useEffect(()=>{const cv=ref.current;if(!cv)return;const ctx=cv.getContext("2d"),w=cv.width=cv.offsetWidth*2,h=cv.height=cv.offsetHeight*2;ctx.scale(2,2);const stars=Array.from({length:25},()=>({x:Math.random()*w/2,y:Math.random()*h/2,s:.4+Math.random()*1.4,sp:.07+Math.random()*.18,ph:Math.random()*Math.PI*2,c:[P.teal,P.mag,P.main,P.gold,"#fff",P.blue][~~(Math.random()*6)]}));let t=0;const loop=()=>{t+=.02;ctx.clearRect(0,0,w/2,h/2);stars.forEach(s=>{s.y-=s.sp;if(s.y<-5){s.y=h/2+5;s.x=Math.random()*w/2}ctx.globalAlpha=.1+Math.sin(t*2+s.ph)*.08;ctx.fillStyle=s.c;ctx.beginPath();ctx.arc(s.x,s.y,s.s,0,Math.PI*2);ctx.fill()});an.current=requestAnimationFrame(loop)};loop();return()=>cancelAnimationFrame(an.current)},[]);return <canvas ref={ref} style={{position:"absolute",inset:0,pointerEvents:"none",width:"100%",height:"100%",zIndex:0,opacity:.5}}/>}

const CSS = `@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap');
@keyframes fadeUp{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:translateY(0)}}
@keyframes pop{0%{transform:scale(.4);opacity:0}55%{transform:scale(1.12)}100%{transform:scale(1);opacity:1}}
@keyframes megaPop{0%{transform:scale(.2);opacity:0}45%{transform:scale(1.2)}70%{transform:scale(.95)}100%{transform:scale(1);opacity:1}}
@keyframes shake{0%,100%{transform:translateX(0)}12%{transform:translateX(-5px)}28%{transform:translateX(5px)}42%{transform:translateX(-3px)}58%{transform:translateX(3px)}}
@keyframes xpFly{0%{opacity:1;transform:translateY(0) scale(1)}50%{transform:translateY(-30px) scale(1.3)}100%{opacity:0;transform:translateY(-55px) scale(.5)}}
@keyframes comboSlam{0%{transform:scale(0);opacity:0}40%{transform:scale(1.35)}65%{transform:scale(.92)}100%{transform:scale(1);opacity:1}}
@keyframes bounce{0%{transform:translateY(0)}25%{transform:translateY(-12px)}50%{transform:translateY(0)}70%{transform:translateY(-5px)}100%{transform:translateY(0)}}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-5px)}}
@keyframes slideIn{from{transform:translateX(25px);opacity:0}to{transform:translateX(0);opacity:1}}
@keyframes insightReveal{0%{transform:scale(.88) translateY(6px);opacity:0}100%{transform:scale(1) translateY(0);opacity:1}}
@keyframes speechBub{0%{transform:scale(0) translateY(8px);opacity:0}50%{transform:scale(1.05)}100%{transform:scale(1) translateY(0);opacity:1}}
@keyframes tipScale{0%{transform:rotate(0)}100%{transform:rotate(var(--tilt))}}
@keyframes chainLink{0%{transform:scale(0);opacity:0}60%{transform:scale(1.1)}100%{transform:scale(1);opacity:1}}
@keyframes highlight{0%{background:transparent}100%{background:var(--hl)}}
@keyframes sliderReveal{0%{width:0}100%{width:var(--sw)}}
@keyframes correctPop{0%{transform:scale(.9);opacity:0}100%{transform:scale(1);opacity:1}}
@keyframes streakGlow{0%{text-shadow:0 0 4px ${P.teal}50}50%{text-shadow:0 0 20px ${P.teal}}100%{text-shadow:0 0 4px ${P.teal}50}}
@keyframes wiggle{0%,100%{transform:rotate(0)}25%{transform:rotate(-3deg)}75%{transform:rotate(3deg)}}`;

// Brain mascot (compact)
function Brain({lvl=1,streak=0,mood=0,size=80,msg}){const ref=useRef(null),t=useRef(0),an=useRef(null);useEffect(()=>{const cv=ref.current;if(!cv)return;const ctx=cv.getContext("2d");cv.width=size*2;cv.height=size*2;const draw=()=>{t.current+=.035;const T=t.current,cx=size,cy=size,s=size*.4;ctx.clearRect(0,0,size*2,size*2);const gR=s*(1.4+Math.min(lvl,10)*.05);const gG=ctx.createRadialGradient(cx,cy,s*.2,cx,cy,gR);gG.addColorStop(0,(streak>=5?P.gold:streak>=3?P.teal:P.main)+"30");gG.addColorStop(1,"transparent");ctx.fillStyle=gG;ctx.beginPath();ctx.arc(cx,cy,gR,0,Math.PI*2);ctx.fill();ctx.save();ctx.translate(cx,cy);const bob=mood===1?Math.sin(T*14)*5*Math.max(0,1-(T%1)):Math.sin(T*1.5)*2;ctx.translate(0,bob);const bG=ctx.createRadialGradient(-s*.12,-s*.2,s*.1,0,s*.1,s*1.1);bG.addColorStop(0,"#e2b4ff");bG.addColorStop(.5,"#c77dff");bG.addColorStop(1,"#7c3aed");ctx.fillStyle=bG;ctx.beginPath();ctx.moveTo(0,-s*.88);ctx.bezierCurveTo(-s*.55,-s*.96,-s*.96,-s*.55,-s*.9,0);ctx.bezierCurveTo(-s*.98,s*.4,-s*.68,s*.85,-s*.18,s*.8);ctx.bezierCurveTo(0,s*.84,0,s*.84,s*.18,s*.8);ctx.bezierCurveTo(s*.68,s*.85,s*.98,s*.4,s*.9,0);ctx.bezierCurveTo(s*.96,-s*.55,s*.55,-s*.96,0,-s*.88);ctx.fill();ctx.strokeStyle="#6d28d9";ctx.lineWidth=2;ctx.stroke();const eY=-s*.18,eR=s*.17,blink=Math.sin(T*.35)>.96?.1:1,lk=Math.sin(T*.6)*1.5;[-1,1].forEach(side=>{const ex=side*s*.28;ctx.fillStyle="#fff";ctx.beginPath();ctx.ellipse(ex,eY,eR*1.1,eR*blink*1.1,0,0,Math.PI*2);ctx.fill();if(blink>.5){if(mood===1&&streak>=4){ctx.fillStyle=P.mag;const hs=eR*.65;ctx.beginPath();ctx.moveTo(ex+lk,eY+hs*.3);ctx.bezierCurveTo(ex+lk-hs*.5,eY-hs*.5,ex+lk-hs,eY+hs*.1,ex+lk,eY+hs*.7);ctx.bezierCurveTo(ex+lk+hs,eY+hs*.1,ex+lk+hs*.5,eY-hs*.5,ex+lk,eY+hs*.3);ctx.fill()}else{ctx.fillStyle="#5b21b6";ctx.beginPath();ctx.arc(ex+lk,eY,eR*.55,0,Math.PI*2);ctx.fill();ctx.fillStyle="#1a0a40";ctx.beginPath();ctx.arc(ex+lk,eY,eR*.3,0,Math.PI*2);ctx.fill()}ctx.fillStyle="#fff";ctx.beginPath();ctx.arc(ex+eR*.2+lk,eY-eR*.2,eR*.17,0,Math.PI*2);ctx.fill()}});ctx.fillStyle="rgba(247,37,133,.12)";[-1,1].forEach(side=>{ctx.beginPath();ctx.ellipse(side*s*.48,s*.06,s*.12,s*.07,0,0,Math.PI*2);ctx.fill()});ctx.strokeStyle="#6d28d9";ctx.lineWidth=2.5;ctx.lineCap="round";if(mood===1){ctx.beginPath();ctx.arc(0,s*.2,s*.16,.1*Math.PI,.9*Math.PI);ctx.stroke()}else if(mood===-1){ctx.beginPath();ctx.ellipse(0,s*.22,s*.07,s*.09,0,0,Math.PI*2);ctx.stroke()}else{ctx.beginPath();ctx.arc(0,s*.17,s*.11,.15*Math.PI,.85*Math.PI);ctx.stroke()}ctx.restore();an.current=requestAnimationFrame(draw)};draw();return()=>cancelAnimationFrame(an.current)},[lvl,streak,mood,size]);return <div style={{position:"relative",display:"inline-block"}}><canvas ref={ref} style={{width:size,height:size,animation:mood===1?"bounce .5s ease":"float 3s ease-in-out infinite"}}/>{msg&&<div style={{position:"absolute",top:-10,left:"50%",transform:"translateX(-50%)",background:"#fff",color:P.bg,fontSize:12,fontWeight:900,padding:"5px 12px",borderRadius:12,whiteSpace:"nowrap",animation:"speechBub .3s ease-out",boxShadow:"0 4px 10px rgba(0,0,0,.3)",fontFamily:F,zIndex:10}}>{msg}<div style={{position:"absolute",bottom:-6,left:"50%",transform:"translateX(-50%)",width:0,height:0,borderLeft:"6px solid transparent",borderRight:"6px solid transparent",borderTop:"6px solid #fff"}}/></div>}</div>}

function GBtn({children,onClick,color=P.main,disabled,big,outline,style:st}){const[h,setH]=useState(false),[pr,setPr]=useState(false);return <button disabled={disabled} onClick={e=>{Snd.tap();H.l();setPr(true);setTimeout(()=>setPr(false),100);onClick?.(e)}} onMouseEnter={()=>setH(true)} onMouseLeave={()=>{setH(false);setPr(false)}} style={{padding:big?"16px 36px":"12px 24px",background:outline?"transparent":(pr?color+"d0":color),border:outline?`3px solid ${color}`:"none",borderRadius:16,boxShadow:pr?`0 1px 0 ${color}80`:`0 5px 0 ${outline?color+"50":color+"80"}`,color:outline?color:"#fff",fontSize:big?17:14,fontWeight:900,fontFamily:F,cursor:disabled?"default":"pointer",transform:pr?"translateY(4px)":h?"translateY(-1px)":"none",transition:"all .08s",textTransform:"uppercase",letterSpacing:".03em",opacity:disabled?.35:1,...st}}>{children}</button>}

const pick = a => a[~~(Math.random() * a.length)];
const COMBO = ["nice! ✨","smooth! 💫","yesss! 🌟","AMAZING! ⭐","BRILLIANT! 💎","ON FIRE! 🔥","LEGENDARY! 👑"];
const COMBO_C = [P.teal,P.teal,P.main,P.gold,P.gold,P.mag,P.mag];
const COMBO_SZ = [16,17,20,24,28,34,40];
const B_OK = ["nailed it!","big brain!","too easy 😎","sheesh! 🔥","exactly right!"];
const B_NO = ["we got this!","close!","next one 💪","tricky!"];

/* ═══════════════════════════════════════════════════════════════
   ROUND DATA — 6 mechanic types
   ═══════════════════════════════════════════════════════════════ */
const ROUNDS = [
  // ─── 🔬 HIGHLIGHT — Tap the exact flawed phrase ───
  { type: "highlight",
    setup: "📱 A TikToker says:",
    text: ["This supplement", "cured my anxiety", "in 3 days!", "Link in bio"],
    flaw: 0, // index of "This supplement" — but actually the flaw is the WHOLE claim. Let's pick the weakest phrase.
    flawIdx: [1, 2], // "cured my anxiety" + "in 3 days!" are the flaw
    w: "Anecdote ≠ Evidence",
    explain: "One person's story + they're selling it = zero evidence",
  },
  { type: "highlight",
    setup: "🤔 Someone argues:",
    text: ["You can't trust her research", "because she went to", "a bad school"],
    flawIdx: [2],
    w: "Ad Hominem",
    explain: "School doesn't determine research quality. Attack the WORK not the person.",
  },
  { type: "highlight",
    setup: "💬 A social media post:",
    text: ["If you're not sharing this,", "you're part of", "the problem"],
    flawIdx: [0, 2],
    w: "False Dilemma",
    explain: "Donating, volunteering, talking privately — many options besides sharing.",
  },
  { type: "highlight",
    setup: "⏰ Grandpa says:",
    text: ["We walked to school in snow!", "Kids today", "are soft"],
    flawIdx: [2],
    w: "Cherry Picking",
    explain: "Selecting one memory to judge an entire generation.",
  },

  // ─── ⚖️ SCALE — Drag evidence to stronger side ───
  { type: "scale",
    setup: "Restaurant packed every night. Is the food actually good?",
    left: { label: "Good food", icon: "👍" },
    right: { label: "Just popular", icon: "📊" },
    cards: [
      { text: "Long wait times", side: "left", weight: 1 },
      { text: "Near the train station", side: "right", weight: 2 },
      { text: "Great reviews from food critics", side: "left", weight: 3 },
      { text: "Only restaurant on the block", side: "right", weight: 2 },
      { text: "Cheap prices", side: "right", weight: 1 },
    ],
    w: "Popularity ≠ Quality",
    explain: "Crowds prove demand, not quality. Location, price, and hype matter too.",
  },
  { type: "scale",
    setup: "New brain supplement — 1M sold! Does it work?",
    left: { label: "Probably works", icon: "💊" },
    right: { label: "No real proof", icon: "🔬" },
    cards: [
      { text: "No clinical trial done", side: "right", weight: 3 },
      { text: "Millions of sales", side: "left", weight: 1 },
      { text: "Influencer testimonials", side: "left", weight: 1 },
      { text: "Placebo effect explains reviews", side: "right", weight: 2 },
      { text: "Company profits from sales", side: "right", weight: 2 },
    ],
    w: "Evidence Hierarchy",
    explain: "Sales = marketing success. Reviews = placebo. Only trials prove anything.",
  },

  // ─── 🔗 CHAIN — Build consequence timeline ───
  { type: "chain",
    setup: "🚌 A city makes all transit FREE to reduce traffic",
    prompt: "Build what happens next →",
    steps: [
      { text: "Walkers & bikers switch to buses", order: 0 },
      { text: "Buses get overcrowded", order: 1 },
      { text: "Service quality drops", order: 2 },
      { text: "Drivers still don't switch", order: 3 },
    ],
    shuffled: [2, 0, 3, 1], // display order (shuffled)
    w: "Second-Order Effects",
    explain: "Free doesn't just attract drivers. EVERYONE switches. Overcrowding kills quality.",
  },
  { type: "chain",
    setup: "🐍 A town pays bounty for each dead cobra",
    prompt: "What happens over time? →",
    steps: [
      { text: "People start killing cobras for money", order: 0 },
      { text: "Entrepreneurs start BREEDING cobras", order: 1 },
      { text: "Government cancels the program", order: 2 },
      { text: "Breeders release cobras → MORE than before", order: 3 },
    ],
    shuffled: [1, 3, 0, 2],
    w: "Cobra Effect",
    explain: "Incentivizing the fix created MORE of the problem.",
  },
  { type: "chain",
    setup: "📊 School publishes student test rankings publicly",
    prompt: "Chain of consequences →",
    steps: [
      { text: "Students focus on test scores only", order: 0 },
      { text: "Cheating increases", order: 1 },
      { text: "Curiosity and creativity drop", order: 2 },
      { text: "Bottom-ranked students give up entirely", order: 3 },
    ],
    shuffled: [3, 1, 0, 2],
    w: "Perverse Incentives",
    explain: "When rank = status, students game the metric. Real learning disappears.",
  },

  // ─── 🎚️ SLIDER — Set probability, see reality ───
  { type: "slider",
    setup: "😰 Priya tested positive for a rare disease",
    detail: "Disease affects 1 in 10,000 people. Test is 99% accurate.",
    question: "What's the chance Priya actually has it?",
    answer: 1, // ~1%
    tolerance: 8, // within ±8% = correct
    w: "Base Rate Neglect",
    explain: "1 in 10,000 → ~100 false positives per 1 true positive. She's probably fine.",
  },
  { type: "slider",
    setup: "🎲 You flipped 5 heads in a row",
    detail: "Fair coin. No tricks.",
    question: "Chance the next flip is tails?",
    answer: 50,
    tolerance: 5,
    w: "Gambler's Fallacy",
    explain: "Each flip is 50/50. Coins don't have memory.",
  },
  { type: "slider",
    setup: "✈️ You see a plane crash on the news",
    detail: "Car deaths: 1 in 100. Plane deaths: 1 in 11,000.",
    question: "How dangerous is flying vs driving? (100 = equally dangerous)",
    answer: 1,
    tolerance: 10,
    w: "Availability Heuristic",
    explain: "Dramatic events FEEL likely. Flying is 100x safer than driving.",
  },

  // ─── ✏️ REWRITE — Fix the broken argument ───
  { type: "rewrite",
    setup: "🎮 Your friend says:",
    original: ["I have 2,000 hours", "so I can't quit now", "— that'd be wasted"],
    fix: { from: 1, to: "but past hours are gone either way" },
    w: "Sunk Cost Fallacy",
    explain: "Past time is gone whether you stay or leave. Only future fun counts.",
  },
  { type: "rewrite",
    setup: "📈 Manager says:",
    original: ["Tickets per hour up 40%!", "System works!", "Keep pushing!"],
    fix: { from: 1, to: "But are problems actually solved?" },
    w: "Goodhart's Law",
    explain: "When a measure becomes a target, it gets gamed.",
  },
  { type: "rewrite",
    setup: "🍕 An ad says:",
    original: ["9 out of 10 kids", "prefer PizzaBlast!", "It's the best!"],
    fix: { from: 2, to: "But popular ≠ best quality" },
    w: "Appeal to Popularity",
    explain: "Most-chosen ≠ best. Marketing shapes preference.",
  },

  // ─── 🎤 PERSUADE — Build the argument in optimal order ───
  { type: "persuade",
    setup: "🏫 You want to convince your school to allow phones at lunch",
    blocks: [
      { text: "Students could use educational apps during breaks", tag: "solution", order: 3 },
      { text: "72% of teens say phone bans increase stress", tag: "evidence", order: 4 },
      { text: "Most schools ban phones — but are students actually happier?", tag: "hook", order: 0 },
      { text: "Allow supervised phone use during lunch only", tag: "action", order: 5 },
      { text: "Without any break, focus drops 40% after lunch", tag: "stakes", order: 2 },
      { text: "Students need mental resets between intense classes", tag: "problem", order: 1 },
    ],
    w: "Persuasive Structure",
    explain: "Hook → Problem → Stakes → Solution → Evidence → Action. Most people start with the solution. Pros start with the pain.",
  },
  { type: "persuade",
    setup: "💰 Convince your parents to raise your allowance",
    blocks: [
      { text: "I'll track every dollar in a spreadsheet", tag: "evidence", order: 4 },
      { text: "I've been doing extra chores for 3 months with no raise", tag: "hook", order: 0 },
      { text: "Could we try $15/week for one month as a test?", tag: "action", order: 5 },
      { text: "I can't even save for my own things at this rate", tag: "problem", order: 1 },
      { text: "Learning money management NOW prevents problems later", tag: "solution", order: 3 },
      { text: "Without practice, teens make worse financial decisions as adults", tag: "stakes", order: 2 },
    ],
    w: "Persuasion Architecture",
    explain: "Don't start with what you WANT. Start with what THEY care about. Lead with a track record, build the case, then ask.",
  },
  { type: "persuade",
    setup: "🌍 Convince classmates to join your recycling project",
    blocks: [
      { text: "Our school throws away 200 lbs of recyclables per week", tag: "hook", order: 0 },
      { text: "Sign up at the booth — takes 30 seconds", tag: "action", order: 5 },
      { text: "That's 10,000 lbs per year going to landfills", tag: "stakes", order: 2 },
      { text: "3 other schools cut waste 60% in one semester", tag: "evidence", order: 4 },
      { text: "Most of it could be recycled with just two extra bins", tag: "solution", order: 3 },
      { text: "Nobody's doing anything about it yet", tag: "problem", order: 1 },
    ],
    w: "Hook → Stakes → Solution",
    explain: "Start shocking (200 lbs!), make it urgent (10,000/year!), then make it easy (2 bins, 30 seconds).",
  },
  { type: "persuade",
    setup: "🎮 Convince a friend that a new game is worth trying",
    blocks: [
      { text: "Remember how bored you said you were with shooters?", tag: "hook", order: 0 },
      { text: "It has a free demo — try 20 minutes, no commitment", tag: "action", order: 5 },
      { text: "This game has 95% positive reviews from people who hate RPGs", tag: "evidence", order: 4 },
      { text: "You keep replaying the same 3 games on loop", tag: "problem", order: 1 },
      { text: "It combines the parts you like — strategy + co-op — without the grind", tag: "solution", order: 3 },
      { text: "You'll run out of content in those games eventually", tag: "stakes", order: 2 },
    ],
    w: "Audience-First Persuasion",
    explain: "Start with THEIR frustration, not your enthusiasm. Make it about what THEY want, then offer the bridge.",
  },

  // ─── ⚔️ CLASSIC — Upgraded multi-choice ───
  { type: "classic",
    e: "😎", n: "Marcus",
    q: "Barber made $40K on crypto. Putting in $5K 🚀",
    pr: "🤔 the trap:",
    o: ["Only hears winners, not losers","Crypto is always bad","Barbers can't invest","He should invest more"],
    a: 0, w: "Survivorship Bias", l: "Losers don't brag. You only see survivors." },
  { type: "classic",
    e: "🏫", n: "Principal",
    q: "Phone-free schools = better grades. Banning phones! 📵",
    pr: "🤔 missing:",
    o: ["Those schools differ in many ways","Phones = bad grades always","Schools shouldn't have rules","Studies prove the link"],
    a: 0, w: "Confounding Variables", l: "Phone-free schools may just be richer schools." },
  { type: "classic",
    e: "🏷️", n: "Shopping",
    q: "Jacket was $200, now $80! Amazing deal! 🤑",
    pr: "💸 the trick:",
    o: ["$200 anchored you — $80 may still be overpriced","$120 off is always good","Original price = quality","Sales are always genuine"],
    a: 0, w: "Anchoring Bias", l: "The first number tricks you into thinking $80 is cheap." },
  { type: "classic",
    e: "👥", n: "Group Project",
    q: "Everyone agrees with the loudest person. No one objects.",
    pr: "🤫 what's happening:",
    o: ["Groupthink — conformity kills debate","Loud person is smartest","Agreeing = good teamwork","Silence = agreement"],
    a: 0, w: "Bandwagon Effect", l: "Groups often follow the loudest, not the smartest." },
];

/* ═══════════════════════════════════════════════════════════════
   MECHANIC COMPONENTS
   ═══════════════════════════════════════════════════════════════ */

// 🔬 HIGHLIGHT — tap the exact flaw
function QHighlight({ r, onResult }) {
  const [tapped, setTapped] = useState(new Set());
  const [done, setDone] = useState(false);
  const [correct, setCorrect] = useState(null);

  const tap = (i) => {
    if (done) return;
    Snd.tap(); H.l();
    const next = new Set(tapped);
    if (next.has(i)) next.delete(i); else next.add(i);
    setTapped(next);
  };

  const check = () => {
    const flawSet = new Set(r.flawIdx);
    const ok = r.flawIdx.every(i => tapped.has(i)) && tapped.size === flawSet.size;
    setCorrect(ok); setDone(true);
    onResult(ok);
  };

  return <div style={{ animation: "fadeUp .3s" }}>
    <div style={{ fontSize: 12, color: P.dim, fontWeight: 700, marginBottom: 8 }}>{r.setup}</div>
    <div style={{ background: P.sf, borderRadius: 16, padding: "16px", marginBottom: 12, boxShadow: `0 4px 0 ${P.bdr}`, display: "flex", flexWrap: "wrap", gap: 6, lineHeight: 1.8 }}>
      {r.text.map((phrase, i) => {
        const isFlawed = r.flawIdx.includes(i);
        const isTapped = tapped.has(i);
        const revealed = done;
        let bg = "transparent", brd = "2px solid transparent", col = P.txt;
        if (revealed && isFlawed) { bg = correct ? P.teal + "25" : P.red + "25"; brd = `2px solid ${correct ? P.teal : P.red}`; col = correct ? P.teal : P.red; }
        else if (revealed && isTapped && !isFlawed) { bg = P.red + "15"; brd = `2px solid ${P.red}50`; col = P.red; }
        else if (isTapped) { bg = P.mag + "20"; brd = `2px solid ${P.mag}`; col = P.mag; }
        return <button key={i} onClick={() => tap(i)} disabled={done}
          style={{ background: bg, border: brd, borderRadius: 10, padding: "4px 10px", fontSize: 15, color: col, fontWeight: 700, fontFamily: F, cursor: done ? "default" : "pointer", transition: "all .15s", lineHeight: 1.6 }}>
          {phrase}
          {revealed && isFlawed && <span style={{ marginLeft: 4 }}>{correct ? "✓" : "⚠️"}</span>}
        </button>;
      })}
    </div>
    <div style={{ fontSize: 11, color: P.mut, marginBottom: 10, fontWeight: 700 }}>🔬 Tap the part that's flawed, then check</div>
    {!done && tapped.size > 0 && <GBtn color={P.teal} onClick={check}>check →</GBtn>}
  </div>;
}

// ⚖️ SCALE — drag evidence cards to sides
function QScale({ r, onResult }) {
  const [placed, setPlaced] = useState({}); // cardIdx -> "left"|"right"
  const [done, setDone] = useState(false);
  const [score, setScore] = useState(null);

  const place = (ci, side) => {
    if (done) return;
    Snd.tap(); H.l();
    setPlaced(prev => ({ ...prev, [ci]: side }));
  };

  const check = () => {
    let correct = 0;
    r.cards.forEach((c, i) => { if (placed[i] === c.side) correct++; });
    const ok = correct >= Math.ceil(r.cards.length * 0.6);
    setScore(correct); setDone(true);
    onResult(ok);
  };

  const leftW = r.cards.reduce((s, c, i) => placed[i] === "left" ? s + c.weight : s, 0);
  const rightW = r.cards.reduce((s, c, i) => placed[i] === "right" ? s + c.weight : s, 0);
  const tilt = Math.max(-25, Math.min(25, (leftW - rightW) * 4));

  return <div style={{ animation: "fadeUp .3s" }}>
    <div style={{ fontSize: 13, color: P.dim, fontWeight: 700, marginBottom: 10, textAlign: "center" }}>{r.setup}</div>
    {/* Visual scale */}
    <div style={{ display: "flex", justifyContent: "center", alignItems: "flex-end", marginBottom: 12, height: 60, position: "relative" }}>
      <div style={{ position: "absolute", bottom: 0, width: 4, height: 30, background: P.bdr, borderRadius: 2 }} />
      <div style={{ position: "absolute", bottom: 28, width: "80%", height: 4, background: P.main, borderRadius: 2, transform: `rotate(${tilt}deg)`, transition: "transform .4s cubic-bezier(.4,0,.2,1)", transformOrigin: "center" }}>
        <div style={{ position: "absolute", left: 0, top: -22, fontSize: 11, fontWeight: 800, color: P.blue }}>{r.left.icon} {r.left.label}</div>
        <div style={{ position: "absolute", right: 0, top: -22, fontSize: 11, fontWeight: 800, color: P.mag, textAlign: "right" }}>{r.right.icon} {r.right.label}</div>
      </div>
    </div>
    {/* Evidence cards */}
    <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
      {r.cards.map((card, i) => {
        const p = placed[i];
        const revealed = done;
        const correct = revealed && p === card.side;
        const wrong = revealed && p && p !== card.side;
        return <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, animation: `slideIn .3s ${i * .06}s ease both` }}>
          <button onClick={() => place(i, "left")} disabled={done}
            style={{ width: 32, height: 32, borderRadius: 10, border: `2px solid ${p === "left" ? (revealed ? (correct ? P.teal : P.red) : P.blue) : P.bdr}`, background: p === "left" ? (revealed ? (correct ? P.teal + "20" : P.red + "20") : P.blue + "20") : P.sf, cursor: done ? "default" : "pointer", fontSize: 12, color: P.blue, fontWeight: 800, fontFamily: F, display: "flex", alignItems: "center", justifyContent: "center" }}>
            {p === "left" ? (revealed ? (correct ? "✓" : "✗") : "←") : "←"}
          </button>
          <div style={{ flex: 1, background: P.sf, borderRadius: 12, padding: "8px 12px", fontSize: 12, color: p ? P.txt : P.dim, fontWeight: 700, boxShadow: `0 3px 0 ${P.bdr}`, border: wrong ? `2px solid ${P.red}50` : correct ? `2px solid ${P.teal}50` : `2px solid transparent`, transition: "all .2s" }}>
            {card.text}
          </div>
          <button onClick={() => place(i, "right")} disabled={done}
            style={{ width: 32, height: 32, borderRadius: 10, border: `2px solid ${p === "right" ? (revealed ? (correct ? P.teal : P.red) : P.mag) : P.bdr}`, background: p === "right" ? (revealed ? (correct ? P.teal + "20" : P.red + "20") : P.mag + "20") : P.sf, cursor: done ? "default" : "pointer", fontSize: 12, color: P.mag, fontWeight: 800, fontFamily: F, display: "flex", alignItems: "center", justifyContent: "center" }}>
            {p === "right" ? (revealed ? (correct ? "✓" : "✗") : "→") : "→"}
          </button>
        </div>;
      })}
    </div>
    {!done && Object.keys(placed).length >= r.cards.length && <div style={{ marginTop: 12, textAlign: "center" }}><GBtn color={P.teal} onClick={check}>weigh it ⚖️</GBtn></div>}
  </div>;
}

// 🔗 CHAIN — build the consequence timeline
function QChain({ r, onResult }) {
  const [chain, setChain] = useState([]);
  const [done, setDone] = useState(false);
  const [correct, setCorrect] = useState(null);
  const used = new Set(chain);

  const add = (order) => {
    if (done || used.has(order)) return;
    Snd.chain(); H.l();
    setChain(prev => [...prev, order]);
  };

  const undo = () => {
    if (done) return;
    setChain(prev => prev.slice(0, -1));
  };

  const check = () => {
    const ok = chain.every((v, i) => v === i);
    setCorrect(ok); setDone(true);
    onResult(ok);
  };

  return <div style={{ animation: "fadeUp .3s" }}>
    <div style={{ fontSize: 13, color: P.dim, fontWeight: 700, marginBottom: 6 }}>{r.setup}</div>
    <div style={{ fontSize: 12, color: P.teal, fontWeight: 800, marginBottom: 12 }}>{r.prompt}</div>
    {/* Built chain */}
    <div style={{ display: "flex", flexDirection: "column", gap: 4, marginBottom: 14, minHeight: 40 }}>
      {chain.map((order, i) => {
        const step = r.steps[order];
        const isRight = done && order === i;
        const isWrong = done && order !== i;
        return <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, animation: "chainLink .3s ease" }}>
          <div style={{ width: 24, height: 24, borderRadius: 8, background: done ? (isRight ? P.teal : P.red) : P.main, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11, color: "#fff", fontWeight: 900, flexShrink: 0 }}>{i + 1}</div>
          <div style={{ flex: 1, background: done ? (isRight ? P.teal + "15" : P.red + "15") : P.sf, borderRadius: 12, padding: "8px 12px", fontSize: 12, fontWeight: 700, color: P.txt, border: `2px solid ${done ? (isRight ? P.teal + "50" : P.red + "50") : P.bdr}` }}>
            {step.text} {done && (isRight ? "✓" : "✗")}
          </div>
          {i < chain.length - 1 && <div style={{ position: "absolute", left: 26, marginTop: 32, fontSize: 10, color: P.mut }}>↓</div>}
        </div>;
      })}
      {chain.length > 0 && !done && <button onClick={undo} style={{ fontSize: 11, color: P.mut, background: "none", border: "none", cursor: "pointer", fontFamily: F, fontWeight: 700, alignSelf: "flex-start", padding: "2px 8px" }}>↩ undo</button>}
    </div>
    {/* Available steps */}
    {!done && <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
      {r.shuffled.map((order, i) => {
        if (used.has(order)) return null;
        const step = r.steps[order];
        return <button key={order} onClick={() => add(order)}
          style={{ background: P.sf, borderRadius: 12, padding: "10px 14px", fontSize: 12, fontWeight: 700, color: P.txt, border: `2px solid ${P.bdr}`, cursor: "pointer", fontFamily: F, textAlign: "left", boxShadow: `0 3px 0 ${P.bdr}`, transition: "all .1s" }}
          onMouseEnter={e => { e.currentTarget.style.transform = "translateY(-2px)"; }}
          onMouseLeave={e => { e.currentTarget.style.transform = "none"; }}>
          {step.text}
        </button>;
      })}
    </div>}
    {!done && chain.length === r.steps.length && <div style={{ marginTop: 12, textAlign: "center" }}><GBtn color={P.teal} onClick={check}>lock it in 🔗</GBtn></div>}
  </div>;
}

// 🎚️ SLIDER — set probability
function QSlider({ r, onResult }) {
  const [val, setVal] = useState(50);
  const [done, setDone] = useState(false);
  const [correct, setCorrect] = useState(null);

  const check = () => {
    const ok = Math.abs(val - r.answer) <= r.tolerance;
    setCorrect(ok); setDone(true);
    onResult(ok);
  };

  return <div style={{ animation: "fadeUp .3s" }}>
    <div style={{ fontSize: 13, color: P.dim, fontWeight: 700, marginBottom: 6 }}>{r.setup}</div>
    <div style={{ fontSize: 11, color: P.mut, fontWeight: 600, marginBottom: 12 }}>{r.detail}</div>
    <div style={{ fontSize: 14, color: P.teal, fontWeight: 800, marginBottom: 16 }}>{r.question}</div>
    {/* Slider */}
    <div style={{ position: "relative", padding: "0 4px", marginBottom: 8 }}>
      <input type="range" min={0} max={100} value={val} disabled={done}
        onChange={e => { setVal(+e.target.value); Snd.slide(); }}
        style={{ width: "100%", height: 8, borderRadius: 4, appearance: "none", background: `linear-gradient(90deg, ${P.teal} ${val}%, ${P.bdr} ${val}%)`, outline: "none", cursor: done ? "default" : "pointer" }} />
    </div>
    <div style={{ textAlign: "center", marginBottom: 16 }}>
      <span style={{ fontSize: 36, fontWeight: 900, color: done ? (correct ? P.teal : P.red) : P.main, transition: "color .3s" }}>{val}%</span>
    </div>
    {done && <div style={{ textAlign: "center", marginBottom: 8 }}>
      <div style={{ display: "inline-block", background: P.sf, borderRadius: 12, padding: "8px 16px", boxShadow: `0 3px 0 ${P.bdr}` }}>
        <span style={{ fontSize: 12, color: P.dim, fontWeight: 700 }}>Reality: </span>
        <span style={{ fontSize: 18, fontWeight: 900, color: P.gold }}>~{r.answer}%</span>
      </div>
    </div>}
    {!done && <div style={{ textAlign: "center" }}><GBtn color={P.teal} onClick={check}>lock answer 🎚️</GBtn></div>}
  </div>;
}

// 🎤 PERSUADE — build argument in optimal order
function QPersuade({ r, onResult }) {
  const [placed, setPlaced] = useState([]);
  const [done, setDone] = useState(false);
  const [score, setScore] = useState(null);
  const used = new Set(placed);

  const tagC = { hook: P.mag, problem: P.red, stakes: "#ff9e00", solution: P.teal, evidence: P.blue, action: P.lime };
  const tagL = { hook: "🪝 Hook", problem: "😤 Problem", stakes: "⚠️ Stakes", solution: "💡 Solution", evidence: "📊 Proof", action: "👉 Action" };

  const add = (idx) => { if (done || used.has(idx)) return; Snd.chain(); H.l(); setPlaced(prev => [...prev, idx]); };
  const undo = () => { if (done) return; setPlaced(prev => prev.slice(0, -1)); };
  const check = () => {
    let correct = 0;
    placed.forEach((bi, pos) => { if (r.blocks[bi].order === pos) correct++; });
    const ok = correct >= Math.ceil(r.blocks.length * 0.65);
    setScore(correct); setDone(true); onResult(ok);
  };

  return <div style={{ animation: "fadeUp .3s" }}>
    <div style={{ fontSize: 13, color: P.dim, fontWeight: 700, marginBottom: 6 }}>{r.setup}</div>
    <div style={{ fontSize: 11, color: P.gold, fontWeight: 800, marginBottom: 10 }}>🎤 Tap blocks in the most persuasive order</div>

    {done && <div style={{ display: "flex", gap: 3, marginBottom: 8, flexWrap: "wrap" }}>
      {["hook","problem","stakes","solution","evidence","action"].map(tag => (
        <span key={tag} style={{ fontSize: 8, padding: "2px 6px", borderRadius: 6, background: tagC[tag] + "20", color: tagC[tag], fontWeight: 800 }}>{tagL[tag]}</span>
      ))}
    </div>}

    {/* Built sequence */}
    <div style={{ display: "flex", flexDirection: "column", gap: 4, marginBottom: 10, minHeight: 20 }}>
      {placed.map((bi, pos) => {
        const block = r.blocks[bi];
        const isRight = done && block.order === pos;
        const isWrong = done && block.order !== pos;
        return <div key={pos} style={{ display: "flex", alignItems: "center", gap: 6, animation: "chainLink .3s ease" }}>
          <div style={{ width: 20, height: 20, borderRadius: 6, background: done ? (isRight ? P.teal : P.red) : P.main, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 9, color: "#fff", fontWeight: 900, flexShrink: 0 }}>{pos + 1}</div>
          <div style={{ flex: 1, borderRadius: 10, padding: "6px 10px", fontSize: 11, fontWeight: 700, lineHeight: 1.4,
            color: done ? (isRight ? P.teal : P.txt) : P.txt,
            background: done ? (isRight ? P.teal + "12" : P.red + "08") : P.sf,
            border: `2px solid ${done ? (isRight ? P.teal + "40" : P.red + "30") : P.bdr}`,
            textDecoration: done && isWrong ? "line-through" : "none",
            opacity: done && isWrong ? .6 : 1,
          }}>
            {block.text}
            {done && <span style={{ marginLeft: 4, fontSize: 8, padding: "1px 5px", borderRadius: 5, background: tagC[block.tag] + "25", color: tagC[block.tag], fontWeight: 800 }}>{block.tag}</span>}
          </div>
        </div>;
      })}
      {placed.length > 0 && !done && <button onClick={undo} style={{ fontSize: 10, color: P.mut, background: "none", border: "none", cursor: "pointer", fontFamily: F, fontWeight: 700, alignSelf: "flex-start", padding: "2px 6px" }}>↩ undo</button>}
    </div>

    {/* Available blocks */}
    {!done && <div style={{ display: "flex", flexDirection: "column", gap: 5 }}>
      {r.blocks.map((block, i) => {
        if (used.has(i)) return null;
        return <button key={i} onClick={() => add(i)}
          style={{ background: P.sf, borderRadius: 12, padding: "9px 12px", fontSize: 12, fontWeight: 700, color: P.txt, border: `2px solid ${P.bdr}`, cursor: "pointer", fontFamily: F, textAlign: "left", boxShadow: `0 3px 0 ${P.bdr}`, transition: "all .1s" }}
          onMouseEnter={e => { e.currentTarget.style.transform = "translateY(-2px)"; e.currentTarget.style.borderColor = P.main; }}
          onMouseLeave={e => { e.currentTarget.style.transform = "none"; e.currentTarget.style.borderColor = P.bdr; }}>
          {block.text}
        </button>;
      })}
    </div>}

    {!done && placed.length === r.blocks.length && <div style={{ marginTop: 10, textAlign: "center" }}><GBtn color={P.gold} onClick={check}>deliver it 🎤</GBtn></div>}

    {/* Optimal order reveal */}
    {done && <div style={{ marginTop: 8, background: P.sf2, borderRadius: 12, padding: "10px", border: `2px solid ${P.bdr}` }}>
      <div style={{ fontSize: 10, color: P.gold, fontWeight: 900, marginBottom: 6 }}>✨ Optimal order:</div>
      {[...r.blocks].sort((a, b) => a.order - b.order).map((block, i) => (
        <div key={i} style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 3 }}>
          <span style={{ fontSize: 8, padding: "1px 6px", borderRadius: 5, background: tagC[block.tag] + "25", color: tagC[block.tag], fontWeight: 800, minWidth: 55, textAlign: "center" }}>{tagL[block.tag]}</span>
          <span style={{ fontSize: 10, color: P.dim, fontWeight: 600, lineHeight: 1.3 }}>{block.text}</span>
        </div>
      ))}
    </div>}
  </div>;
}

// ✏️ REWRITE — fix the broken argument
function QRewrite({ r, onResult }) {
  const [fixed, setFixed] = useState(false);
  const [done, setDone] = useState(false);

  const doFix = () => {
    if (done) return;
    Snd.reveal(); H.s();
    setFixed(true); setDone(true);
    onResult(true); // rewrite is always "correct" — it teaches by showing the fix
  };

  return <div style={{ animation: "fadeUp .3s" }}>
    <div style={{ fontSize: 12, color: P.dim, fontWeight: 700, marginBottom: 8 }}>{r.setup}</div>
    <div style={{ background: P.sf, borderRadius: 16, padding: "14px", boxShadow: `0 4px 0 ${P.bdr}`, marginBottom: 12 }}>
      {r.original.map((phrase, i) => {
        const isTarget = i === r.fix.from;
        const showFix = isTarget && fixed;
        return <span key={i} style={{
          display: "inline", fontSize: 15, fontWeight: 700, lineHeight: 1.8,
          color: showFix ? P.teal : (isTarget && !done) ? P.red : P.txt,
          textDecoration: showFix ? "none" : (isTarget ? "line-through wavy" : "none"),
          background: showFix ? P.teal + "15" : (isTarget && !done) ? P.red + "10" : "transparent",
          borderRadius: 6, padding: isTarget ? "2px 6px" : 0,
          transition: "all .4s",
        }}>
          {showFix ? r.fix.to : phrase}{" "}
        </span>;
      })}
    </div>
    <div style={{ fontSize: 11, color: P.mut, fontWeight: 700, marginBottom: 10 }}>
      {!done ? "✏️ Tap to fix the flawed reasoning" : "✓ Fixed!"}
    </div>
    {!done && <GBtn color={P.mag} onClick={doFix}>fix it ✏️</GBtn>}
  </div>;
}

// ⚔️ CLASSIC — upgraded multi-choice
function QClassic({ r, onResult }) {
  const [sel, setSel] = useState(null);
  const [done, setDone] = useState(false);
  const AC = [P.red, P.blue, P.green, P.yellow];
  const AS = [P.redS, P.blueS, P.greenS, P.yellowS];
  const SH = ["●", "◆", "▲", "★"];

  const pick = (i) => {
    if (done) return;
    Snd.tap(); H.l();
    setSel(i); setDone(true);
    onResult(i === r.a);
  };

  return <div style={{ animation: "fadeUp .3s" }}>
    <div style={{ display: "flex", gap: 10, marginBottom: 10 }}>
      <div style={{ width: 44, height: 44, borderRadius: 14, background: P.sf, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22, boxShadow: `0 4px 0 ${P.bdr}` }}>{r.e}</div>
      <div style={{ background: P.sf, borderRadius: 14, borderTopLeftRadius: 4, padding: "8px 12px", flex: 1, boxShadow: `0 4px 0 ${P.bdr}` }}>
        <div style={{ fontSize: 9, color: P.mut, fontWeight: 800 }}>{r.n}</div>
        <div style={{ fontSize: 14, color: P.txt, fontWeight: 700, lineHeight: 1.4 }}>{r.q}</div>
      </div>
    </div>
    <div style={{ fontSize: 13, color: P.teal, fontWeight: 800, marginBottom: 8 }}>{r.pr}</div>
    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
      {r.o.map((opt, i) => {
        const iS = sel === i, iO = i === r.a;
        let bg = AC[i], sh = `0 5px 0 ${AS[i]}`, op = 1;
        if (done) { if (iO) { bg = P.teal; sh = `0 5px 0 ${P.tealS}`; } else if (iS) { bg = P.red + "60"; op = .7; } else { op = .12; sh = "none"; } }
        return <button key={i} onClick={() => pick(i)} disabled={done}
          style={{ textAlign: "left", padding: "10px 12px", background: bg, borderRadius: 14, cursor: done ? "default" : "pointer", fontSize: 12, color: "#fff", fontFamily: F, fontWeight: 700, lineHeight: 1.35, opacity: op, boxShadow: sh, border: "none", transition: "all .1s" }}
          onMouseEnter={e => { if (!done) e.currentTarget.style.transform = "translateY(-3px)"; }}
          onMouseLeave={e => { if (!done) e.currentTarget.style.transform = "none"; }}>
          <span style={{ fontSize: 14, marginRight: 6, opacity: .8 }}>{SH[i]}</span>{opt}
          {done && iO && <span style={{ marginLeft: 4 }}>✓</span>}
        </button>;
      })}
    </div>
  </div>;
}

/* ═══════════════════════════════════════════════════════════════
   GAME ENGINE
   ═══════════════════════════════════════════════════════════════ */
function Game({ filterType = "all", onHome }) {
  const pool = filterType === "all" ? ROUNDS : ROUNDS.filter(r => r.type === filterType);
  const [deck] = useState(() => [...pool].sort(() => Math.random() - .5));
  const [ri, setRi] = useState(0);
  const [fb, setFb] = useState(null);
  const [show, setShow] = useState(false);
  const [streak, setStreak] = useState(0);
  const [best, setBest] = useState(0);
  const [xp, setXp] = useState(0);
  const [hearts, setHearts] = useState(5);
  const [cel, setCel] = useState(0);
  const [shk, setShk] = useState(false);
  const [lvl, setLvl] = useState(1);
  const [lvu, setLvu] = useState(false);
  const [pts, setPts] = useState(0);
  const [done, setDone] = useState(false);
  const [ins, setIns] = useState([]);
  const [tc, setTc] = useState(0);
  const [ta, setTa] = useState(0);
  const [mood, setMood] = useState(0);
  const [bMsg, setBMsg] = useState(null);
  const r = deck[ri % deck.length];
  const ci = Math.min(streak, COMBO.length - 1);
  const maxR = Math.min(deck.length, 10);

  const onResult = useCallback((ok) => {
    setTa(x => x + 1);
    if (ok) {
      const ns = streak + 1; setStreak(ns); setBest(b => Math.max(b, ns)); setTc(x => x + 1);
      const p = 12 + Math.min(ns, 7) * 6;
      setXp(x => x + p); setPts(p); setMood(1); setFb(1);
      setBMsg(pick(B_OK)); setTimeout(() => setBMsg(null), 1500);
      Snd.ok(ns); H.s(); setCel(c => c + 1);
      if (!ins.includes(r.w)) setIns(i => [...i, r.w]);
      if (ns % 4 === 0 && lvl < 15) setTimeout(() => { setLvl(l => l + 1); setLvu(true); Snd.lv(); H.big(); setTimeout(() => setLvu(false), 1600); }, 250);
    } else {
      setStreak(0); setPts(0); setHearts(h => Math.max(0, h - 1)); setMood(-1); setFb(0);
      setBMsg(pick(B_NO)); setTimeout(() => setBMsg(null), 1500);
      Snd.no(); H.e(); setShk(true); setTimeout(() => setShk(false), 400);
    }
    setTimeout(() => { setShow(true); setTimeout(() => setMood(0), 800); }, 500);
  }, [streak, r, ins, lvl]);

  const nxt = () => {
    if (hearts <= 0 || (ri > 0 && (ri + 1) % maxR === 0)) { setDone(true); return; }
    setRi(i => i + 1); setFb(null); setShow(false);
  };
  const again = () => { setDone(false); setHearts(5); setRi(i => i + 1); setFb(null); setShow(false); };
  const acc = ta ? Math.round(tc / ta * 100) : 0;

  if (done) return (
    <div style={{ minHeight: "100vh", background: `radial-gradient(ellipse at 50% 30%, #2a1055, ${P.bg} 65%)`, fontFamily: F, color: P.txt, padding: "28px 20px", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", position: "relative" }}>
      <style>{CSS}</style><Stars /><Boom trigger={1} n={85} mega />
      <div style={{ animation: "megaPop .6s cubic-bezier(.34,1.56,.64,1)", textAlign: "center", maxWidth: 360, zIndex: 2 }}>
        <Brain lvl={lvl} streak={best} mood={1} size={100} msg={hearts > 0 ? "crushed it! 🎉" : "next time! 💪"} />
        <div style={{ display: "grid", gridTemplateColumns: "repeat(3,1fr)", gap: 8, margin: "12px 0" }}>
          {[{ v: xp, c: P.gold, e: "⚡" }, { v: `${acc}%`, c: P.teal, e: "🎯" }, { v: best, c: P.mag, e: "✨" }].map((s, i) =>
            <div key={i} style={{ background: P.sf, borderRadius: 16, padding: "10px 6px", textAlign: "center", boxShadow: `0 4px 0 ${P.bdr}` }}>
              <div style={{ fontSize: 11 }}>{s.e}</div><div style={{ fontSize: 22, fontWeight: 900, color: s.c }}>{s.v}</div>
            </div>
          )}
        </div>
        {ins.length > 0 && <div style={{ background: P.sf, borderRadius: 14, padding: "10px", marginBottom: 12, boxShadow: `0 4px 0 ${P.bdr}`, textAlign: "left" }}>
          <div style={{ fontSize: 10, color: P.teal, fontWeight: 900, marginBottom: 6 }}>🧠 {ins.length} concepts learned</div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 3 }}>{ins.map((w, i) => <span key={i} style={{ fontSize: 9, color: P.teal, padding: "2px 6px", border: `2px solid ${P.teal}30`, borderRadius: 10, background: P.tealBg, fontWeight: 700 }}>{w}</span>)}</div>
        </div>}
        <div style={{ display: "flex", gap: 10, justifyContent: "center" }}>
          <GBtn color={P.teal} big onClick={again}>✨ again</GBtn>
          <GBtn color={P.mut} outline onClick={onHome}>home</GBtn>
        </div>
      </div>
    </div>
  );

  if (lvu) return (
    <div style={{ position: "fixed", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", background: `radial-gradient(circle, #3a1070, ${P.bg})`, zIndex: 200, fontFamily: F }}>
      <style>{CSS}</style><Boom trigger={1} n={95} mega /><Stars />
      <div style={{ textAlign: "center", animation: "megaPop .5s cubic-bezier(.34,1.56,.64,1)", zIndex: 2 }}>
        <Brain lvl={lvl} streak={streak} mood={1} size={130} msg="LEVEL UP! 🎉" />
        <div style={{ fontSize: 56, fontWeight: 900, color: P.teal, lineHeight: 1, textShadow: `0 0 30px ${P.teal}50`, marginTop: 8 }}>{lvl}</div>
      </div>
    </div>
  );

  const bgStr = `radial-gradient(ellipse at 50% 30%, rgba(${streak >= 5 ? "247,37,133" : streak >= 3 ? "0,245,212" : "199,125,255"},${Math.min(streak * .022, .14)}) 0%, ${P.bg} 55%)`;
  const typeLabel = { highlight: "🔬 find the flaw", scale: "⚖️ weigh evidence", chain: "🔗 build the chain", slider: "🎚️ calibrate", rewrite: "✏️ fix it", persuade: "🎤 build your case", classic: "🎯 spot it" };

  return (
    <div style={{ minHeight: "100vh", background: bgStr, fontFamily: F, color: P.txt, padding: "12px 14px 20px", display: "flex", flexDirection: "column", alignItems: "center", position: "relative", transition: "background .8s" }}>
      <style>{CSS}</style><Stars /><Boom trigger={cel} n={streak >= 5 ? 65 : streak >= 3 ? 40 : 20} mega={streak >= 5} />
      {pts > 0 && fb === 1 && <div style={{ position: "absolute", top: "38%", left: "50%", transform: "translateX(-50%)", zIndex: 60, animation: "xpFly .9s ease-out forwards", pointerEvents: "none" }}><span style={{ fontSize: 30, fontWeight: 900, color: P.gold, textShadow: `0 0 20px ${P.gold}` }}>+{pts}</span></div>}

      {/* TOP BAR */}
      <div style={{ width: "100%", maxWidth: 460, marginBottom: 6, zIndex: 2 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <button onClick={onHome} style={{ background: P.sf, borderRadius: 12, color: P.mut, cursor: "pointer", fontSize: 14, fontFamily: F, padding: "4px 10px", fontWeight: 800, boxShadow: `0 3px 0 ${P.bdr}`, border: "none" }}>✕</button>
          <div style={{ flex: 1, margin: "0 10px", height: 16, background: P.sf, borderRadius: 10, overflow: "hidden", boxShadow: `inset 0 2px 4px rgba(0,0,0,.3), 0 2px 0 ${P.bdr}` }}>
            <div style={{ height: "100%", width: `${((ri % maxR) / maxR) * 100}%`, background: `linear-gradient(90deg, ${P.teal}, ${P.mag})`, borderRadius: 8, transition: "width .4s" }} />
          </div>
          <div style={{ display: "flex", gap: 1.5 }}>{[...Array(5)].map((_, i) => <span key={i} style={{ fontSize: 14, opacity: i < hearts ? 1 : .15 }}>💜</span>)}</div>
        </div>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 4 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
            <Brain lvl={lvl} streak={streak} mood={mood} size={32} msg={bMsg} />
            <span style={{ fontSize: 11, fontWeight: 900, color: P.main }}>L{lvl}</span>
            {streak >= 3 && <span style={{ fontSize: 11, fontWeight: 900, color: COMBO_C[ci], animation: "streakGlow 1s infinite" }}>✨x{Math.min(streak, 7)}</span>}
          </div>
          <div style={{ background: P.goldBg, borderRadius: 10, padding: "2px 10px", boxShadow: "0 2px 0 rgba(255,214,10,.2)" }}><span style={{ fontSize: 12, fontWeight: 900, color: P.gold }}>⚡{xp}</span></div>
        </div>
      </div>

      {streak >= 2 && fb === 1 && !show && <div style={{ animation: "comboSlam .4s ease-out", marginBottom: 2, zIndex: 2 }}><span style={{ fontSize: COMBO_SZ[ci], fontWeight: 900, color: COMBO_C[ci], textShadow: `0 0 ${8 + ci * 4}px ${COMBO_C[ci]}50` }}>{COMBO[ci]}</span></div>}

      {/* TYPE BADGE */}
      <div style={{ marginBottom: 8, animation: "fadeUp .2s", zIndex: 2 }}>
        <span style={{ fontSize: 11, padding: "4px 14px", borderRadius: 20, fontWeight: 800, background: "rgba(199,125,255,.12)", color: P.main, boxShadow: `0 3px 0 ${P.mainS}30` }}>
          {typeLabel[r.type] || "🧠"}
        </span>
      </div>

      {/* QUESTION CONTENT */}
      <div style={{ width: "100%", maxWidth: 440, animation: shk ? "shake .45s" : "fadeUp .25s", zIndex: 2 }}>
        {r.type === "highlight" && <QHighlight r={r} onResult={onResult} />}
        {r.type === "scale" && <QScale r={r} onResult={onResult} />}
        {r.type === "chain" && <QChain r={r} onResult={onResult} />}
        {r.type === "slider" && <QSlider r={r} onResult={onResult} />}
        {r.type === "persuade" && <QPersuade r={r} onResult={onResult} />}
        {r.type === "rewrite" && <QRewrite r={r} onResult={onResult} />}
        {r.type === "classic" && <QClassic r={r} onResult={onResult} />}

        {/* INSIGHT REVEAL */}
        {show && <div style={{ marginTop: 10, animation: "insightReveal .4s ease-out" }}>
          <div style={{ background: P.sf, borderRadius: 18, padding: "14px", boxShadow: `0 4px 0 ${P.bdr}`, textAlign: "center" }}>
            <div style={{ display: "inline-flex", alignItems: "center", gap: 6, padding: "5px 16px", borderRadius: 20, background: fb ? P.tealBg : P.magBg, border: `2px solid ${fb ? P.teal + "30" : P.mag + "30"}`, marginBottom: 8, animation: "wiggle .5s" }}>
              <span style={{ fontSize: 16 }}>🧠</span>
              <span style={{ fontSize: 14, color: fb ? P.teal : P.mag, fontWeight: 900 }}>{r.w}</span>
            </div>
            <p style={{ fontSize: 13, color: P.dim, lineHeight: 1.45, margin: "0 0 12px", fontWeight: 700 }}>{r.explain || r.l}</p>
            <GBtn color={P.teal} onClick={nxt}>continue →</GBtn>
          </div>
        </div>}
      </div>

      <div style={{ marginTop: "auto", paddingTop: 8, fontSize: 10, color: P.mut, textAlign: "center", fontWeight: 700, zIndex: 2 }}>
        {ins.length > 0 && <span>🧠 {ins.length} · </span>}best ✨{best}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   LANDING — Choose your mechanic
   ═══════════════════════════════════════════════════════════════ */
function Landing({ onPlay }) {
  const [c, setC] = useState(0);
  const modes = [
    { key: "all", icon: "🎲", name: "Mix All", desc: "Every mechanic, shuffled", color: P.teal, count: ROUNDS.length },
    { key: "highlight", icon: "🔬", name: "Find the Flaw", desc: "Tap the broken logic", color: P.mag, count: ROUNDS.filter(r => r.type === "highlight").length },
    { key: "scale", icon: "⚖️", name: "Weigh Evidence", desc: "Sort what matters", color: P.blue, count: ROUNDS.filter(r => r.type === "scale").length },
    { key: "chain", icon: "🔗", name: "Build the Chain", desc: "Predict consequences", color: P.lime, count: ROUNDS.filter(r => r.type === "chain").length },
    { key: "slider", icon: "🎚️", name: "Calibrate", desc: "Test your intuition", color: "#2dd4bf", count: ROUNDS.filter(r => r.type === "slider").length },
    { key: "persuade", icon: "🎤", name: "Build Your Case", desc: "Master persuasion order", color: P.gold, count: ROUNDS.filter(r => r.type === "persuade").length },
    { key: "rewrite", icon: "✏️", name: "Fix It", desc: "Repair broken arguments", color: "#ff9e00", count: ROUNDS.filter(r => r.type === "rewrite").length },
    { key: "classic", icon: "🎯", name: "Spot It", desc: "Quick fire multi-choice", color: P.red, count: ROUNDS.filter(r => r.type === "classic").length },
  ];

  return (
    <div style={{ minHeight: "100vh", background: `radial-gradient(ellipse at 50% 20%, #2a1055 0%, ${P.bg} 60%)`, display: "flex", flexDirection: "column", alignItems: "center", padding: "24px 16px", fontFamily: F, position: "relative", overflow: "hidden" }}>
      <style>{CSS}</style><Stars /><Boom trigger={c} n={65} mega />
      <div style={{ animation: "megaPop .7s cubic-bezier(.34,1.56,.64,1)", zIndex: 2, marginTop: 10 }}>
        <Brain lvl={6} streak={4} mood={c ? 1 : 0} size={90} msg={c ? "let's goooo! 🚀" : null} />
      </div>
      <h1 style={{ fontSize: "clamp(30px,8vw,46px)", fontWeight: 900, textAlign: "center", lineHeight: 1.05, marginBottom: 2, animation: "fadeUp .5s ease-out .15s both", zIndex: 2, background: `linear-gradient(135deg, ${P.teal}, ${P.main}, ${P.mag})`, WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>CORTEX</h1>
      <p style={{ fontSize: 13, color: P.dim, marginBottom: 18, fontWeight: 700, animation: "fadeUp .5s ease-out .25s both", zIndex: 2 }}>choose your training ✨</p>

      {/* Mode grid */}
      <div style={{ display: "flex", flexDirection: "column", gap: 8, width: "100%", maxWidth: 420, zIndex: 2 }}>
        {modes.map((m, i) => (
          <button key={m.key}
            onClick={() => { Snd.tap(); H.l(); setC(x => x + 1); setTimeout(() => onPlay(m.key), m.key === "all" ? 300 : 150); if (m.key === "all") { Snd.go(); H.big(); } }}
            style={{
              display: "flex", alignItems: "center", gap: 12, width: "100%",
              background: m.key === "all" ? `linear-gradient(135deg, ${P.teal}18, ${P.mag}12)` : P.sf,
              border: m.key === "all" ? `2px solid ${P.teal}40` : `2px solid ${P.bdr}`,
              borderRadius: 16, padding: m.key === "all" ? "14px 16px" : "12px 14px",
              cursor: "pointer", fontFamily: F, textAlign: "left",
              boxShadow: `0 4px 0 ${m.key === "all" ? P.tealS + "40" : P.bdr}`,
              animation: `fadeUp .35s ${.15 + i * .06}s ease-out both`,
              transition: "all .12s",
            }}
            onMouseEnter={e => { e.currentTarget.style.transform = "translateY(-2px)"; e.currentTarget.style.boxShadow = `0 6px 0 ${m.key === "all" ? P.tealS + "40" : P.bdr}`; }}
            onMouseLeave={e => { e.currentTarget.style.transform = "none"; e.currentTarget.style.boxShadow = `0 4px 0 ${m.key === "all" ? P.tealS + "40" : P.bdr}`; }}
          >
            <div style={{
              width: m.key === "all" ? 48 : 42, height: m.key === "all" ? 48 : 42,
              borderRadius: 14, background: m.color + "18",
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: m.key === "all" ? 24 : 20, flexShrink: 0,
            }}>{m.icon}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: m.key === "all" ? 15 : 13, fontWeight: 900, color: m.key === "all" ? P.teal : P.txt }}>{m.name}</div>
              <div style={{ fontSize: 11, color: P.mut, fontWeight: 600 }}>{m.desc}</div>
            </div>
            <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
              <span style={{ fontSize: 10, color: P.mut, fontWeight: 700 }}>{m.count}</span>
              <span style={{ fontSize: 14, color: m.color }}>→</span>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

export default function App() {
  const [screen, setScreen] = useState("home");
  const [mode, setMode] = useState("all");
  return <div style={{ background: P.bg, minHeight: "100vh" }}>
    {screen === "home" && <Landing onPlay={(m) => { setMode(m); setScreen("game"); }} />}
    {screen === "game" && <Game filterType={mode} onHome={() => setScreen("home")} />}
  </div>;
}
