extends Node3D
# KEEP THE LIGHT - a storm-night errand. Everything generated in code.

const TAU2 = PI*2.0
const R_SHELL = 5.6
const WALL_R = 7.0
const GAP = [10.0, 10.3]
const SURF = [
  {a0=0.0, a1=3.2,  y0=0.0,  y1=3.8,  gap=false},
  {a0=3.2, a1=4.0,  y0=3.8,  y1=3.8,  gap=false},
  {a0=4.0, a1=5.65, y0=3.8,  y1=6.175, gap=false},
  {a0=5.65, a1=6.35, y0=6.175, y1=6.175, gap=false},  # the window landing: a flat rest at the gallery vista
  {a0=6.35, a1=7.2, y0=6.175, y1=7.6,  gap=false},
  {a0=7.2, a1=8.0,  y0=7.6,  y1=7.6,  gap=false},
  {a0=8.0, a1=11.2, y0=7.6,  y1=11.4, gap=true},
  {a0=11.2,a1=12.0, y0=11.4, y1=11.4, gap=false},
  {a0=12.0,a1=15.2, y0=11.4, y1=15.2, gap=false},
  {a0=15.2,a1=16.0, y0=15.2, y1=15.2, gap=false},
  {a0=16.0,a1=19.2, y0=15.2, y1=19.0, gap=false},
  {a0=19.2,a1=1e9,  y0=19.0, y1=19.0, gap=false},
]
const MISSING = [1,3,5,8,10]
# sea-glass hues: one identity per pane (shard glow, HUD pip silhouette, fitted lens facet)
const PANE_COLORS = [Color(1.0,0.78,0.42), Color(0.45,0.85,0.80), Color(0.95,0.55,0.60), Color(0.65,0.62,0.95), Color(0.62,0.90,0.60)]
var AUTO = false
var FAST = false
var GUSTHOLD = false
var DOORSHUT = false
var DOOROPEN = false
var START_OIL = 80.0

func surf_y(s, th):
  var t = clamp((th - s.a0) / (s.a1 - s.a0), 0.0, 1.0)
  return lerp(s.y0, s.y1, t)

func floor_at(th, y_ref):
  var best = 0.0
  for s in SURF:
    if th < s.a0 - 1e-6 or th > s.a1 + 1e-6: continue
    if s.gap and th > GAP[0] and th < GAP[1]: continue
    var y = surf_y(s, th)
    if y <= y_ref + 0.35 and y > best: best = y
  return best

var panes = []
func pane_pos_list():
  var out = []
  for th in [1.7, 7.6, 9.5, 15.6, 18.3]:
    out.append({th=th, y=floor_at(th, 99.0) + 1.15, got=false, node=null})
  return out

func place_radial(n, th, r, y):
  n.position = Vector3(r * cos(th), y, r * sin(th))
  n.rotation.y = -th - PI/2.0

func cyl_between(a, b, r, mat):
  var dir = b - a
  var len = dir.length()
  var mesh = CylinderMesh.new()
  mesh.top_radius = r; mesh.bottom_radius = r; mesh.height = len; mesh.radial_segments = 6
  var mi = MeshInstance3D.new()
  mi.mesh = mesh
  if mat: mi.material_override = mat
  var up = dir.normalized()
  var right = up.cross(Vector3.UP)
  if right.length() < 0.01: right = Vector3.RIGHT
  right = right.normalized()
  var forward = right.cross(up).normalized()
  mi.transform = Transform3D(Basis(right, up, forward), (a + b) * 0.5)
  return mi

# ---------- procedural audio: pre-rendered wavs ----------
var SR = 22050
var SND = {}
func make_wav(samples):
  var w = AudioStreamWAV.new()
  w.format = AudioStreamWAV.FORMAT_16_BITS
  w.mix_rate = SR
  w.stereo = false
  var data = PackedByteArray()
  data.resize(samples.size() * 2)
  for i in samples.size():
    data.encode_s16(i * 2, int(clamp(samples[i], -1.0, 1.0) * 32000))
  w.data = data
  return w
func synth(dur, fn):
  var n = int(dur * SR)
  var samples = []
  samples.resize(n)
  var lp = 0.0
  for i in n:
    var t = float(i) / SR
    samples[i] = fn.call(t, i, n, lp)
    lp = lerp(lp, samples[i], 0.12)
  return samples
func build_audio():
  # rain bed: looped filtered noise
  var rain = synth(2.3, func(t, i, n, lp):
    return (randf() * 2.0 - 1.0) * 0.14 * sin(PI * float(i) / n))
  # wind: slow swell noise
  var wind = synth(3.1, func(t, i, n, lp):
    var sw = 0.5 + 0.5 * sin(t * 0.9) * sin(t * 0.37 + 1.3)
    return (randf() * 2.0 - 1.0) * 0.10 * sw * sin(PI * float(i) / n))
  SND.rain = make_wav(rain); SND.rain.loop_mode = AudioStreamWAV.LOOP_FORWARD; SND.rain.loop_end = rain.size()
  SND.wind = make_wav(wind); SND.wind.loop_mode = AudioStreamWAV.LOOP_FORWARD; SND.wind.loop_end = wind.size()
  # gust: a short soft swell that telegraphs a push of wind
  SND.gust = make_wav(synth(0.9, func(t, i, n, lp):
    var env = sin(PI * float(i) / n)
    return (randf() * 2.0 - 1.0) * 0.12 * env * env))
  SND.surf = make_wav(synth(4.0, func(t, i, n, lp):
    var sw = 0.5 + 0.5 * sin(t * 0.55 + sin(t * 0.23) * 1.5)
    return ((randf() * 2.0 - 1.0) * 0.22 + lp * 1.7) * 0.08 * sw * sin(PI * float(i) / n)))
  SND.surf.loop_mode = AudioStreamWAV.LOOP_FORWARD; SND.surf.loop_end = int(4.0 * SR)
  SND.thunder = make_wav(synth(2.8, func(t, i, n, lp):
    var env = exp(-t * 1.6)
    var r = (randf() * 2.0 - 1.0)
    return (r * 0.35 + lp * 1.4) * env * 0.45))
  # per-pane chime ladder: A-C-D-E-G pentatonic, ascending with each pane.
  # upper partials shrink as pitch rises so high notes stay soft on phone speakers.
  var ladder = [[440.0, 0.15], [523.25, 0.13], [587.33, 0.11], [659.25, 0.09], [783.99, 0.11]]
  for li in ladder.size():
    var f = ladder[li][0]; var br = ladder[li][1]
    var tail = 2.4 if li < 4 else 2.0
    var dur = 1.4 if li < 4 else 1.7
    SND["chime" + str(li + 1)] = make_wav(synth(dur, func(t, i, n, lp):
      var body = sin(TAU2 * f * t) * 0.5 + sin(TAU2 * f * 2.0 * t) * br * 0.7 + sin(TAU2 * f * 2.76 * t) * br
      return body * exp(-t * tail) * 0.7))
  SND.clink = make_wav(synth(0.3, func(t, i, n, lp):
    return (sin(TAU2 * 1700.0 * t) * 0.3 + sin(TAU2 * 2550.0 * t) * 0.15) * exp(-t * 18.0) * 0.6))
  SND.jump = make_wav(synth(0.22, func(t, i, n, lp):
    return (randf() * 2.0 - 1.0 - lp * 0.7) * exp(-t * 9.0) * 0.25))
  SND.land = make_wav(synth(0.16, func(t, i, n, lp):
    return sin(TAU2 * (90.0 - t * 200.0) * t) * exp(-t * 22.0) * 0.5))
  SND.step = make_wav(synth(0.09, func(t, i, n, lp):
    return ((randf() * 2.0 - 1.0) * 0.4 + lp * 1.3) * exp(-t * 60.0) * 0.15 + sin(TAU2 * 75.0 * t) * exp(-t * 50.0) * 0.2))
  SND.ignite = make_wav(synth(1.5, func(t, i, n, lp):
    var r = (randf() * 2.0 - 1.0)
    var env = min(t * 6.0, 1.0) * exp(-t * 1.5)
    return (r * 0.3 + lp * 0.9) * env * 0.5 + sin(TAU2 * 110.0 * t) * env * 0.25))
  SND.drone = make_wav(synth(2.6, func(t, i, n, lp):
    return (sin(TAU2 * 110.0 * t) * 0.4 + sin(TAU2 * 164.8 * t) * 0.22) * 0.3 * sin(PI * float(i) / n)))
  SND.drone.loop_mode = AudioStreamWAV.LOOP_FORWARD; SND.drone.loop_end = int(2.6 * SR)
  SND.bell = make_wav(synth(3.2, func(t, i, n, lp):
    return (sin(TAU2 * 659.0 * t) * 0.4 + sin(TAU2 * 988.0 * t) * 0.18) * exp(-t * 1.1) * 0.55))
  # foghorn: the ship out in the storm - low root + fifth, slow swell, soft.
  # heard during the climb; the same ship that sets her course for home at the end.
  SND.horn = make_wav(synth(2.4, func(t, i, n, lp):
    var env = sin(PI * float(i) / n)
    return (sin(TAU2 * 98.0 * t) * 0.5 + sin(TAU2 * 147.0 * t) * 0.22) * env * env * 0.4))
  SND.gutter = make_wav(synth(1.3, func(t, i, n, lp):
    return (sin(TAU2 * (150.0 - t * 90.0) * t) * 0.4 + (randf() * 2.0 - 1.0) * 0.2) * exp(-t * 2.4) * 0.6))
var players = {}
func sfx(name, vol_db = 0.0, pitch = 1.0):
  if not SND.has(name): return
  var p = players.get(name)
  if p == null:
    p = AudioStreamPlayer.new()
    p.stream = SND[name]
    add_child(p)
    players[name] = p
  p.volume_db = vol_db
  p.pitch_scale = pitch
  p.play()
func loop_sfx(name, vol_db):
  var p = AudioStreamPlayer.new()
  p.stream = SND[name]
  p.volume_db = vol_db
  add_child(p)
  players[name] = p
  p.play()
  return p

# ---------- procedural textures ----------
func tex_brick():
  var img = Image.create(512, 512, false, Image.FORMAT_RGBA8)
  img.fill(Color(0.25, 0.235, 0.275))
  var rows = 16
  var bh = 512.0 / rows
  for r in rows:
    var off = (r % 2) * 40
    for x in range(-80, 592, 80):
      var L = randf_range(-0.035, 0.035)
      img.fill_rect(Rect2i(x + off + 2, int(r * bh) + 2, 76, int(bh) - 4), Color(0.30 + L, 0.28 + L, 0.33 + L))
      if randf() < 0.12:
        img.fill_rect(Rect2i(x + off + 2, int(r * bh) + 2, 76, int(bh) - 4), Color(0.10, 0.09, 0.11, 0.25))
  return ImageTexture.create_from_image(img)
