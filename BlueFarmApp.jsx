import { useState, useEffect, useRef, useCallback } from "react";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, AreaChart, Area } from "recharts";

/* ═══════════════════════════════════════════════════════════
   GLOBAL STYLES
═══════════════════════════════════════════════════════════ */
const GlobalStyles = () => (
  <style>{`
    @import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap');

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --navy: #0D1B6B;
      --blue-dark: #0D47A1;
      --blue-mid: #1565C0;
      --blue-light: #2196F3;
      --teal: #00BCD4;
      --green: #00C853;
      --warn: #FFA000;
      --red: #F44336;
      --bg: #EFF4FF;
      --card: #FFFFFF;
      --text-mid: #546E7A;
      --text-light: #90A4AE;
      --track: #E3F2FD;
      --shadow: 0 4px 20px rgba(21,101,192,0.10);
      --radius-card: 18px;
      --radius-btn: 50px;
    }

    .dark-mode {
      --navy: #E8EEFF;
      --blue-dark: #90CAF9;
      --blue-mid: #64B5F6;
      --blue-light: #42A5F5;
      --teal: #00E5FF;
      --green: #00FF8A;
      --bg: #0A0F1E;
      --card: #121929;
      --text-mid: #8BA3C7;
      --text-light: #5C7A9E;
      --track: #1A2744;
      --shadow: 0 4px 24px rgba(0,0,0,0.5);
    }

    html, body { font-family: 'Nunito', sans-serif; overscroll-behavior: none; }

    /* ── BOUNCE KEYFRAMES ── */
    @keyframes bounceIn {
      0%   { transform: scale(0.3); opacity: 0; }
      50%  { transform: scale(1.08); opacity: 1; }
      70%  { transform: scale(0.95); }
      85%  { transform: scale(1.03); }
      100% { transform: scale(1); }
    }
    @keyframes bounceUp {
      0%   { transform: translateY(60px); opacity: 0; }
      60%  { transform: translateY(-10px); opacity: 1; }
      80%  { transform: translateY(4px); }
      100% { transform: translateY(0); }
    }
    @keyframes bounceLeft {
      0%   { transform: translateX(-40px); opacity: 0; }
      60%  { transform: translateX(8px); opacity: 1; }
      80%  { transform: translateX(-3px); }
      100% { transform: translateX(0); }
    }
    @keyframes bounceRight {
      0%   { transform: translateX(40px); opacity: 0; }
      60%  { transform: translateX(-8px); opacity: 1; }
      80%  { transform: translateX(3px); }
      100% { transform: translateX(0); }
    }
    @keyframes fadeSlideUp {
      0%   { transform: translateY(24px); opacity: 0; }
      100% { transform: translateY(0); opacity: 1; }
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50%       { opacity: 0.5; transform: scale(0.85); }
    }
    @keyframes ripple {
      0%   { transform: scale(1); opacity: 0.6; }
      100% { transform: scale(2.5); opacity: 0; }
    }
    @keyframes shimmer {
      0%   { background-position: -400px 0; }
      100% { background-position: 400px 0; }
    }
    @keyframes floatY {
      0%, 100% { transform: translateY(0px); }
      50%       { transform: translateY(-8px); }
    }
    @keyframes spin {
      from { transform: rotate(0deg); }
      to   { transform: rotate(360deg); }
    }
    @keyframes waveFlow {
      0%   { transform: translateX(0); }
      100% { transform: translateX(-50%); }
    }
    @keyframes progressFill {
      from { width: 0%; }
    }
    @keyframes dockBounce {
      0%   { transform: translateY(0) scale(1); }
      30%  { transform: translateY(-18px) scale(1.18); }
      55%  { transform: translateY(-6px) scale(1.06); }
      75%  { transform: translateY(-10px) scale(1.10); }
      100% { transform: translateY(0) scale(1); }
    }
    @keyframes counterUp {
      from { opacity: 0; transform: translateY(8px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    @keyframes glowPulse {
      0%, 100% { box-shadow: 0 0 0 0 rgba(0,200,83,0.4); }
      50%       { box-shadow: 0 0 0 8px rgba(0,200,83,0); }
    }
    @keyframes cardEntrance {
      0%   { transform: translateY(32px) scale(0.96); opacity: 0; }
      60%  { transform: translateY(-4px) scale(1.01); opacity: 1; }
      80%  { transform: translateY(2px) scale(0.995); }
      100% { transform: translateY(0) scale(1); opacity: 1; }
    }
    @keyframes headerSlide {
      0%   { transform: translateY(-100%); opacity: 0; }
      60%  { transform: translateY(6px); opacity: 1; }
      80%  { transform: translateY(-2px); }
      100% { transform: translateY(0); }
    }
    @keyframes splashLogo {
      0%   { transform: scale(0) rotate(-20deg); opacity: 0; }
      60%  { transform: scale(1.12) rotate(3deg); opacity: 1; }
      80%  { transform: scale(0.96) rotate(-1deg); }
      100% { transform: scale(1) rotate(0deg); }
    }
    @keyframes typewriter {
      from { width: 0; }
      to   { width: 100%; }
    }
    @keyframes blinkCursor {
      50% { border-color: transparent; }
    }
    @keyframes liquidFill {
      from { transform: scaleX(0); }
      to   { transform: scaleX(1); }
    }
    @keyframes notifBounce {
      0%, 100% { transform: rotate(0deg); }
      20%       { transform: rotate(-15deg); }
      40%       { transform: rotate(15deg); }
      60%       { transform: rotate(-10deg); }
      80%       { transform: rotate(8deg); }
    }
    @keyframes scanLine {
      0%   { top: 20%; }
      50%  { top: 80%; }
      100% { top: 20%; }
    }
    @keyframes connectRing {
      0%   { transform: scale(0.8); opacity: 0.8; }
      100% { transform: scale(2); opacity: 0; }
    }
    @keyframes dotBlink {
      0%, 66% { opacity: 1; }
      33%      { opacity: 0; }
    }

    /* ── SCREEN TRANSITIONS ── */
    .screen-enter {
      animation: bounceUp 0.55s cubic-bezier(0.34,1.56,0.64,1) forwards;
    }
    .screen-exit {
      animation: fadeSlideUp 0.3s ease forwards reverse;
    }

    /* ── SCROLLBAR ── */
    ::-webkit-scrollbar { width: 4px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: rgba(21,101,192,0.2); border-radius: 4px; }

    /* ── DOCK ITEM HOVER ── */
    .dock-item:hover .dock-icon {
      transform: scale(1.25) translateY(-8px);
      transition: transform 0.25s cubic-bezier(0.34,1.56,0.64,1);
    }
    .dock-item .dock-icon {
      transition: transform 0.3s cubic-bezier(0.34,1.56,0.64,1);
    }

    /* ── BUTTON PRESS ── */
    .btn-press:active {
      transform: scale(0.94);
      transition: transform 0.1s;
    }

    /* ── GLASS MORPHISM ── */
    .glass {
      background: rgba(255,255,255,0.15);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border: 1px solid rgba(255,255,255,0.25);
    }
    .dark-mode .glass {
      background: rgba(10,15,30,0.6);
      border: 1px solid rgba(255,255,255,0.08);
    }

    /* ── STATUS BADGE ── */
    .badge-normal  { background: #00C853; color: #fff; }
    .badge-warning { background: #FFA000; color: #fff; }
    .badge-danger  { background: #F44336; color: #fff; }

    /* ── PROGRESS BAR FILL ── */
    .progress-fill {
      animation: liquidFill 1.2s cubic-bezier(0.34,1.2,0.64,1) forwards;
      transform-origin: left;
    }

    /* ── INPUT FOCUS ── */
    .bf-input:focus {
      outline: none;
      border-color: var(--teal);
      box-shadow: 0 0 0 3px rgba(0,188,212,0.15);
      transform: scale(1.01);
      transition: all 0.2s cubic-bezier(0.34,1.56,0.64,1);
    }

    /* ── CARD HOVER ── */
    .sensor-card:hover {
      transform: translateY(-3px) scale(1.01);
      box-shadow: 0 12px 40px rgba(21,101,192,0.18);
      transition: all 0.3s cubic-bezier(0.34,1.56,0.64,1);
    }
    .sensor-card {
      transition: all 0.3s cubic-bezier(0.34,1.56,0.64,1);
    }
  `}</style>
);

/* ═══════════════════════════════════════════════════════════
   CONSTANTS
═══════════════════════════════════════════════════════════ */
const SENSOR_CONFIG = [
  { key: "ph",       label: "pH Level",         icon: "🧪", unit: "pH",   min: 6.5, max: 8.5,  display_min: 6.5, display_max: 8.5 },
  { key: "temp",     label: "Temperature",       icon: "🌡️", unit: "°C",  min: 24,  max: 30,   display_min: 24,  display_max: 30  },
  { key: "do",       label: "Dissolved Oxygen",  icon: "💧", unit: "mg/L",min: 5,   max: 8,    display_min: 5,   display_max: 8   },
  { key: "turb",     label: "Turbidity",         icon: "🔵", unit: "NTU", min: 1,   max: 5,    display_min: 1,   display_max: 5   },
  { key: "ammonia",  label: "Ammonia",            icon: "⚠️", unit: "mg/L",min: 0,   max: 0.5,  display_min: 0,   display_max: 0.5 },
  { key: "level",    label: "Water Level",        icon: "📏", unit: "%",   min: 80,  max: 100,  display_min: 80,  display_max: 100 },
];

