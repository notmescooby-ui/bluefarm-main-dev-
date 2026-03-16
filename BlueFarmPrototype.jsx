import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";

/* ═══════════════════════════════════════════════════════════════════
   DESIGN TOKENS
═══════════════════════════════════════════════════════════════════ */
const T = {
  navy: "#0D1B6B", blueDark: "#0D47A1", blueMid: "#1565C0", blueLight: "#2196F3",
  blueSky: "#29B6F6", teal: "#00BCD4", tealDark: "#00ACC1", green: "#00C853",
  amber: "#FFA000", red: "#F44336", bgLight: "#EFF4FF", bgLighter: "#F5F8FF",
  card: "#FFFFFF", trackLight: "#E3F2FD",
  bgDark: "#0A0F1E", cardDark: "#121929", borderDark: "#1E2D4A", trackDark: "#1A2744",
  textNavy: "#0D1B6B", textMid: "#546E7A", textLight: "#90A4AE",
  textDark: "#E8EEFF", textDarkMid: "#8BA3C7", textDarkDim: "#5C7A9E",
};

/* ═══════════════════════════════════════════════════════════════════
   GLOBAL STYLES
═══════════════════════════════════════════════════════════════════ */
const STYLES = `
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap');
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html,body{font-family:'Nunito',sans-serif;overscroll-behavior:none}
::-webkit-scrollbar{width:3px}
::-webkit-scrollbar-thumb{background:rgba(21,101,192,.2);border-radius:99px}

@keyframes bIn{0%{transform:scale(.3) rotate(-15deg);opacity:0}55%{transform:scale(1.1) rotate(2deg);opacity:1}75%{transform:scale(.95) rotate(-1deg)}90%{transform:scale(1.03)}100%{transform:scale(1) rotate(0deg)}}
@keyframes bUp{0%{transform:translateY(60px);opacity:0}60%{transform:translateY(-12px);opacity:1}80%{transform:translateY(5px)}100%{transform:translateY(0)}}
@keyframes bLeft{0%{transform:translateX(-44px);opacity:0}60%{transform:translateX(9px);opacity:1}80%{transform:translateX(-3px)}100%{transform:translateX(0)}}
@keyframes bRight{0%{transform:translateX(44px);opacity:0}60%{transform:translateX(-9px);opacity:1}80%{transform:translateX(3px)}100%{transform:translateX(0)}}
@keyframes cardIn{0%{transform:translateY(34px) scale(.96);opacity:0}60%{transform:translateY(-5px) scale(1.01);opacity:1}80%{transform:translateY(2px) scale(.995)}100%{transform:translateY(0) scale(1)}}
@keyframes hdrIn{0%{transform:translateY(-110%);opacity:0}60%{transform:translateY(7px);opacity:1}80%{transform:translateY(-3px)}100%{transform:translateY(0)}}
@keyframes splashLogo{0%{transform:scale(0) rotate(-20deg);opacity:0}58%{transform:scale(1.14) rotate(3deg);opacity:1}78%{transform:scale(.96) rotate(-1deg)}100%{transform:scale(1) rotate(0deg)}}
@keyframes pulse{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.45;transform:scale(.82)}}
@keyframes glow{0%,100%{box-shadow:0 0 0 0 rgba(0,200,83,.45)}55%{box-shadow:0 0 0 9px rgba(0,200,83,0)}}
@keyframes wave{0%{transform:translateX(0)}100%{transform:translateX(-50%)}}
@keyframes spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-9px)}}
@keyframes fillBar{from{transform:scaleX(0)}to{transform:scaleX(1)}}
@keyframes dockJump{0%{transform:translateY(0) scale(1)}28%{transform:translateY(-20px) scale(1.2)}52%{transform:translateY(-7px) scale(1.07)}72%{transform:translateY(-12px) scale(1.12)}100%{transform:translateY(0) scale(1)}}
@keyframes notifShake{0%,100%{transform:rotate(0)}18%{transform:rotate(-16deg)}38%{transform:rotate(16deg)}56%{transform:rotate(-11deg)}76%{transform:rotate(9deg)}}
@keyframes scanRing{0%{transform:translate(-50%,-50%) scale(.8);opacity:.85}100%{transform:translate(-50%,-50%) scale(2.2);opacity:0}}
@keyframes particleDrift{0%{transform:translate(0,0);opacity:0}10%{opacity:1}90%{opacity:.5}100%{transform:translate(var(--dx),var(--dy));opacity:0}}
@keyframes screenIn{0%{transform:translateY(48px) scale(.97);opacity:0}62%{transform:translateY(-6px) scale(1.01);opacity:1}80%{transform:translateY(3px) scale(.997)}100%{transform:translateY(0) scale(1)}}
@keyframes shimmer{0%{background-position:-400px 0}100%{background-position:400px 0}}
@keyframes flipIn{0%{transform:perspective(400px) rotateX(-90deg);opacity:0}60%{transform:perspective(400px) rotateX(12deg);opacity:1}80%{transform:perspective(400px) rotateX(-6deg)}100%{transform:perspective(400px) rotateX(0deg)}}
@keyframes rippleOut{0%{transform:scale(1);opacity:.7}100%{transform:scale(3);opacity:0}}
@keyframes indicatorPop{0%{transform:scale(0);opacity:0}60%{transform:scale(1.4)}100%{transform:scale(1);opacity:1}}

.screen-enter{animation:screenIn .6s cubic-bezier(.34,1.4,.64,1) both}
.btn-tap:active{transform:scale(.93)!important;transition:transform .08s!important}
.card-hover{transition:transform .3s cubic-bezier(.34,1.56,.64,1),box-shadow .3s}
.card-hover:hover{transform:translateY(-4px) scale(1.015)!important}
.input-focus:focus{outline:none;border-color:#00BCD4!important;box-shadow:0 0 0 3px rgba(0,188,212,.18)!important;transform:scale(1.015);transition:all .2s cubic-bezier(.34,1.56,.64,1)}
`;

/* ═══════════════════════════════════════════════════════════════════
   SENSOR CONFIG
═══════════════════════════════════════════════════════════════════ */
const SENSORS = [
  {key:"ph",      label:"pH Level",        emoji:"🧪", unit:"pH",   dispMin:6.5,  dispMax:8.5,  normLo:6.5, normHi:8.5,  warnLo:6.0, warnHi:9.0},
  {key:"temp",    label:"Temperature",     emoji:"🌡️", unit:"°C",   dispMin:24,   dispMax:30,   normLo:24,  normHi:30,   warnLo:22,  warnHi:32 },
  {key:"do",      label:"Dissolved Oxygen",emoji:"💧", unit:"mg/L", dispMin:5,    dispMax:8,    normLo:5,   normHi:8,    warnLo:4,   warnHi:10 },
  {key:"turb",    label:"Turbidity",       emoji:"🔵", unit:"NTU",  dispMin:1,    dispMax:5,    normHi:5,   warnHi:7                           },
  {key:"ammonia", label:"Ammonia",         emoji:"⚠️", unit:"mg/L", dispMin:0,    dispMax:0.5,  normHi:0.3, warnHi:0.5                         },
  {key:"level",   label:"Water Level",     emoji:"📏", unit:"%",    dispMin:80,   dispMax:100,  normLo:80,  normHi:100,  warnLo:75              },
];

const DEFAULTS = {ph:7.2, temp:28.5, do:6.8, turb:2.5, ammonia:0.15, level:92};

function getStat(key, v) {
  const s = SENSORS.find(s=>s.key===key);
  if (!s) return "NORMAL";
  if (key==="turb"||key==="ammonia") { if(v<=s.normHi)return"NORMAL"; if(v<=s.warnHi)return"WARNING"; return"DANGER"; }
  if (key==="level") { if(v>=s.normLo)return"NORMAL"; if(v>=s.warnLo)return"WARNING"; return"DANGER"; }
  if (v>=s.normLo&&v<=s.normHi) return "NORMAL";
  if (v>=(s.warnLo||0)&&v<=(s.warnHi||999)) return "WARNING";
  return "DANGER";
}

const STAT_COLORS = {NORMAL:"#00C853", WARNING:"#FFA000", DANGER:"#F44336"};
const STAT_GRAD = {
  NORMAL:"linear-gradient(90deg,#00BCD4,#00C853)",
  WARNING:"linear-gradient(90deg,#FF8F00,#FFCA28)",
  DANGER:"linear-gradient(90deg,#D32F2F,#FF5252)",
};

function mkTrend(base, n=24, spread=0.3) {
  return Array.from({length:n},(_,i)=>({
    t:`${String(i).padStart(2,"0")}:00`,
    v:parseFloat((base+(Math.random()-.5)*spread*2).toFixed(2))
  }));
}

