// Three.js 3D Scene for Dzik_Dzak Rice
// Floating rice grains + ambient particles

(function () {
  const container = document.getElementById('canvas-container');
  if (!container) return;

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(60, innerWidth / innerHeight, 0.1, 1000);
  camera.position.z = 30;

  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  renderer.setSize(innerWidth, innerHeight);
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  renderer.setClearColor(0x000000, 0);
  container.appendChild(renderer.domElement);

  // --- Ambient Particles (gold dust) ---
  const pCount = 800;
  const pPos = new Float32Array(pCount * 3);
  const pCol = new Float32Array(pCount * 3);
  for (let i = 0; i < pCount; i++) {
    pPos[i * 3] = (Math.random() - 0.5) * 60;
    pPos[i * 3 + 1] = (Math.random() - 0.5) * 60;
    pPos[i * 3 + 2] = (Math.random() - 0.5) * 40;
    const brightness = 0.5 + Math.random() * 0.5;
    pCol[i * 3] = 0.96 * brightness;     // R
    pCol[i * 3 + 1] = 0.77 * brightness; // G
    pCol[i * 3 + 2] = 0.26 * brightness; // B
  }
  const pGeo = new THREE.BufferGeometry();
  pGeo.setAttribute('position', new THREE.BufferAttribute(pPos, 3));
  pGeo.setAttribute('color', new THREE.BufferAttribute(pCol, 3));
  const pMat = new THREE.PointsMaterial({
    size: 0.08,
    transparent: true,
    opacity: 0.6,
    vertexColors: true,
    blending: THREE.AdditiveBlending,
    depthWrite: false,
  });
  const particles = new THREE.Points(pGeo, pMat);
  scene.add(particles);

  // --- Floating Rice Grain Shapes (ellipsoids) ---
  const grains = [];
  const grainMat = new THREE.MeshBasicMaterial({
    color: 0xf5e6c8,
    transparent: true,
    opacity: 0.15,
    wireframe: true,
  });

  for (let i = 0; i < 12; i++) {
    const scaleX = 0.3 + Math.random() * 0.4;
    const scaleY = 0.1 + Math.random() * 0.15;
    const scaleZ = 0.1 + Math.random() * 0.15;
    const geo = new THREE.SphereGeometry(1, 8, 6);
    const mesh = new THREE.Mesh(geo, grainMat.clone());
    mesh.scale.set(scaleX, scaleY, scaleZ);
    mesh.position.set(
      (Math.random() - 0.5) * 30,
      (Math.random() - 0.5) * 30,
      (Math.random() - 0.5) * 20 - 5
    );
    mesh.rotation.set(
      Math.random() * Math.PI,
      Math.random() * Math.PI,
      Math.random() * Math.PI
    );
    scene.add(mesh);
    grains.push({
      mesh,
      rotSpeed: {
        x: (Math.random() - 0.5) * 0.008,
        y: (Math.random() - 0.5) * 0.012,
        z: (Math.random() - 0.5) * 0.006,
      },
      floatSpeed: 0.0005 + Math.random() * 0.001,
      floatOffset: Math.random() * Math.PI * 2,
      baseY: mesh.position.y,
    });
  }

  // --- Golden Rings ---
  const rings = [];
  const ringMat = new THREE.MeshBasicMaterial({
    color: 0xf5c542,
    transparent: true,
    opacity: 0.06,
    wireframe: true,
  });
  for (let i = 0; i < 3; i++) {
    const radius = 4 + i * 4;
    const ring = new THREE.Mesh(
      new THREE.TorusGeometry(radius, 0.03, 16, 80),
      ringMat.clone()
    );
    ring.position.set(
      (Math.random() - 0.5) * 8,
      (Math.random() - 0.5) * 8,
      -5 - i * 3
    );
    ring.rotation.set(Math.random() * Math.PI, Math.random() * Math.PI, 0);
    scene.add(ring);
    rings.push({
      mesh: ring,
      speed: 0.001 + i * 0.0008,
    });
  }

  // --- Mouse tracking ---
  let mx = 0, my = 0;
  document.addEventListener('mousemove', (e) => {
    mx = (e.clientX / innerWidth) * 2 - 1;
    my = -(e.clientY / innerHeight) * 2 + 1;
  });

  // --- Animation Loop ---
  const clock = new THREE.Clock();
  (function loop() {
    requestAnimationFrame(loop);
    const t = clock.getElapsedTime();

    // Rotate particles slowly
    particles.rotation.y += 0.0003;
    particles.rotation.x += 0.0001;

    // Animate rice grains
    grains.forEach((g) => {
      g.mesh.rotation.x += g.rotSpeed.x;
      g.mesh.rotation.y += g.rotSpeed.y;
      g.mesh.rotation.z += g.rotSpeed.z;
      g.mesh.position.y = g.baseY + Math.sin(t * g.floatSpeed * 100 + g.floatOffset) * 2;
    });

    // Rotate rings
    rings.forEach((r) => {
      r.mesh.rotation.x += r.speed;
      r.mesh.rotation.y += r.speed * 1.3;
    });

    // Camera parallax
    camera.position.x += (mx * 4 - camera.position.x) * 0.015;
    camera.position.y += (my * 3 - camera.position.y) * 0.015;
    camera.lookAt(0, 0, 0);

    renderer.render(scene, camera);
  })();

  // --- Resize ---
  addEventListener('resize', () => {
    camera.aspect = innerWidth / innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(innerWidth, innerHeight);
  });
})();