const MOCK_VALUES = { ph: 7.2, temp: 28.5, do: 6.8, turb: 2.5, ammonia: 0.15, level: 92 };

function getStatus(key, val) {
  const thresholds = {
    ph:      { warnLo: 6.0, normLo: 6.5, normHi: 8.5, warnHi: 9.0 },
    temp:    { warnLo: 22,  normLo: 24,  normHi: 30,  warnHi: 32  },
    do:      { warnLo: 4,   normLo: 5,   normHi: 8,   warnHi: 10  },
    turb:    { normLo: 0,   normHi: 5,   warnHi: 7                 },
    ammonia: { normLo: 0,   normHi: 0.3, warnHi: 0.5              },
    level:   { warnLo: 75,  normLo: 80,  normHi: 100              },
  };
  const t = thresholds[key];
  if (!t) return "NORMAL";
  if (key === "turb" || key === "ammonia") {
    if (val <= t.normHi) return "NORMAL";
    if (val <= t.warnHi) return "WARNING";
    return "DANGER";
  }
  if (key === "level") {
    if (val >= t.normLo) return "NORMAL";
    if (val >= t.warnLo) return "WARNING";
    return "DANGER";
  }
  if (val >= t.normLo && val <= t.normHi) return "NORMAL";
  if (val >= t.warnLo && val <= t.warnHi) return "WARNING";
  return "DANGER";
}

function generateTrend(base, points = 24, variance = 0.3) {
  return Array.from({ length: points }, (_, i) => ({
    time: `${String(i).padStart(2, "0")}:00`,
    value: parseFloat((base + (Math.random() - 0.5) * variance * 2).toFixed(2)),
  }));
}

/* ═══════════════════════════════════════════════════════════
   ANIMATED COUNTER
═══════════════════════════════════════════════════════════ */
function AnimatedNumber({ value, decimals = 1 }) {
  const [display, setDisplay] = useState(0);
  const prev = useRef(0);

  useEffect(() => {
    const start = prev.current;
    const end = parseFloat(value);
    const duration = 900;
    const startTime = performance.now();
    const frame = (now) => {
      const progress = Math.min((now - startTime) / duration, 1);
      const ease = 1 - Math.pow(1 - progress, 4);
      setDisplay(parseFloat((start + (end - start) * ease).toFixed(decimals)));
      if (progress < 1) requestAnimationFrame(frame);
      else prev.current = end;
    };
    requestAnimationFrame(frame);
  }, [value]);

  return <span>{display}</span>;
}

/* ═══════════════════════════════════════════════════════════
   LIVE INDICATOR
═══════════════════════════════════════════════════════════ */
function LivePill({ isOnline }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 6,
      padding: "5px 12px", borderRadius: 50,
      background: "rgba(255,255,255,0.14)",
      border: "1px solid rgba(255,255,255,0.28)",
      backdropFilter: "blur(8px)",
      animation: "bounceIn 0.6s cubic-bezier(0.34,1.56,0.64,1) both",
    }}>
      <div style={{
        width: 8, height: 8, borderRadius: "50%",
        background: isOnline ? "#00C853" : "#F44336",
        animation: "glowPulse 1.5s infinite",
        boxShadow: `0 0 6px ${isOnline ? "#00C853" : "#F44336"}`,
      }} />
      <span style={{ color: "#fff", fontSize: 11, fontWeight: 800, letterSpacing: 0.8 }}>LIVE</span>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   APP HEADER