func tex_floor():
  var img = Image.create(512, 512, false, Image.FORMAT_RGBA8)
  img.fill(Color(0.20, 0.20, 0.235))
  for i in 4:
    for j in 4:
      var L = randf_range(-0.03, 0.03)
      img.fill_rect(Rect2i(i * 128 + 3, j * 128 + 3, 122, 122), Color(0.235 + L, 0.23 + L, 0.27 + L))
  for i in 14:
    var p = Vector2(randf() * 512, randf() * 512)
    for k in 5:
      var q = p + Vector2(randf_range(-40, 40), randf_range(-40, 40))
      img.fill_rect(Rect2i(int(min(p.x,q.x)), int(min(p.y,q.y)), int(abs(q.x-p.x))+2, int(abs(q.y-p.y))+2), Color(0.05,0.05,0.07,0.5))
      p = q
  return ImageTexture.create_from_image(img)
func tex_glow():
  var img = Image.create(128, 128, false, Image.FORMAT_RGBA8)
  for y in 128:
    for x in 128:
      var d = Vector2(x - 64, y - 64).length() / 62.0
      var a = clamp(1.0 - d, 0.0, 1.0)
      a = a * a * (3.0 - 2.0 * a)
      img.set_pixel(x, y, Color(1, 1, 1, a))
  return ImageTexture.create_from_image(img)
func tex_skywin():
  var img = Image.create(128, 256, false, Image.FORMAT_RGBA8)
  for y in 256:
    var t = y / 255.0
    var c = Color(0.027, 0.047, 0.086)
    if t > 0.55 and t < 0.72: c = Color(0.10, 0.16, 0.26).lerp(Color(0.22, 0.33, 0.44), (t - 0.55) / 0.17)
    elif t >= 0.72 and t < 0.78: c = Color(0.09, 0.135, 0.20)
    img.fill_rect(Rect2i(0, y, 128, 1), c)
  for i in 30:
    img.set_pixel(randi_range(0,127), randi_range(0,127), Color(1,1,1,0.6))
  img.fill_rect(Rect2i(84, 88, 18, 18), Color(0.9, 0.94, 0.97, 0.9))
  img.fill_rect(Rect2i(78, int(256*0.72), 28, 70), Color(0.59, 0.75, 0.86, 0.16))
  return ImageTexture.create_from_image(img)
func tex_vista():
  # the second-landing gallery window: big moon, moonlit sea, stars.
  # composed for the mid band - the follow camera mostly shows the texture's middle.
  var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
  for y in 256:
    var t = y / 255.0
    var c
    if t < 0.60: c = Color(0.075, 0.115, 0.20).lerp(Color(0.16, 0.235, 0.345), pow(t / 0.60, 1.5))
    elif t < 0.645: c = Color(0.30, 0.40, 0.52)  # horizon haze line
    else: c = Color(0.085, 0.14, 0.215).lerp(Color(0.045, 0.075, 0.13), (t - 0.645) / 0.355)  # sea
    img.fill_rect(Rect2i(0, y, 256, 1), c)
  # stars
  for i in 80:
    var sx = randi_range(0, 255); var sy = randi_range(0, 148)
    img.set_pixel(sx, sy, Color(1, 1, 1, randf_range(0.35, 0.85)))
    if i % 5 == 0: img.set_pixel((sx + 1) % 256, sy, Color(1, 1, 1, 0.4))
  # moon + halo, centered in the visible band
  var mx = 150.0; var my = 118.0
  for dy in range(-50, 51):
    for dx in range(-50, 51):
      var d = sqrt(dx * dx + dy * dy)
      var px2 = int(mx + dx); var py2 = int(my + dy)
      if px2 < 0 or px2 > 255 or py2 < 0 or py2 > 162: continue
      if d <= 26: img.set_pixel(px2, py2, Color(0.94, 0.96, 1.0, 1.0))
      elif d <= 50:
        var cur = img.get_pixel(px2, py2)
        img.set_pixel(px2, py2, cur.lerp(Color(0.72, 0.81, 0.94, 1.0), 0.55 * (1.0 - (d - 26.0) / 24.0)))
  # moon reflection shimmer on the sea
  for i in 110:
    var ry = randi_range(168, 252)
    var spread = 7.0 + (ry - 168) * 0.24
    var rx = int(mx + randf_range(-spread, spread))
    var rw = randi_range(2, 9)
    img.fill_rect(Rect2i(clamp(rx, 0, 248), ry, rw, 1), Color(0.66, 0.79, 0.92, randf_range(0.2, 0.55)))
  return ImageTexture.create_from_image(img)

func tex_rain_streaks():
  var img = Image.create(128, 128, false, Image.FORMAT_RGBA8)
  img.fill(Color(0,0,0,0))
  for i in 26:
    var x = randf() * 128; var y = randf() * 128
    for k in 12:
      img.set_pixel(int(x + k*0.15) % 128, (int(y) + k) % 128, Color(0.62, 0.72, 0.83, 0.5 - k*0.03))
  return ImageTexture.create_from_image(img)

func tex_beam():
  var img = Image.create(64, 256, false, Image.FORMAT_RGBA8)
  for y in 256:
    for x in 64:
      var across = 1.0 - abs(x - 32) / 32.0
      var along = 1.0 - y / 255.0
      var a = pow(across, 1.6) * (0.25 + 0.75 * along) * 0.85
      img.set_pixel(x, y, Color(1, 1, 1, a))
  return ImageTexture.create_from_image(img)

func mat_lam(color, tex = null):
  var m = StandardMaterial3D.new()
  m.albedo_color = color
  if tex: m.albedo_texture = tex
  m.roughness = 0.9
  return m
func mat_glow(color, energy = 1.0, alpha = 1.0, additive = false):
  var m = StandardMaterial3D.new()
  m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  m.albedo_color = Color(color.r, color.g, color.b, alpha)
  m.emission_enabled = true
  m.emission = color
  m.emission_energy_multiplier = energy
  if alpha < 1.0 or additive:
    m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  if additive:
    m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
  m.disable_fog = false
  return m

func box(sz, mat):
  var b = BoxMesh.new(); b.size = sz
  var mi = MeshInstance3D.new(); mi.mesh = b
  if mat: mi.material_override = mat
  return mi

# ---------- tower ----------
var tower = {}
var tower_root = null
func build_tower(root):
  var brick = tex_brick()
  var floor_t = tex_floor()
  var sky = tex_skywin()
  var vista = tex_vista()
  var rain_t = tex_rain_streaks()
  tower.glow_tex = tex_glow()

  var wall_m = CylinderMesh.new()
  wall_m.top_radius = WALL_R; wall_m.bottom_radius = WALL_R; wall_m.height = 26
  wall_m.radial_segments = 56; wall_m.flip_faces = true
  var wall = MeshInstance3D.new(); wall.mesh = wall_m
  var wallmat = mat_lam(Color.WHITE, brick)
  wallmat.uv1_scale = Vector3(14, 6, 1)
  wall.material_override = wallmat
  wall.position.y = 12
  root.add_child(wall)

  var base = MeshInstance3D.new()
  var disc = CylinderMesh.new(); disc.top_radius = WALL_R; disc.bottom_radius = WALL_R; disc.height = 0.1
  base.mesh = disc
  var bmat = mat_lam(Color.WHITE, floor_t); bmat.uv1_scale = Vector3(2,2,1)
  base.material_override = bmat
  base.position.y = -0.05
  root.add_child(base)

  # door
  var door = Node3D.new()
  var dframe = mat_lam(Color(0.165,0.176,0.22))
  var wood = mat_lam(Color(0.29,0.22,0.15))
  var dl = box(Vector3(0.28,3.2,0.5), dframe); dl.position.x = -1.05; door.add_child(dl)
  var dr = box(Vector3(0.28,3.2,0.5), dframe); dr.position.x = 1.05; door.add_child(dr)
  var dt2 = box(Vector3(2.4,0.3,0.5), dframe); dt2.position.y = 1.65; door.add_child(dt2)
  var hinge = Node3D.new(); hinge.position = Vector3(-0.9, 0.05, 0.18); hinge.rotation.y = 0.5; door.add_child(hinge)
  var panel = box(Vector3(1.8,3.1,0.12), wood); panel.position = Vector3(0.9, 0, 0); hinge.add_child(panel)
  tower.door_panel = hinge
  place_radial(door, 0, 6.75, 1.6)
  root.add_child(door)

  # steps via MultiMesh
  var steps = []
  var stepD = 0.107
  for s in SURF:
    if s.a1 > 100: continue
    var th = s.a0
    while th < s.a1 - 0.02:
      var mid = th + stepD / 2.0
      if not (s.gap and mid > GAP[0] - 0.05 and mid < GAP[1] + 0.05):
        steps.append([mid, surf_y(s, mid)])
      th += stepD
  var mm = MultiMesh.new()
  mm.transform_format = MultiMesh.TRANSFORM_3D
  mm.use_colors = true
  var stepmesh = BoxMesh.new(); stepmesh.size = Vector3(1.45, 0.16, 2.35)
  mm.mesh = stepmesh
  mm.instance_count = steps.size()
  var i = 0
  for st in steps:
    var b = Basis(Vector3.UP, -st[0] - PI/2.0)
    mm.set_instance_transform(i, Transform3D(b, Vector3(R_SHELL * cos(st[0]), st[1] - 0.08, R_SHELL * sin(st[0]))))
    var L = 0.42 + randf_range(-0.04, 0.04)
    mm.set_instance_color(i, Color(L * 1.04, L * 1.0, L * 0.98))
    i += 1
  var mmi = MultiMeshInstance3D.new(); mmi.multimesh = mm
  var smat = mat_lam(Color.WHITE); smat.vertex_color_use_as_albedo = true
  mmi.material_override = smat
  root.add_child(mmi)
  # broken stubs + debris
  var stubmat = mat_lam(Color(0.50,0.49,0.55))
  for pair in [[GAP[0]-0.06, 0.5],[GAP[1]+0.06, -0.5]]:
    var yv = floor_at(pair[0] + (0.2 if pair[1] < 0 else -0.2), 99.0)
    var stub = box(Vector3(0.55,0.14,1.4), stubmat)
    stub.position = Vector3(R_SHELL*cos(pair[0]), yv - 0.1, R_SHELL*sin(pair[0]))
    stub.rotation = Vector3(0, -pair[0]-PI/2.0, pair[1])
    root.add_child(stub)
  for k in 4:
    var th2 = randf_range(9.6, 10.8); var rr = randf_range(3.5, 6.2)
    var d = box(Vector3(randf_range(0.4,0.9), 0.14, randf_range(0.5,1.2)), stubmat)
    d.position = Vector3(rr*cos(th2), 0.07, rr*sin(th2)); d.rotation.y = randf()*TAU2
    root.add_child(d)
  # railings
  var railmat = mat_lam(Color(0.20,0.21,0.26))
  for s in SURF:
    if s.a1 > 100: continue
    var spans = [[s.a0, s.a1]]
    if s.gap: spans = [[s.a0, GAP[0]-0.05],[GAP[1]+0.05, s.a1]]
    for sp in spans:
      var prev = null
      var th3 = sp[0]
      while th3 <= sp[1] + 0.01:
        var p = Vector3(4.62*cos(th3), surf_y(s, th3) + 1.0, 4.62*sin(th3))
        if prev != null:
          root.add_child(cyl_between(prev, p, 0.045, railmat))
        if int(th3 * 100) % 32 < int((sp[1]-sp[0]) * 100 / 14.0):
          var post = CylinderMesh.new(); post.top_radius = 0.035; post.bottom_radius = 0.045; post.height = 1.0; post.radial_segments = 6
          var pi2 = MeshInstance3D.new(); pi2.mesh = post; pi2.material_override = railmat
          pi2.position = Vector3(4.62*cos(th3), surf_y(s, th3) + 0.5, 4.62*sin(th3))
          root.add_child(pi2)
        prev = p
        th3 += (sp[1]-sp[0]) / 14.0
  # windows
  tower.win_rain = []
  for th4 in [1.6, 6.0, 10.9, 15.0]:
    var y4 = floor_at(th4, 99.0) + 2.7
    var wf = 1.9 if abs(th4 - 6.0) < 0.01 else 1.0
    var g = Node3D.new()
    var fr = mat_lam(Color(0.13,0.145,0.18))
    var mk = func(sz, x2, y2):
      var m = box(sz, fr); m.position = Vector3(x2, y2, 0); g.add_child(m)
    mk.call(Vector3(0.22,2.9,0.34), -0.95 * wf, 0)
    mk.call(Vector3(0.22,2.9,0.34), 0.95 * wf, 0)
    mk.call(Vector3(2.1 * wf,0.22,0.34), 0, 1.5)
    mk.call(Vector3(2.3 * wf,0.26,0.34), 0, -1.42)
    var skyq = MeshInstance3D.new()
    var pm = PlaneMesh.new(); pm.size = Vector2(1.75 * wf, 3.1)
    skyq.mesh = pm
    var skym = StandardMaterial3D.new()
    skym.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    skym.albedo_texture = vista if wf > 1.0 else sky
    skyq.material_override = skym
    skyq.position.z = 0.06
    g.add_child(skyq)
    var rainq = MeshInstance3D.new()
    var pm2 = PlaneMesh.new(); pm2.size = Vector2(1.75 * wf, 3.1)
    rainq.mesh = pm2
    var rainm = StandardMaterial3D.new()
    rainm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    rainm.albedo_texture = rain_t
    rainm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    rainm.uv1_scale = Vector3(1, 3, 1)
    rainq.material_override = rainm
    rainq.position.z = 0.10
    g.add_child(rainq)
    tower.win_rain.append(rainm)
    if wf > 1.0:
      var spill = MeshInstance3D.new()
      var spm = PlaneMesh.new(); spm.size = Vector2(3.6, 4.4)
      spill.mesh = spm
      var spmt = StandardMaterial3D.new()
      spmt.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
      spmt.albedo_texture = tower.glow_tex
      spmt.albedo_color = Color(0.62, 0.74, 0.88, 0.4)
      spmt.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
      spmt.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
      spill.material_override = spmt
      spill.rotation.x = -PI / 2.0
      spill.rotation.z = 0.22
      spill.position = Vector3(0.2, -2.62, 2.0)
      g.add_child(spill)
    place_radial(g, th4, 6.97, y4)
    if wf > 1.0:
      g.rotation.y += 0.38  # bay the gallery window toward the climbing approach
    root.add_child(g)

