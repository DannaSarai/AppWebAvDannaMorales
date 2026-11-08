<%@ Page Title="Canciones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.Song" %>

<asp:Content ID="SongContent" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        :root {
            --bg-0: #07020f;
            --bg-1: #140629;
            --surface: rgba(30, 12, 58, 0.62);
            --surface-strong: rgba(42, 16, 80, 0.9);
            --border: rgba(186, 140, 255, 0.24);
            --text: #f3ecff;
            --text-muted: #bba8db;
            --violet: #9d4dff;
            --violet-2: #c77dff;
            --magenta: #ff5fd2;
            --gold: #ffcf5c;
            --cyan: #6ee7ff;
            --radius: 18px;
            --glow: 0 0 18px rgba(157, 77, 255, .55), 0 0 42px rgba(199, 125, 255, .25);
        }
        body {
            color: var(--text);
            background: radial-gradient(ellipse at 20% 0%, #2c0b57 0%, var(--bg-1) 42%, var(--bg-0) 100%) fixed;
            background-color: var(--bg-0);
            font-family: "Space Grotesk", system-ui, "Segoe UI", sans-serif;
            padding-bottom: 120px;
        }
        nav.navbar.bg-dark {
            background: rgba(10, 3, 22, .75) !important;
            backdrop-filter: blur(12px);
            border-bottom: 1px solid var(--border);
        }
        .navbar-brand { font-family: "Orbitron", sans-serif; letter-spacing: .03em; }
        .body-content hr { border-color: var(--border); }
        .body-content footer { color: var(--text-muted); }

        #starfield { position: fixed; inset: 0; width: 100%; height: 100%; z-index: -2; pointer-events: none; }
        .nebula {
            position: fixed; inset: -20%; z-index: -1; pointer-events: none;
            background:
                radial-gradient(closest-side at 78% 22%, rgba(255, 95, 210, .18), transparent),
                radial-gradient(closest-side at 15% 70%, rgba(110, 231, 255, .10), transparent),
                radial-gradient(closest-side at 55% 55%, rgba(157, 77, 255, .22), transparent 70%);
            filter: blur(30px);
            animation: drift 40s ease-in-out infinite alternate;
        }
        @keyframes drift { to { transform: translate3d(3%, -2%, 0) rotate(4deg); } }

        .pm-hero {
            display: flex; align-items: center; justify-content: space-between; gap: 1.5rem; flex-wrap: wrap;
            padding: clamp(18px, 3vw, 28px); margin: 1rem 0 1.5rem; border-radius: var(--radius);
            background: linear-gradient(120deg, rgba(157, 77, 255, .38), rgba(255, 95, 210, .14) 60%, rgba(110, 231, 255, .08));
            border: 1px solid var(--border);
        }
        .pm-eyebrow { margin: 0 0 .25rem; text-transform: uppercase; letter-spacing: .16em; font-size: .72rem; color: var(--gold); font-weight: 700; }
        .pm-welcome { margin: 0 0 .4rem; font-size: clamp(1.5rem, 4vw, 2.3rem); font-weight: 700; }
        .pm-welcome .name {
            background: linear-gradient(90deg, var(--gold), var(--magenta) 70%);
            -webkit-background-clip: text; background-clip: text; color: transparent;
        }
        .pm-muted { color: var(--text-muted); }
        .pm-role {
            display: inline-block; padding: .05rem .6rem; border-radius: 999px; font-size: .72rem; font-weight: 700;
            letter-spacing: .08em; color: var(--cyan); border: 1px solid rgba(110, 231, 255, .45); background: rgba(110, 231, 255, .1);
        }
        .pm-role.admin { color: var(--magenta); border-color: rgba(255, 95, 210, .5); background: rgba(255, 95, 210, .12); }
        .pm-user {
            display: flex; align-items: center; gap: .9rem; padding: .7rem .9rem .7rem .7rem;
            border-radius: 16px; background: var(--surface); border: 1px solid var(--border);
        }
        .pm-user img { width: 52px; height: 52px; border-radius: 50%; object-fit: cover; border: 2px solid var(--violet-2); box-shadow: var(--glow); }
        .pm-user-meta { display: flex; flex-direction: column; line-height: 1.25; min-width: 0; }
        .pm-user-meta span { font-size: .8rem; color: var(--text-muted); overflow: hidden; text-overflow: ellipsis; }

        .pm-panel {
            background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius);
            padding: clamp(16px, 3vw, 28px); backdrop-filter: blur(10px);
            box-shadow: 0 20px 60px rgba(0, 0, 0, .35), inset 0 1px 0 rgba(255, 255, 255, .05);
        }
        .pm-head { display: flex; align-items: flex-end; justify-content: space-between; gap: 1rem; flex-wrap: wrap; margin-bottom: 1rem; }
        .pm-title {
            font-family: "Orbitron", sans-serif; font-weight: 800; margin: 0; letter-spacing: .03em;
            font-size: clamp(1.7rem, 4.5vw, 2.5rem);
            background: linear-gradient(90deg, #fff 0%, var(--violet-2) 50%, var(--magenta) 100%);
            -webkit-background-clip: text; background-clip: text; color: transparent;
            filter: drop-shadow(0 0 12px rgba(199, 125, 255, .45));
        }
        .pm-stats { display: flex; gap: .6rem; flex-wrap: wrap; }
        .pm-stat { padding: .35rem .8rem; border-radius: 999px; background: rgba(157, 77, 255, .18); border: 1px solid var(--border); font-size: .85rem; }
        .pm-stat b { color: var(--cyan); }
        .pm-search { display: flex; gap: .6rem; margin-bottom: .5rem; flex-wrap: wrap; }
        .pm-search input[type=text] {
            flex: 1 1 260px; max-width: none; padding: .7rem .95rem; border-radius: 12px; font: inherit; color: var(--text);
            background: rgba(8, 2, 20, .6); border: 1px solid var(--border);
        }
        .pm-search input[type=text]::placeholder { color: var(--text-muted); }
        .pm-search input[type=text]:focus { border-color: var(--violet-2); box-shadow: 0 0 0 3px rgba(157, 77, 255, .25); outline: none; }
        .pm-btn {
            display: inline-flex; align-items: center; justify-content: center; padding: .6rem 1.1rem; border-radius: 12px;
            border: 1px solid transparent; cursor: pointer; font: inherit; font-weight: 700; color: #fff;
            transition: transform .15s, box-shadow .2s, background .2s;
        }
        .pm-btn-primary { background: linear-gradient(135deg, var(--violet), var(--magenta)); box-shadow: 0 0 14px rgba(157, 77, 255, .45); }
        .pm-btn-primary:hover { transform: translateY(-1px); box-shadow: var(--glow); }
        .pm-btn-ghost { background: rgba(255, 255, 255, .06); border-color: var(--border); color: var(--text); }
        .pm-btn-ghost:hover { background: rgba(157, 77, 255, .28); }
        .pm-btn:focus-visible, .pm-play:focus-visible { outline: 2px solid var(--cyan); outline-offset: 2px; }
        .pm-result { font-size: .85rem; margin: 0 0 .4rem; }

        .pm-grid-wrap { overflow-x: auto; }
        table.pm-grid { width: 100%; border-collapse: separate; border-spacing: 0 6px; color: var(--text); }
        table.pm-grid th {
            text-align: left; font-size: .72rem; text-transform: uppercase; letter-spacing: .12em; color: var(--text-muted);
            padding: .4rem .9rem; font-weight: 500; border-bottom: 1px solid var(--border);
        }
        table.pm-grid td { padding: .65rem .9rem; vertical-align: middle; background: rgba(255, 255, 255, .035); transition: background .2s; }
        table.pm-grid td:first-child { border-radius: 12px 0 0 12px; }
        table.pm-grid td:last-child { border-radius: 0 12px 12px 0; }
        table.pm-grid tr:hover td { background: rgba(157, 77, 255, .16); }
        table.pm-grid tr.is-playing td { background: linear-gradient(90deg, rgba(157, 77, 255, .38), rgba(255, 95, 210, .18)); }
        table.pm-grid tr.is-playing td:first-child { box-shadow: inset 3px 0 0 var(--magenta); }
        .pm-num { text-align: right; width: 1%; white-space: nowrap; font-variant-numeric: tabular-nums; }
        .pm-song { display: flex; align-items: center; gap: .75rem; }
        .pm-song img { width: 46px; height: 46px; border-radius: 10px; object-fit: cover; flex: none; }
        .pm-song b { font-weight: 700; }
        .pm-plays { display: inline-block; min-width: 2.3em; padding: .1rem .55rem; border-radius: 999px; text-align: center; background: rgba(110, 231, 255, .12); color: var(--cyan); }
        .pm-plays.bump { animation: bump .6s ease; }
        @keyframes bump { 40% { transform: scale(1.35); box-shadow: 0 0 16px var(--cyan); } }
        .pm-play {
            width: 42px; height: 42px; border-radius: 50%; border: 0; cursor: pointer; display: grid; place-items: center;
            background: linear-gradient(135deg, var(--violet), var(--magenta)); box-shadow: 0 0 14px rgba(157, 77, 255, .5);
            transition: transform .15s, box-shadow .2s;
        }
        .pm-play:hover { transform: scale(1.08); box-shadow: var(--glow); }
        .pm-ico { width: 0; height: 0; margin-left: 3px; border-left: 13px solid #fff; border-top: 8px solid transparent; border-bottom: 8px solid transparent; }
        tr.is-playing .pm-ico { margin: 0; width: 13px; height: 15px; border: 0; border-left: 4px solid #fff; border-right: 4px solid #fff; }
        .pm-empty { text-align: center; color: var(--text-muted); padding: 2rem 0; }

        .pm-player {
            position: fixed; left: 50%; bottom: 14px; transform: translateX(-50%); z-index: 1040;
            width: min(980px, calc(100% - 24px)); display: none; align-items: center; gap: 1rem; padding: .6rem 1rem;
            background: var(--surface-strong); border: 1px solid var(--border); border-radius: 20px; color: var(--text);
            backdrop-filter: blur(16px); box-shadow: 0 10px 40px rgba(0, 0, 0, .5), var(--glow);
        }
        .pm-player.show { display: flex; }
        .pm-player img { width: 52px; height: 52px; border-radius: 12px; object-fit: cover; flex: none; }
        .pm-player.playing img { border-radius: 50%; animation: spin 8s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .pm-player-info { display: flex; flex-direction: column; min-width: 0; flex: 0 1 210px; }
        .pm-player-info b, .pm-player-info span { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .pm-player-info span { font-size: .8rem; color: var(--text-muted); }
        .pm-player-controls { display: flex; align-items: center; gap: .5rem; flex: 1; min-width: 0; }
        .pm-player audio { flex: 1; min-width: 0; height: 40px; }
        .pm-ctrl { width: 38px; height: 38px; border-radius: 50%; border: 1px solid var(--border); background: rgba(255, 255, 255, .08); color: var(--text); cursor: pointer; flex: none; font-size: .9rem; }
        .pm-ctrl:hover { background: rgba(157, 77, 255, .35); }

        @media (max-width: 680px) {
            table.pm-grid thead { display: none; }
            table.pm-grid, table.pm-grid tbody, table.pm-grid tr, table.pm-grid td { display: block; width: 100%; }
            table.pm-grid tr { position: relative; margin-bottom: .6rem; }
            table.pm-grid td { border-radius: 0 !important; padding: .25rem .9rem; text-align: left; }
            table.pm-grid td:first-child { display: none; }
            table.pm-grid td:nth-child(2) { border-radius: 14px 14px 0 0 !important; padding-top: .8rem; padding-right: 64px; }
            table.pm-grid td:last-child { position: absolute; top: .75rem; right: .3rem; width: auto; background: none; }
            table.pm-grid td:nth-last-child(2) { border-radius: 0 0 14px 14px !important; padding-bottom: .8rem; }
            table.pm-grid td[data-label]::before { content: attr(data-label) ": "; color: var(--text-muted); font-size: .8rem; }
            .pm-player { flex-wrap: wrap; gap: .5rem; bottom: 8px; padding: .6rem; }
            .pm-player-info { flex: 1 1 0; }
            .pm-player-controls { flex-basis: 100%; }
        }
        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after { animation: none !important; transition: none !important; }
        }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Orbitron:wght@600;800&amp;family=Space+Grotesk:wght@400;500;700&amp;display=swap" />

    <canvas id="starfield" aria-hidden="true"></canvas>
    <div class="nebula" aria-hidden="true"></div>

    <section class="pm-hero">
        <div>
            <p class="pm-eyebrow">Panel de escucha</p>
            <h1 class="pm-welcome">Bienvenido/a, <span class="name"><asp:Literal ID="litWelcomeName" runat="server" /></span></h1>
            <p class="pm-muted mb-0">
                Tu sesión está activa con el rol <asp:Literal ID="litRole" runat="server" />
                · elige una canción y deja que suene entre las estrellas.
            </p>
        </div>
        <div class="pm-user">
            <asp:Image ID="imgUser" runat="server" AlternateText="Foto de perfil" />
            <div class="pm-user-meta">
                <b><asp:Literal ID="litUserName" runat="server" /></b>
                <span><asp:Literal ID="litEmail" runat="server" /></span>
            </div>
        </div>
    </section>

    <section class="pm-panel">
        <div class="pm-head">
            <h2 class="pm-title">Song List</h2>
            <div class="pm-stats">
                <span class="pm-stat"><b><asp:Literal ID="litTotalSongs" runat="server" /></b> canciones</span>
                <span class="pm-stat"><b id="totalPlays"><asp:Literal ID="litTotalPlays" runat="server" /></b> reproducciones</span>
            </div>
        </div>

        <asp:Panel ID="pnlSearch" runat="server" CssClass="pm-search" DefaultButton="btnSearch" role="search">
            <asp:TextBox ID="txtSearch" runat="server" MaxLength="50" placeholder="Buscar por canción, artista o álbum..." />
            <asp:Button ID="btnSearch" runat="server" Text="Buscar" CssClass="pm-btn pm-btn-primary" OnClick="btnSearch_Click" />
            <asp:Button ID="btnClear" runat="server" Text="Limpiar" CssClass="pm-btn pm-btn-ghost" OnClick="btnClear_Click" />
        </asp:Panel>
        <p class="pm-result pm-muted"><asp:Literal ID="litResult" runat="server" /></p>

        <div class="pm-grid-wrap">
            <asp:GridView ID="gvSongs" runat="server" AutoGenerateColumns="false" CssClass="pm-grid"
                GridLines="None" CellSpacing="-1" DataKeyNames="ID_SONG" OnRowDataBound="gvSongs_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="#">
                        <ItemStyle CssClass="pm-num" />
                        <HeaderStyle CssClass="pm-num" />
                        <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Canción">
                        <ItemTemplate>
                            <div class="pm-song">
                                <img src="<%# CoverUrl(Eval("ID_SONG")) %>" alt="" />
                                <b><%#: Eval("SONG_NAME") %></b>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ARTISTS" HeaderText="Artista" HtmlEncode="true" />
                    <asp:BoundField DataField="ALBUMS" HeaderText="Álbum" HtmlEncode="true" />
                    <asp:TemplateField HeaderText="Reproducciones">
                        <ItemStyle CssClass="pm-num" />
                        <HeaderStyle CssClass="pm-num" />
                        <ItemTemplate><span class="pm-plays"><%# Eval("PLAYS") %></span></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <ItemStyle CssClass="pm-num" />
                        <ItemTemplate>
                            <button type="button" class="pm-play"
                                data-id="<%# Eval("ID_SONG") %>"
                                data-src="<%# SongUrl(Eval("SONG_PATH")) %>"
                                data-title="<%#: Eval("SONG_NAME") %>"
                                data-artist="<%#: Eval("ARTISTS") %>"
                                data-cover="<%# CoverUrl(Eval("ID_SONG")) %>"
                                aria-label="Reproducir <%#: Eval("SONG_NAME") %>">
                                <span class="pm-ico" aria-hidden="true"></span>
                            </button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <p class="pm-empty">No se encontraron canciones.</p>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </section>

    <div class="pm-player" id="player">
        <img id="playerCover" src="<%: ResolveUrl("~/PlaylistImages/default.jpg") %>" alt="" />
        <div class="pm-player-info">
            <b id="playerTitle">-</b>
            <span id="playerArtist">-</span>
        </div>
        <div class="pm-player-controls">
            <button type="button" class="pm-ctrl" id="btnPrev" aria-label="Anterior">&#9664;&#9664;</button>
            <audio id="audio" controls="controls" preload="none"></audio>
            <button type="button" class="pm-ctrl" id="btnNext" aria-label="Siguiente">&#9654;&#9654;</button>
        </div>
    </div>

    <script>
        (function () {
            "use strict";
            var reduceMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

            var canvas = document.getElementById("starfield");
            var ctx = canvas.getContext("2d");
            var stars = [], shooting = null, w = 0, h = 0;
            var colors = ["#ffffff", "#e3c8ff", "#c77dff", "#ffd6f5", "#bdf3ff"];
            function resize() {
                var dpr = Math.min(window.devicePixelRatio || 1, 2);
                w = window.innerWidth; h = window.innerHeight;
                canvas.width = w * dpr; canvas.height = h * dpr;
                ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
                stars = [];
                for (var i = 0, n = Math.round(w * h / 4200); i < n; i++) {
                    stars.push({ x: Math.random() * w, y: Math.random() * h, r: Math.random() * 1.3 + .2,
                        a: Math.random() * 6, s: Math.random() * .015 + .003, c: colors[(Math.random() * colors.length) | 0] });
                }
                if (reduceMotion) draw();
            }
            function draw() {
                ctx.clearRect(0, 0, w, h);
                for (var i = 0; i < stars.length; i++) {
                    var st = stars[i];
                    st.a += st.s;
                    ctx.globalAlpha = .35 + Math.abs(Math.sin(st.a)) * .65;
                    ctx.fillStyle = st.c;
                    ctx.beginPath(); ctx.arc(st.x, st.y, st.r, 0, Math.PI * 2); ctx.fill();
                }
                if (!shooting && Math.random() < .004) shooting = { x: Math.random() * w * .7, y: Math.random() * h * .4, len: 0, life: 1 };
                if (shooting) {
                    shooting.x += 9; shooting.y += 4; shooting.len = Math.min(shooting.len + 12, 140); shooting.life -= .018;
                    var g = ctx.createLinearGradient(shooting.x, shooting.y, shooting.x - shooting.len, shooting.y - shooting.len * .45);
                    g.addColorStop(0, "rgba(255,255,255," + Math.max(shooting.life, 0) + ")");
                    g.addColorStop(1, "rgba(199,125,255,0)");
                    ctx.globalAlpha = 1; ctx.strokeStyle = g; ctx.lineWidth = 2;
                    ctx.beginPath(); ctx.moveTo(shooting.x, shooting.y);
                    ctx.lineTo(shooting.x - shooting.len, shooting.y - shooting.len * .45); ctx.stroke();
                    if (shooting.life <= 0) shooting = null;
                }
                ctx.globalAlpha = 1;
            }
            function loop() { draw(); requestAnimationFrame(loop); }
            window.addEventListener("resize", resize);
            resize();
            if (!reduceMotion) loop();

            var buttons = Array.prototype.slice.call(document.querySelectorAll(".pm-play"));
            var bar = document.getElementById("player");
            var audio = document.getElementById("audio");
            var current = -1, counted = false;

            function refresh() {
                buttons.forEach(function (b, i) {
                    var on = i === current && !audio.paused;
                    b.closest("tr").classList.toggle("is-playing", on);
                    b.setAttribute("aria-label", (on ? "Pausar " : "Reproducir ") + b.getAttribute("data-title"));
                });
                bar.classList.toggle("playing", !audio.paused);
            }
            function load(i) {
                var b = buttons[i];
                if (!b) return;
                current = i; counted = false;
                audio.src = b.getAttribute("data-src");
                document.getElementById("playerTitle").textContent = b.getAttribute("data-title");
                document.getElementById("playerArtist").textContent = b.getAttribute("data-artist") || "Artista desconocido";
                document.getElementById("playerCover").src = b.getAttribute("data-cover");
                bar.classList.add("show");
                audio.play().catch(function () { });
            }
            function registerPlay() {
                var b = buttons[current];
                if (!b) return;
                fetch(window.location.pathname, {
                    method: "POST",
                    credentials: "same-origin",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: "action=play&id=" + encodeURIComponent(b.getAttribute("data-id"))
                }).then(function (r) {
                    if (r.status === 401) { window.location.reload(); return null; }
                    return r.ok ? r.json() : null;
                }).then(function (data) {
                    if (!data || !data.ok) return;
                    var cell = b.closest("tr").querySelector(".pm-plays");
                    cell.textContent = data.plays;
                    cell.classList.remove("bump"); void cell.offsetWidth; cell.classList.add("bump");
                    var total = document.getElementById("totalPlays");
                    total.textContent = parseInt(total.textContent, 10) + 1;
                }).catch(function () { });
            }

            buttons.forEach(function (b, i) {
                b.addEventListener("click", function () {
                    if (i === current) { if (audio.paused) audio.play(); else audio.pause(); }
                    else load(i);
                });
            });
            audio.addEventListener("play", function () {
                if (!counted) { counted = true; registerPlay(); }
                refresh();
            });
            audio.addEventListener("pause", refresh);
            audio.addEventListener("ended", function () {
                counted = false;
                if (current < buttons.length - 1) load(current + 1); else refresh();
            });
            document.getElementById("btnPrev").addEventListener("click", function () {
                if (audio.currentTime > 3) { audio.currentTime = 0; return; }
                load(current <= 0 ? buttons.length - 1 : current - 1);
            });
            document.getElementById("btnNext").addEventListener("click", function () {
                load(current >= buttons.length - 1 ? 0 : current + 1);
            });
        })();
    </script>

</asp:Content>
