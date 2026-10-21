/* ============================================================
   PoliMusic · interacción del cliente
   - Fondo de estrellas animado
   - Menú móvil y mostrar contraseña
   - Reproductor: reproduce desde la tabla y suma PLAYS vía play.asp
   ============================================================ */
(function () {
  "use strict";

  var reduceMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---------- Fondo de estrellas ---------- */
  function starfield() {
    var canvas = document.getElementById("starfield");
    if (!canvas || !canvas.getContext) return;
    var ctx = canvas.getContext("2d");
    var stars = [], shooting = null, w, h, dpr;
    var colors = ["#ffffff", "#e3c8ff", "#c77dff", "#ffd6f5", "#bdf3ff"];

    function resize() {
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      w = window.innerWidth; h = window.innerHeight;
      canvas.width = w * dpr; canvas.height = h * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      var count = Math.round((w * h) / 4200);
      stars = [];
      for (var i = 0; i < count; i++) {
        stars.push({
          x: Math.random() * w, y: Math.random() * h,
          r: Math.random() * 1.3 + 0.2,
          a: Math.random(), s: Math.random() * 0.015 + 0.003,
          c: colors[(Math.random() * colors.length) | 0]
        });
      }
      if (reduceMotion) draw();
    }

    function draw() {
      ctx.clearRect(0, 0, w, h);
      for (var i = 0; i < stars.length; i++) {
        var st = stars[i];
        st.a += st.s;
        var alpha = 0.35 + Math.abs(Math.sin(st.a)) * 0.65;
        ctx.globalAlpha = alpha;
        ctx.fillStyle = st.c;
        ctx.beginPath();
        ctx.arc(st.x, st.y, st.r, 0, Math.PI * 2);
        ctx.fill();
      }
      // Estrella fugaz ocasional
      if (!shooting && Math.random() < 0.004) {
        shooting = { x: Math.random() * w * 0.7, y: Math.random() * h * 0.4, len: 0, life: 1 };
      }
      if (shooting) {
        shooting.x += 9; shooting.y += 4; shooting.len = Math.min(shooting.len + 12, 140); shooting.life -= 0.018;
        var grad = ctx.createLinearGradient(shooting.x, shooting.y, shooting.x - shooting.len, shooting.y - shooting.len * 0.45);
        grad.addColorStop(0, "rgba(255,255,255," + shooting.life + ")");
        grad.addColorStop(1, "rgba(199,125,255,0)");
        ctx.globalAlpha = 1;
        ctx.strokeStyle = grad; ctx.lineWidth = 2;
        ctx.beginPath(); ctx.moveTo(shooting.x, shooting.y);
        ctx.lineTo(shooting.x - shooting.len, shooting.y - shooting.len * 0.45); ctx.stroke();
        if (shooting.life <= 0) shooting = null;
      }
      ctx.globalAlpha = 1;
    }

    function loop() { draw(); requestAnimationFrame(loop); }

    window.addEventListener("resize", resize);
    resize();
    if (!reduceMotion) loop();
  }

  /* ---------- Menú móvil ---------- */
  function navToggle() {
    var btn = document.querySelector(".nav-toggle");
    var nav = document.getElementById("mainnav");
    if (!btn || !nav) return;
    btn.addEventListener("click", function () {
      var open = nav.classList.toggle("open");
      btn.setAttribute("aria-expanded", open ? "true" : "false");
    });
  }

  /* ---------- Mostrar/ocultar contraseña ---------- */
  function pwdToggle() {
    var btn = document.querySelector(".pwd-toggle");
    var input = document.getElementById("password");
    if (!btn || !input) return;
    btn.addEventListener("click", function () {
      var show = input.type === "password";
      input.type = show ? "text" : "password";
      btn.setAttribute("aria-label", show ? "Ocultar contraseña" : "Mostrar contraseña");
    });
  }

  /* ---------- Reproductor ---------- */
  function player() {
    var table = document.getElementById("songTable");
    var bar = document.getElementById("player");
    var audio = document.getElementById("audio");
    if (!table || !bar || !audio) return;

    var rows = Array.prototype.slice.call(table.querySelectorAll("tbody tr"));
    var current = -1;
    var counted = false; // ya se sumó una reproducción para la pista actual
    var csrf = bar.getAttribute("data-csrf");

    function markPlaying() {
      rows.forEach(function (r, i) {
        r.classList.toggle("is-playing", i === current && !audio.paused);
        var b = r.querySelector(".play-btn");
        if (b) b.setAttribute("aria-label", (i === current && !audio.paused ? "Pausar " : "Reproducir ") + r.getAttribute("data-title"));
      });
      bar.classList.toggle("playing", !audio.paused);
    }

    function load(i) {
      var row = rows[i];
      if (!row) return;
      current = i;
      counted = false;
      audio.src = row.getAttribute("data-src");
      document.getElementById("playerTitle").textContent = row.getAttribute("data-title");
      document.getElementById("playerArtist").textContent = row.getAttribute("data-artist");
      document.getElementById("playerCover").src = row.getAttribute("data-cover");
      bar.hidden = false;
      audio.play().catch(function () { /* el navegador bloqueó la reproducción */ });
    }

    function registerPlay() {
      var row = rows[current];
      if (!row) return;
      var body = new URLSearchParams();
      body.append("id", row.getAttribute("data-id"));
      body.append("csrf", csrf);
      fetch("play.asp", {
        method: "POST",
        credentials: "same-origin",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: body.toString()
      })
        .then(function (r) {
          if (r.status === 401) { window.location.href = "login.asp"; return null; }
          return r.json();
        })
        .then(function (data) {
          if (!data || !data.ok) return;
          var cell = row.querySelector(".plays");
          if (cell) {
            cell.textContent = data.plays;
            cell.classList.remove("bump"); void cell.offsetWidth; cell.classList.add("bump");
          }
          var total = document.getElementById("totalPlays");
          if (total) total.textContent = parseInt(total.textContent, 10) + 1;
        })
        .catch(function () { /* sin conexión: no se actualiza el contador */ });
    }

    rows.forEach(function (row, i) {
      var btn = row.querySelector(".play-btn");
      if (!btn) return;
      btn.addEventListener("click", function () {
        if (i === current) {
          if (audio.paused) audio.play(); else audio.pause();
        } else {
          load(i);
        }
      });
    });

    audio.addEventListener("play", function () {
      if (!counted) { counted = true; registerPlay(); }
      markPlaying();
    });
    audio.addEventListener("pause", markPlaying);
    audio.addEventListener("ended", function () {
      counted = false;
      if (current < rows.length - 1) load(current + 1); else markPlaying();
    });

    document.getElementById("btnPrev").addEventListener("click", function () {
      if (audio.currentTime > 3) { audio.currentTime = 0; return; }
      load(current <= 0 ? rows.length - 1 : current - 1);
    });
    document.getElementById("btnNext").addEventListener("click", function () {
      load(current >= rows.length - 1 ? 0 : current + 1);
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    starfield();
    navToggle();
    pwdToggle();
    player();
  });
})();