func build_lamp_room(root):
  var lr = Node3D.new()
  lr.position.y = 19.0
  root.add_child(lr)
  tower.lamp_room = lr
  var floor_t = tex_floor()
  var lfm = mat_lam(Color.WHITE, floor_t); lfm.uv1_scale = Vector3(3,3,1)
  var lf = MeshInstance3D.new()
  var dc = CylinderMesh.new(); dc.top_radius = 6.95; dc.bottom_radius = 6.95; dc.height = 0.12
  lf.mesh = dc; lf.material_override = lfm; lf.position.y = -0.06
  lr.add_child(lf)
  var drumm = StandardMaterial3D.new()
  drumm.albedo_color = Color(0.62, 0.76, 0.85, 0.16)
  drumm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  drumm.cull_mode = BaseMaterial3D.CULL_DISABLED
  var drum = MeshInstance3D.new()
  var dm = CylinderMesh.new(); dm.top_radius = 5.3; dm.bottom_radius = 5.3; dm.height = 2.2; dm.radial_segments = 24
  drum.mesh = dm; drum.material_override = drumm; drum.position.y = 1.6
  lr.add_child(drum)
  var mull = mat_lam(Color(0.23,0.20,0.13))
  for k in 12:
    var a = k / 12.0 * TAU2
    var m = box(Vector3(0.09,2.2,0.09), mull)
    m.position = Vector3(5.3*cos(a), 1.6, 5.3*sin(a))
    lr.add_child(m)
  var roof = MeshInstance3D.new()
  var cm = CylinderMesh.new(); cm.top_radius = 0.1; cm.bottom_radius = 5.6; cm.height = 1.8; cm.radial_segments = 24
  roof.mesh = cm; roof.material_override = mat_lam(Color(0.17,0.185,0.227)); roof.position.y = 3.6
  lr.add_child(roof)
  var ped = MeshInstance3D.new()
  var pm = CylinderMesh.new(); pm.top_radius = 0.85; pm.bottom_radius = 1.05; pm.height = 1.05
  ped.mesh = pm; ped.material_override = mat_lam(Color(0.21,0.22,0.27)); ped.position.y = 0.52
  lr.add_child(ped)
  var bronze = mat_lam(Color(0.54,0.42,0.18))
  for ry in [1.35, 2.85]:
    var ring = MeshInstance3D.new()
    var tm = TorusMesh.new(); tm.inner_radius = 1.22; tm.outer_radius = 1.30
    ring.mesh = tm; ring.material_override = bronze
    ring.rotation.x = PI/2.0; ring.position.y = ry
    lr.add_child(ring)
  for k in 12:
    var a2 = k / 12.0 * TAU2
    var bar = box(Vector3(0.06,1.5,0.06), bronze)
    bar.position = Vector3(1.28*cos(a2), 2.1, 1.28*sin(a2))
    lr.add_child(bar)
  # lens panes (flat facets), 5 missing
  tower.lens_panes = []
  var lensmat = StandardMaterial3D.new()
  lensmat.albedo_color = Color(0.97, 0.93, 0.82, 0.55)
  lensmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  lensmat.cull_mode = BaseMaterial3D.CULL_DISABLED
  for k in 12:
    var a3 = k / 12.0 * TAU2
    var p = box(Vector3(0.60, 1.42, 0.045), lensmat.duplicate())
    p.position = Vector3(1.24*cos(a3 + TAU2/24.0), 2.1, 1.24*sin(a3 + TAU2/24.0))
    p.rotation.y = -a3 - TAU2/24.0 - PI/2.0
    if k in MISSING:
      p.visible = false
      var fh = PANE_COLORS[MISSING.find(k) % PANE_COLORS.size()]
      p.material_override.albedo_color = Color(fh.r, fh.g, fh.b, 0.6)
    lr.add_child(p)
    tower.lens_panes.append(p)
  var core = MeshInstance3D.new()
  var sm = SphereMesh.new(); sm.radius = 0.34; sm.height = 0.68
  core.mesh = sm; core.material_override = mat_glow(Color(0.08,0.086,0.11), 1.0)
  core.position.y = 2.1
  lr.add_child(core)
  tower.core = core
  var glow = Sprite3D.new()
  glow.texture = tower.glow_tex
  glow.modulate = Color(1.0, 0.85, 0.63, 0.0)
  glow.scale = Vector3(5,5,1)
  glow.position.y = 2.1
  lr.add_child(glow)
  tower.core_glow = glow
  var lamp = OmniLight3D.new()
  lamp.light_color = Color(1.0, 0.75, 0.42)
  lamp.light_energy = 0.0
  lamp.omni_range = 30.0
  lamp.omni_attenuation = 1.4
  lamp.position.y = 2.2
  lr.add_child(lamp)
  tower.lamp_light = lamp
  # rotating beams
  var bg = Node3D.new()
  bg.position.y = 2.1
  bg.visible = false
  lr.add_child(bg)
  var bm = StandardMaterial3D.new()
  bm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  bm.albedo_color = Color(1.0, 0.94, 0.78, 0.0)
  bm.emission_enabled = true
  bm.emission = Color(1.0, 0.94, 0.78)
  bm.emission_energy_multiplier = 0.8
  bm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  bm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
  bm.cull_mode = BaseMaterial3D.CULL_DISABLED
  bm.disable_fog = true
  bm.albedo_texture = tex_beam()
  bm.emission_texture = bm.albedo_texture
  for d in [1, -1]:
    var cone = MeshInstance3D.new()
    var cc = CylinderMesh.new(); cc.top_radius = 0.35; cc.bottom_radius = 2.6; cc.height = 16; cc.radial_segments = 14
    cone.mesh = cc; cone.material_override = bm
    cone.rotation.z = d * PI/2.0
    cone.position.x = d * 8.0
    bg.add_child(cone)
  tower.beam_group = bg
  tower.beam_mat = bm

func build_shards(root):
  tower.shards = []
  var shardmat = mat_glow(Color(1.0, 0.96, 0.85), 1.2)
  var pi = 0
  for p in panes:
    var hue = PANE_COLORS[pi % PANE_COLORS.size()]
    var g = Node3D.new()
    var pr = MeshInstance3D.new()
    var pm = PrismMesh.new(); pm.size = Vector3(0.5, 0.85, 0.5)
    pr.mesh = pm; pr.material_override = mat_glow(hue, 1.2)
    g.add_child(pr)
    var gl = Sprite3D.new()
    gl.texture = tower.glow_tex
    gl.modulate = Color(hue.r, hue.g, hue.b, 0.85)
    pi += 1
    gl.scale = Vector3(1.7, 1.7, 1)
    g.add_child(gl)
    g.position = Vector3(R_SHELL*cos(p.th), p.y, R_SHELL*sin(p.th))
    root.add_child(g)
    p.node = g
    tower.shards.append(g)