═══════════════════════════════════════════════════════════ */
function AppHeader({ onSettings, isDark }) {
  return (
    <div style={{
      background: isDark
        ? "linear-gradient(135deg,#0A1628,#0D2147,#0F2D5F)"
        : "linear-gradient(90deg,#0D47A1,#1565C0,#1976D2)",
      padding: "14px 18px",
      display: "flex", alignItems: "center", gap: 12,
      boxShadow: "0 4px 24px rgba(13,71,161,0.35)",
      animation: "headerSlide 0.6s cubic-bezier(0.34,1.2,0.64,1) both",
      position: "sticky", top: 0, zIndex: 100,
      flexShrink: 0,
    }}>
      {/* Logo icon */}
      <div style={{
        width: 44, height: 44, borderRadius: 12, overflow: "hidden",
        background: "linear-gradient(135deg,#29B6F6,#00ACC1)",
        display: "flex", alignItems: "center", justifyContent: "center",
        boxShadow: "0 4px 12px rgba(0,188,212,0.4)",
        animation: "bounceIn 0.7s 0.1s cubic-bezier(0.34,1.56,0.64,1) both",
        fontSize: 22, flexShrink: 0,
      }}>🌊</div>

      {/* Title */}
      <div style={{ flex: 1, animation: "bounceLeft 0.5s 0.2s both" }}>
        <div style={{ color: "#fff", fontWeight: 900, fontSize: 16, lineHeight: 1.1 }}>BlueFarm</div>
        <div style={{ color: "rgba(255,255,255,0.7)", fontWeight: 600, fontSize: 11 }}>Water Quality System</div>
      </div>

      {/* Live + Settings */}
      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
        <LivePill isOnline={true} />
        <button
          onClick={onSettings}
          style={{
            width: 36, height: 36, borderRadius: 10, border: "1px solid rgba(255,255,255,0.2)",
            background: "rgba(255,255,255,0.12)", cursor: "pointer",
            display: "flex", alignItems: "center", justifyContent: "center",
            color: "#fff", fontSize: 18, backdropFilter: "blur(8px)",
            animation: "bounceIn 0.6s 0.3s both",
            transition: "all 0.2s cubic-bezier(0.34,1.56,0.64,1)",
          }}
          className="btn-press"
          onMouseEnter={e => e.currentTarget.style.transform = "rotate(90deg) scale(1.1)"}
          onMouseLeave={e => e.currentTarget.style.transform = ""}
        >⚙️</button>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   iOS DOCK BAR
═══════════════════════════════════════════════════════════ */
function IosDock({ active, onTab, isDark }) {
  const tabs = [
    { icon: "🏠", label: "Home", id: "home" },
    { icon: "🦠", label: "Diseases", id: "diseases" },
    { icon: "💰", label: "Market", id: "market" },
    { icon: "⚙️", label: "Settings", id: "settings" },
  ];
  const [bouncing, setBouncing] = useState(null);
  const [hovered, setHovered] = useState(null);

  const handleTap = (id) => {
    setBouncing(id);
    setTimeout(() => setBouncing(null), 600);
    onTab(id);
  };

  const getScale = (id) => {
    if (id === hovered) return 1.25;
    const ids = tabs.map(t => t.id);
    const hIdx = ids.indexOf(hovered);
    const cIdx = ids.indexOf(id);
    if (hIdx === -1) return 1;
    const dist = Math.abs(hIdx - cIdx);
    if (dist === 1) return 1.1;
    return 1;
  };

  return (
    <div style={{
      position: "fixed", bottom: 16, left: "50%", transform: "translateX(-50%)",
      display: "flex", alignItems: "flex-end", gap: 8,
      padding: "10px 18px",
      background: isDark ? "rgba(18,25,41,0.88)" : "rgba(255,255,255,0.88)",
      backdropFilter: "blur(24px)", WebkitBackdropFilter: "blur(24px)",
      borderRadius: 28,
      border: isDark ? "1px solid rgba(255,255,255,0.08)" : "1px solid rgba(255,255,255,0.8)",
      boxShadow: isDark
        ? "0 8px 40px rgba(0,0,0,0.6), inset 0 1px 0 rgba(255,255,255,0.06)"
        : "0 8px 40px rgba(21,101,192,0.18), inset 0 1px 0 rgba(255,255,255,0.9)",
      zIndex: 200,
      animation: "bounceUp 0.7s 0.3s cubic-bezier(0.34,1.56,0.64,1) both",
    }}>
      {tabs.map((tab, i) => {
        const isActive = active === tab.id;
        const isBouncing = bouncing === tab.id;
        const scale = getScale(tab.id);

        return (
          <div
            key={tab.id}
            className="dock-item"
            onClick={() => handleTap(tab.id)}
            onMouseEnter={() => setHovered(tab.id)}
            onMouseLeave={() => setHovered(null)}
            style={{
              display: "flex", flexDirection: "column", alignItems: "center",
              gap: 3, cursor: "pointer", position: "relative",
              width: 56,
              transform: `scale(${scale})`,
              transition: "transform 0.25s cubic-bezier(0.34,1.56,0.64,1)",
              transformOrigin: "bottom center",
            }}
          >
            {/* Icon container */}
            <div
              className="dock-icon"
              style={{
                width: 48, height: 48, borderRadius: 14,
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 24,
                background: isActive
                  ? (isDark ? "rgba(33,150,243,0.25)" : "#E3F0FF")
                  : "transparent",
                border: isActive
                  ? (isDark ? "1px solid rgba(33,150,243,0.4)" : "1px solid rgba(33,150,243,0.2)")
                  : "1px solid transparent",
                animation: isBouncing ? "dockBounce 0.55s cubic-bezier(0.34,1.56,0.64,1)" : "none",
                transition: "all 0.25s cubic-bezier(0.34,1.56,0.64,1)",
                boxShadow: isActive ? "0 4px 16px rgba(33,150,243,0.25)" : "none",
              }}
            >
              {tab.icon}
            </div>
            {/* Label */}
            <span style={{
              fontSize: 10, fontWeight: 700,
              color: isActive
                ? (isDark ? "#42A5F5" : "#2196F3")
                : (isDark ? "#5C7A9E" : "#90A4AE"),
              transition: "color 0.2s",
              letterSpacing: 0.3,
            }}>{tab.label}</span>
            {/* Active dot */}
            {isActive && (
              <div style={{
                position: "absolute", bottom: -6, width: 4, height: 4,
                borderRadius: "50%", background: "#2196F3",
                animation: "bounceIn 0.4s cubic-bezier(0.34,1.56,0.64,1)",
              }} />
            )}
          </div>
        );
      })}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   STATUS BADGE
═══════════════════════════════════════════════════════════ */
function StatusBadge({ status }) {
  const colors = { NORMAL: "#00C853", WARNING: "#FFA000", DANGER: "#F44336" };
  return (
    <span style={{
      padding: "2px 8px", borderRadius: 50, fontSize: 9, fontWeight: 800,
      letterSpacing: 0.8, color: "#fff",
      background: colors[status] || "#00C853",
      display: "inline-block",
      animation: "bounceIn 0.5s cubic-bezier(0.34,1.56,0.64,1) both",
      boxShadow: `0 2px 8px ${colors[status]}55`,
    }}>{status}</span>
  );
}

/* ═══════════════════════════════════════════════════════════
   PROGRESS BAR
═══════════════════════════════════════════════════════════ */
function ProgressBar({ value, min, max, status, isDark }) {
  const pct = Math.max(2, Math.min(100, ((value - min) / (max - min)) * 100));
  const gradients = {
    NORMAL:  "linear-gradient(90deg,#00BCD4,#00C853)",
    WARNING: "linear-gradient(90deg,#FF8F00,#FFCA28)",
    DANGER:  "linear-gradient(90deg,#D32F2F,#FF5252)",
  };
  return (
    <div style={{
      height: 7, borderRadius: 50,
      background: isDark ? "#1A2744" : "#E3F2FD",
      overflow: "hidden", position: "relative",
    }}>
      <div className="progress-fill" style={{
        height: "100%", width: `${pct}%`, borderRadius: 50,
        background: gradients[status] || gradients.NORMAL,
        animationDuration: "1.4s",
        boxShadow: status === "NORMAL" ? "0 0 8px rgba(0,200,83,0.4)" : "none",
      }} />
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   SENSOR CARD
═══════════════════════════════════════════════════════════ */
function SensorCard({ config, value, index, isDark }) {
  const status = getStatus(config.key, value);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setVisible(true), index * 90);
    return () => clearTimeout(t);
  }, [index]);

  if (!visible) return <div style={{ minHeight: 160 }} />;

  return (
    <div
      className="sensor-card"
      style={{
        background: isDark ? "#121929" : "#fff",
        borderRadius: 18,
        padding: "16px",
        border: isDark ? "1px solid #1E2D4A" : "none",
        boxShadow: isDark ? "0 4px 24px rgba(0,0,0,0.3)" : "0 4px 20px rgba(21,101,192,0.10)",
        animation: `cardEntrance 0.65s ${index * 0.08}s cubic-bezier(0.34,1.2,0.64,1) both`,
      }}
    >
      {/* Header row */}
      <div style={{ display: "flex", alignItems: "flex-start", gap: 10, marginBottom: 14 }}>
        <div style={{
          width: 44, height: 44, borderRadius: 12, flexShrink: 0,
          background: status === "DANGER"
            ? (isDark ? "rgba(244,67,54,0.15)" : "rgba(244,67,54,0.08)")
            : status === "WARNING"
            ? (isDark ? "rgba(255,160,0,0.15)" : "#FFF8E1")
            : (isDark ? "rgba(0,229,255,0.1)" : "#E3F2FD"),
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: 20, animation: "bounceIn 0.6s cubic-bezier(0.34,1.56,0.64,1) both",
        }}>{config.icon}</div>
        <div>
          <div style={{ fontWeight: 800, fontSize: 13, color: isDark ? "#E8EEFF" : "#0D1B6B", marginBottom: 4 }}>
            {config.label}
          </div>
          <StatusBadge status={status} />
        </div>
      </div>

      {/* Big value */}
      <div style={{ display: "flex", alignItems: "baseline", gap: 4, marginBottom: 14 }}>
        <span style={{
          fontSize: 32, fontWeight: 900, color: isDark ? "#E8EEFF" : "#0D1B6B",
          lineHeight: 1, animation: "counterUp 0.6s cubic-bezier(0.34,1.56,0.64,1) both",
        }}>
          <AnimatedNumber value={value} decimals={value < 10 && value !== Math.floor(value) ? 1 : value < 1 ? 2 : 1} />
        </span>
        <span style={{ fontSize: 12, fontWeight: 700, color: isDark ? "#8BA3C7" : "#546E7A" }}>
          {config.unit}
        </span>
      </div>

      {/* Progress bar */}
      <ProgressBar value={value} min={config.display_min} max={config.display_max} status={status} isDark={isDark} />

      {/* Min / Max */}
      <div style={{ display: "flex", justifyContent: "space-between", marginTop: 6 }}>
        <span style={{ fontSize: 10, fontWeight: 700, color: isDark ? "#5C7A9E" : "#90A4AE" }}>
          {config.display_min}{config.unit}
        </span>
        <span style={{ fontSize: 10, fontWeight: 700, color: isDark ? "#5C7A9E" : "#90A4AE" }}>
          {config.display_max}{config.unit}
        </span>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   ALERT BANNER
═══════════════════════════════════════════════════════════ */
function AlertBanner({ isDark }) {
  return (
    <div style={{
      background: isDark ? "#121929" : "#fff",
      borderRadius: 16, padding: "16px",
      borderLeft: "4px solid #FFA000",
      boxShadow: isDark ? "0 4px 24px rgba(0,0,0,0.3)" : "0 4px 20px rgba(255,160,0,0.12)",
      animation: "bounceUp 0.6s cubic-bezier(0.34,1.56,0.64,1) both",
      marginBottom: 16,
    }}>
      <div style={{ display: "flex", gap: 12 }}>
        <div style={{
          width: 38, height: 38, borderRadius: 10, flexShrink: 0,
          background: "rgba(255,160,0,0.12)",
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: 18, animation: "notifBounce 0.8s 0.3s ease both",
        }}>💡</div>
        <div>
          <div style={{ fontWeight: 800, fontSize: 14, color: isDark ? "#E8EEFF" : "#0D1B6B", marginBottom: 4 }}>
            Turbidity slightly high
          </div>
          <div style={{ fontWeight: 700, fontSize: 12, color: "#FFA000", marginBottom: 4 }}>Possible causes:</div>
          {["Excess feeding", "Too much algae", "Stirred up bottom mud"].map((c, i) => (
            <div key={i} style={{ fontSize: 12, color: isDark ? "#8BA3C7" : "#546E7A", marginBottom: 2 }}>• {c}</div>
          ))}
          <div style={{ fontWeight: 700, fontSize: 12, color: "#00BCD4", margin: "8px 0 4px" }}>What to do:</div>
          {["Reduce feed by 20% for 2 days", "Do a 15% water change", "Check if filter is working"].map((a, i) => (
            <div key={i} style={{ fontSize: 12, color: isDark ? "#8BA3C7" : "#546E7A", marginBottom: 2 }}>✓ {a}</div>
          ))}
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   TREND CHART
═══════════════════════════════════════════════════════════ */
function TrendChart({ title, lines, isDark }) {
  return (
    <div style={{
      background: isDark ? "#121929" : "#fff",
      borderRadius: 18, padding: 16,
      border: isDark ? "1px solid #1E2D4A" : "none",
      boxShadow: isDark ? "0 4px 24px rgba(0,0,0,0.3)" : "0 4px 20px rgba(21,101,192,0.08)",
      animation: "cardEntrance 0.6s cubic-bezier(0.34,1.2,0.64,1) both",
      marginBottom: 12,
    }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
        <span style={{ fontWeight: 800, fontSize: 13, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>{title}</span>
        <div style={{ display: "flex", gap: 12 }}>
          {lines.map(l => (
            <div key={l.key} style={{ display: "flex", alignItems: "center", gap: 4 }}>
              <div style={{ width: 8, height: 8, borderRadius: "50%", background: l.color }} />
              <span style={{ fontSize: 10, color: isDark ? "#8BA3C7" : "#546E7A" }}>{l.label}</span>
            </div>
          ))}
        </div>
      </div>
      <ResponsiveContainer width="100%" height={140}>
        <AreaChart data={lines[0].data} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
          <CartesianGrid strokeDasharray="3 3" stroke={isDark ? "#1E2D4A" : "#E3F2FD"} vertical={false} />
          <XAxis dataKey="time" tick={{ fontSize: 9, fill: isDark ? "#5C7A9E" : "#90A4AE", fontFamily: "Nunito" }} tickLine={false} axisLine={false} interval={5} />
          <YAxis tick={{ fontSize: 9, fill: isDark ? "#5C7A9E" : "#90A4AE", fontFamily: "Nunito" }} tickLine={false} axisLine={false} />
          <Tooltip
            contentStyle={{
              background: isDark ? "#121929" : "#fff",
              border: isDark ? "1px solid #1E2D4A" : "1px solid #E3F2FD",
              borderRadius: 10, fontSize: 11, fontFamily: "Nunito",
              color: isDark ? "#E8EEFF" : "#0D1B6B",
            }}
          />
          {lines.map(l => (
            <Area key={l.key} type="monotoneX" dataKey="value" data={l.data}
              stroke={l.color} strokeWidth={2.5} fill={`${l.color}18`}
              dot={false} activeDot={{ r: 4, fill: l.color }}
            />
          ))}
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   SCREEN: SPLASH
═══════════════════════════════════════════════════════════ */
function SplashScreen({ onNext }) {
  useEffect(() => { const t = setTimeout(onNext, 2600); return () => clearTimeout(t); }, []);

  return (
    <div style={{
      height: "100%", display: "flex", flexDirection: "column",
      background: "linear-gradient(180deg,#F0F6FF 45%,#C5D9F5 100%)",
      overflow: "hidden", position: "relative",
    }}>
      {/* Decorative fish outline top-left */}
      <div style={{
        position: "absolute", top: 20, left: 20, fontSize: 64, opacity: 0.07,
        animation: "floatY 3s ease-in-out infinite",
      }}>🐟</div>

      {/* Wave BG */}
      <div style={{ position: "absolute", bottom: 0, width: "100%", height: 200, overflow: "hidden", opacity: 0.15 }}>
        <svg viewBox="0 0 800 200" style={{ width: "200%", animation: "waveFlow 8s linear infinite" }}>
          <path d="M0,100 C100,60 200,140 300,100 C400,60 500,140 600,100 C700,60 800,140 900,100 L900,200 L0,200 Z" fill="#1565C0" />
        </svg>
      </div>

      {/* Content - top half */}
      <div style={{ flex: 1, display: "flex", alignItems: "flex-end", justifyContent: "center", paddingBottom: 20 }}>
        {/* App Icon */}
        <div style={{
          width: 110, height: 110, borderRadius: 28,
          background: "linear-gradient(135deg,#80DEEA,#E0F7FA,#BBDEFB)",
          display: "flex", alignItems: "center", justifyContent: "center",
          boxShadow: "0 16px 48px rgba(0,188,212,0.4), 0 4px 16px rgba(0,0,0,0.12)",
          animation: "splashLogo 1s 0.3s cubic-bezier(0.34,1.56,0.64,1) both",
          border: "3px solid rgba(255,255,255,0.9)",
          fontSize: 52,
        }}>🌊</div>
      </div>

      {/* Content - bottom half */}
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", paddingTop: 24, gap: 8 }}>
        <div style={{
          fontSize: 34, fontWeight: 900, color: "#0D1B6B",
          animation: "bounceUp 0.7s 0.7s cubic-bezier(0.34,1.56,0.64,1) both",
          letterSpacing: -0.5,
        }}>BlueFarm</div>
        <div style={{
          fontSize: 14, fontWeight: 600, color: "#1565C0",
          animation: "bounceUp 0.7s 0.9s cubic-bezier(0.34,1.56,0.64,1) both",
          letterSpacing: 0.3,
        }}>watching farms with you, for you</div>

        {/* Loading dots */}
        <div style={{ display: "flex", gap: 6, marginTop: 32, animation: "fadeSlideUp 0.5s 1.2s both" }}>
          {[0,1,2].map(i => (
            <div key={i} style={{
              width: 8, height: 8, borderRadius: "50%", background: "#00BCD4",
              animation: `pulse 1.2s ${i * 0.2}s infinite`,
            }} />
          ))}
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   SCREEN: LANGUAGE
═══════════════════════════════════════════════════════════ */
const LANGS = [
  { code: "en", native: "English", label: "ENGLISH" },
  { code: "hi", native: "हिन्दी",  label: "HINDI" },
  { code: "te", native: "తెలుగు",  label: "TELUGU" },
  { code: "ta", native: "தமிழ்",   label: "TAMIL" },
  { code: "bn", native: "বাংলা",   label: "BENGALI" },
  { code: "mr", native: "मराठी",   label: "MARATHI" },
];

function LanguageScreen({ onNext }) {
  const [selected, setSelected] = useState("en");

  return (
    <div style={{ height: "100%", background: "#F5F8FF", display: "flex", flexDirection: "column", padding: "40px 28px 28px", overflowY: "auto" }}>
      {/* Icon */}
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", marginBottom: 28 }}>
        <div style={{
          width: 68, height: 68, borderRadius: 20, background: "#2196F3",
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: 32, color: "#fff", fontWeight: 900,
          boxShadow: "0 8px 24px rgba(33,150,243,0.4)",
          animation: "splashLogo 0.7s cubic-bezier(0.34,1.56,0.64,1) both",
        }}>🌐</div>
        <div style={{ fontSize: 24, fontWeight: 900, color: "#0D1B6B", marginTop: 16, animation: "bounceUp 0.5s 0.2s both" }}>
          Choose Language
        </div>
        <div style={{ fontSize: 13, color: "#546E7A", marginTop: 4, animation: "bounceUp 0.5s 0.3s both" }}>
          Select your preferred language to continue.
        </div>
      </div>

      {/* Lang list */}
      <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 10 }}>
        {LANGS.map((lang, i) => (
          <div
            key={lang.code}
            onClick={() => setSelected(lang.code)}
            style={{
              padding: "16px 18px", borderRadius: 16,
              background: "#fff",
              border: selected === lang.code ? "2px solid #2196F3" : "2px solid transparent",
              boxShadow: selected === lang.code
                ? "0 4px 20px rgba(33,150,243,0.18)"
                : "0 2px 8px rgba(0,0,0,0.05)",
              cursor: "pointer",
              display: "flex", justifyContent: "space-between", alignItems: "center",
              animation: `bounceLeft 0.5s ${0.1 + i * 0.07}s cubic-bezier(0.34,1.56,0.64,1) both`,
              transition: "all 0.25s cubic-bezier(0.34,1.56,0.64,1)",
              transform: selected === lang.code ? "scale(1.01)" : "scale(1)",
            }}
          >
            <div>
              <div style={{ fontWeight: 800, fontSize: 18, color: "#0D1B6B" }}>{lang.native}</div>
              <div style={{ fontWeight: 600, fontSize: 11, color: "#546E7A", letterSpacing: 1 }}>{lang.label}</div>
            </div>
            {selected === lang.code && (
              <div style={{
                width: 28, height: 28, borderRadius: "50%", background: "#2196F3",
                display: "flex", alignItems: "center", justifyContent: "center", color: "#fff", fontSize: 14,
                animation: "bounceIn 0.4s cubic-bezier(0.34,1.56,0.64,1)",
              }}>✓</div>
            )}
          </div>
        ))}
      </div>

      {/* Continue button */}
      <button
        onClick={onNext}
        className="btn-press"
        style={{
          marginTop: 20, padding: "18px", borderRadius: 50, border: "none",
          background: "linear-gradient(90deg,#2196F3,#0D47A1)",
          color: "#fff", fontWeight: 800, fontSize: 17, cursor: "pointer",
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          boxShadow: "0 8px 24px rgba(33,150,243,0.4)",
          animation: "bounceUp 0.5s 0.7s both",
          fontFamily: "Nunito",
        }}
      >Continue <span>›</span></button>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   SCREEN: LOGIN
═══════════════════════════════════════════════════════════ */
function LoginScreen({ onLogin }) {
  const [showEmail, setShowEmail] = useState(false);
  const [isSignUp, setIsSignUp] = useState(false);

  return (
    <div style={{
      height: "100%", overflow: "auto",
      background: "linear-gradient(135deg,#1E88E5 0%,#29B6F6 35%,#00ACC1 70%,#00BCD4 100%)",
      display: "flex", flexDirection: "column", alignItems: "center",
      justifyContent: "center", padding: "40px 32px",
    }}>
      {/* Ripple bg circles */}
      {[1,2,3].map(i => (
        <div key={i} style={{
          position: "absolute", width: 200 + i * 100, height: 200 + i * 100,
          borderRadius: "50%", border: "1px solid rgba(255,255,255,0.08)",
          top: "50%", left: "50%", transform: "translate(-50%,-50%)",
          pointerEvents: "none",
        }} />
      ))}

      {/* App Icon */}
      <div style={{
        width: 96, height: 96, borderRadius: 24, marginBottom: 24,
        background: "linear-gradient(135deg,#80DEEA,#E0F7FA,#BBDEFB)",
        display: "flex", alignItems: "center", justifyContent: "center",
        boxShadow: "0 12px 40px rgba(0,0,0,0.22), 0 4px 12px rgba(0,0,0,0.1)",
        animation: "splashLogo 0.8s cubic-bezier(0.34,1.56,0.64,1) both",
        border: "2px solid rgba(255,255,255,0.85)",
        fontSize: 46, zIndex: 1,
      }}>🌊</div>

      <div style={{ fontSize: 34, fontWeight: 900, color: "#fff", marginBottom: 6, animation: "bounceUp 0.6s 0.2s both", zIndex: 1 }}>
        BlueFarm
      </div>
      <div style={{ fontSize: 15, color: "rgba(255,255,255,0.85)", fontWeight: 600, marginBottom: 48, animation: "bounceUp 0.6s 0.3s both", zIndex: 1 }}>
        Your aquaculture companion
      </div>

      {!showEmail ? (
        <div style={{ width: "100%", maxWidth: 380, display: "flex", flexDirection: "column", gap: 14, zIndex: 1 }}>
          {/* Google */}
          <button
            onClick={onLogin}
            className="btn-press"
            style={{
              padding: "16px 20px", borderRadius: 50, border: "none", background: "#fff",
              display: "flex", alignItems: "center", gap: 12, cursor: "pointer",
              boxShadow: "0 4px 20px rgba(0,0,0,0.14)",
              animation: "bounceUp 0.5s 0.4s cubic-bezier(0.34,1.56,0.64,1) both",
              fontFamily: "Nunito",
              transition: "transform 0.2s cubic-bezier(0.34,1.56,0.64,1)",
            }}
            onMouseEnter={e => e.currentTarget.style.transform = "scale(1.02)"}
            onMouseLeave={e => e.currentTarget.style.transform = ""}
          >
            <span style={{ fontSize: 20 }}>🔴</span>
            <span style={{ flex: 1, textAlign: "center", fontWeight: 700, fontSize: 16, color: "#0D1B6B" }}>
              Continue with Google
            </span>
          </button>

          {/* Phone */}
          <button
            onClick={() => setShowEmail(true)}
            className="btn-press"
            style={{
              padding: "16px 20px", borderRadius: 50, border: "none", background: "#fff",
              display: "flex", alignItems: "center", gap: 12, cursor: "pointer",
              boxShadow: "0 4px 20px rgba(0,0,0,0.14)",
              animation: "bounceUp 0.5s 0.5s cubic-bezier(0.34,1.56,0.64,1) both",
              fontFamily: "Nunito",
              transition: "transform 0.2s cubic-bezier(0.34,1.56,0.64,1)",
            }}
            onMouseEnter={e => e.currentTarget.style.transform = "scale(1.02)"}
            onMouseLeave={e => e.currentTarget.style.transform = ""}
          >
            <span style={{ fontSize: 20 }}>📱</span>
            <span style={{ flex: 1, textAlign: "center", fontWeight: 700, fontSize: 16, color: "#0D1B6B" }}>
              Continue with Phone
            </span>
          </button>

          <div
            onClick={() => { setIsSignUp(true); setShowEmail(true); }}
            style={{
              textAlign: "center", color: "rgba(255,255,255,0.9)", fontWeight: 700,
              fontSize: 14, marginTop: 8, cursor: "pointer",
              animation: "bounceUp 0.5s 0.6s both",
            }}
          >First time here? Sign up now</div>
        </div>
      ) : (
        <div style={{ width: "100%", maxWidth: 380, zIndex: 1, animation: "bounceUp 0.4s both" }}>
          {isSignUp && (
            <input className="bf-input" placeholder="Full Name" style={inputStyle} />
          )}
          <input className="bf-input" placeholder="Email Address" type="email" style={{ ...inputStyle, marginTop: isSignUp ? 10 : 0 }} />
          <input className="bf-input" placeholder="Password" type="password" style={{ ...inputStyle, marginTop: 10 }} />
          <button onClick={onLogin} className="btn-press" style={{
            ...actionBtnStyle, marginTop: 20, fontFamily: "Nunito",
          }}>{isSignUp ? "Create Account" : "Sign In"}</button>
          <div onClick={() => setShowEmail(false)} style={{
            textAlign: "center", color: "rgba(255,255,255,0.75)", fontWeight: 600,
            fontSize: 13, marginTop: 12, cursor: "pointer",
          }}>← Back</div>
        </div>
      )}
    </div>
  );
}

const inputStyle = {
  width: "100%", padding: "14px 16px", borderRadius: 14,
  border: "1px solid rgba(255,255,255,0.3)",
  background: "rgba(255,255,255,0.18)",
  color: "#fff", fontSize: 15, fontWeight: 600,
  fontFamily: "Nunito", outline: "none",
  display: "block",
};

const actionBtnStyle = {
  width: "100%", padding: "16px", borderRadius: 50, border: "none",
  background: "#fff", color: "#0D1B6B", fontWeight: 800,
  fontSize: 16, cursor: "pointer",
  boxShadow: "0 6px 20px rgba(0,0,0,0.15)",
};

/* ═══════════════════════════════════════════════════════════
   SCREEN: FARM INFO
═══════════════════════════════════════════════════════════ */
function FarmInfoScreen({ onNext }) {
  const fields = ["Farmer Name", "Farm Name", "PIN Code", "Pond Size (in acres)", "Fish Species (Rohu, Catla, etc.)"];
  return (
    <div style={{ height: "100%", background: "#F5F8FF", overflowY: "auto", padding: "40px 28px 28px" }}>
      <div style={{ animation: "bounceUp 0.5s both" }}>
        <div style={{ fontSize: 26, fontWeight: 900, color: "#0D1B6B", marginBottom: 6 }}>Tell us about your farm</div>
        <div style={{ fontSize: 14, fontWeight: 600, color: "#00BCD4", marginBottom: 28 }}>We'll help you monitor it better</div>
      </div>

      <div style={{
        background: "#fff", borderRadius: 20, padding: 20,
        boxShadow: "0 4px 20px rgba(21,101,192,0.08)",
        animation: "cardEntrance 0.6s 0.1s both",
        display: "flex", flexDirection: "column", gap: 12,
      }}>
        {fields.map((f, i) => (
          <input
            key={f}
            placeholder={f}
            className="bf-input"
            style={{
              padding: "14px 16px", borderRadius: 12, border: "1px solid #E3F2FD",
              background: "#F0F5FF", fontSize: 14, fontWeight: 600,
              color: "#0D1B6B", fontFamily: "Nunito", outline: "none",
              animation: `bounceLeft 0.4s ${0.15 + i * 0.06}s both`,
              width: "100%",
            }}
          />
        ))}
        <select style={{
          padding: "14px 16px", borderRadius: 12, border: "1px solid #E3F2FD",
          background: "#F0F5FF", fontSize: 14, fontFamily: "Nunito",
          color: "#546E7A", outline: "none",
          animation: "bounceLeft 0.4s 0.5s both",
        }}>
          <option value="">Type of Waterbody</option>
          {["Pond", "Tank", "Cage", "Raceway", "Open Water"].map(t => <option key={t}>{t}</option>)}
        </select>
      </div>

      <button onClick={onNext} className="btn-press" style={{
        width: "100%", marginTop: 24, padding: "18px", borderRadius: 50, border: "none",
        background: "linear-gradient(90deg,#00BCD4,#1565C0)",
        color: "#fff", fontWeight: 800, fontSize: 17, cursor: "pointer",
        boxShadow: "0 8px 24px rgba(0,188,212,0.4)",
        fontFamily: "Nunito",
        animation: "bounceUp 0.5s 0.6s both",
      }}>Next Step</button>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   SCREEN: CONNECT DEVICE
═══════════════════════════════════════════════════════════ */
function ConnectScreen({ onNext }) {
  const [scanning, setScanning] = useState(false);

  const doScan = () => {
    setScanning(true);
    setTimeout(() => { setScanning(false); onNext(); }, 2000);
  };

  return (
    <div style={{
      height: "100%", background: "#F5F8FF",
      display: "flex", flexDirection: "column", alignItems: "center",
      justifyContent: "center", padding: "40px 32px",
    }}>
      {/* Satellite icon with rings */}
      <div style={{ position: "relative", marginBottom: 40 }}>
        {scanning && [1,2,3].map(i => (
          <div key={i} style={{
            position: "absolute", borderRadius: "50%",
            border: "2px solid rgba(0,188,212,0.4)",
            width: 60 + i * 40, height: 60 + i * 40,
            top: "50%", left: "50%", transform: "translate(-50%,-50%)",
            animation: `connectRing 1.5s ${i * 0.3}s ease-out infinite`,
          }} />
        ))}
        <div style={{
          width: 130, height: 130, borderRadius: "50%",
          background: "linear-gradient(135deg,rgba(0,188,212,0.12),rgba(21,101,192,0.08))",
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: 58,
          animation: scanning ? "spin 2s linear infinite" : "floatY 3s ease-in-out infinite",
        }}>📡</div>
      </div>

      <div style={{ fontSize: 24, fontWeight: 900, color: "#0D1B6B", textAlign: "center", marginBottom: 10, animation: "bounceUp 0.5s 0.2s both" }}>
        Connect your monitoring device
      </div>
      <div style={{ fontSize: 14, fontWeight: 600, color: "#00BCD4", textAlign: "center", marginBottom: 44, animation: "bounceUp 0.5s 0.3s both" }}>
        This helps us track water quality in real-time
      </div>

      <button onClick={doScan} className="btn-press" disabled={scanning} style={{
        width: "100%", maxWidth: 340, padding: "18px", borderRadius: 50, border: "none",
        background: scanning ? "#90CAF9" : "linear-gradient(90deg,#00BCD4,#1565C0)",
        color: "#fff", fontWeight: 800, fontSize: 17, cursor: scanning ? "wait" : "pointer",
        boxShadow: scanning ? "none" : "0 8px 24px rgba(0,188,212,0.4)",
        fontFamily: "Nunito",
        animation: "bounceUp 0.5s 0.4s both",
      }}>{scanning ? "Scanning..." : "Scan & Connect"}</button>

      <button onClick={onNext} className="btn-press" style={{
        width: "100%", maxWidth: 340, padding: "18px", borderRadius: 50,
        border: "1px solid #E3F2FD", background: "#fff",
        color: "#0D1B6B", fontWeight: 700, fontSize: 16, cursor: "pointer",
        marginTop: 14, fontFamily: "Nunito",
        animation: "bounceUp 0.5s 0.5s both",
      }}>Skip for now</button>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   SCREEN: HOME DASHBOARD
═══════════════════════════════════════════════════════════ */
function HomeScreen({ isDark, sensorValues, onSettings }) {
  const [trendPeriod, setTrendPeriod] = useState("Today");
  const phData = generateTrend(7.2, 24, 0.4);
  const tempData = generateTrend(28.5, 24, 1.5);
  const doData = generateTrend(6.8, 24, 0.5);
  const turbData = generateTrend(2.5, 24, 0.6);

  const lastUpdated = new Date().toLocaleTimeString("en-IN", { hour12: false });

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", overflow: "hidden" }}>
      <AppHeader onSettings={onSettings} isDark={isDark} />

      {/* Scrollable content */}
      <div style={{ flex: 1, overflowY: "auto", padding: "16px 14px 100px", background: isDark ? "#0A0F1E" : "#EFF4FF" }}>
        {/* Alert banner */}
        <AlertBanner isDark={isDark} />

        {/* Live Parameters heading */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
          <span style={{ fontSize: 20, fontWeight: 900, color: isDark ? "#E8EEFF" : "#0D1B6B", animation: "bounceLeft 0.5s both" }}>
            Live Parameters
          </span>
          <span style={{ fontSize: 11, fontWeight: 600, color: isDark ? "#5C7A9E" : "#90A4AE", animation: "bounceRight 0.5s both" }}>
            Updated {lastUpdated}
          </span>
        </div>

        {/* 2-col sensor grid */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 24 }}>
          {SENSOR_CONFIG.map((cfg, i) => (
            <SensorCard key={cfg.key} config={cfg} value={sensorValues[cfg.key] ?? MOCK_VALUES[cfg.key]} index={i} isDark={isDark} />
          ))}
        </div>

        {/* Trends section */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
          <span style={{ fontSize: 20, fontWeight: 900, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>Trends</span>
          <div style={{ display: "flex", gap: 6 }}>
            {["Today", "Weekly", "Monthly"].map(p => (
              <button
                key={p}
                onClick={() => setTrendPeriod(p)}
                className="btn-press"
                style={{
                  padding: "6px 12px", borderRadius: 50, border: "none", cursor: "pointer",
                  background: trendPeriod === p ? "#2196F3" : (isDark ? "#1A2744" : "#fff"),
                  color: trendPeriod === p ? "#fff" : (isDark ? "#8BA3C7" : "#546E7A"),
                  fontWeight: 700, fontSize: 12, fontFamily: "Nunito",
                  border: trendPeriod !== p ? (isDark ? "1px solid #1E2D4A" : "1px solid #CFD8DC") : "none",
                  transition: "all 0.25s cubic-bezier(0.34,1.56,0.64,1)",
                  transform: trendPeriod === p ? "scale(1.05)" : "scale(1)",
                }}
              >{p}</button>
            ))}
          </div>
        </div>

        <TrendChart title="pH Level & Temperature" lines={[
          { key: "ph", data: phData, color: "#2196F3", label: "pH" },
          { key: "temp", data: tempData, color: "#FF7043", label: "Temp °C" },
        ]} isDark={isDark} />

        <TrendChart title="Dissolved Oxygen & Turbidity" lines={[
          { key: "do", data: doData, color: "#00BCD4", label: "DO mg/L" },
          { key: "turb", data: turbData, color: "#9C27B0", label: "Turbidity NTU" },
        ]} isDark={isDark} />
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   SCREEN: DISEASES
═══════════════════════════════════════════════════════════ */
const DISEASES = [
  { name: "Bacterial Gill Disease", icon: "🐟", species: "Catfish, Tilapia, Rohu", risk: "High ammonia + Low DO", color: "#E53935",
    symptoms: "Gills become pale, fish gasp at surface, loss of appetite",
    treatment: "Improve aeration • Reduce feeding 50% • Potassium permanganate (2-3 ppm) • 20-30% water change" },
  { name: "Columnaris Disease", icon: "🦠", species: "Catfish, Carp, Tilapia", risk: "High temp >28°C + Low O₂", color: "#FF6F00",
    symptoms: "White patches on skin, fin erosion, ulcers, sluggish behavior",
    treatment: "Lower water temp • Salt bath (3-5 g/L) • Antibiotic treatment • Improve water quality" },
  { name: "Ich (White Spot)", icon: "🔴", species: "All freshwater fish", risk: "Sudden temp change", color: "#1976D2",
    symptoms: "White dots on skin/fins, fish rubbing surfaces, lethargy",
    treatment: "Gradually raise temp to 30°C • Salt 1-3 g/L • Copper sulfate 0.5 ppm for 7 days" },
  { name: "Ammonia Poisoning", icon: "⚗️", species: "All fish", risk: "Ammonia > 0.5 mg/L", color: "#7B1FA2",
    symptoms: "Gasping at surface, red/purple gills, erratic swimming",
    treatment: "Emergency 40% water change • Stop feeding • Heavy aeration • Add zeolite" },
  { name: "Aeromonas Infection", icon: "🩸", species: "Carp, Catfish, Goldfish", risk: "Poor water + Stress", color: "#388E3C",
    symptoms: "Hemorrhagic ulcers, fin rot, swollen belly, scale loss",
    treatment: "Improve water quality • Oxytetracycline • Salt bath 5 g/L for 10 min" },
  { name: "Oxygen Depletion", icon: "💨", species: "All pond fish", risk: "DO < 4 mg/L", color: "#0097A7",
    symptoms: "Fish crowd surface, gulping air, mass mortality risk",
    treatment: "Emergency aeration • Stop feeding • Remove dead organic matter • Partial water exchange" },
  { name: "pH Shock", icon: "🧪", species: "All fish", risk: "pH < 6.0 or pH > 9.0", color: "#F57C00",
    symptoms: "Erratic swimming, excessive mucus, skin lesions, mortality",
    treatment: "Lime application for low pH • Water exchange for high pH" },
  { name: "Saprolegnia (Fungal)", icon: "🍄", species: "Catfish, Carp, Salmon", risk: "Cold water + Injury", color: "#5D4037",
    symptoms: "White/grey cotton growth on skin, fins or eggs",
    treatment: "Salt bath 3 g/L × 30 min • Formalin treatment • Remove infected eggs" },
];

function DiseasesScreen({ isDark }) {
  const [expanded, setExpanded] = useState(null);

  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", overflow: "hidden" }}>
      <AppHeader isDark={isDark} />
      <div style={{ flex: 1, overflowY: "auto", padding: "16px 14px 100px", background: isDark ? "#0A0F1E" : "#EFF4FF" }}>
        <div style={{ fontSize: 20, fontWeight: 900, color: isDark ? "#E8EEFF" : "#0D1B6B", marginBottom: 16, animation: "bounceLeft 0.5s both" }}>
          Disease Directory
        </div>
        {DISEASES.map((d, i) => (
          <div
            key={d.name}
            onClick={() => setExpanded(expanded === i ? null : i)}
            style={{
              background: isDark ? "#121929" : "#fff",
              borderRadius: 16, marginBottom: 10, overflow: "hidden", cursor: "pointer",
              border: isDark ? "1px solid #1E2D4A" : "none",
              boxShadow: isDark ? "0 4px 16px rgba(0,0,0,0.3)" : "0 2px 12px rgba(0,0,0,0.06)",
              animation: `bounceUp 0.5s ${i * 0.07}s both`,
              transition: "all 0.3s cubic-bezier(0.34,1.56,0.64,1)",
            }}
          >
            <div style={{ padding: "14px 16px", display: "flex", alignItems: "center", gap: 12 }}>
              <div style={{
                width: 42, height: 42, borderRadius: 12, flexShrink: 0,
                background: `${d.color}18`,
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 20,
              }}>{d.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 800, fontSize: 14, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>{d.name}</div>
                <div style={{ fontSize: 11, color: isDark ? "#8BA3C7" : "#546E7A", marginTop: 2 }}>{d.species}</div>
              </div>
              <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 4 }}>
                <div style={{
                  padding: "2px 8px", borderRadius: 50, fontSize: 9, fontWeight: 700,
                  color: d.color, background: `${d.color}15`,
                  border: `1px solid ${d.color}30`,
                }}>⚠ Risk</div>
                <span style={{
                  color: isDark ? "#5C7A9E" : "#90A4AE",
                  transform: expanded === i ? "rotate(180deg)" : "rotate(0deg)",
                  transition: "transform 0.3s cubic-bezier(0.34,1.56,0.64,1)",
                  fontSize: 16, display: "block",
                }}>⌄</span>
              </div>
            </div>
            {expanded === i && (
              <div style={{
                padding: "0 16px 16px", borderTop: isDark ? "1px solid #1E2D4A" : "1px solid #E3F2FD",
                animation: "bounceUp 0.35s cubic-bezier(0.34,1.56,0.64,1)",
              }}>
                <div style={{ marginTop: 10 }}>
                  <span style={{ fontWeight: 800, fontSize: 12, color: d.color }}>⚠ Risk: </span>
                  <span style={{ fontSize: 12, color: isDark ? "#8BA3C7" : "#546E7A" }}>{d.risk}</span>
                </div>
                <div style={{ marginTop: 6 }}>
                  <span style={{ fontWeight: 800, fontSize: 12, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>🔍 Symptoms: </span>
                  <span style={{ fontSize: 12, color: isDark ? "#8BA3C7" : "#546E7A" }}>{d.symptoms}</span>
                </div>
                <div style={{ marginTop: 6 }}>
                  <span style={{ fontWeight: 800, fontSize: 12, color: "#00BCD4" }}>💊 Treatment: </span>
                  <span style={{ fontSize: 12, color: isDark ? "#8BA3C7" : "#546E7A" }}>{d.treatment}</span>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   SCREEN: MARKET
═══════════════════════════════════════════════════════════ */
const FISH_PRICES = [
  { species: "Rohu", emoji: "🐠", price: 185, region: "North India", trend: "up", change: "+₹12", updated: "Today" },
  { species: "Catla", emoji: "🐟", price: 210, region: "West Bengal", trend: "up", change: "+₹8", updated: "Today" },
  { species: "Tilapia", emoji: "🐡", price: 130, region: "South India", trend: "flat", change: "₹0", updated: "Yesterday" },
  { species: "Catfish", emoji: "🐟", price: 160, region: "Andhra Pradesh", trend: "down", change: "-₹5", updated: "Today" },
  { species: "Pangasius", emoji: "🐠", price: 95, region: "All India", trend: "down", change: "-₹10", updated: "2 days ago" },
  { species: "Freshwater Prawn", emoji: "🦐", price: 420, region: "Kerala", trend: "up", change: "+₹25", updated: "Today" },
  { species: "Mrigal", emoji: "🐟", price: 170, region: "Odisha", trend: "flat", change: "₹0", updated: "Yesterday" },
  { species: "Silver Carp", emoji: "🐠", price: 145, region: "Bihar", trend: "up", change: "+₹6", updated: "Today" },
];

function MarketScreen({ isDark }) {
  const trendColor = { up: "#00C853", flat: "#FFA000", down: "#F44336" };
  const trendIcon  = { up: "↑", flat: "→", down: "↓" };

  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", overflow: "hidden" }}>
      <AppHeader isDark={isDark} />
      <div style={{ flex: 1, overflowY: "auto", padding: "16px 14px 100px", background: isDark ? "#0A0F1E" : "#EFF4FF" }}>
        {/* Header */}
        <div style={{ marginBottom: 16, animation: "bounceLeft 0.5s both" }}>
          <div style={{ fontSize: 20, fontWeight: 900, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>Fish Market Prices</div>
          <div style={{ fontSize: 12, fontWeight: 600, color: isDark ? "#8BA3C7" : "#546E7A", marginTop: 2 }}>₹ per kg — Wholesale prices</div>
        </div>

        {/* Stat chips */}
        <div style={{ display: "flex", gap: 10, marginBottom: 16 }}>
          {[
            { label: "Avg Price", value: "₹189/kg", color: "#2196F3" },
            { label: "Best Value", value: "Pangasius", color: "#00C853" },
            { label: "Trending ↑", value: "Rohu", color: "#FFA000" },
          ].map((s, i) => (
            <div key={s.label} style={{
              flex: 1, background: isDark ? "#121929" : "#fff", borderRadius: 12,
              padding: "10px 12px",
              border: isDark ? "1px solid #1E2D4A" : "none",
              boxShadow: isDark ? "0 2px 12px rgba(0,0,0,0.25)" : "0 2px 8px rgba(0,0,0,0.06)",
              animation: `bounceUp 0.4s ${i * 0.08}s both`,
            }}>
              <div style={{ fontSize: 10, color: isDark ? "#5C7A9E" : "#90A4AE", fontWeight: 600 }}>{s.label}</div>
              <div style={{ fontSize: 13, fontWeight: 800, color: s.color, marginTop: 2 }}>{s.value}</div>
            </div>
          ))}
        </div>

        {/* Price cards */}
        {FISH_PRICES.map((f, i) => (
          <div key={f.species} style={{
            background: isDark ? "#121929" : "#fff",
            borderRadius: 16, padding: "14px 16px", marginBottom: 10,
            border: isDark ? "1px solid #1E2D4A" : "none",
            boxShadow: isDark ? "0 4px 16px rgba(0,0,0,0.25)" : "0 2px 10px rgba(0,0,0,0.06)",
            display: "flex", alignItems: "center", gap: 14,
            animation: `bounceUp 0.45s ${i * 0.06}s both`,
            transition: "all 0.25s cubic-bezier(0.34,1.56,0.64,1)",
            cursor: "pointer",
          }}
            onMouseEnter={e => { e.currentTarget.style.transform = "scale(1.02) translateX(3px)"; e.currentTarget.style.boxShadow = isDark ? "0 8px 32px rgba(0,0,0,0.4)" : "0 8px 32px rgba(21,101,192,0.15)"; }}
            onMouseLeave={e => { e.currentTarget.style.transform = ""; e.currentTarget.style.boxShadow = ""; }}
          >
            <div style={{
              width: 50, height: 50, borderRadius: 14, flexShrink: 0,
              background: isDark ? "#1A2744" : "#E3F2FD",
              display: "flex", alignItems: "center", justifyContent: "center", fontSize: 26,
            }}>{f.emoji}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 800, fontSize: 15, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>{f.species}</div>
              <div style={{ fontSize: 11, color: isDark ? "#5C7A9E" : "#90A4AE", marginTop: 2 }}>📍 {f.region} • {f.updated}</div>
            </div>
            <div style={{ textAlign: "right" }}>
              <div style={{ fontWeight: 900, fontSize: 20, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>₹{f.price}</div>
              <div style={{ fontWeight: 700, fontSize: 12, color: trendColor[f.trend] }}>
                {trendIcon[f.trend]} {f.change}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   SCREEN: SETTINGS
═══════════════════════════════════════════════════════════ */
function SettingsScreen({ isDark, onToggleDark }) {
  const [relays, setRelays] = useState({ pump: false, filter: false, aerator: false, extra: false });
  const [notifs, setNotifs] = useState({ ph: true, temp: true, ammonia: true, oxygen: true });

  const Section = ({ title }) => (
    <div style={{ fontSize: 11, fontWeight: 800, letterSpacing: 1.2, color: isDark ? "#5C7A9E" : "#546E7A", marginBottom: 8, marginTop: 20, paddingLeft: 4, textTransform: "uppercase" }}>{title}</div>
  );

  const Toggle = ({ val, onChange }) => (
    <div
      onClick={() => onChange(!val)}
      style={{
        width: 46, height: 26, borderRadius: 13,
        background: val ? "#2196F3" : (isDark ? "#1E2D4A" : "#CFD8DC"),
        position: "relative", cursor: "pointer",
        transition: "background 0.3s cubic-bezier(0.34,1.56,0.64,1)",
        flexShrink: 0,
      }}
    >
      <div style={{
        position: "absolute", top: 3, width: 20, height: 20, borderRadius: "50%",
        background: "#fff", boxShadow: "0 2px 6px rgba(0,0,0,0.2)",
        left: val ? 23 : 3,
        transition: "left 0.3s cubic-bezier(0.34,1.56,0.64,1)",
      }} />
    </div>
  );

  const Row = ({ icon, label, sub, right, delay = 0 }) => (
    <div style={{
      display: "flex", alignItems: "center", gap: 12, padding: "12px 14px",
      animation: `bounceLeft 0.4s ${delay}s both`,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 10, flexShrink: 0,
        background: isDark ? "#1A2744" : "#E3F2FD",
        display: "flex", alignItems: "center", justifyContent: "center",
        fontSize: 17,
      }}>{icon}</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontWeight: 700, fontSize: 13, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>{label}</div>
        {sub && <div style={{ fontSize: 11, color: isDark ? "#5C7A9E" : "#90A4AE", marginTop: 1 }}>{sub}</div>}
      </div>
      {right}
    </div>
  );

  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", overflow: "hidden" }}>
      <AppHeader isDark={isDark} />
      <div style={{ flex: 1, overflowY: "auto", padding: "16px 14px 100px", background: isDark ? "#0A0F1E" : "#EFF4FF" }}>

        {/* Profile card */}
        <div style={{
          background: isDark ? "#121929" : "#fff", borderRadius: 18, padding: "16px",
          border: isDark ? "1px solid #1E2D4A" : "none",
          boxShadow: isDark ? "0 4px 24px rgba(0,0,0,0.3)" : "0 4px 20px rgba(21,101,192,0.08)",
          display: "flex", alignItems: "center", gap: 14, marginBottom: 4,
          animation: "cardEntrance 0.5s both",
        }}>
          <div style={{
            width: 58, height: 58, borderRadius: "50%", flexShrink: 0,
            background: "linear-gradient(135deg,#29B6F6,#00BCD4)",
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 24, fontWeight: 900, color: "#fff",
            boxShadow: "0 4px 16px rgba(0,188,212,0.4)",
          }}>F</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 900, fontSize: 17, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>Farmer</div>
            <div style={{ fontSize: 12, color: isDark ? "#8BA3C7" : "#546E7A", marginTop: 2 }}>farmer@bluefarm.app</div>
            <div style={{ fontSize: 12, fontWeight: 700, color: "#00BCD4", marginTop: 2 }}>🌾 My Fish Farm</div>
          </div>
          <span style={{ fontSize: 16, color: isDark ? "#5C7A9E" : "#90A4AE" }}>✏️</span>
        </div>

        <Section title="Appearance" />
        <div style={{ background: isDark ? "#121929" : "#fff", borderRadius: 16, border: isDark ? "1px solid #1E2D4A" : "none", boxShadow: isDark ? "0 4px 16px rgba(0,0,0,0.25)" : "0 2px 12px rgba(0,0,0,0.05)", animation: "bounceUp 0.4s 0.1s both" }}>
          <Row icon={isDark ? "🌙" : "☀️"} label="Dark Mode" sub={isDark ? "Dark theme active" : "Light theme active"} delay={0.1}
            right={<Toggle val={isDark} onChange={onToggleDark} />} />
        </div>

        <Section title="Relay Control" />
        <div style={{ background: isDark ? "#121929" : "#fff", borderRadius: 16, border: isDark ? "1px solid #1E2D4A" : "none", boxShadow: isDark ? "0 4px 16px rgba(0,0,0,0.25)" : "0 2px 12px rgba(0,0,0,0.05)", animation: "bounceUp 0.4s 0.15s both" }}>
          {Object.entries(relays).map(([k, v], i) => {
            const icons = { pump: "💧", filter: "🔩", aerator: "💨", extra: "⚡" };
            const names = { pump: "Pump (D7)", filter: "Filter (D8)", aerator: "Aerator (D9)", extra: "Extra (D10)" };
            return (
              <div key={k}>
                <Row icon={icons[k]} label={names[k]} sub={v ? "ON — Manual override" : "OFF — Auto mode"} delay={0.1 + i * 0.05}
                  right={<Toggle val={v} onChange={nv => setRelays(prev => ({ ...prev, [k]: nv }))} />} />
                {i < 3 && <div style={{ height: 1, background: isDark ? "#1E2D4A" : "#E3F2FD", marginLeft: 62 }} />}
              </div>
            );
          })}
        </div>

        <Section title="Notifications" />
        <div style={{ background: isDark ? "#121929" : "#fff", borderRadius: 16, border: isDark ? "1px solid #1E2D4A" : "none", boxShadow: isDark ? "0 4px 16px rgba(0,0,0,0.25)" : "0 2px 12px rgba(0,0,0,0.05)", animation: "bounceUp 0.4s 0.25s both" }}>
          {Object.entries(notifs).map(([k, v], i) => {
            const labels = { ph: "pH Alerts", temp: "Temperature Alerts", ammonia: "Ammonia Alerts", oxygen: "Oxygen Alerts" };
            return (
              <div key={k}>
                <Row icon="🔔" label={labels[k]} delay={0.2 + i * 0.04}
                  right={<Toggle val={v} onChange={nv => setNotifs(prev => ({ ...prev, [k]: nv }))} />} />
                {i < 3 && <div style={{ height: 1, background: isDark ? "#1E2D4A" : "#E3F2FD", marginLeft: 62 }} />}
              </div>
            );
          })}
        </div>

        <Section title="About" />
        <div style={{ background: isDark ? "#121929" : "#fff", borderRadius: 16, border: isDark ? "1px solid #1E2D4A" : "none", boxShadow: isDark ? "0 4px 16px rgba(0,0,0,0.25)" : "0 2px 12px rgba(0,0,0,0.05)", animation: "bounceUp 0.4s 0.35s both" }}>
          {[["Version", "1.0.0 (Build 1)"], ["Backend", "Supabase"], ["Hardware", "Raspberry Pi 3"]].map(([label, value], i) => (
            <div key={label}>
              <div style={{ display: "flex", justifyContent: "space-between", padding: "12px 16px" }}>
                <span style={{ fontWeight: 700, fontSize: 13, color: isDark ? "#8BA3C7" : "#546E7A" }}>{label}</span>
                <span style={{ fontWeight: 700, fontSize: 13, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>{value}</span>
              </div>
              {i < 2 && <div style={{ height: 1, background: isDark ? "#1E2D4A" : "#E3F2FD" }} />}
            </div>
          ))}
        </div>

        {/* Sign out */}
        <button className="btn-press" style={{
          width: "100%", marginTop: 24, padding: "16px", borderRadius: 16, border: "none",
          background: "rgba(244,67,54,0.1)",
          border: "1px solid rgba(244,67,54,0.3)",
          color: "#F44336", fontWeight: 800, fontSize: 15, cursor: "pointer",
          fontFamily: "Nunito",
          animation: "bounceUp 0.4s 0.45s both",
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
        }}>
          <span>↩</span> Sign Out
        </button>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════
   ROOT APP
═══════════════════════════════════════════════════════════ */
export default function BlueFarmApp() {
  const [screen, setScreen] = useState("splash"); // splash → lang → login → farminfo → connect → app
  const [tab, setTab] = useState("home");
  const [isDark, setIsDark] = useState(false);
  const [sensorValues, setSensorValues] = useState(MOCK_VALUES);

  // Simulate live sensor updates
  useEffect(() => {
    if (screen !== "app") return;
    const interval = setInterval(() => {
      setSensorValues(prev => ({
        ph:      parseFloat((prev.ph + (Math.random() - 0.5) * 0.1).toFixed(2)),
        temp:    parseFloat((prev.temp + (Math.random() - 0.5) * 0.3).toFixed(1)),
        do:      parseFloat((prev.do + (Math.random() - 0.5) * 0.15).toFixed(1)),
        turb:    parseFloat((prev.turb + (Math.random() - 0.5) * 0.2).toFixed(1)),
        ammonia: parseFloat((prev.ammonia + (Math.random() - 0.5) * 0.01).toFixed(2)),
        level:   parseFloat((prev.level + (Math.random() - 0.5) * 0.5).toFixed(1)),
      }));
    }, 5000);
    return () => clearInterval(interval);
  }, [screen]);

  const navigate = (s) => setScreen(s);

  const renderContent = () => {
    switch (screen) {
      case "splash":    return <SplashScreen onNext={() => navigate("lang")} />;
      case "lang":      return <LanguageScreen onNext={() => navigate("login")} />;
      case "login":     return <LoginScreen onLogin={() => navigate("farminfo")} />;
      case "farminfo":  return <FarmInfoScreen onNext={() => navigate("connect")} />;
      case "connect":   return <ConnectScreen onNext={() => navigate("app")} />;
      case "app":
        return (
          <div style={{ display: "flex", flexDirection: "column", height: "100%", position: "relative" }}>
            {tab === "home"     && <HomeScreen isDark={isDark} sensorValues={sensorValues} onSettings={() => setTab("settings")} />}
            {tab === "diseases" && <DiseasesScreen isDark={isDark} />}
            {tab === "market"   && <MarketScreen isDark={isDark} />}
            {tab === "settings" && <SettingsScreen isDark={isDark} onToggleDark={() => setIsDark(d => !d)} />}
            <IosDock active={tab} onTab={setTab} isDark={isDark} />
          </div>
        );
      default: return null;
    }
  };

  return (
    <div className={isDark ? "dark-mode" : ""} style={{
      width: "100%", height: "100dvh",
      display: "flex", alignItems: "center", justifyContent: "center",
      background: isDark ? "#050810" : "#CBD9F5",
      fontFamily: "Nunito, sans-serif",
      overflow: "hidden",
    }}>
      <GlobalStyles />

      {/* Phone frame */}
      <div style={{
        width: "min(420px, 100vw)",
        height: "min(860px, 100dvh)",
        borderRadius: "min(40px, 0px)",
        overflow: "hidden",
        position: "relative",
        background: isDark ? "#0A0F1E" : "#EFF4FF",
        boxShadow: "0 32px 80px rgba(0,0,0,0.35), 0 8px 24px rgba(0,0,0,0.2), inset 0 1px 0 rgba(255,255,255,0.1)",
        border: "1px solid rgba(255,255,255,0.08)",
        display: "flex", flexDirection: "column",
      }}>
        {/* Status bar */}
        {screen === "app" && (
          <div style={{
            height: 28, background: isDark ? "#0A0F1E" : "#EFF4FF",
            display: "flex", alignItems: "center", justifyContent: "space-between",
            padding: "0 20px", flexShrink: 0,
          }}>
            <span style={{ fontSize: 12, fontWeight: 800, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>9:41</span>
            <div style={{ display: "flex", gap: 6 }}>
              <span style={{ fontSize: 12, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>●●●</span>
              <span style={{ fontSize: 12, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>WiFi</span>
              <span style={{ fontSize: 12, color: isDark ? "#E8EEFF" : "#0D1B6B" }}>🔋</span>
            </div>
          </div>
        )}

        {/* Main content */}
        <div key={screen} className={screen !== "splash" ? "screen-enter" : ""} style={{ flex: 1, overflow: "hidden", display: "flex", flexDirection: "column" }}>
          {renderContent()}
        </div>
      </div>
    </div>
  );
}
