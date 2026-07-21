document.addEventListener("DOMContentLoaded", () => {
    
    // --- 1. Custom Magnetic Cursor ---
    const cursorDot = document.querySelector('.cursor-dot');
    const cursorRing = document.querySelector('.cursor-ring');
    const interactives = document.querySelectorAll('.interactive');

    let mouseX = 0, mouseY = 0;
    let ringX = 0, ringY = 0;

    window.addEventListener('mousemove', (e) => {
        mouseX = e.clientX;
        mouseY = e.clientY;
        
        // Immediate dot follow
        cursorDot.style.left = `${mouseX}px`;
        cursorDot.style.top = `${mouseY}px`;
    });

    // Smooth ring follow loop
    function renderCursor() {
        ringX += (mouseX - ringX) * 0.09;
        ringY += (mouseY - ringY) * 0.09;
        
        cursorRing.style.left = `${ringX}px`;
        cursorRing.style.top = `${ringY}px`;
        
        requestAnimationFrame(renderCursor);
    }
    renderCursor();

    // Hover states
    interactives.forEach(el => {
        el.addEventListener('mouseenter', () => {
            const cursorType = el.getAttribute('data-cursor');
            document.body.classList.add(`cursor-${cursorType}`);
        });
        el.addEventListener('mouseleave', () => {
            const cursorType = el.getAttribute('data-cursor');
            document.body.classList.remove(`cursor-${cursorType}`);
        });
    });


    // --- 2. Live Canvas Particles (Magical Embers) ---
    const canvas = document.getElementById("mystical-canvas");
    const ctx = canvas.getContext("2d");
    
    let width, height;
    function resize() {
        width = window.innerWidth;
        height = window.innerHeight;
        canvas.width = width;
        canvas.height = height;
    }
    window.addEventListener("resize", resize);
    resize();

    const particles = [];
    const particleCount = 120;

    class Particle {
        constructor() {
            this.reset();
            this.y = Math.random() * height; // initial random placement
        }
        
        reset() {
            this.x = Math.random() * width;
            this.y = height + 10;
            this.size = Math.random() * 2 + 0.5;
            this.speed = Math.random() * 1.5 + 0.5;
            this.angle = Math.random() * 360;
            this.spin = (Math.random() - 0.5) * 0.02;
            // Orange/Gold embers
            this.color = `rgba(255, ${100 + Math.random() * 100}, 0, ${Math.random() * 0.6 + 0.2})`;
        }

        update() {
            this.y -= this.speed;
            this.angle += this.spin;
            this.x += Math.sin(this.angle) * 0.5;

            // Mouse repulsion
            let dx = mouseX - this.x;
            let dy = mouseY - this.y;
            let dist = Math.sqrt(dx*dx + dy*dy);
            if (dist < 150) {
                this.x -= dx * 0.02;
                this.y -= dy * 0.02;
            }

            if (this.y < -10) this.reset();

            ctx.fillStyle = this.color;
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            ctx.fill();
        }
    }

    for (let i = 0; i < particleCount; i++) particles.push(new Particle());

    function animateParticles() {
        ctx.clearRect(0, 0, width, height);
        particles.forEach(p => p.update());
        requestAnimationFrame(animateParticles);
    }
    animateParticles();


    // --- 3. GSAP Animations & ScrollTrigger ---
    gsap.registerPlugin(ScrollTrigger);

    // Parallax background layers
    gsap.utils.toArray('.parallax-bg').forEach(layer => {
        const speed = layer.getAttribute('data-speed');
        gsap.to(layer, {
            y: (i, target) => -ScrollTrigger.maxScroll(window) * target.dataset.speed,
            ease: "none",
            scrollTrigger: {
                trigger: "body",
                start: "top top",
                end: "bottom bottom",
                scrub: 1
            }
        });
    });

    // Hero Reveals
    gsap.from(".reveal-text", {
        y: 100,
        opacity: 0,
        duration: 1.2,
        stagger: 0.2,
        ease: "power4.out",
        delay: 0.2
    });

    gsap.from(".reveal-fade", {
        opacity: 0,
        y: 30,
        duration: 1,
        stagger: 0.3,
        ease: "power2.out",
        delay: 0.8
    });

    // Scroll Reveals for Sections
    gsap.utils.toArray('.reveal-up').forEach(elem => {
        gsap.from(elem, {
            scrollTrigger: {
                trigger: elem,
                start: "top 85%",
            },
            y: 50,
            opacity: 0,
            duration: 1,
            ease: "power3.out"
        });
    });

    // Staggered Cards
    gsap.from(".feature-card", {
        scrollTrigger: {
            trigger: ".feature-grid",
            start: "top 90%"
        },
        y: 60,
        opacity: 0,
        duration: 0.8,
        stagger: 0.15,
        ease: "power2.out",
        immediateRender: false
    });

    gsap.from(".ai-node", {
        scrollTrigger: {
            trigger: ".ai-nodes-container",
            start: "top 90%"
        },
        scale: 0.8,
        opacity: 0,
        duration: 0.6,
        stagger: 0.1,
        ease: "power2.out",
        immediateRender: false
    });

    // AI Node Expansion Logic
    document.querySelectorAll('.ai-node').forEach(node => {
        node.addEventListener('click', () => {
            const isExpanded = node.classList.contains('expanded');
            
            // Close all nodes
            document.querySelectorAll('.ai-node').forEach(n => n.classList.remove('expanded'));
            
            // If it wasn't already expanded, open it
            if (!isExpanded) {
                node.classList.add('expanded');
                // Optional: Scroll slightly into view if it expands out of bounds
                setTimeout(() => {
                    const rect = node.getBoundingClientRect();
                    if (rect.bottom > window.innerHeight) {
                        window.scrollBy({ top: rect.bottom - window.innerHeight + 40, behavior: 'smooth' });
                    }
                }, 300);
            }
        });
    });
});