# ---------- keeper ----------
func build_keeper(root):
  var g = Node3D.new()
  var coatm = mat_lam(Color(0.169,0.180,0.227))
  var darkm = mat_lam(Color(0.118,0.125,0.161))
  var coat = MeshInstance3D.new()
  var c1 = CylinderMesh.new(); c1.top_radius = 0.26; c1.bottom_radius = 0.42; c1.height = 0.95; c1.radial_segments = 10
  coat.mesh = c1; coat.material_override = coatm; coat.position.y = 0.85
  g.add_child(coat)
  var chest = MeshInstance3D.new()
  var s2 = SphereMesh.new(); s2.radius = 0.27; s2.height = 0.44
  chest.mesh = s2; chest.material_override = coatm; chest.position.y = 1.32
  g.add_child(chest)
  var head = MeshInstance3D.new()
  var s3 = SphereMesh.new(); s3.radius = 0.19; s3.height = 0.38
  head.mesh = s3; head.material_override = mat_lam(Color(0.54,0.435,0.34)); head.position.y = 1.62
  g.add_child(head)
  var cap = MeshInstance3D.new()
  var c4 = CylinderMesh.new(); c4.top_radius = 0.20; c4.bottom_radius = 0.21; c4.height = 0.14
  cap.mesh = c4; cap.material_override = darkm; cap.position.y = 1.76
  g.add_child(cap)
  var brim = MeshInstance3D.new()
  var c5 = CylinderMesh.new(); c5.top_radius = 0.26; c5.bottom_radius = 0.26; c5.height = 0.03
  brim.mesh = c5; brim.material_override = darkm; brim.position = Vector3(0, 1.70, 0.08)
  g.add_child(brim)
  var legs = []
  for sd in [-1, 1]:
    var legpiv = Node3D.new(); legpiv.position = Vector3(sd*0.13, 0.52, 0)
    var leg = box(Vector3(0.13,0.5,0.16), darkm); leg.position.y = -0.25
    legpiv.add_child(leg); g.add_child(legpiv); legs.append(legpiv)
  var armL = Node3D.new(); armL.position = Vector3(-0.30, 1.35, 0)
  var alm = box(Vector3(0.10,0.5,0.12), coatm); alm.position.y = -0.22; armL.add_child(alm)
  g.add_child(armL)
  var armR = Node3D.new(); armR.position = Vector3(0.30, 1.35, 0); armR.rotation.x = -0.5
  var arm = box(Vector3(0.10,0.5,0.12), coatm); arm.position.y = -0.22; armR.add_child(arm)
  g.add_child(armR)
  var pole = MeshInstance3D.new()
  var pm2 = CylinderMesh.new(); pm2.top_radius = 0.02; pm2.bottom_radius = 0.02; pm2.height = 0.7
  pole.mesh = pm2; pole.material_override = darkm
  pole.position = Vector3(0.36, 1.05, 0.28); pole.rotation.x = 0.5
  g.add_child(pole)
  var lampg = Node3D.new(); lampg.position = Vector3(0.36, 0.72, 0.55)
  var cage = box(Vector3(0.16,0.22,0.16), darkm); lampg.add_child(cage)
  var flame = box(Vector3(0.09,0.13,0.09), mat_glow(Color(1.0,0.85,0.63), 1.4)); lampg.add_child(flame)
  var ltop = MeshInstance3D.new()
  var cm2 = CylinderMesh.new(); cm2.top_radius = 0.02; cm2.bottom_radius = 0.11; cm2.height = 0.09; cm2.radial_segments = 4
  ltop.mesh = cm2; ltop.material_override = darkm; ltop.position.y = 0.16
  lampg.add_child(ltop)
  var lglow = Sprite3D.new(); lglow.texture = tower.glow_tex
  lglow.modulate = Color(1.0, 0.79, 0.54, 0.9); lglow.scale = Vector3(1.1,1.1,1)
  lampg.add_child(lglow)
  g.add_child(lampg)
  root.add_child(g)
  return {g=g, legs=legs, armL=armL, lamp=lampg, lglow=lglow}

# ---------- HUD ----------
var ui = {}
func cream(): return Color(0.957, 0.918, 0.847)
func ink(): return Color(0.141, 0.122, 0.102)
func chip_style():
  var s = StyleBoxFlat.new()
  s.bg_color = Color(0.957, 0.918, 0.847, 0.92)
  s.corner_radius_top_left = 10; s.corner_radius_top_right = 10
  s.corner_radius_bottom_left = 10; s.corner_radius_bottom_right = 10
  s.content_margin_left = 12; s.content_margin_right = 12
  s.content_margin_top = 8; s.content_margin_bottom = 8
  return s
func card_style():
  var s = chip_style()
  s.bg_color = cream()
  s.corner_radius_top_left = 18; s.corner_radius_top_right = 18
  s.corner_radius_bottom_left = 18; s.corner_radius_bottom_right = 18
  s.content_margin_left = 26; s.content_margin_right = 26
  s.content_margin_top = 24; s.content_margin_bottom = 22
  s.shadow_color = Color(0,0,0,0.5); s.shadow_size = 24
  return s
func mk_label(txt, size, col, spacing = 0):
  var l = Label.new()
  l.text = txt
  l.add_theme_font_size_override("font_size", size)
  l.add_theme_color_override("font_color", col)
  if spacing > 0: l.add_theme_constant_override("font_spacing" if false else "outline_size", 0)
  l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  return l
func mk_button(txt):
  var b = Button.new()
  b.text = txt
  var st = StyleBoxFlat.new()
  st.bg_color = ink()
  st.corner_radius_top_left = 12; st.corner_radius_top_right = 12
  st.corner_radius_bottom_left = 12; st.corner_radius_bottom_right = 12
  st.content_margin_left = 28; st.content_margin_right = 28
  st.content_margin_top = 12; st.content_margin_bottom = 12
  b.add_theme_stylebox_override("normal", st)
  b.add_theme_stylebox_override("hover", st)
  b.add_theme_stylebox_override("pressed", st)
  b.add_theme_color_override("font_color", cream())
  b.add_theme_font_size_override("font_size", 14)
  b.custom_minimum_size = Vector2(220, 44)
  return b
func mk_card(title, sub, body, btn):
  var center = CenterContainer.new()
  center.set_anchors_preset(Control.PRESET_FULL_RECT)
  var dim = ColorRect.new()
  dim.color = Color(0.02, 0.027, 0.043, 0.35)
  dim.set_anchors_preset(Control.PRESET_FULL_RECT)
  center.add_child(dim)
  var pc = PanelContainer.new()
  pc.add_theme_stylebox_override("panel", card_style())
  pc.custom_minimum_size = Vector2(340, 0)
  var vb = VBoxContainer.new()
  vb.add_theme_constant_override("separation", 10)
  vb.alignment = BoxContainer.ALIGNMENT_CENTER
  var glyph = Control.new(); glyph.custom_minimum_size = Vector2(64,64)
  glyph.set_script(GlyphDraw)
  vb.add_child(glyph); glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
  var h = mk_label(title, 27, ink()); vb.add_child(h)
  var su = mk_label(sub, 11, Color(0.29,0.26,0.22,0.75)); vb.add_child(su)
  var p = mk_label(body, 13, Color(0.29,0.26,0.22))
  p.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  p.custom_minimum_size = Vector2(280, 0)
  vb.add_child(p)
  vb.add_child(btn); btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
  pc.add_child(vb)
  center.add_child(pc)
  return center

var GlyphDraw = GDScript.new()
func build_hud():
  var src = "extends Control\nfunc _draw():\n\tvar c = Color(0.141,0.122,0.102)\n\tdraw_line(Vector2(26,58),Vector2(29,22),c,2)\n\tdraw_line(Vector2(38,58),Vector2(35,22),c,2)\n\tdraw_line(Vector2(29,22),Vector2(35,22),c,2)\n\tdraw_line(Vector2(24,58),Vector2(40,58),c,2)\n\tdraw_rect(Rect2(27,14,10,8),c,false,2)\n\tdraw_line(Vector2(25,14),Vector2(39,14),c,2)\n\tdraw_line(Vector2(32,6),Vector2(32,14),c,2)\n\tdraw_line(Vector2(37,17),Vector2(54,13),c,1.6)\n\tdraw_line(Vector2(37,19),Vector2(54,21),c,1.6)\n"
  GlyphDraw.source_code = src
  GlyphDraw.reload()
  var layer = CanvasLayer.new()
  add_child(layer)
  ui.layer = layer
  # oil chip
  var oilc = PanelContainer.new()
  oilc.add_theme_stylebox_override("panel", chip_style())
  oilc.set_anchors_preset(Control.PRESET_TOP_LEFT)
  oilc.position = Vector2(12, 12)
  var hb = HBoxContainer.new()
  hb.add_theme_constant_override("separation", 8)
  hb.add_child(mk_label("OIL", 11, ink()))
  var barbg = ColorRect.new(); barbg.color = Color(0.141,0.122,0.102,0.22)
  barbg.custom_minimum_size = Vector2(74, 5)
  var fill = ColorRect.new(); fill.color = Color(0.541,0.353,0.118)
  fill.set_anchors_preset(Control.PRESET_FULL_RECT)
  barbg.add_child(fill)
  fill.anchor_right = 1.0
  hb.add_child(barbg)
  oilc.add_child(hb)
  layer.add_child(oilc)
  ui.oilfill = fill; ui.oilchip = oilc
  # pips
  var pips = HBoxContainer.new()
  pips.add_theme_constant_override("separation", 7)
  pips.set_anchors_preset(Control.PRESET_TOP_RIGHT)
  pips.position = Vector2(-160, 18)
  pips.grow_horizontal = Control.GROW_DIRECTION_BEGIN
  ui.pips = []
  for k in 5:
    var pp = PanelContainer.new()
    var ps = StyleBoxFlat.new()
    ps.bg_color = Color(0.957,0.918,0.847,0.40)
    pp.add_theme_stylebox_override("panel", ps)
    var inner = ColorRect.new()
    var hc = PANE_COLORS[k % PANE_COLORS.size()]
    inner.color = Color(hc.r, hc.g, hc.b, 0.22)
    inner.custom_minimum_size = Vector2(10,10)
    pp.add_child(inner)
    pp.pivot_offset = Vector2(8,8)
    pp.rotation = PI/4.0
    pips.add_child(pp)
    ui.pips.append(inner)
  layer.add_child(pips)
  var pauseb = Button.new()
  pauseb.text = "II"
  var pbs = chip_style()
  pauseb.add_theme_stylebox_override("normal", pbs)
  pauseb.add_theme_stylebox_override("hover", pbs)
  pauseb.add_theme_stylebox_override("pressed", pbs)
  pauseb.add_theme_color_override("font_color", ink())
  pauseb.add_theme_font_size_override("font_size", 11)
  pauseb.custom_minimum_size = Vector2(34, 26)
  pauseb.set_anchors_preset(Control.PRESET_TOP_RIGHT)
  pauseb.position = Vector2(-14, 12)
  pauseb.grow_horizontal = Control.GROW_DIRECTION_BEGIN
  pauseb.pressed.connect(toggle_pause)
  layer.add_child(pauseb)
  ui.pauseb = pauseb
  # toast
  var toastc = PanelContainer.new()
  toastc.add_theme_stylebox_override("panel", chip_style())
  toastc.set_anchors_preset(Control.PRESET_CENTER_TOP)
  toastc.position = Vector2(0, 100)
  toastc.grow_horizontal = Control.GROW_DIRECTION_BOTH
  var tl = mk_label("", 12, ink())
  toastc.add_child(tl)
  toastc.modulate.a = 0
  layer.add_child(toastc)
  ui.toast = toastc; ui.toast_label = tl
  # notch
  var notch = ColorRect.new()
  notch.color = Color(1.0, 0.85, 0.63, 0.0)
  notch.custom_minimum_size = Vector2(14,14)
  notch.size = Vector2(14,14)
  notch.pivot_offset = Vector2(7,7)
  notch.rotation = PI/4.0
  layer.add_child(notch)
  ui.notch = notch
  # dim
  var dimf = ColorRect.new()
  dimf.color = Color(0.02,0.027,0.043,0.0)
  dimf.set_anchors_preset(Control.PRESET_FULL_RECT)
  layer.add_child(dimf)
  ui.dim = dimf
  # touch controls
  var stick = ColorRect.new()
  stick.color = Color(0.957,0.918,0.847,0.14)
  stick.custom_minimum_size = Vector2(118,118); stick.size = Vector2(118,118)
  layer.add_child(stick)
  var knob = ColorRect.new()
  knob.color = Color(0.957,0.918,0.847,0.5)
  knob.custom_minimum_size = Vector2(40,40); knob.size = Vector2(40,40)
  layer.add_child(knob)
  var jumpb = mk_button("JUMP")
  layer.add_child(jumpb)
  ui.stick = stick; ui.knob = knob; ui.jumpb = jumpb
  # cards
  var b1 = mk_button("BEGIN THE CLIMB"); b1.pressed.connect(_on_begin)
  ui.title = mk_card("KEEP THE LIGHT", "A STORM-NIGHT ERRAND",
    "The lamp is out. Five lens panes lie scattered on the stair. Climb, gather them, and relight the light before the oil is gone.", b1)
  layer.add_child(ui.title)
  var b2 = mk_button("KEEP IT AGAIN"); b2.pressed.connect(_on_begin)
  ui.end = mk_card("THE LIGHT HOLDS", "",
    "The beam turns again over black water. Somewhere out in the rain, a ship sets her course for home.", b2)
  ui.end.visible = false
  layer.add_child(ui.end)
  var b3 = mk_button("TRY AGAIN"); b3.pressed.connect(_on_begin)
  ui.fail = mk_card("THE LAMP GUTTERED", "THE OIL RAN OUT ON THE STAIR",
    "The tower goes dark, and the rain keeps what it took. Another can of oil, another climb.", b3)
  ui.fail.visible = false
  layer.add_child(ui.fail)
  var b4 = mk_button("RESUME"); b4.pressed.connect(toggle_pause)
  ui.paused = mk_card("PAUSED", "THE STORM WAITS",
    "WASD or left stick - climb. Mouse or drag - look. SPACE or JUMP - jump. Walk into a pane to take it. ESC - back to the stair.", b4)
  ui.paused.visible = false
  layer.add_child(ui.paused)