/* ═══════════════════════════════════════════════════════════════════
   ANIMATED COUNTER
═══════════════════════════════════════════════════════════════════ */
function Counter({to, dec=1, style={}}) {
  const [val, setVal] = useState(0);
  const prev = useRef(0);
  useEffect(()=>{
    const from=prev.current, end=parseFloat(to), dur=900;
    const t0=performance.now();
    const tick=(now)=>{
      const p=Math.min((now-t0)/dur,1), e=1-Math.pow(1-p,4);
      setVal(parseFloat((from+(end-from)*e).toFixed(dec)));
      if(p<1)requestAnimationFrame(tick); else prev.current=end;
    };
    requestAnimationFrame(tick);
  },[to]);
  return <span style={style}>{val}</span>;
}

/* ═══════════════════════════════════════════════════════════════════
   PARTICLES (login screen)
═══════════════════════════════════════════════════════════════════ */
function Particles() {
  const particles = useMemo(()=>Array.from({length:18},(_,i)=>({
    id:i,
    x: Math.random()*100, y: Math.random()*100,
    dx: (Math.random()-.5)*200, dy: (Math.random()-.5)*300,
    size: 3+Math.random()*6,
    delay: Math.random()*4,
    dur: 4+Math.random()*4,
    opacity: .15+Math.random()*.25,
  })),[]);
  return (
    <div style={{position:"absolute",inset:0,overflow:"hidden",pointerEvents:"none"}}>
      {particles.map(p=>(
        <div key={p.id} style={{
          position:"absolute", borderRadius:"50%",
          width:p.size, height:p.size,
          background:"rgba(255,255,255,0.6)",
          left:`${p.x}%`, top:`${p.y}%`,
          "--dx":`${p.dx}px`,"--dy":`${p.dy}px`,
          animation:`particleDrift ${p.dur}s ${p.delay}s ease-out infinite`,
          opacity:p.opacity,
        }}/>
      ))}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   LIVE PILL
═══════════════════════════════════════════════════════════════════ */
function LivePill() {
  return (
    <div style={{
      display:"flex",alignItems:"center",gap:6,padding:"5px 12px",borderRadius:50,
      background:"rgba(255,255,255,.14)",border:"1px solid rgba(255,255,255,.28)",
      backdropFilter:"blur(8px)",animation:"bIn .6s .3s cubic-bezier(.34,1.56,.64,1) both",
    }}>
      <div style={{width:8,height:8,borderRadius:"50%",background:"#00C853",animation:"glow 1.5s infinite",boxShadow:"0 0 6px #00C853"}}/>
      <span style={{color:"#fff",fontSize:11,fontWeight:800,letterSpacing:.8}}>LIVE</span>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   APP HEADER
═══════════════════════════════════════════════════════════════════ */
function Header({dark, onGear}) {
  const bg = dark
    ? "linear-gradient(135deg,#0A1628,#0D2147,#0F2D5F)"
    : "linear-gradient(90deg,#0D47A1,#1565C0,#1976D2)";
  return (
    <div style={{background:bg,padding:"14px 18px",display:"flex",alignItems:"center",gap:12,
      boxShadow:"0 4px 24px rgba(13,71,161,.35)",animation:"hdrIn .6s cubic-bezier(.34,1.2,.64,1) both",
      flexShrink:0,position:"sticky",top:0,zIndex:100}}>
      <div style={{width:44,height:44,borderRadius:12,background:"linear-gradient(135deg,#29B6F6,#00ACC1)",
        display:"flex",alignItems:"center",justifyContent:"center",fontSize:22,flexShrink:0,
        boxShadow:"0 4px 12px rgba(0,188,212,.4)",animation:"bIn .7s .1s cubic-bezier(.34,1.56,.64,1) both"}}>🌊</div>
      <div style={{flex:1,animation:"bLeft .5s .2s both"}}>
        <div style={{color:"#fff",fontWeight:900,fontSize:16,lineHeight:1.1}}>BlueFarm</div>
        <div style={{color:"rgba(255,255,255,.7)",fontWeight:600,fontSize:11}}>Water Quality System</div>
      </div>
      <div style={{display:"flex",alignItems:"center",gap:10}}>
        <LivePill/>
        <button onClick={onGear} className="btn-tap" style={{
          width:36,height:36,borderRadius:10,border:"1px solid rgba(255,255,255,.2)",
          background:"rgba(255,255,255,.12)",cursor:"pointer",display:"flex",
          alignItems:"center",justifyContent:"center",fontSize:18,backdropFilter:"blur(8px)",
          animation:"bIn .6s .35s both",transition:"transform .2s cubic-bezier(.34,1.56,.64,1)",color:"#fff",
        }}
          onMouseEnter={e=>e.currentTarget.style.transform="rotate(90deg) scale(1.1)"}
          onMouseLeave={e=>e.currentTarget.style.transform=""}
        >⚙️</button>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   iOS DOCK
═══════════════════════════════════════════════════════════════════ */
function Dock({active, onTab, dark}) {
  const tabs=[
    {id:"home",     emoji:"🏠", label:"Home"},
    {id:"diseases", emoji:"🦠", label:"Diseases"},
    {id:"market",   emoji:"💰", label:"Market"},
    {id:"settings", emoji:"⚙️", label:"Settings"},
  ];
  const [hovered, setHovered] = useState(null);
  const [jumping, setJumping] = useState(null);

  const tap = id => {
    setJumping(id);
    setTimeout(()=>setJumping(null), 600);
    onTab(id);
  };

  // iOS-style magnification: neighbor tabs also scale up
  const getScale = idx => {
    if (hovered===null) return 1;
    const dist = Math.abs(idx - tabs.findIndex(t=>t.id===hovered));
    if (dist===0) return 1.32;
    if (dist===1) return 1.14;
    if (dist===2) return 1.05;
    return 1;
  };
  const getTransY = idx => {
    if (hovered===null) return 0;
    const dist = Math.abs(idx - tabs.findIndex(t=>t.id===hovered));
    if (dist===0) return -10;
    if (dist===1) return -5;
    return 0;
  };

  return (
    <div style={{
      position:"absolute",bottom:16,left:"50%",transform:"translateX(-50%)",
      display:"flex",alignItems:"flex-end",gap:4,padding:"10px 16px 12px",
      background: dark?"rgba(18,25,41,.9)":"rgba(255,255,255,.9)",
      backdropFilter:"blur(28px)",WebkitBackdropFilter:"blur(28px)",
      borderRadius:28,zIndex:200,
      border: dark?"1px solid rgba(255,255,255,.08)":"1px solid rgba(255,255,255,.85)",
      boxShadow: dark
        ?"0 12px 48px rgba(0,0,0,.65),inset 0 1px 0 rgba(255,255,255,.06)"
        :"0 12px 48px rgba(21,101,192,.2),inset 0 1px 0 rgba(255,255,255,.95)",
      animation:"bUp .7s .3s cubic-bezier(.34,1.56,.64,1) both",
    }}>
      {tabs.map((tab,i)=>{
        const isActive=active===tab.id;
        const isJumping=jumping===tab.id;
        const scale=getScale(i);
        const ty=getTransY(i);
        return (
          <div key={tab.id}
            onClick={()=>tap(tab.id)}
            onMouseEnter={()=>setHovered(tab.id)}
            onMouseLeave={()=>setHovered(null)}
            style={{
              width:58,display:"flex",flexDirection:"column",alignItems:"center",
              gap:3,cursor:"pointer",position:"relative",
              transform:`scale(${scale}) translateY(${ty}px)`,
              transformOrigin:"bottom center",
              transition:"transform .22s cubic-bezier(.34,1.56,.64,1)",
            }}
          >
            <div style={{
              width:50,height:50,borderRadius:14,
              display:"flex",alignItems:"center",justifyContent:"center",fontSize:25,
              background: isActive
                ? (dark?"rgba(33,150,243,.25)":"#E3F0FF")
                : "transparent",
              border: isActive
                ? (dark?"1px solid rgba(33,150,243,.45)":"1px solid rgba(33,150,243,.22)")
                : "1px solid transparent",
              animation: isJumping?"dockJump .55s cubic-bezier(.34,1.56,.64,1)":"none",
              transition:"all .22s cubic-bezier(.34,1.56,.64,1)",
              boxShadow: isActive?"0 4px 18px rgba(33,150,243,.28)":"none",
            }}>
              {tab.emoji}
            </div>
            <span style={{
              fontSize:10,fontWeight:700,letterSpacing:.3,
              color: isActive?(dark?"#42A5F5":"#2196F3"):(dark?"#5C7A9E":"#90A4AE"),
              transition:"color .18s",
            }}>{tab.label}</span>
            {isActive&&(
              <div style={{
                position:"absolute",bottom:-8,width:4,height:4,borderRadius:"50%",background:"#2196F3",
                animation:"indicatorPop .4s cubic-bezier(.34,1.56,.64,1)",
              }}/>
            )}
          </div>
        );
      })}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   STATUS BADGE
═══════════════════════════════════════════════════════════════════ */
function Badge({status}) {
  const c=STAT_COLORS[status]||"#00C853";
  return (
    <span style={{
      padding:"2px 8px",borderRadius:50,fontSize:9,fontWeight:800,
      color:"#fff",background:c,letterSpacing:.8,display:"inline-block",
      animation:"bIn .5s cubic-bezier(.34,1.56,.64,1) both",
      boxShadow:`0 2px 8px ${c}55`,
    }}>{status}</span>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   PROGRESS BAR
═══════════════════════════════════════════════════════════════════ */
function ProgressBar({val, min, max, status, dark}) {
  const pct=Math.max(2,Math.min(100,((val-min)/(max-min))*100));
  return (
    <div style={{height:7,borderRadius:50,background:dark?"#1A2744":"#E3F2FD",overflow:"hidden"}}>
      <div className="fill-bar" style={{
        height:"100%",width:`${pct}%`,borderRadius:50,
        background:STAT_GRAD[status]||STAT_GRAD.NORMAL,
        animation:"fillBar 1.4s cubic-bezier(.34,1.2,.64,1) both",
        transformOrigin:"left",
        boxShadow:status==="NORMAL"?"0 0 8px rgba(0,200,83,.42)":"none",
      }}/>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SENSOR CARD
═══════════════════════════════════════════════════════════════════ */
function SensorCard({s, val, idx, dark}) {
  const status=getStat(s.key,val);
  const [vis, setVis]=useState(false);
  useEffect(()=>{const t=setTimeout(()=>setVis(true),idx*85);return()=>clearTimeout(t)},[idx]);
  if (!vis) return <div style={{minHeight:170}}/>;

  const iconBg = dark
    ? (status==="DANGER"?"rgba(244,67,54,.15)":status==="WARNING"?"rgba(255,160,0,.15)":"rgba(0,229,255,.1)")
    : (status==="DANGER"?"rgba(244,67,54,.08)":status==="WARNING"?"#FFF8E1":"#E3F2FD");

  const dec = val<1?2:val<10?1:0;

  return (
    <div className="card-hover" style={{
      background:dark?"#121929":"#fff",borderRadius:18,padding:16,
      border:dark?"1px solid #1E2D4A":"none",
      boxShadow:dark?"0 4px 24px rgba(0,0,0,.3)":"0 4px 20px rgba(21,101,192,.1)",
      animation:`cardIn .65s ${idx*.08}s cubic-bezier(.34,1.2,.64,1) both`,
    }}>
      <div style={{display:"flex",alignItems:"flex-start",gap:10,marginBottom:14}}>
        <div style={{
          width:44,height:44,borderRadius:12,flexShrink:0,background:iconBg,
          display:"flex",alignItems:"center",justifyContent:"center",fontSize:20,
          animation:"bIn .6s cubic-bezier(.34,1.56,.64,1) both",
        }}>{s.emoji}</div>
        <div>
          <div style={{fontWeight:800,fontSize:13,color:dark?T.textDark:T.navy,marginBottom:4}}>{s.label}</div>
          <Badge status={status}/>
        </div>
      </div>
      <div style={{display:"flex",alignItems:"baseline",gap:4,marginBottom:14}}>
        <Counter to={val} dec={dec} style={{fontSize:32,fontWeight:900,color:dark?T.textDark:T.navy,lineHeight:1}}/>
        <span style={{fontSize:12,fontWeight:700,color:dark?T.textDarkMid:T.textMid}}>{s.unit}</span>
      </div>
      <ProgressBar val={val} min={s.dispMin} max={s.dispMax} status={status} dark={dark}/>
      <div style={{display:"flex",justifyContent:"space-between",marginTop:6}}>
        <span style={{fontSize:10,fontWeight:700,color:dark?T.textDarkDim:T.textLight}}>{s.dispMin}{s.unit}</span>
        <span style={{fontSize:10,fontWeight:700,color:dark?T.textDarkDim:T.textLight}}>{s.dispMax}{s.unit}</span>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   ALERT BANNER
═══════════════════════════════════════════════════════════════════ */
function AlertBanner({dark}) {
  return (
    <div style={{
      background:dark?"#121929":"#fff",borderRadius:16,padding:16,
      borderLeft:"4px solid #FFA000",marginBottom:16,
      boxShadow:dark?"0 4px 24px rgba(0,0,0,.3)":"0 4px 20px rgba(255,160,0,.12)",
      animation:"bUp .6s cubic-bezier(.34,1.56,.64,1) both",
    }}>
      <div style={{display:"flex",gap:12}}>
        <div style={{
          width:38,height:38,borderRadius:10,flexShrink:0,
          background:"rgba(255,160,0,.12)",display:"flex",alignItems:"center",justifyContent:"center",
          fontSize:18,animation:"notifShake .8s .3s ease both",
        }}>💡</div>
        <div style={{flex:1}}>
          <div style={{fontWeight:800,fontSize:14,color:dark?T.textDark:T.navy,marginBottom:4}}>Turbidity slightly high</div>
          <div style={{fontWeight:700,fontSize:12,color:"#FFA000",marginBottom:3}}>Possible causes:</div>
          {["Excess feeding","Too much algae","Stirred up bottom mud"].map(c=>(
            <div key={c} style={{fontSize:12,color:dark?T.textDarkMid:T.textMid,marginBottom:2}}>• {c}</div>
          ))}
          <div style={{fontWeight:700,fontSize:12,color:"#00BCD4",margin:"7px 0 3px"}}>What to do:</div>
          {["Reduce feed by 20% for 2 days","Do a 15% water change","Check if filter is working"].map(a=>(
            <div key={a} style={{fontSize:12,color:dark?T.textDarkMid:T.textMid,marginBottom:2}}>✓ {a}</div>
          ))}
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   TREND CHART
═══════════════════════════════════════════════════════════════════ */
function TrendChart({title, lines, dark}) {
  return (
    <div style={{
      background:dark?"#121929":"#fff",borderRadius:18,padding:16,marginBottom:12,
      border:dark?"1px solid #1E2D4A":"none",
      boxShadow:dark?"0 4px 24px rgba(0,0,0,.3)":"0 4px 20px rgba(21,101,192,.08)",
      animation:"cardIn .6s cubic-bezier(.34,1.2,.64,1) both",
    }}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:12}}>
        <span style={{fontWeight:800,fontSize:13,color:dark?T.textDark:T.navy}}>{title}</span>
        <div style={{display:"flex",gap:12}}>
          {lines.map(l=>(
            <div key={l.key} style={{display:"flex",alignItems:"center",gap:4}}>
              <div style={{width:8,height:8,borderRadius:"50%",background:l.color}}/>
              <span style={{fontSize:10,color:dark?T.textDarkMid:T.textMid}}>{l.label}</span>
            </div>
          ))}
        </div>
      </div>
      <ResponsiveContainer width="100%" height={130}>
        <AreaChart data={lines[0].data} margin={{top:4,right:4,left:-22,bottom:0}}>
          <CartesianGrid strokeDasharray="3 3" stroke={dark?"#1E2D4A":"#E3F2FD"} vertical={false}/>
          <XAxis dataKey="t" tick={{fontSize:9,fill:dark?T.textDarkDim:T.textLight,fontFamily:"Nunito"}} tickLine={false} axisLine={false} interval={5}/>
          <YAxis tick={{fontSize:9,fill:dark?T.textDarkDim:T.textLight,fontFamily:"Nunito"}} tickLine={false} axisLine={false}/>
          <Tooltip contentStyle={{background:dark?"#121929":"#fff",border:dark?"1px solid #1E2D4A":"1px solid #E3F2FD",borderRadius:10,fontSize:11,fontFamily:"Nunito",color:dark?T.textDark:T.navy}}/>
          {lines.map(l=>(
            <Area key={l.key} type="monotoneX" dataKey="v" data={l.data}
              stroke={l.color} strokeWidth={2.5} fill={`${l.color}14`}
              dot={false} activeDot={{r:4,fill:l.color}}/>
          ))}
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SCREEN: SPLASH
═══════════════════════════════════════════════════════════════════ */
function Splash({onDone}) {
  useEffect(()=>{const t=setTimeout(onDone,2700);return()=>clearTimeout(t)},[]);
  return (
    <div style={{height:"100%",display:"flex",flexDirection:"column",
      background:"linear-gradient(180deg,#F0F6FF 45%,#C5D9F5 100%)",overflow:"hidden",position:"relative"}}>
      <div style={{position:"absolute",top:20,left:20,fontSize:60,opacity:.07,animation:"float 3s ease-in-out infinite"}}>🐟</div>
      <div style={{position:"absolute",bottom:0,width:"100%",height:200,overflow:"hidden",opacity:.15}}>
        <svg viewBox="0 0 800 200" style={{width:"200%",animation:"wave 8s linear infinite"}}>
          <path d="M0,100 C100,60 200,140 300,100 C400,60 500,140 600,100 C700,60 800,140 900,100 L900,200 L0,200Z" fill="#1565C0"/>
        </svg>
      </div>
      <div style={{flex:1,display:"flex",alignItems:"flex-end",justifyContent:"center",paddingBottom:24}}>
        <div style={{
          width:110,height:110,borderRadius:28,fontSize:52,
          background:"linear-gradient(135deg,#80DEEA,#E0F7FA,#BBDEFB)",
          display:"flex",alignItems:"center",justifyContent:"center",
          border:"3px solid rgba(255,255,255,.9)",
          boxShadow:"0 16px 48px rgba(0,188,212,.4),0 4px 16px rgba(0,0,0,.12)",
          animation:"splashLogo 1s .3s cubic-bezier(.34,1.56,.64,1) both",
        }}>🌊</div>
      </div>
      <div style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",paddingTop:28,gap:8}}>
        <div style={{fontSize:34,fontWeight:900,color:"#0D1B6B",letterSpacing:-.5,animation:"bUp .7s .7s cubic-bezier(.34,1.56,.64,1) both"}}>BlueFarm</div>
        <div style={{fontSize:14,fontWeight:600,color:"#1565C0",letterSpacing:.3,animation:"bUp .7s .9s cubic-bezier(.34,1.56,.64,1) both"}}>watching farms with you, for you</div>
        <div style={{display:"flex",gap:6,marginTop:32}}>
          {[0,1,2].map(i=><div key={i} style={{width:8,height:8,borderRadius:"50%",background:"#00BCD4",animation:`pulse 1.2s ${i*.2}s infinite`}}/>)}
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SCREEN: LANGUAGE
═══════════════════════════════════════════════════════════════════ */
const LANGS=[
  {code:"en",native:"English",  label:"ENGLISH"},
  {code:"hi",native:"हिन्दी",    label:"HINDI"},
  {code:"te",native:"తెలుగు",    label:"TELUGU"},
  {code:"ta",native:"தமிழ்",     label:"TAMIL"},
  {code:"bn",native:"বাংলা",     label:"BENGALI"},
  {code:"mr",native:"मराठी",     label:"MARATHI"},
];

function LangScreen({onNext}) {
  const [sel, setSel]=useState("en");
  return (
    <div style={{height:"100%",background:"#F5F8FF",display:"flex",flexDirection:"column",padding:"40px 28px 28px",overflowY:"auto"}}>
      <div style={{display:"flex",flexDirection:"column",alignItems:"center",marginBottom:28}}>
        <div style={{
          width:68,height:68,borderRadius:20,background:"#2196F3",
          display:"flex",alignItems:"center",justifyContent:"center",fontSize:32,
          boxShadow:"0 8px 24px rgba(33,150,243,.4)",
          animation:"splashLogo .7s cubic-bezier(.34,1.56,.64,1) both",
        }}>🌐</div>
        <div style={{fontSize:24,fontWeight:900,color:"#0D1B6B",marginTop:16,animation:"bUp .5s .2s both"}}>Choose Language</div>
        <div style={{fontSize:13,color:"#546E7A",marginTop:4,animation:"bUp .5s .3s both"}}>Select your preferred language to continue.</div>
      </div>
      <div style={{flex:1,display:"flex",flexDirection:"column",gap:10}}>
        {LANGS.map((l,i)=>(
          <div key={l.code} onClick={()=>setSel(l.code)} style={{
            padding:"16px 18px",borderRadius:16,background:"#fff",
            border:sel===l.code?"2px solid #2196F3":"2px solid transparent",
            boxShadow:sel===l.code?"0 4px 20px rgba(33,150,243,.18)":"0 2px 8px rgba(0,0,0,.05)",
            cursor:"pointer",display:"flex",justifyContent:"space-between",alignItems:"center",
            animation:`bLeft .5s ${.1+i*.07}s cubic-bezier(.34,1.56,.64,1) both`,
            transition:"all .25s cubic-bezier(.34,1.56,.64,1)",
            transform:sel===l.code?"scale(1.015)":"scale(1)",
          }}>
            <div>
              <div style={{fontWeight:800,fontSize:18,color:"#0D1B6B"}}>{l.native}</div>
              <div style={{fontWeight:600,fontSize:11,color:"#546E7A",letterSpacing:1}}>{l.label}</div>
            </div>
            {sel===l.code&&(
              <div style={{width:28,height:28,borderRadius:"50%",background:"#2196F3",
                display:"flex",alignItems:"center",justifyContent:"center",color:"#fff",fontSize:14,
                animation:"bIn .4s cubic-bezier(.34,1.56,.64,1)"}}>✓</div>
            )}
          </div>
        ))}
      </div>
      <button className="btn-tap" onClick={onNext} style={{
        marginTop:20,padding:"18px",borderRadius:50,border:"none",
        background:"linear-gradient(90deg,#2196F3,#0D47A1)",
        color:"#fff",fontWeight:800,fontSize:17,cursor:"pointer",
        boxShadow:"0 8px 24px rgba(33,150,243,.4)",fontFamily:"Nunito",
        display:"flex",alignItems:"center",justifyContent:"center",gap:8,
        animation:"bUp .5s .75s both",
      }}>Continue <span>›</span></button>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SCREEN: LOGIN
═══════════════════════════════════════════════════════════════════ */
function LoginScreen({onLogin}) {
  const [mode, setMode]=useState("main"); // main | email | signup
  return (
    <div style={{
      height:"100%",overflow:"auto",position:"relative",
      background:"linear-gradient(135deg,#1E88E5 0%,#29B6F6 35%,#00ACC1 70%,#00BCD4 100%)",
      display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",padding:"40px 32px",
    }}>
      <Particles/>
      {[1,2,3].map(i=>(
        <div key={i} style={{position:"absolute",borderRadius:"50%",border:"1px solid rgba(255,255,255,.07)",
          width:200+i*110,height:200+i*110,top:"50%",left:"50%",transform:"translate(-50%,-50%)",pointerEvents:"none"}}/>
      ))}
      <div style={{
        width:96,height:96,borderRadius:24,marginBottom:24,fontSize:46,zIndex:1,
        background:"linear-gradient(135deg,#80DEEA,#E0F7FA,#BBDEFB)",
        display:"flex",alignItems:"center",justifyContent:"center",
        border:"2px solid rgba(255,255,255,.85)",
        boxShadow:"0 12px 40px rgba(0,0,0,.22),0 4px 12px rgba(0,0,0,.1)",
        animation:"splashLogo .8s cubic-bezier(.34,1.56,.64,1) both",
      }}>🌊</div>
      <div style={{fontSize:34,fontWeight:900,color:"#fff",marginBottom:6,animation:"bUp .6s .2s both",zIndex:1}}>BlueFarm</div>
      <div style={{fontSize:15,color:"rgba(255,255,255,.85)",fontWeight:600,marginBottom:44,animation:"bUp .6s .3s both",zIndex:1}}>Your aquaculture companion</div>

      {mode==="main"&&(
        <div style={{width:"100%",maxWidth:380,display:"flex",flexDirection:"column",gap:14,zIndex:1}}>
          {[
            {icon:"🔴",label:"Continue with Google",onClick:onLogin,delay:.42},
            {icon:"📱",label:"Continue with Phone",onClick:()=>setMode("email"),delay:.52},
          ].map((b,i)=>(
            <button key={i} className="btn-tap" onClick={b.onClick} style={{
              padding:"16px 20px",borderRadius:50,border:"none",background:"#fff",
              display:"flex",alignItems:"center",gap:12,cursor:"pointer",
              boxShadow:"0 4px 20px rgba(0,0,0,.14)",fontFamily:"Nunito",
              animation:`bUp .5s ${b.delay}s cubic-bezier(.34,1.56,.64,1) both`,
              transition:"transform .2s cubic-bezier(.34,1.56,.64,1)",
            }}
              onMouseEnter={e=>e.currentTarget.style.transform="scale(1.025)"}
              onMouseLeave={e=>e.currentTarget.style.transform=""}
            >
              <span style={{fontSize:20}}>{b.icon}</span>
              <span style={{flex:1,textAlign:"center",fontWeight:700,fontSize:16,color:"#0D1B6B"}}>{b.label}</span>
            </button>
          ))}
          <div onClick={()=>setMode("signup")} style={{
            textAlign:"center",color:"rgba(255,255,255,.9)",fontWeight:700,
            fontSize:14,marginTop:8,cursor:"pointer",animation:"bUp .5s .62s both",
          }}>First time here? Sign up now</div>
        </div>
      )}

      {(mode==="email"||mode==="signup")&&(
        <div style={{width:"100%",maxWidth:380,zIndex:1,animation:"bUp .4s both"}}>
          {mode==="signup"&&<input className="input-focus" placeholder="Full Name" style={IS}/>}
          <input className="input-focus" placeholder="Email Address" type="email" style={{...IS,marginTop:mode==="signup"?10:0}}/>
          <input className="input-focus" placeholder="Password" type="password" style={{...IS,marginTop:10}}/>
          <button className="btn-tap" onClick={onLogin} style={ABtnStyle}>
            {mode==="signup"?"Create Account":"Sign In"}
          </button>
          <div onClick={()=>setMode("main")} style={{textAlign:"center",color:"rgba(255,255,255,.7)",fontWeight:600,fontSize:13,marginTop:12,cursor:"pointer"}}>← Back</div>
        </div>
      )}
    </div>
  );
}
const IS={width:"100%",padding:"14px 16px",borderRadius:14,border:"1px solid rgba(255,255,255,.3)",background:"rgba(255,255,255,.18)",color:"#fff",fontSize:15,fontWeight:600,fontFamily:"Nunito",outline:"none",display:"block"};
const ABtnStyle={width:"100%",padding:16,borderRadius:50,border:"none",background:"#fff",color:"#0D1B6B",fontWeight:800,fontSize:16,cursor:"pointer",boxShadow:"0 6px 20px rgba(0,0,0,.15)",marginTop:20,fontFamily:"Nunito"};

/* ═══════════════════════════════════════════════════════════════════
   SCREEN: FARM INFO
═══════════════════════════════════════════════════════════════════ */
function FarmInfoScreen({onNext}) {
  return (
    <div style={{height:"100%",background:"#F5F8FF",overflowY:"auto",padding:"40px 28px 28px"}}>
      <div style={{animation:"bUp .5s both"}}>
        <div style={{fontSize:26,fontWeight:900,color:"#0D1B6B",marginBottom:6}}>Tell us about your farm</div>
        <div style={{fontSize:14,fontWeight:600,color:"#00BCD4",marginBottom:28}}>We'll help you monitor it better</div>
      </div>
      <div style={{background:"#fff",borderRadius:20,padding:20,boxShadow:"0 4px 20px rgba(21,101,192,.08)",animation:"cardIn .6s .1s both",display:"flex",flexDirection:"column",gap:12}}>
        {["Farmer Name","Farm Name","PIN Code","Pond Size (in acres)","Fish Species (Rohu, Catla, etc.)"].map((f,i)=>(
          <input key={f} className="input-focus" placeholder={f} style={{
            padding:"14px 16px",borderRadius:12,border:"1px solid #E3F2FD",background:"#F0F5FF",
            fontSize:14,fontWeight:600,color:"#0D1B6B",fontFamily:"Nunito",outline:"none",width:"100%",
            animation:`bLeft .4s ${.15+i*.06}s both`,
          }}/>
        ))}
        <select style={{padding:"14px 16px",borderRadius:12,border:"1px solid #E3F2FD",background:"#fff",fontSize:14,fontFamily:"Nunito",color:"#546E7A",outline:"none",animation:"bLeft .4s .5s both"}}>
          <option value="">Type of Waterbody</option>
          {["Pond","Tank","Cage","Raceway","Open Water"].map(t=><option key={t}>{t}</option>)}
        </select>
      </div>
      <button className="btn-tap" onClick={onNext} style={{
        width:"100%",marginTop:24,padding:18,borderRadius:50,border:"none",
        background:"linear-gradient(90deg,#00BCD4,#1565C0)",color:"#fff",fontWeight:800,
        fontSize:17,cursor:"pointer",boxShadow:"0 8px 24px rgba(0,188,212,.4)",fontFamily:"Nunito",
        animation:"bUp .5s .6s both",
      }}>Next Step</button>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SCREEN: CONNECT DEVICE
═══════════════════════════════════════════════════════════════════ */
function ConnectScreen({onNext}) {
  const [scanning, setScanning]=useState(false);
  const doScan=()=>{setScanning(true);setTimeout(()=>{setScanning(false);onNext();},2200)};
  return (
    <div style={{height:"100%",background:"#F5F8FF",display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",padding:"40px 32px"}}>
      <div style={{position:"relative",marginBottom:40}}>
        {scanning&&[1,2,3].map(i=>(
          <div key={i} style={{
            position:"absolute",borderRadius:"50%",border:"2px solid rgba(0,188,212,.4)",
            width:60+i*44,height:60+i*44,top:"50%",left:"50%",
            animation:`scanRing 1.6s ${i*.33}s ease-out infinite`,
          }}/>
        ))}
        <div style={{
          width:130,height:130,borderRadius:"50%",fontSize:58,
          background:"linear-gradient(135deg,rgba(0,188,212,.12),rgba(21,101,192,.08))",
          display:"flex",alignItems:"center",justifyContent:"center",
          animation:scanning?"spin 2s linear infinite":"float 3s ease-in-out infinite",
        }}>📡</div>
      </div>
      <div style={{fontSize:24,fontWeight:900,color:"#0D1B6B",textAlign:"center",marginBottom:10,animation:"bUp .5s .2s both"}}>Connect your monitoring device</div>
      <div style={{fontSize:14,fontWeight:600,color:"#00BCD4",textAlign:"center",marginBottom:44,animation:"bUp .5s .3s both"}}>This helps us track water quality in real-time</div>
      <button className="btn-tap" onClick={doScan} disabled={scanning} style={{
        width:"100%",maxWidth:340,padding:18,borderRadius:50,border:"none",
        background:scanning?"#90CAF9":"linear-gradient(90deg,#00BCD4,#1565C0)",
        color:"#fff",fontWeight:800,fontSize:17,cursor:scanning?"wait":"pointer",
        boxShadow:scanning?"none":"0 8px 24px rgba(0,188,212,.4)",fontFamily:"Nunito",
        animation:"bUp .5s .42s both",
      }}>{scanning?"Scanning...":"Scan & Connect"}</button>
      <button className="btn-tap" onClick={onNext} style={{
        width:"100%",maxWidth:340,padding:18,borderRadius:50,border:"1px solid #E3F2FD",
        background:"#fff",color:"#0D1B6B",fontWeight:700,fontSize:16,cursor:"pointer",
        marginTop:14,fontFamily:"Nunito",animation:"bUp .5s .52s both",
      }}>Skip for now</button>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SCREEN: HOME
═══════════════════════════════════════════════════════════════════ */
function HomeScreen({dark, vals, onGear}) {
  const [period, setPeriod]=useState("Today");
  const ph=useMemo(()=>mkTrend(vals.ph,24,.4),[]);
  const temp=useMemo(()=>mkTrend(vals.temp,24,1.5),[]);
  const doD=useMemo(()=>mkTrend(vals.do,24,.5),[]);
  const turb=useMemo(()=>mkTrend(vals.turb,24,.6),[]);

  return (
    <div style={{display:"flex",flexDirection:"column",height:"100%",overflow:"hidden"}}>
      <Header dark={dark} onGear={onGear}/>
      <div style={{flex:1,overflowY:"auto",padding:"16px 14px 110px",background:dark?"#0A0F1E":"#EFF4FF"}}>
        <AlertBanner dark={dark}/>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:14}}>
          <span style={{fontSize:20,fontWeight:900,color:dark?T.textDark:T.navy,animation:"bLeft .5s both"}}>Live Parameters</span>
          <span style={{fontSize:11,fontWeight:600,color:dark?T.textDarkDim:T.textLight,animation:"bRight .5s both"}}>Updated just now</span>
        </div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:12,marginBottom:24}}>
          {SENSORS.map((s,i)=><SensorCard key={s.key} s={s} val={vals[s.key]??DEFAULTS[s.key]} idx={i} dark={dark}/>)}
        </div>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:14}}>
          <span style={{fontSize:20,fontWeight:900,color:dark?T.textDark:T.navy}}>Trends</span>
          <div style={{display:"flex",gap:6}}>
            {["Today","Weekly","Monthly"].map(p=>(
              <button key={p} className="btn-tap" onClick={()=>setPeriod(p)} style={{
                padding:"6px 12px",borderRadius:50,border:"none",cursor:"pointer",fontFamily:"Nunito",
                background:period===p?"#2196F3":(dark?"#1A2744":"#fff"),
                color:period===p?"#fff":(dark?T.textDarkMid:T.textMid),
                fontWeight:700,fontSize:12,
                border:period!==p?(dark?"1px solid #1E2D4A":"1px solid #CFD8DC"):"none",
                transition:"all .25s cubic-bezier(.34,1.56,.64,1)",
                transform:period===p?"scale(1.06)":"scale(1)",
              }}>{p}</button>
            ))}
          </div>
        </div>
        <TrendChart title="pH Level & Temperature" lines={[
          {key:"ph",data:ph,color:"#2196F3",label:"pH"},
          {key:"temp",data:temp,color:"#FF7043",label:"Temp °C"},
        ]} dark={dark}/>
        <TrendChart title="Dissolved Oxygen & Turbidity" lines={[
          {key:"do",data:doD,color:"#00BCD4",label:"DO mg/L"},
          {key:"turb",data:turb,color:"#9C27B0",label:"NTU"},
        ]} dark={dark}/>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SCREEN: DISEASES
═══════════════════════════════════════════════════════════════════ */
const DISEASES=[
  {name:"Bacterial Gill Disease",  icon:"🐟",sp:"Catfish, Tilapia, Rohu",  risk:"High ammonia + Low DO",        color:"#E53935",sym:"Gills pale, fish gasp at surface, appetite loss",tx:"Aeration • Reduce feed 50% • KMnO₄ 2-3ppm • 20% water change"},
  {name:"Columnaris Disease",      icon:"🦠",sp:"Catfish, Carp, Tilapia",   risk:"High temp >28°C + Low O₂",    color:"#FF6F00",sym:"White patches, fin erosion, ulcers, sluggish",tx:"Lower temp • Salt 3-5g/L • Antibiotics • Water quality"},
  {name:"Ich (White Spot)",        icon:"🔵",sp:"All freshwater fish",       risk:"Sudden temp change",          color:"#1976D2",sym:"White dots on skin/fins, rubbing, lethargy",tx:"Raise temp to 30°C • Salt 1-3g/L • CuSO₄ 0.5ppm × 7d"},
  {name:"Ammonia Poisoning",       icon:"⚗️",sp:"All fish",                  risk:"Ammonia > 0.5 mg/L",          color:"#7B1FA2",sym:"Gasping, red/purple gills, erratic swimming",tx:"40% water change • Stop feeding • Aeration • Zeolite"},
  {name:"Aeromonas Infection",     icon:"🩸",sp:"Carp, Catfish, Goldfish",   risk:"Poor water + Stress",         color:"#388E3C",sym:"Hemorrhagic ulcers, fin rot, swollen belly",tx:"Water quality • Oxytetracycline • Salt 5g/L × 10min"},
  {name:"Oxygen Depletion",        icon:"💨",sp:"All pond fish",             risk:"DO < 4 mg/L",                 color:"#0097A7",sym:"Surface crowding, gulping air, mass mortality",tx:"Emergency aeration • Stop feeding • Remove detritus"},
  {name:"pH Shock",                icon:"🧪",sp:"All fish",                  risk:"pH < 6.0 or > 9.0",           color:"#F57C00",sym:"Erratic swimming, mucus, skin lesions",tx:"Lime for low pH • Water exchange for high pH"},
  {name:"Saprolegnia (Fungal)",    icon:"🍄",sp:"Catfish, Carp, Salmon",     risk:"Cold water + Injury",         color:"#5D4037",sym:"White/grey cotton growth on skin or eggs",tx:"Salt 3g/L × 30min • Formalin • Remove infected eggs"},
];

function DiseasesScreen({dark}) {
  const [exp, setExp]=useState(null);
  return (
    <div style={{height:"100%",display:"flex",flexDirection:"column",overflow:"hidden"}}>
      <Header dark={dark} onGear={()=>{}}/>
      <div style={{flex:1,overflowY:"auto",padding:"16px 14px 110px",background:dark?"#0A0F1E":"#EFF4FF"}}>
        <div style={{fontSize:20,fontWeight:900,color:dark?T.textDark:T.navy,marginBottom:16,animation:"bLeft .5s both"}}>Disease Directory</div>
        {DISEASES.map((d,i)=>(
          <div key={d.name} onClick={()=>setExp(exp===i?null:i)} style={{
            background:dark?"#121929":"#fff",borderRadius:16,marginBottom:10,overflow:"hidden",cursor:"pointer",
            border:dark?"1px solid #1E2D4A":"none",
            boxShadow:dark?"0 4px 16px rgba(0,0,0,.3)":"0 2px 12px rgba(0,0,0,.06)",
            animation:`bUp .5s ${i*.07}s both`,transition:"all .3s cubic-bezier(.34,1.56,.64,1)",
          }}>
            <div style={{padding:"14px 16px",display:"flex",alignItems:"center",gap:12}}>
              <div style={{width:42,height:42,borderRadius:12,flexShrink:0,background:`${d.color}18`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:20}}>{d.icon}</div>
              <div style={{flex:1}}>
                <div style={{fontWeight:800,fontSize:14,color:dark?T.textDark:T.navy}}>{d.name}</div>
                <div style={{fontSize:11,color:dark?T.textDarkMid:T.textMid,marginTop:2}}>{d.sp}</div>
              </div>
              <div style={{display:"flex",flexDirection:"column",alignItems:"flex-end",gap:4}}>
                <div style={{padding:"2px 8px",borderRadius:50,fontSize:9,fontWeight:700,color:d.color,background:`${d.color}15`,border:`1px solid ${d.color}30`}}>⚠ RISK</div>
                <span style={{fontSize:16,color:dark?T.textDarkDim:T.textLight,transform:exp===i?"rotate(180deg)":"",transition:"transform .3s cubic-bezier(.34,1.56,.64,1)",display:"block"}}>⌄</span>
              </div>
            </div>
            {exp===i&&(
              <div style={{padding:"0 16px 16px",borderTop:dark?"1px solid #1E2D4A":"1px solid #E3F2FD",animation:"bUp .35s cubic-bezier(.34,1.56,.64,1)"}}>
                <div style={{marginTop:10}}><b style={{fontSize:12,color:d.color}}>⚠ Risk: </b><span style={{fontSize:12,color:dark?T.textDarkMid:T.textMid}}>{d.risk}</span></div>
                <div style={{marginTop:6}}><b style={{fontSize:12,color:dark?T.textDark:T.navy}}>🔍 Symptoms: </b><span style={{fontSize:12,color:dark?T.textDarkMid:T.textMid}}>{d.sym}</span></div>
                <div style={{marginTop:6}}><b style={{fontSize:12,color:"#00BCD4"}}>💊 Treatment: </b><span style={{fontSize:12,color:dark?T.textDarkMid:T.textMid}}>{d.tx}</span></div>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SCREEN: MARKET
═══════════════════════════════════════════════════════════════════ */
const PRICES=[
  {sp:"Rohu",          em:"🐠",price:185,region:"North India",     trend:"up",  ch:"+₹12",updated:"Today"},
  {sp:"Catla",         em:"🐟",price:210,region:"West Bengal",     trend:"up",  ch:"+₹8", updated:"Today"},
  {sp:"Tilapia",       em:"🐡",price:130,region:"South India",     trend:"flat",ch:"₹0",  updated:"Yesterday"},
  {sp:"Catfish",       em:"🐟",price:160,region:"Andhra Pradesh",  trend:"down",ch:"-₹5", updated:"Today"},
  {sp:"Pangasius",     em:"🐠",price:95, region:"All India",       trend:"down",ch:"-₹10",updated:"2 days ago"},
  {sp:"Freshwater Prawn",em:"🦐",price:420,region:"Kerala",        trend:"up",  ch:"+₹25",updated:"Today"},
  {sp:"Mrigal",        em:"🐟",price:170,region:"Odisha",          trend:"flat",ch:"₹0",  updated:"Yesterday"},
  {sp:"Silver Carp",   em:"🐠",price:145,region:"Bihar",           trend:"up",  ch:"+₹6", updated:"Today"},
  {sp:"Snakehead",     em:"🐟",price:280,region:"Tamil Nadu",      trend:"up",  ch:"+₹18",updated:"Today"},
  {sp:"Magur (Catfish)",em:"🐠",price:320,region:"Bihar/UP",       trend:"up",  ch:"+₹20",updated:"Today"},
];
const TC={up:"#00C853",flat:"#FFA000",down:"#F44336"};
const TI={up:"↑",flat:"→",down:"↓"};

function MarketScreen({dark}) {
  const [search, setSearch]=useState("");
  const filtered=PRICES.filter(p=>p.sp.toLowerCase().includes(search.toLowerCase()));
  return (
    <div style={{height:"100%",display:"flex",flexDirection:"column",overflow:"hidden"}}>
      <Header dark={dark} onGear={()=>{}}/>
      <div style={{flex:1,overflowY:"auto",padding:"16px 14px 110px",background:dark?"#0A0F1E":"#EFF4FF"}}>
        <div style={{marginBottom:16,animation:"bLeft .5s both"}}>
          <div style={{fontSize:20,fontWeight:900,color:dark?T.textDark:T.navy}}>Fish Market Prices</div>
          <div style={{fontSize:12,fontWeight:600,color:dark?T.textDarkMid:T.textMid,marginTop:2}}>₹ per kg — Wholesale prices</div>
        </div>
        {/* Stat chips */}
        <div style={{display:"flex",gap:10,marginBottom:14}}>
          {[{l:"Avg Price",v:"₹189/kg",c:"#2196F3"},{l:"Best Value",v:"Pangasius",c:"#00C853"},{l:"Top Gainer",v:"Prawn ↑₹25",c:"#FFA000"}].map((s,i)=>(
            <div key={s.l} style={{flex:1,background:dark?"#121929":"#fff",borderRadius:12,padding:"10px 12px",border:dark?"1px solid #1E2D4A":"none",boxShadow:dark?"0 2px 12px rgba(0,0,0,.25)":"0 2px 8px rgba(0,0,0,.06)",animation:`bUp .4s ${i*.08}s both`}}>
              <div style={{fontSize:10,color:dark?T.textDarkDim:T.textLight,fontWeight:600}}>{s.l}</div>
              <div style={{fontSize:13,fontWeight:800,color:s.c,marginTop:2}}>{s.v}</div>
            </div>
          ))}
        </div>
        {/* Search */}
        <input className="input-focus" placeholder="🔍  Search species..." value={search} onChange={e=>setSearch(e.target.value)} style={{
          width:"100%",padding:"12px 16px",borderRadius:14,border:dark?"1px solid #1E2D4A":"1px solid #E3F2FD",
          background:dark?"#121929":"#fff",color:dark?T.textDark:T.navy,fontSize:14,fontWeight:600,
          fontFamily:"Nunito",outline:"none",marginBottom:14,
        }}/>
        {filtered.map((f,i)=>(
          <div key={f.sp} style={{
            background:dark?"#121929":"#fff",borderRadius:16,padding:"14px 16px",marginBottom:10,
            border:dark?"1px solid #1E2D4A":"none",
            boxShadow:dark?"0 4px 16px rgba(0,0,0,.25)":"0 2px 10px rgba(0,0,0,.06)",
            display:"flex",alignItems:"center",gap:14,cursor:"pointer",
            animation:`bUp .45s ${i*.06}s both`,transition:"all .25s cubic-bezier(.34,1.56,.64,1)",
          }}
            onMouseEnter={e=>{e.currentTarget.style.transform="scale(1.02) translateX(4px)";e.currentTarget.style.boxShadow=dark?"0 8px 32px rgba(0,0,0,.4)":"0 8px 32px rgba(21,101,192,.15)"}}
            onMouseLeave={e=>{e.currentTarget.style.transform="";e.currentTarget.style.boxShadow=""}}
          >
            <div style={{width:50,height:50,borderRadius:14,flexShrink:0,background:dark?"#1A2744":"#E3F2FD",display:"flex",alignItems:"center",justifyContent:"center",fontSize:26}}>{f.em}</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:800,fontSize:15,color:dark?T.textDark:T.navy}}>{f.sp}</div>
              <div style={{fontSize:11,color:dark?T.textDarkDim:T.textLight,marginTop:2}}>📍 {f.region} · {f.updated}</div>
            </div>
            <div style={{textAlign:"right"}}>
              <div style={{fontWeight:900,fontSize:20,color:dark?T.textDark:T.navy}}>₹{f.price}</div>
              <div style={{fontWeight:700,fontSize:12,color:TC[f.trend]}}>{TI[f.trend]} {f.ch}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SCREEN: SETTINGS
═══════════════════════════════════════════════════════════════════ */
function SettingsScreen({dark, onToggleDark}) {
  const [relays, setRelays]=useState({pump:false,filter:false,aerator:false,extra:false});
  const [notifs, setNotifs]=useState({ph:true,temp:true,ammonia:true,oxygen:true});
  const [alerts, setAlerts]=useState({push:true,sms:false,email:true});

  const Toggle=({v,onChange})=>(
    <div onClick={()=>onChange(!v)} style={{
      width:46,height:26,borderRadius:13,position:"relative",cursor:"pointer",flexShrink:0,
      background:v?"#2196F3":(dark?"#1E2D4A":"#CFD8DC"),
      transition:"background .3s cubic-bezier(.34,1.56,.64,1)",
    }}>
      <div style={{position:"absolute",top:3,width:20,height:20,borderRadius:"50%",background:"#fff",
        boxShadow:"0 2px 6px rgba(0,0,0,.22)",left:v?23:3,
        transition:"left .3s cubic-bezier(.34,1.56,.64,1)"}}/>
    </div>
  );

  const Row=({icon,label,sub,right,delay=0})=>(
    <div style={{display:"flex",alignItems:"center",gap:12,padding:"12px 14px",animation:`bLeft .4s ${delay}s both`}}>
      <div style={{width:36,height:36,borderRadius:10,flexShrink:0,background:dark?"#1A2744":"#E3F2FD",display:"flex",alignItems:"center",justifyContent:"center",fontSize:17}}>{icon}</div>
      <div style={{flex:1}}>
        <div style={{fontWeight:700,fontSize:13,color:dark?T.textDark:T.navy}}>{label}</div>
        {sub&&<div style={{fontSize:11,color:dark?T.textDarkDim:T.textLight,marginTop:1}}>{sub}</div>}
      </div>
      {right}
    </div>
  );

  const Card=({children,delay=0})=>(
    <div style={{background:dark?"#121929":"#fff",borderRadius:16,border:dark?"1px solid #1E2D4A":"none",
      boxShadow:dark?"0 4px 16px rgba(0,0,0,.25)":"0 2px 12px rgba(0,0,0,.05)",
      animation:`bUp .4s ${delay}s both`,overflow:"hidden"}}>
      {children}
    </div>
  );

  const SL=({title})=>(
    <div style={{fontSize:11,fontWeight:800,letterSpacing:1.2,color:dark?T.textDarkDim:T.textMid,
      marginBottom:8,marginTop:20,paddingLeft:4,textTransform:"uppercase"}}>{title}</div>
  );
  const Div=()=><div style={{height:1,background:dark?"#1E2D4A":"#E3F2FD",marginLeft:62}}/>;

  return (
    <div style={{height:"100%",display:"flex",flexDirection:"column",overflow:"hidden"}}>
      <Header dark={dark} onGear={()=>{}}/>
      <div style={{flex:1,overflowY:"auto",padding:"16px 14px 110px",background:dark?"#0A0F1E":"#EFF4FF"}}>
        {/* Profile */}
        <div style={{background:dark?"#121929":"#fff",borderRadius:18,padding:16,
          border:dark?"1px solid #1E2D4A":"none",
          boxShadow:dark?"0 4px 24px rgba(0,0,0,.3)":"0 4px 20px rgba(21,101,192,.08)",
          display:"flex",alignItems:"center",gap:14,marginBottom:4,animation:"cardIn .5s both"}}>
          <div style={{width:58,height:58,borderRadius:"50%",flexShrink:0,
            background:"linear-gradient(135deg,#29B6F6,#00BCD4)",
            display:"flex",alignItems:"center",justifyContent:"center",
            fontSize:24,fontWeight:900,color:"#fff",boxShadow:"0 4px 16px rgba(0,188,212,.4)"}}>F</div>
          <div style={{flex:1}}>
            <div style={{fontWeight:900,fontSize:17,color:dark?T.textDark:T.navy}}>Farmer</div>
            <div style={{fontSize:12,color:dark?T.textDarkMid:T.textMid,marginTop:2}}>farmer@bluefarm.app</div>
            <div style={{fontSize:12,fontWeight:700,color:"#00BCD4",marginTop:2}}>🌾 My Fish Farm</div>
          </div>
          <span style={{fontSize:16,color:dark?T.textDarkDim:T.textLight,cursor:"pointer"}}>✏️</span>
        </div>

        <SL title="Appearance"/>
        <Card delay={.1}><Row icon={dark?"🌙":"☀️"} label="Dark Mode" sub={dark?"Dark theme active":"Light theme active"} delay={.1} right={<Toggle v={dark} onChange={onToggleDark}/>}/></Card>

        <SL title="Relay Control"/>
        <Card delay={.15}>
          {Object.entries(relays).map(([k,v],i)=>{
            const icons={pump:"💧",filter:"🔩",aerator:"💨",extra:"⚡"};
            const names={pump:"Pump (GPIO17)",filter:"Filter (GPIO27)",aerator:"Aerator (GPIO22)",extra:"Extra (GPIO23)"};
            return <div key={k}><Row icon={icons[k]} label={names[k]} sub={v?"ON — Manual":"OFF — Auto"} delay={.1+i*.05} right={<Toggle v={v} onChange={nv=>setRelays(p=>({...p,[k]:nv}))}/>}/>{i<3&&<Div/>}</div>;
          })}
        </Card>

        <SL title="Notification Alerts"/>
        <Card delay={.22}>
          {Object.entries(notifs).map(([k,v],i)=>{
            const labels={ph:"pH Alerts",temp:"Temperature Alerts",ammonia:"Ammonia Alerts",oxygen:"Oxygen Alerts"};
            return <div key={k}><Row icon="🔔" label={labels[k]} delay={.2+i*.04} right={<Toggle v={v} onChange={nv=>setNotifs(p=>({...p,[k]:nv}))}/>}/>{i<3&&<Div/>}</div>;
          })}
        </Card>

        <SL title="Alert Channels"/>
        <Card delay={.30}>
          {Object.entries(alerts).map(([k,v],i)=>{
            const labels={push:"Push Notifications",sms:"SMS Alerts",email:"Email Reports"};
            const icons={push:"📲",sms:"💬",email:"📧"};
            return <div key={k}><Row icon={icons[k]} label={labels[k]} delay={.28+i*.04} right={<Toggle v={v} onChange={nv=>setAlerts(p=>({...p,[k]:nv}))}/>}/>{i<2&&<Div/>}</div>;
          })}
        </Card>

        <SL title="About"/>
        <Card delay={.37}>
          {[["Version","1.0.0 (Build 1)"],["Backend","Supabase"],["Hardware","Raspberry Pi 3"],["Sensors","pH, Temp, DO, Turbidity"]].map(([l,v],i)=>(
            <div key={l}>
              <div style={{display:"flex",justifyContent:"space-between",padding:"12px 16px"}}>
                <span style={{fontWeight:700,fontSize:13,color:dark?T.textDarkMid:T.textMid}}>{l}</span>
                <span style={{fontWeight:700,fontSize:13,color:dark?T.textDark:T.navy}}>{v}</span>
              </div>
              {i<3&&<Div/>}
            </div>
          ))}
        </Card>

        <button className="btn-tap" style={{
          width:"100%",marginTop:24,padding:16,borderRadius:16,border:"1px solid rgba(244,67,54,.3)",
          background:"rgba(244,67,54,.1)",color:"#F44336",fontWeight:800,fontSize:15,cursor:"pointer",
          fontFamily:"Nunito",animation:"bUp .4s .45s both",display:"flex",alignItems:"center",justifyContent:"center",gap:8,
        }}>↩ Sign Out</button>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   STATUS BAR
═══════════════════════════════════════════════════════════════════ */
function StatusBar({dark}) {
  const [time, setTime]=useState(()=>new Date().toLocaleTimeString("en",{hour:"2-digit",minute:"2-digit",hour12:false}));
  useEffect(()=>{const t=setInterval(()=>setTime(new Date().toLocaleTimeString("en",{hour:"2-digit",minute:"2-digit",hour12:false})),30000);return()=>clearInterval(t)},[]);
  return (
    <div style={{height:28,background:dark?"#0A0F1E":"#EFF4FF",display:"flex",alignItems:"center",justifyContent:"space-between",padding:"0 20px",flexShrink:0}}>
      <span style={{fontSize:12,fontWeight:800,color:dark?T.textDark:T.navy}}>{time}</span>
      <div style={{display:"flex",gap:5,alignItems:"center"}}>
        <span style={{fontSize:11,color:dark?T.textDark:T.navy}}>●●●</span>
        <span style={{fontSize:11,color:dark?T.textDark:T.navy}}>WiFi</span>
        <span style={{fontSize:12}}>🔋</span>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   ROOT APP
═══════════════════════════════════════════════════════════════════ */
export default function App() {
  const [screen, setScreen]=useState("splash");
  const [tab, setTab]=useState("home");
  const [dark, setDark]=useState(false);
  const [vals, setVals]=useState(DEFAULTS);

  // Live sensor simulation
  useEffect(()=>{
    if (screen!=="app") return;
    const id=setInterval(()=>{
      setVals(p=>({
        ph:      +Math.max(6.2,Math.min(9.2,p.ph+(Math.random()-.5)*.12)).toFixed(2),
        temp:    +Math.max(20,Math.min(35,p.temp+(Math.random()-.5)*.35)).toFixed(1),
        do:      +Math.max(3,Math.min(10,p.do+(Math.random()-.5)*.18)).toFixed(1),
        turb:    +Math.max(.5,Math.min(9,p.turb+(Math.random()-.5)*.25)).toFixed(1),
        ammonia: +Math.max(0,Math.min(.7,p.ammonia+(Math.random()-.5)*.015)).toFixed(2),
        level:   +Math.max(70,Math.min(100,p.level+(Math.random()-.5)*.6)).toFixed(1),
      }));
    },4500);
    return()=>clearInterval(id);
  },[screen]);

  const renderMain=()=>{
    if (screen!=="app") return null;
    return (
      <div style={{display:"flex",flexDirection:"column",height:"100%",position:"relative"}}>
        {tab==="home"     &&<HomeScreen dark={dark} vals={vals} onGear={()=>setTab("settings")}/>}
        {tab==="diseases" &&<DiseasesScreen dark={dark}/>}
        {tab==="market"   &&<MarketScreen dark={dark}/>}
        {tab==="settings" &&<SettingsScreen dark={dark} onToggleDark={()=>setDark(d=>!d)}/>}
        <Dock active={tab} onTab={setTab} dark={dark}/>
      </div>
    );
  };

  const renderScreen=()=>{
    switch(screen){
      case "splash":    return <Splash onDone={()=>setScreen("lang")}/>;
      case "lang":      return <LangScreen onNext={()=>setScreen("login")}/>;
      case "login":     return <LoginScreen onLogin={()=>setScreen("farminfo")}/>;
      case "farminfo":  return <FarmInfoScreen onNext={()=>setScreen("connect")}/>;
      case "connect":   return <ConnectScreen onNext={()=>setScreen("app")}/>;
      case "app":       return renderMain();
      default: return null;
    }
  };

  return (
    <div className={dark?"":""} style={{
      width:"100%",height:"100dvh",
      display:"flex",alignItems:"center",justifyContent:"center",
      background:dark?"linear-gradient(135deg,#030508,#0A0F1E)":"linear-gradient(135deg,#B8CFF5,#D4E4FF,#C5D5F0)",
      fontFamily:"Nunito,sans-serif",overflow:"hidden",
    }}>
      <style>{STYLES}</style>

      {/* Phone shell */}
      <div style={{
        width:"min(410px,100vw)", height:"min(860px,100dvh)",
        borderRadius:"min(44px,0px)", overflow:"hidden", position:"relative",
        background:dark?"#0A0F1E":"#EFF4FF",
        boxShadow:"0 40px 90px rgba(0,0,0,.38),0 10px 30px rgba(0,0,0,.22),inset 0 1px 0 rgba(255,255,255,.1)",
        border:"1px solid rgba(255,255,255,.08)",
        display:"flex",flexDirection:"column",
      }}>
        {/* Status bar */}
        {screen==="app"&&<StatusBar dark={dark}/>}

        {/* Screen content */}
        <div
          key={screen==="app"?`app-${tab}`:screen}
          className={screen!=="splash"?"screen-enter":""}
          style={{flex:1,overflow:"hidden",display:"flex",flexDirection:"column"}}
        >
          {renderScreen()}
        </div>
      </div>
    </div>
  );
}
