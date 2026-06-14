// Three.js 3D Rice Scene — Toko Beras DZIK & DZAK
(function () {
  const container = document.getElementById('canvas-container');
  if (!container) return;

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(45, innerWidth / innerHeight, 0.1, 1000);
  camera.position.set(0, 1.5, 16);

  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  renderer.setSize(innerWidth, innerHeight);
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = 1.0;
  container.appendChild(renderer.domElement);

  // --- Lighting ---
  const ambient = new THREE.AmbientLight(0x443322, 0.5);
  scene.add(ambient);

  const keyLight = new THREE.DirectionalLight(0xffd700, 1.2);
  keyLight.position.set(8, 12, 6);
  scene.add(keyLight);

  const fillLight = new THREE.DirectionalLight(0xffaa44, 0.5);
  fillLight.position.set(-6, 4, 8);
  scene.add(fillLight);

  const rimLight = new THREE.DirectionalLight(0x4488ff, 0.15);
  rimLight.position.set(0, -6, -12);
  scene.add(rimLight);

  const spotLight = new THREE.SpotLight(0xffd700, 0.3, 30, Math.PI / 6, 0.5, 1);
  spotLight.position.set(0, 10, 0);
  spotLight.target.position.set(0, 0, 0);
  scene.add(spotLight);
  scene.add(spotLight.target);

  // --- Create Rice Grain ---
  function createRiceGrain() {
    const geo = new THREE.SphereGeometry(0.1, 6, 6);
    // scale to elongated rice grain shape (long in x, narrow in y, medium in z)
    geo.scale(1.8, 0.45, 0.7);
    const mat = new THREE.MeshPhysicalMaterial({
      color: new THREE.Color().setHSL(0.12, 0.08, 0.85 + Math.random() * 0.12),
      roughness: 0.35,
      metalness: 0.0,
      clearcoat: 0.05,
      clearcoatRoughness: 0.4,
    });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.castShadow = false;
    mesh.receiveShadow = false;
    return mesh;
  }

  // --- Rice Bowl (LatheGeometry) ---
  const pts = [];
  const steps = 20;
  // Bowl profile: sweeping from center to rim
  const profile = [
    [0.0, 0.0],
    [0.4, 0.02],
    [0.8, 0.08],
    [1.2, 0.18],
    [1.6, 0.35],
    [2.0, 0.6],
    [2.3, 0.9],
    [2.5, 1.2],
    [2.55, 1.5],
    [2.5, 1.8],
    [2.35, 2.1],
    [2.1, 2.35],
    [1.8, 2.5],
    [1.4, 2.6],
    [1.0, 2.6],
    [0.5, 2.5],
    [0.1, 2.4],
    [0.0, 2.35],
  ];
  profile.forEach((p) => pts.push(new THREE.Vector2(p[0], p[1])));

  const bowlGeo = new THREE.LatheGeometry(pts, 48);
  const bowlMat = new THREE.MeshPhysicalMaterial({
    color: 0xbb7744,
    roughness: 0.55,
    metalness: 0.15,
    clearcoat: 0.15,
    clearcoatRoughness: 0.3,
    emissive: 0x442200,
    emissiveIntensity: 0.04,
    side: THREE.DoubleSide,
  });
  const bowl = new THREE.Mesh(bowlGeo, bowlMat);
  bowl.position.y = -1.8;
  bowl.position.z = -0.2;
  scene.add(bowl);

  // --- Glow ring under bowl ---
  const glowRingMat = new THREE.MeshPhysicalMaterial({
    color: 0xffd700,
    emissive: 0xff8800,
    emissiveIntensity: 0.15,
    transparent: true,
    opacity: 0.08,
    metalness: 0.9,
    roughness: 0.1,
    side: THREE.DoubleSide,
  });
  const glowRing = new THREE.Mesh(new THREE.RingGeometry(2.5, 3.2, 48), glowRingMat);
  glowRing.position.y = -1.75;
  glowRing.rotation.x = -Math.PI / 2;
  scene.add(glowRing);

  // --- Rice Grains in Bowl ---
  const bowlGrains = [];
  for (let i = 0; i < 120; i++) {
    const grain = createRiceGrain();
    const angle = Math.random() * Math.PI * 2;
    const radius = 0.2 + Math.random() * 2.0;
    const height = 0.1 + Math.random() * 1.2;
    const xOff = Math.cos(angle) * radius * 0.85;
    const zOff = Math.sin(angle) * radius * 0.85;
    grain.position.set(xOff, -1.5 + height * 0.7, zOff - 0.2);
    grain.rotation.set(
      Math.random() * Math.PI,
      Math.random() * Math.PI,
      Math.random() * Math.PI
    );
    // Slight random scale variation
    const s = 0.8 + Math.random() * 0.6;
    grain.scale.set(s, s * 0.8, s * 0.9);
    scene.add(grain);
    bowlGrains.push({
      mesh: grain,
      angle: angle,
      radius: radius,
      height: height,
      rotSpeed: 0.003 + Math.random() * 0.006,
      phase: Math.random() * Math.PI * 2,
    });
  }

  // --- Floating Rice Grains ---
  const floatGrains = [];
  for (let i = 0; i < 50; i++) {
    const grain = createRiceGrain();
    const s = 0.7 + Math.random() * 0.8;
    grain.scale.set(s, s * 0.8, s * 0.9);
    const angle = Math.random() * Math.PI * 2;
    const radius = 2.5 + Math.random() * 5.5;
    const height = -1 + Math.random() * 4.5;
    grain.position.set(
      Math.cos(angle) * radius,
      height,
      Math.sin(angle) * radius
    );
    grain.rotation.set(Math.random() * Math.PI, Math.random() * Math.PI, 0);
    scene.add(grain);
    floatGrains.push({
      mesh: grain,
      angle: angle,
      radius: radius,
      baseHeight: height,
      orbitSpeed: 0.002 + Math.random() * 0.004,
      bobSpeed: 0.004 + Math.random() * 0.012,
      bobAmp: 0.15 + Math.random() * 0.3,
      bobPhase: Math.random() * Math.PI * 2,
      rotXSpeed: (Math.random() - 0.5) * 0.01,
      rotYSpeed: (Math.random() - 0.5) * 0.02,
    });
  }

  // --- Falling Rice Rain ---
  const fallingGrains = [];
  const FALL_COUNT = 150;
  const FALL_SPREAD = 12;
  const FALL_TOP = 12;
  const FALL_BOTTOM = -6;

  for (let i = 0; i < FALL_COUNT; i++) {
    const grain = createRiceGrain();
    const s = 0.5 + Math.random() * 0.7;
    grain.scale.set(s, s * 0.8, s * 0.9);
    grain.position.set(
      (Math.random() - 0.5) * FALL_SPREAD * 2,
      FALL_BOTTOM + Math.random() * (FALL_TOP - FALL_BOTTOM),
      (Math.random() - 0.5) * FALL_SPREAD * 2
    );
    grain.rotation.set(
      Math.random() * Math.PI * 2,
      Math.random() * Math.PI * 2,
      Math.random() * Math.PI * 2
    );
    scene.add(grain);
    fallingGrains.push({
      mesh: grain,
      speed: 0.02 + Math.random() * 0.045,
      rotXSpeed: (Math.random() - 0.5) * 0.04,
      rotYSpeed: (Math.random() - 0.5) * 0.06,
      rotZSpeed: (Math.random() - 0.5) * 0.03,
      swingAmp: 0.2 + Math.random() * 0.6,
      swingFreq: 0.3 + Math.random() * 0.6,
      swingPhase: Math.random() * Math.PI * 2,
    });
  }

  // --- Orbital Rings ---
  function createOrbitRing(radius, y, opacity, color) {
    const mat = new THREE.MeshPhysicalMaterial({
      color: color || 0xffd700,
      emissive: 0xff8800,
      emissiveIntensity: 0.05,
      transparent: true,
      opacity: opacity || 0.1,
      metalness: 0.6,
      roughness: 0.3,
      side: THREE.DoubleSide,
    });
    const mesh = new THREE.Mesh(new THREE.TorusGeometry(radius, 0.025, 8, 64), mat);
    mesh.position.y = y;
    return mesh;
  }

  const orbitRings = [];
  const ringConfigs = [
    { r: 3.5, y: 0.0, o: 0.08, tiltX: 0.4, tiltZ: 0.2, speed: 0.004 },
    { r: 5.0, y: 1.2, o: 0.06, tiltX: -0.3, tiltZ: 0.5, speed: -0.003 },
    { r: 2.5, y: 2.5, o: 0.05, tiltX: 0.6, tiltZ: -0.3, speed: 0.005 },
    { r: 4.2, y: -0.8, o: 0.04, tiltX: -0.5, tiltZ: 0.1, speed: -0.002 },
  ];
  ringConfigs.forEach((cfg) => {
    const ring = createOrbitRing(cfg.r, cfg.y, cfg.o);
    ring.rotation.x = cfg.tiltX;
    ring.rotation.z = cfg.tiltZ;
    scene.add(ring);
    orbitRings.push({ mesh: ring, speed: cfg.speed });
  });

  // --- Particle System (golden dust) ---
  const pCount = 2500;
  const pos = new Float32Array(pCount * 3);
  const col = new Float32Array(pCount * 3);
  const sizes = new Float32Array(pCount);
  const pVelocities = [];

  for (let i = 0; i < pCount; i++) {
    const radius = 0.5 + Math.random() * 18;
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.acos(2 * Math.random() - 1);
    pos[i * 3] = Math.sin(phi) * Math.cos(theta) * radius;
    pos[i * 3 + 1] = (Math.random() - 0.5) * 12;
    pos[i * 3 + 2] = Math.sin(phi) * Math.sin(theta) * radius;

    sizes[i] = 0.02 + Math.random() * 0.08;

    const t = Math.random();
    col[i * 3] = 1.0;
    col[i * 3 + 1] = 0.5 + t * 0.5;
    col[i * 3 + 2] = 0.1 + t * 0.3;

    pVelocities.push({
      x: (Math.random() - 0.5) * 0.002,
      y: (Math.random() - 0.5) * 0.001,
      z: (Math.random() - 0.5) * 0.002,
    });
  }

  const pGeo = new THREE.BufferGeometry();
  pGeo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  pGeo.setAttribute('color', new THREE.BufferAttribute(col, 3));
  pGeo.setAttribute('size', new THREE.BufferAttribute(sizes, 1));

  const pMat = new THREE.PointsMaterial({
    size: 0.04,
    transparent: true,
    opacity: 0.5,
    vertexColors: true,
    blending: THREE.AdditiveBlending,
    depthWrite: false,
    sizeAttenuation: true,
  });
  const particles = new THREE.Points(pGeo, pMat);
  scene.add(particles);

  // --- Stored refs for animation ---
  const pPos = particles.geometry.attributes.position.array;

  // --- Mouse ---
  let mx = 0, my = 0;
  let tx = 0, ty = 0;
  document.addEventListener('mousemove', (e) => {
    tx = (e.clientX / innerWidth) * 2 - 1;
    ty = -(e.clientY / innerHeight) * 2 + 1;
  });

  let time = 0;

  // --- Animation Loop ---
  (function loop() {
    requestAnimationFrame(loop);
    time += 0.008;

    // Smooth mouse
    mx += (tx - mx) * 0.025;
    my += (ty - my) * 0.025;

    // Particles slow rotation & drift
    particles.rotation.y += 0.0006;
    particles.rotation.x += 0.0002;

    // Animate individual particle positions for gentle floating
    for (let i = 0; i < pCount; i++) {
      pPos[i * 3] += pVelocities[i].x;
      pPos[i * 3 + 1] += pVelocities[i].y + Math.sin(time + i) * 0.0002;
      pPos[i * 3 + 2] += pVelocities[i].z;
    }
    particles.geometry.attributes.position.needsUpdate = true;

    // Orbit rings rotation
    orbitRings.forEach((r) => {
      r.mesh.rotation.z += r.speed;
    });

    // Glow ring pulse
    glowRing.material.opacity = 0.06 + Math.sin(time * 1.5) * 0.025;
    glowRing.scale.setScalar(1 + Math.sin(time * 1.2) * 0.02);

    // Bowl grains — gentle sway
    bowlGrains.forEach((g) => {
      g.mesh.rotation.x += g.rotSpeed * 0.5;
      g.mesh.rotation.y += g.rotSpeed;
      g.mesh.rotation.z += g.rotSpeed * 0.3;
    });

    // Floating grains orbit + bob
    floatGrains.forEach((g) => {
      g.angle += g.orbitSpeed;
      const bob = Math.sin(time * g.bobSpeed + g.bobPhase) * g.bobAmp;
      g.mesh.position.x = Math.cos(g.angle) * g.radius;
      g.mesh.position.z = Math.sin(g.angle) * g.radius;
      g.mesh.position.y = g.baseHeight + bob;
      g.mesh.rotation.x += g.rotXSpeed;
      g.mesh.rotation.y += g.rotYSpeed;
    });

    // Falling rice rain
    fallingGrains.forEach((g) => {
      g.mesh.position.y -= g.speed;
      g.mesh.position.x += Math.sin(time * g.swingFreq + g.swingPhase) * g.swingAmp * 0.004;
      g.mesh.position.z += Math.cos(time * g.swingFreq * 0.7 + g.swingPhase) * g.swingAmp * 0.003;
      g.mesh.rotation.x += g.rotXSpeed;
      g.mesh.rotation.y += g.rotYSpeed;
      g.mesh.rotation.z += g.rotZSpeed;

      // Reset to top when below bottom
      if (g.mesh.position.y < FALL_BOTTOM) {
        g.mesh.position.y = FALL_TOP + Math.random() * 3;
        g.mesh.position.x = (Math.random() - 0.5) * FALL_SPREAD * 2;
        g.mesh.position.z = (Math.random() - 0.5) * FALL_SPREAD * 2;
      }
    });

    // Camera position based on mouse
    const camX = mx * 2.5;
    const camY = my * 1.8 + 1.5;
    camera.position.x += (camX - camera.position.x) * 0.015;
    camera.position.y += (camY - camera.position.y) * 0.015;
    camera.lookAt(0, 0.5, 0);

    renderer.render(scene, camera);
  })();

  // --- Resize ---
  addEventListener('resize', () => {
    camera.aspect = innerWidth / innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(innerWidth, innerHeight);
  });
})();