# ---------- exterior ending ----------
var EXT = {}
func build_exterior():
  var g = Node3D.new()
  g.visible = false
  add_child(g)
  EXT.root = g
  var sea = MeshInstance3D.new()
  var sp = PlaneMesh.new(); sp.size = Vector2(700,700); sp.subdivide_depth = 4; sp.subdivide_width = 4
  sea.mesh = sp
  var sm = StandardMaterial3D.new()
  sm.albedo_color = Color(0.13, 0.18, 0.25)
  sm.roughness = 0.25; sm.metallic = 0.35
  sea.material_override = sm
  g.add_child(sea)
  # moon glint road: scrolling additive plane
  var road = MeshInstance3D.new()
  var rp = PlaneMesh.new(); rp.size = Vector2(10, 140)
  road.mesh = rp
  var rm = StandardMaterial3D.new()
  rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  rm.albedo_color = Color(0.74, 0.82, 0.91, 0.16)
  rm.emission_enabled = true; rm.emission = Color(0.74,0.82,0.91); rm.emission_energy_multiplier = 0.5
  rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  rm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
  rm.albedo_texture = tex_rain_streaks()
  rm.uv1_scale = Vector3(1, 6, 1)
  road.material_override = rm
  road.rotation.x = -PI/2.0; road.rotation.z = 0.18
  road.position = Vector3(-46, 0.35, -90)
  g.add_child(road)
  EXT.road_mat = rm
  # moon + halo (unfogged unshaded quads)
  for spec in [[20.0, 0.93, 0.95, 0.98, 0.95], [60.0, 0.62, 0.71, 0.85, 0.22]]:
    var q = MeshInstance3D.new()
    var qp = PlaneMesh.new(); qp.size = Vector2(spec[0], spec[0])
    q.mesh = qp
    var qm = StandardMaterial3D.new()
    qm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    qm.albedo_color = Color(1,1,1,spec[4])
    qm.albedo_texture = tower.glow_tex
    qm.emission_enabled = true
    qm.emission = Color(spec[1], spec[2], spec[3])
    qm.emission_energy_multiplier = 1.2
    qm.emission_texture = tower.glow_tex
    qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    qm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
    qm.disable_fog = true
    q.material_override = qm
    q.position = Vector3(-40, 34, -120)
    g.add_child(q)
  # stars
  var stars = ImmediateMesh.new()
  stars.surface_begin(Mesh.PRIMITIVE_POINTS, mat_glow(Color(0.8,0.85,0.92), 0.8))
  for k in 240:
    stars.surface_add_vertex(Vector3(randf_range(-260,260), randf_range(20,180), randf_range(-280,-40)))
  stars.surface_end()
  var stmi = MeshInstance3D.new(); stmi.mesh = stars
  var stmat = stmi.material_override
  g.add_child(stmi)
  # tower silhouette + light
  var tw = Node3D.new(); tw.position = Vector3(20, 0, -42); g.add_child(tw)
  var bodym = mat_lam(Color(0.067,0.082,0.114))
  var body = MeshInstance3D.new()
  var bm2 = CylinderMesh.new(); bm2.top_radius = 2.2; bm2.bottom_radius = 3.0; bm2.height = 26; bm2.radial_segments = 14
  body.mesh = bm2; body.material_override = bodym; body.position.y = 13
  tw.add_child(body)
  var gal = MeshInstance3D.new()
  var gm = CylinderMesh.new(); gm.top_radius = 3.0; gm.bottom_radius = 3.0; gm.height = 0.4
  gal.mesh = gm; gal.material_override = bodym; gal.position.y = 26
  tw.add_child(gal)
  var glass = MeshInstance3D.new()
  var gm2 = CylinderMesh.new(); gm2.top_radius = 2.3; gm2.bottom_radius = 2.3; gm2.height = 2.8; gm2.radial_segments = 14
  glass.mesh = gm2
  var glm = mat_glow(Color(1.0, 0.77, 0.42), 1.2, 0.55)
  glm.cull_mode = BaseMaterial3D.CULL_DISABLED
  glass.material_override = glm; glass.position.y = 27.6
  tw.add_child(glass)
  var dome = MeshInstance3D.new()
  var dm3 = CylinderMesh.new(); dm3.top_radius = 0.1; dm3.bottom_radius = 2.8; dm3.height = 2.2; dm3.radial_segments = 14
  dome.mesh = dm3; dome.material_override = bodym; dome.position.y = 30
  tw.add_child(dome)
  var lg = Sprite3D.new(); lg.texture = tower.glow_tex
  lg.modulate = Color(1.0,0.85,0.63,0.95); lg.scale = Vector3(16,16,1); lg.position.y = 27.6
  tw.add_child(lg)
  var lp = OmniLight3D.new(); lp.light_color = Color(1.0,0.75,0.42); lp.light_energy = 6.0
  lp.omni_range = 220; lp.omni_attenuation = 0.7; lp.position.y = 27.6
  tw.add_child(lp)
  var beams = Node3D.new(); beams.position.y = 27.6; tw.add_child(beams)
  var ebm = StandardMaterial3D.new()
  ebm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  ebm.albedo_color = Color(1.0,0.94,0.78,0.5)
  ebm.emission_enabled = true; ebm.emission = Color(1.0,0.94,0.78); ebm.emission_energy_multiplier = 0.9
  ebm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  ebm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
  ebm.cull_mode = BaseMaterial3D.CULL_DISABLED
  ebm.disable_fog = true
  ebm.albedo_texture = tex_beam()
  ebm.emission_texture = ebm.albedo_texture
  ebm.albedo_color = Color(1.0,0.94,0.78,0.35)
  for d in [1,-1]:
    var c = MeshInstance3D.new()
    var cc = CylinderMesh.new(); cc.top_radius = 1.2; cc.bottom_radius = 9; cc.height = 90; cc.radial_segments = 14
    c.mesh = cc; c.material_override = ebm
    c.rotation.z = d * PI/2.0; c.position.x = d * 45
    beams.add_child(c)
  EXT.beams = beams
  # rocks, each with a breathing surf-foam ring at its base
  EXT.foam = []
  for k in 5:
    var rk = MeshInstance3D.new()
    var rrad = randf_range(3,7)
    var rc = CylinderMesh.new(); rc.top_radius = 0.2; rc.bottom_radius = rrad; rc.height = randf_range(3,8); rc.radial_segments = 7
    rk.mesh = rc; rk.material_override = mat_lam(Color(0.055,0.07,0.094))
    rk.position = Vector3(randf_range(-30,45), 0, randf_range(-60,-25))
    g.add_child(rk)
    var fq = MeshInstance3D.new()
    var fp = PlaneMesh.new(); fp.size = Vector2(rrad * 3.0, rrad * 3.0)
    fq.mesh = fp
    var fm = StandardMaterial3D.new()
    fm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    fm.albedo_color = Color(0.72, 0.80, 0.88, 0.14)
    fm.emission_enabled = true; fm.emission = Color(0.72, 0.80, 0.88); fm.emission_energy_multiplier = 0.4
    fm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    fm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
    fm.albedo_texture = tower.glow_tex
    fq.material_override = fm
    fq.rotation.x = -PI / 2.0
    fq.position = Vector3(rk.position.x, 0.28, rk.position.z)
    g.add_child(fq)
    EXT.foam.append(fm)
  # moonlight rim: a soft blue key from the moon so the tower reads as form, not cutout
  var mrim = DirectionalLight3D.new()
  mrim.light_color = Color(0.62, 0.72, 0.88)
  mrim.light_energy = 0.5
  mrim.position = Vector3(-40, 34, -120)
  g.add_child(mrim)
  mrim.look_at(Vector3(20, 12, -42), Vector3.UP)
  # rain (immediate lines, rebuilt each frame)
  var rainmi = MeshInstance3D.new()
  rainmi.mesh = ImmediateMesh.new()
  rainmi.material_override = mat_glow(Color(0.56,0.65,0.76), 0.5, 0.4)
  g.add_child(rainmi)
  EXT.rain_mesh = rainmi.mesh
  EXT.rain_mat = rainmi.material_override
  EXT.rain_drops = []
  for k in 300:
    EXT.rain_drops.append(Vector3(randf_range(-50,70), randf_range(0,45), randf_range(-80,20)))
  # clouds
  EXT.clouds = []
  for k in 6:
    var c2 = MeshInstance3D.new()
    var cp = PlaneMesh.new(); cp.size = Vector2(randf_range(30,60), randf_range(6,11))
    c2.mesh = cp
    c2.material_override = mat_glow(Color(0.05,0.078,0.125), 1.0, 0.85)
    c2.position = Vector3(randf_range(-90,90), randf_range(28,48), randf_range(-140,-80))
    g.add_child(c2)
    EXT.clouds.append(c2)
  # ship
  var ship = Node3D.new()
  var hull = MeshInstance3D.new()
  var hm = CylinderMesh.new(); hm.top_radius = 1.1; hm.bottom_radius = 0.5; hm.height = 5.2; hm.radial_segments = 6
  hull.mesh = hm; hull.material_override = mat_lam(Color(0.078,0.102,0.141))
  hull.rotation.z = PI/2.0; hull.position.y = 0.8
  ship.add_child(hull)
  var cab = box(Vector3(1.6,1.1,1.2), mat_lam(Color(0.102,0.133,0.188)))
  cab.position = Vector3(-0.4, 1.6, 0); ship.add_child(cab)
  var mast = MeshInstance3D.new()
  var mm4 = CylinderMesh.new(); mm4.top_radius = 0.06; mm4.bottom_radius = 0.06; mm4.height = 4.4
  mast.mesh = mm4; mast.material_override = mat_lam(Color(0.063,0.086,0.125)); mast.position = Vector3(0.8, 3, 0)
  ship.add_child(mast)
  var win = Sprite3D.new(); win.texture = tower.glow_tex
  win.modulate = Color(1.0,0.79,0.54,0.9); win.scale = Vector3(0.9,0.9,1); win.position = Vector3(-0.4,1.7,0.7)
  ship.add_child(win)
  ship.position = Vector3(-58, 0, -105)
  g.add_child(ship)
  EXT.ship = ship; EXT.ship_vx = 3.0; EXT.ship_turn = 0.0; EXT.belled = false

