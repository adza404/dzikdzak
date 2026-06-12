import*as THREE from'three';
const container=document.getElementById('canvas-container');
const scene=new THREE.Scene();
const camera=new THREE.PerspectiveCamera(60,innerWidth/innerHeight,0.1,1000);
camera.position.z=25;
const renderer=new THREE.WebGLRenderer({antialias:true,alpha:true});
renderer.setSize(innerWidth,innerHeight);
renderer.setPixelRatio(Math.min(devicePixelRatio,2));
container.appendChild(renderer.domElement);
const count=1500;
const pos=new Float32Array(count*3),col=new Float32Array(count*3);
for(let i=0;i<count;i++){pos[i*3]=(Math.random()-.5)*80;pos[i*3+1]=(Math.random()-.5)*80;pos[i*3+2]=(Math.random()-.5)*80;const b=.3+Math.random()*.4;col[i*3]=1;col[i*3+1]=b;col[i*3+2]=b*.4;}
const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.BufferAttribute(pos,3));geo.setAttribute('color',new THREE.BufferAttribute(col,3));
const mat=new THREE.PointsMaterial({size:.12,transparent:true,opacity:.8,vertexColors:true,blending:THREE.AdditiveBlending});
const particles=new THREE.Points(geo,mat);scene.add(particles);
const rings=[];const ringMat=new THREE.MeshBasicMaterial({color:0xffaa00,transparent:true,opacity:.12,wireframe:true});
for(let i=0;i<4;i++){const ring=new THREE.Mesh(new THREE.TorusGeometry(2.5+i*2.5,.04,16,64),ringMat);ring.position.set((Math.random()-.5)*12,(Math.random()-.5)*12,(Math.random()-.5)*8-5);ring.rotation.set(Math.random()*Math.PI,Math.random()*Math.PI,0);scene.add(ring);rings.push({mesh:ring,speed:.002*(i+1)});}
let mx=0,my=0;document.addEventListener('mousemove',e=>{mx=(e.clientX/innerWidth)*2-1;my=-(e.clientY/innerHeight)*2+1;});
(function loop(){requestAnimationFrame(loop);particles.rotation.y+=.0005;particles.rotation.x+=.0002;rings.forEach(k=>{k.mesh.rotation.x+=k.speed;k.mesh.rotation.y+=k.speed*1.5;});camera.position.x+=(mx*3-camera.position.x)*.02;camera.position.y+=(my*2-camera.position.y)*.02;camera.lookAt(0,0,0);renderer.render(scene,camera);})();
addEventListener('resize',()=>{camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();renderer.setSize(innerWidth,innerHeight);});