# ---------- state, input, loop ----------
var ST = {phase="title", th=0.0, y=0.0, vy=0.0, grounded=true, coyote=0.0, oil=80.0,
  panes=0, elapsed=0.0, faceDir=1, walkPh=0.0, stepT=0.0, relightT=0.0, lowWarned=false, gust_v=0.0,
  warnedTop=false, endT=0.0}
var keeper = {}
var cam = Camera3D.new()
var wenv = WorldEnvironment.new()
var env_tower = Environment.new()
var env_ext = Environment.new()
var flash_light = DirectionalLight3D.new()
var lantern = OmniLight3D.new()
var flashV = 0.0
var camTh = 0.0
var camY = 2.5
var camRcur = 0.4
var phase2T = 0.0
var fly = []
var keys = {}
var jumpBuf = 0.0
var stick_id = -1
var stick_x = 0.0
var stick_origin = Vector2.ZERO
var is_touch = false
var toast_t = 0.0
var thunder_t = 7.0
var gust_t = 6.0
var gust_vis = 0.0
var horn_t = 24.0
var thunder_pending = -1.0
var thunder_vol = -8.0
var thunder_pitch = 1.0
var flash2_armed = false
var title_t = 0.0
var stat_t = 0.0

func press_jump(): jumpBuf = 0.12

func _ready():
  randomize()
  if OS.has_feature("web"):
    var q = str(JavaScriptBridge.eval("window.location.search"))
    AUTO = "auto=1" in q
    FAST = "fast=1" in q
    var mo = q.find("startoil=")
    if mo >= 0: START_OIL = clamp(q.substr(mo + 9, 4).to_float(), 5.0, 80.0)
    GUSTHOLD = "gusthold=1" in q
    DOORSHUT = "doorshut=1" in q
    DOOROPEN = "dooropen=1" in q
  else:
    var args = OS.get_cmdline_user_args()
    AUTO = "--auto" in args
    FAST = "--fast" in args
  is_touch = DisplayServer.is_touchscreen_available()
  build_audio()
  loop_sfx("rain", -13.0)
  loop_sfx("wind", -17.0)
  loop_sfx("surf", -20.0)
  panes = pane_pos_list()
  # tower environment
  env_tower.background_mode = Environment.BG_COLOR
  env_tower.background_color = Color(0.047, 0.067, 0.098)
  env_tower.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
  env_tower.ambient_light_color = Color(0.576, 0.643, 0.769)
  env_tower.ambient_light_energy = 0.75
  env_tower.fog_enabled = true
  env_tower.fog_mode = Environment.FOG_MODE_EXPONENTIAL
  env_tower.fog_density = 0.018
  env_tower.fog_light_color = Color(0.047, 0.067, 0.098)
  env_tower.tonemap_mode = Environment.TONE_MAPPER_ACES
  env_tower.adjustment_enabled = true
  env_tower.adjustment_brightness = 1.14
  env_ext.background_mode = Environment.BG_COLOR
  env_ext.background_color = Color(0.039, 0.059, 0.094)
  env_ext.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
  env_ext.ambient_light_color = Color(0.45, 0.53, 0.66)
  env_ext.ambient_light_energy = 0.5
  env_ext.fog_enabled = true
  env_ext.fog_mode = Environment.FOG_MODE_EXPONENTIAL
  env_ext.fog_density = 0.010
  env_ext.fog_light_color = Color(0.039, 0.059, 0.094)
  env_ext.tonemap_mode = Environment.TONE_MAPPER_ACES
  wenv.environment = env_tower
  add_child(wenv)
  var hemi_moon = DirectionalLight3D.new()
  hemi_moon.light_color = Color(0.729, 0.788, 0.910)
  hemi_moon.light_energy = 0.7
  hemi_moon.rotation = Vector3(-0.9, 0.5, 0)
  add_child(hemi_moon)
  flash_light.light_color = Color(0.894, 0.925, 1.0)
  flash_light.light_energy = 0.0
  flash_light.rotation = Vector3(-0.8, 0.3, 0)
  add_child(flash_light)
  lantern.light_color = Color(1.0, 0.69, 0.40)
  lantern.light_energy = 2.2
  lantern.omni_range = 14.0
  lantern.omni_attenuation = 1.6
  add_child(lantern)
  tower_root = Node3D.new()
  add_child(tower_root)
  build_tower(tower_root)
  build_lamp_room(tower_root)
  build_shards(tower_root)
  keeper = build_keeper(tower_root)
  build_exterior()
  build_hud()
  cam.far = 700
  add_child(cam)
  cam.current = true
  layout_hud()
  get_viewport().size_changed.connect(layout_hud)
  var bt = best_time()
  if bt > 0.0:
    var tl = []
    _collect_labels(ui.title, tl)
    if tl.size() > 1: tl[1].text = "A STORM-NIGHT ERRAND - BEST " + fmt_time(bt)
  ui.title.modulate.a = 0.0
  var etw = create_tween()
  etw.tween_property(ui.title, "modulate:a", 1.0, 0.9).set_delay(0.15)
  print("[KTL] ready")
  if AUTO:
    await get_tree().create_timer(0.4).timeout
    reset_run()

func layout_hud():
  var vs = get_viewport().get_visible_rect().size
  ui.stick.visible = is_touch
  ui.knob.visible = is_touch
  ui.jumpb.visible = is_touch
  ui.stick.position = Vector2(26, vs.y - 152)
  ui.knob.position = ui.stick.position + Vector2(39, 39)
  ui.jumpb.position = Vector2(vs.x - 26 - 96, vs.y - 44 - 96)
  ui.jumpb.custom_minimum_size = Vector2(96, 96)
  ui.jumpb.size = Vector2(96, 96)
  cam.fov = 68 if vs.x / vs.y < 0.75 else (62 if vs.x / vs.y < 1.05 else 55)

func toggle_pause():
  if ST.phase == "play":
    ST.phase = "pause"
    ui.paused.visible = true
  elif ST.phase == "pause":
    ST.phase = "play"
    ui.paused.visible = false

func pause_chip_hit(pos):
  var vs3 = get_viewport().get_visible_rect().size
  return (pos - Vector2(vs3.x - 31.0, 25.0)).length() < 30.0

func _input(ev):
  if ev is InputEventKey:
    keys[ev.physical_keycode] = ev.pressed
    if ev.pressed and ev.physical_keycode == KEY_SPACE: press_jump()
    if ev.pressed and ev.physical_keycode == KEY_ESCAPE: toggle_pause()
  if ev is InputEventMouseButton and ev.pressed and pause_chip_hit(ev.position):
    toggle_pause()
  if ev is InputEventScreenTouch:
    if ev.pressed:
      var vs = get_viewport().get_visible_rect().size
      if pause_chip_hit(ev.position):
        toggle_pause()
      elif ev.position.x < vs.x * 0.45 and stick_id == -1:
        stick_id = ev.index
        stick_origin = ev.position
        is_touch = true
        layout_hud()
      elif (ev.position - ui.jumpb.position - Vector2(48,48)).length() < 70:
        press_jump()
    else:
      if ev.index == stick_id:
        stick_id = -1
        stick_x = 0.0
  if ev is InputEventScreenDrag and ev.index == stick_id:
    stick_x = clamp((ev.position.x - stick_origin.x) / 55.0, -1.0, 1.0)
    ui.knob.position = ui.stick.position + Vector2(39, 39) + Vector2(stick_x * 32, 0)

func _on_begin():
  reset_run()

func toast(msg):
  ui.toast_label.text = msg
  ui.toast.modulate.a = 1.0
  toast_t = 1.8

func reset_run():
  ST.phase = "play"; ST.th = 0.0; ST.y = 0.0; ST.vy = 0.0; ST.grounded = true
  # the door swings shut behind the keeper - the night is outside now
  if tower.has("door_panel"):
    tower.door_panel.rotation.y = 0.5
    if DOORSHUT:  # debug: skip the swing for capture
      tower.door_panel.rotation.y = 0.0
    if not DOOROPEN:  # DOOROPEN holds the door ajar for capture
      var dtw = create_tween()
      dtw.tween_interval(0.35)
      dtw.tween_property(tower.door_panel, "rotation:y", 0.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
      dtw.tween_callback(func(): sfx("land", -13.0, 0.62); print("[KTL] door shut"))
  ST.oil = START_OIL; ST.panes = 0; ST.elapsed = 0.0; ST.lowWarned = false; ST.warnedTop = false
  ST.relightT = 0.0; ST.endT = 0.0; phase2T = 0.0; fly.clear()
  ST.gust_v = 0.0; gust_t = 6.0
  for i in panes.size():
    panes[i].got = false
    panes[i].node.visible = true
    var hc2 = PANE_COLORS[i % PANE_COLORS.size()]
    ui.pips[i].color = Color(hc2.r, hc2.g, hc2.b, 0.22)
  for k in tower.lens_panes.size():
    tower.lens_panes[k].visible = not (k in MISSING)
    tower.lens_panes[k].material_override.emission_enabled = false
  tower.core.material_override = mat_glow(Color(0.08,0.086,0.11), 1.0)
  tower.core_glow.modulate.a = 0.0
  tower.lamp_light.light_energy = 0.0
  tower.beam_group.visible = false
  tower.beam_mat.albedo_color.a = 0.0
  ui.dim.color.a = 0.0
  ui.title.visible = false; ui.end.visible = false; ui.fail.visible = false
  EXT.root.visible = false
  tower_root.visible = true
  lantern.visible = true
  wenv.environment = env_tower
  if players.has("drone"): players.drone.stop()
  print("[KTL] begin")

func ignite():
  sfx("ignite", -4.0)
  loop_sfx("drone", -16.0)
  tower.core.material_override = mat_glow(Color(1.0,0.91,0.72), 2.2)
  tower.core_glow.modulate.a = 0.95
  tower.lamp_light.light_energy = 5.5
  for p in tower.lens_panes:
    p.material_override.emission_enabled = true
    p.material_override.emission = Color(1.0, 0.79, 0.48)
    p.material_override.emission_energy_multiplier = 0.9
  tower.beam_group.visible = true
  flashV = 1.0
  print("[KTL] ignite")

func start_relight():
  ST.phase = "relight"
  ST.relightT = 0.0
  toast("THE LENS IS WHOLE")
  var idx = 0
  for slot in MISSING:
    var pr = MeshInstance3D.new()
    var pm = PrismMesh.new(); pm.size = Vector3(0.5, 0.85, 0.5)
    pr.mesh = pm; pr.material_override = mat_glow(Color(1.0,0.96,0.85), 1.2)
    pr.position = keeper.g.position + Vector3(0, 1.2, 0)
    add_child(pr)
    fly.append({mesh=pr, t0=0.55 + idx*0.5, slot=slot, done=false})
    idx += 1

func fail_run():
  ST.phase = "fail"
  sfx("gutter", -4.0)
  var tw = create_tween()
  tw.tween_property(ui.dim, "color:a", 0.92, 1.2)
  # the lamp gutters out in visible throes before the dark takes the stair
  var ltw = create_tween()
  ltw.tween_property(lantern, "light_energy", 0.3, 0.3)
  ltw.tween_property(lantern, "light_energy", 1.1, 0.07)
  ltw.tween_property(lantern, "light_energy", 0.12, 0.22)
  ltw.tween_property(lantern, "light_energy", 0.65, 0.06)
  ltw.tween_property(lantern, "light_energy", 0.0, 0.45)
  await get_tree().create_timer(1.3).timeout
  lantern.visible = false
  keeper.lglow.modulate.a = 0.0
  # the fail card owns up to how close the climb got
  var flabels = []
  _collect_labels(ui.fail, flabels)
  if flabels.size() > 1:
    flabels[1].text = "THE OIL RAN OUT ON THE STAIR - " + str(ST.panes) + " OF 5 PANES LIT"
  if ST.phase == "fail": ui.fail.visible = true
  print("[KTL] fail panes=", ST.panes)

func best_time():
  if not OS.has_feature("web"): return 0.0
  var v = JavaScriptBridge.eval("localStorage.getItem('ktl_best')||''")
  return float(v) if str(v) != "" else 0.0

func win_run():
  ST.phase = "won"
  var prev = best_time()
  var is_best = OS.has_feature("web") and (prev <= 0.0 or ST.elapsed < prev)
  if is_best:
    JavaScriptBridge.eval("localStorage.setItem('ktl_best','" + str(ST.elapsed) + "')")
    print("[KTL] new best ", fmt_time(ST.elapsed))
  var sub = ui.end.find_child("", true, false)
  var labels = []
  _collect_labels(ui.end, labels)
  if labels.size() > 1:
    if is_best:
      labels[1].text = "THE CLIMB TOOK " + fmt_time(ST.elapsed) + " - A NEW BEST"
    elif prev > 0.0:
      labels[1].text = "THE CLIMB TOOK " + fmt_time(ST.elapsed) + " - BEST " + fmt_time(prev)
    else:
      labels[1].text = "THE CLIMB TOOK " + fmt_time(ST.elapsed) + " - 5 PANES"
  ui.end.visible = true
  print("[KTL] won elapsed=", ST.elapsed, " is_best=", is_best)

func _collect_labels(n, out):
  for c in n.get_children():
    if c is Label: out.append(c)
    _collect_labels(c, out)

func fmt_time(t):
  var m = int(t) / 60
  var s = int(t) % 60
  return str(m) + ":" + ("0" if s < 10 else "") + str(s)

func auto_dir():
  if ST.phase != "play": return 0.0
  var target = 20.4
  for p in panes:
    if not p.got:
      target = p.th
      break
  var d = target - ST.th
  var dir = 0.0
  if abs(d) > 0.06: dir = sign(d)
  if ST.grounded and dir > 0:
    var ahead = floor_at(ST.th + 0.35, ST.y + 0.3)
    if ST.y - ahead > 0.9: press_jump()
  return dir

var trace_t = 0.0
func _process(dt):
  dt = min(dt, 0.05) * (3.0 if FAST else 1.0)
  if AUTO:
    trace_t += dt
    if trace_t > 2.0:
      trace_t = 0.0
      print("[KTL] trace phase=", ST.phase, " th=", snapped(ST.th,0.01), " y=", snapped(ST.y,0.01), " oil=", int(ST.oil), " panes=", ST.panes)
  var t_now = Time.get_ticks_msec() / 1000.0
  # thunder + lightning: the flash comes first, the rumble arrives late by
  # distance (near strike = short gap, louder, sharper; far = long gap, soft, low)
  # storm escalation: the higher the climb, the worse the storm. Strikes come
  # more often and the wind swell rises with altitude (still soft - sound bar).
  var storm_h = clamp(ST.y / 19.0, 0.0, 1.0)
  thunder_t -= dt
  if thunder_t <= 0:
    thunder_t = randf_range(lerp(7.0, 3.2, storm_h), lerp(16.0, 7.5, storm_h))
    flashV = 1.0
    flash2_armed = true
    var dist = randf()
    thunder_pending = 0.5 + dist * 1.7
    thunder_vol = -8.0 - dist * 6.0
    thunder_pitch = 1.05 - dist * 0.2
    print("[KTL] lightning delay=", snapped(thunder_pending, 0.01), " next=", snapped(thunder_t, 0.01), " h=", snapped(storm_h, 0.01))
  if players.has("wind"):
    players.wind.volume_db = -17.0 + 4.0 * storm_h
  # wind gusts push the keeper along the stair - the storm you feel, stronger
  # with altitude. Modest next to walk speed (OMEGA 1.2), so it costs footing
  # and seconds, never control.
  gust_t -= dt
  if gust_t <= 0 and ST.phase == "play":
    gust_t = randf_range(lerp(11.0, 6.0, storm_h), lerp(17.0, 9.0, storm_h))
    ST.gust_v = randf_range(0.25, 0.5) * (0.4 + 0.6 * storm_h) * (1.0 if randf() < 0.5 else -1.0)
    sfx("gust", -13.0 + 2.0 * storm_h, randf_range(0.9, 1.1))
    gust_vis = 1.0
    print("[KTL] gust v=", snapped(ST.gust_v, 0.01), " h=", snapped(storm_h, 0.01))
  # distant foghorn, rare and soft - the world beyond the tower
  horn_t -= dt
  if horn_t <= 0 and ST.phase in ["title", "play", "relight"]:
    horn_t = randf_range(40.0, 75.0)
    sfx("horn", -18.0, randf_range(0.94, 1.0))
    print("[KTL] horn")
  if thunder_pending > 0.0:
    thunder_pending -= dt
    if thunder_pending <= 0.0:
      sfx("thunder", thunder_vol, thunder_pitch)
      print("[KTL] thunder vol=", int(thunder_vol))
  if flash2_armed and flashV < 0.45:
    flashV = max(flashV, 0.6)  # second strobe of the same strike
    flash2_armed = false
  if flashV > 0.01: flashV *= pow(0.02, dt)
  else: flashV = 0.0
  flash_light.light_energy = flashV * 2.0
  # window rain scroll
  gust_vis *= pow(0.1, dt)
  if GUSTHOLD and ST.phase == "play": gust_vis = 1.0  # debug: hold the gust visuals for capture
  for m in tower.win_rain:
    m.uv1_offset.y += dt * 0.9 * (1.0 + 1.4 * gust_vis)
    m.uv1_offset.x += dt * 0.55 * gust_vis
  # toast fade
  if toast_t > 0:
    toast_t -= dt
    if toast_t <= 0: ui.toast.modulate.a = 0

  if ST.phase == "title":
    title_t += dt
    camTh += dt * 0.05
    cam.position = Vector3(cos(camTh) * 2.2, 2.6 + sin(t_now * 0.3) * 0.4, sin(camTh) * 2.2)
    cam.look_at(Vector3(cos(1.1)*5.6, 2.0, sin(1.1)*5.6), Vector3.UP)
    return

  if ST.phase == "pause":
    return

  if ST.phase == "play" or ST.phase == "relight":
    var dir = 0.0
    if ST.phase == "play":
      if keys.get(KEY_A, false) or keys.get(KEY_LEFT, false): dir -= 1
      if keys.get(KEY_D, false) or keys.get(KEY_RIGHT, false): dir += 1
      if abs(stick_x) > 0.15: dir = stick_x
      if AUTO: dir = auto_dir()
    var OMEGA = 1.2
    var gv = ST.gust_v if ST.phase == "play" else 0.0
    ST.th = max(0.0, ST.th + (dir * OMEGA + gv) * dt)
    ST.gust_v = move_toward(ST.gust_v, 0.0, dt * 0.9)
    if dir != 0:
      ST.faceDir = sign(dir)
      ST.walkPh += dt * 9
      ST.stepT -= dt
      if ST.grounded and ST.stepT <= 0:
        sfx("step", -14.0)
        ST.stepT = 0.30
    var fl = floor_at(ST.th, ST.y)
    if ST.grounded:
      if fl < ST.y - 0.55:
        ST.grounded = false; ST.vy = 0.0; ST.coyote = 0.10
      else:
        ST.y = fl
    if not ST.grounded:
      ST.coyote -= dt
      ST.vy -= 24.0 * dt
      ST.y += ST.vy * dt
      var fl2 = floor_at(ST.th, ST.y + 0.3)
      if ST.vy <= 0 and ST.y <= fl2:
        ST.y = fl2; ST.vy = 0.0; ST.grounded = true
        sfx("land", -10.0)
    if jumpBuf > 0:
      jumpBuf -= dt
      if ST.grounded or ST.coyote > 0:
        ST.grounded = false; ST.coyote = 0.0; ST.vy = 8.4; jumpBuf = 0.0
        sfx("jump", -10.0)
    if ST.phase == "play":
      ST.elapsed += dt
      ST.oil -= dt
      if ST.oil < 16 and not ST.lowWarned:
        ST.lowWarned = true
        toast("THE OIL IS LOW")
        ui.oilfill.color = Color(0.69, 0.227, 0.133)
        sfx("gutter", -15.0, 1.35)  # a quiet cough from the lamp
        print("[KTL] lowoil")
      if ST.oil <= 0:
        ST.oil = 0
        fail_run()
    ui.oilfill.anchor_right = clamp(ST.oil / 80.0, 0.0, 1.0)
    ui.oilfill.modulate.a = 0.55 + 0.45 * (0.5 + 0.5 * sin(t_now * 6.0)) if ST.oil < 16.0 else 1.0
    # pane pickup
    if ST.phase == "play":
      var px = R_SHELL * cos(ST.th); var pz = R_SHELL * sin(ST.th)
      for i in panes.size():
        var p = panes[i]
        if p.got: continue
        var d2 = Vector2(px - p.node.position.x, pz - p.node.position.z).length_squared() + pow(ST.y + 1.0 - p.node.position.y, 2)
        if d2 < 1.5:
          p.got = true
          p.node.visible = false
          ST.panes += 1
          ST.oil = min(ST.oil + 5.0, 95.0)
          ui.pips[i].color = PANE_COLORS[i % PANE_COLORS.size()]
          sfx("chime" + str(ST.panes), -6.0)
          toast("THE LAST PANE" if ST.panes == 5 else "PANE RECOVERED - +5S OIL")
          print("[KTL] pane ", ST.panes, " chime=chime", ST.panes, " th=", snapped(ST.th,0.1), " y=", snapped(ST.y,0.1))
      if ST.th >= 19.35:
        if ST.panes >= 5:
          start_relight()
        elif not ST.warnedTop:
          ST.warnedTop = true
          toast("THE LENS IS SHORT " + str(5 - ST.panes) + " PANES")
          await get_tree().create_timer(2.6).timeout
          ST.warnedTop = false
    # keeper pose
    var kg = keeper.g
    kg.position = Vector3(R_SHELL * cos(ST.th), ST.y, R_SHELL * sin(ST.th))
    kg.rotation.y = -ST.th - PI/2.0 + (PI/2.0 if ST.faceDir > 0 else -PI/2.0)
    var wob = abs(sin(ST.walkPh)) if ST.grounded else 0.0
    kg.position.y += wob * 0.05
    var sw = sin(ST.walkPh) * 0.7 * (1.0 if dir != 0 and ST.grounded else 0.0)
    keeper.legs[0].rotation.x = sw
    keeper.legs[1].rotation.x = -sw
    keeper.armL.rotation.x = -sin(ST.walkPh) * 0.4 * (1.0 if dir != 0 else 0.0)
    keeper.lamp.position.y = 0.72 + sin(ST.walkPh * 0.5) * 0.05
    keeper.lamp.rotation.z = sin(ST.walkPh * 0.5 + 1.0) * 0.18 * sign(ST.faceDir)
    var lp = keeper.lamp.global_position
    lantern.global_position = lp
    var oil_frac = clamp(ST.oil / 80.0, 0.0, 1.0)
    var flick = 1.0 + sin(t_now*13.0)*0.06 + sin(t_now*31.0)*0.04 + (sin(t_now*47.0)*0.15 if oil_frac < 0.2 else 0.0)
    lantern.light_energy = (0.9 + 1.6 * oil_frac) * flick * (1.0 - 0.3 * gust_vis)
    keeper.lglow.modulate.a = 0.5 + 0.4 * oil_frac * flick
    # shards shimmer
    for i2 in tower.shards.size():
      var s2 = tower.shards[i2]
      if not s2.visible: continue
      s2.rotation.y += dt * 1.4
      s2.position.y = panes[i2].y + sin(t_now * 2.0 + i2) * 0.10
      s2.get_child(1).modulate.a = 0.65 + sin(t_now * 3.0 + i2 * 2.0) * 0.25
    # notch
    var next = null
    for p3 in panes:
      if not p3.got: next = p3; break
    if next != null and ST.phase == "play" and cam.is_position_behind(next.node.position) == false:
      var sp = cam.unproject_position(next.node.position)
      var vs = get_viewport().get_visible_rect().size
      var off = sp.x < 30 or sp.x > vs.x - 30 or sp.y < 30 or sp.y > vs.y - 30
      if off:
        ui.notch.position = Vector2(clamp(sp.x, 30.0, vs.x - 44.0), clamp(sp.y, 30.0, vs.y - 44.0))
        ui.notch.color.a = 0.5 + sin(t_now * 4.0) * 0.3
      else:
        ui.notch.color.a = 0
    else:
      ui.notch.color.a = 0
    # camera
    var desired = ST.th - 0.5 * ST.faceDir
    var zw = 0.0
    if ST.phase == "play":
      zw = 1.0 - clamp(abs(ST.th - 6.0) / 0.85, 0.0, 1.0)
    if zw > 0.0:
      desired = ST.th - (0.5 + 0.7 * zw) * ST.faceDir  # ease wide at the gallery window
    camTh = lerp(camTh, desired, 1.0 - pow(0.001, dt))
    camY = lerp(camY, ST.y + 2.4, 1.0 - pow(0.001, dt))
    var at_top = ST.y > 18.2
    var vs2 = get_viewport().get_visible_rect().size
    var base_r = 0.1 if vs2.x / vs2.y < 0.9 else 0.4
    camRcur = lerp(camRcur, 4.1 if at_top else base_r, 1.0 - pow(0.002, dt))
    if ST.phase == "relight":
      var ca = ST.th + PI
      cam.position = Vector3(4.7 * cos(ca), lerp(camY, 21.7, 0.05), 4.7 * sin(ca))
      cam.look_at(Vector3(0, 20.6, 0), Vector3.UP)
    else:
      cam.position = Vector3(camRcur * cos(camTh), camY, camRcur * sin(camTh))
      var lookt = Vector3(cos(ST.th) * 5.2, ST.y + 1.35, sin(ST.th) * 5.2)
      if zw > 0.0:
        var wt = Vector3(6.97 * cos(6.0), floor_at(6.0, 99.0) + 2.3, 6.97 * sin(6.0))
        lookt = lookt.lerp(wt, zw * 0.55)
      cam.look_at(lookt, Vector3.UP)
    if flashV > 0.4: cam.position.y += sin(t_now * 80.0) * 0.05 * flashV
    # relight cutscene
    if ST.phase == "relight":
      ST.relightT += dt
      var all_done = true
      for f in fly:
        var ft = (ST.relightT - f.t0) / 0.9
        if ft < 0:
          all_done = false
          continue
        if ft >= 1:
          if not f.done:
            f.done = true
            f.mesh.queue_free()
            sfx("clink", -8.0, 1.0 + (f.slot % 5) * 0.12)
            tower.lens_panes[f.slot].visible = true
          continue
        all_done = false
        var sa = f.slot / 12.0 * TAU2 + TAU2 / 24.0
        var target = Vector3(1.24 * cos(sa), 19.0 + 2.1, 1.24 * sin(sa))
        f.mesh.position = f.mesh.position.lerp(target, 1.0 - pow(0.002, dt))
        f.mesh.rotation.y += dt * 6.0
      if all_done and ST.relightT > 3.4 and tower.lamp_light.light_energy == 0.0:
        ignite()
      if tower.lamp_light.light_energy > 0.0:
        tower.beam_mat.albedo_color.a = lerp(tower.beam_mat.albedo_color.a, 0.6, dt * 3.0)
        tower.beam_group.rotation.y += dt * 0.5
        phase2T += dt
        if phase2T > 2.6:
          ST.phase = "ending"
          ST.endT = 0.0
          tower_root.visible = false
          lantern.visible = false
          EXT.root.visible = true
          wenv.environment = env_ext
          sfx("bell", -8.0)
          print("[KTL] ending")
    return

  if ST.phase == "ending" or ST.phase == "won":
    ST.endT += dt
    EXT.beams.rotation.y += dt * 0.55
    EXT.road_mat.uv1_offset.y += dt * 0.4
    # rain rebuild
    var im = EXT.rain_mesh
    im.clear_surfaces()
    im.surface_begin(Mesh.PRIMITIVE_LINES, EXT.rain_mat)
    for i3 in EXT.rain_drops.size():
      var d3 = EXT.rain_drops[i3]
      d3.y -= dt * 26.0
      d3.x += dt * 3.6
      if d3.y < 0:
        d3 = Vector3(randf_range(-50,70), 45 + randf_range(0,4), d3.z)
      EXT.rain_drops[i3] = d3
      im.surface_add_vertex(d3)
      im.surface_add_vertex(d3 + Vector3(0.14, -1.0, 0))
    im.surface_end()
    for i5 in EXT.foam.size():
      var fma = EXT.foam[i5]
      fma.albedo_color.a = 0.10 + 0.07 * (0.5 + 0.5 * sin(t_now * 1.3 + i5 * 1.7))
    for i4 in EXT.clouds.size():
      var c3 = EXT.clouds[i4]
      c3.position.x += dt * (0.6 + i4 * 0.15)
      if c3.position.x > 110: c3.position.x = -110
    # ship
    var ba = EXT.beams.rotation.y
    var bd = Vector2(cos(ba), -sin(ba))
    var sd = Vector2(EXT.ship.position.x - 20, EXT.ship.position.z + 42)
    sd = sd.normalized() if sd.length() > 0.01 else Vector2.RIGHT
    if EXT.ship_turn == 0.0 and abs(bd.dot(sd)) > 0.994 and ST.endT > 2:
      EXT.ship_turn = 0.001
      if not EXT.belled:
        EXT.belled = true
        sfx("bell", -10.0)
    if EXT.ship_turn > 0:
      EXT.ship_turn = min(EXT.ship_turn + dt * 0.4, 1.6)
      EXT.ship.rotation.y = lerp(EXT.ship.rotation.y, -0.9, dt * 0.8)
    EXT.ship.position.x += dt * EXT.ship_vx * (1.0 - EXT.ship_turn * 0.3)
    EXT.ship.position.z += dt * EXT.ship_turn * 3.2
    EXT.ship.position.y = sin(t_now * 1.1) * 0.25
    EXT.ship.rotation.z = sin(t_now * 0.9) * 0.04
    cam.position = Vector3(sin(t_now * 0.05) * 3.0, 4.2 + sin(t_now * 0.1) * 0.5, 28)
    cam.look_at(Vector3(8, 12, -50), Vector3.UP)
    if ST.phase == "ending" and ST.endT > 6.5:
      win_run()
    return

  if ST.phase == "fail":
    return

func _notification(what):
  pass
