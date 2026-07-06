const sidebar = document.getElementById('sidebar');
const menuToggle = document.getElementById('menuToggle');
const navLinks = document.querySelectorAll('.nav-link');
const sections = document.querySelectorAll('.section');

menuToggle.addEventListener('click', () => {
  sidebar.classList.toggle('open');
  menuToggle.classList.toggle('open');
});

navLinks.forEach(link => {
  link.addEventListener('click', () => {
    sidebar.classList.remove('open');
    menuToggle.classList.remove('open');
  });
});

const observer = new IntersectionObserver(
  entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const id = entry.target.id;
        navLinks.forEach(link => {
          link.classList.toggle('active', link.getAttribute('href') === `#${id}`);
        });
      }
    });
  },
  { rootMargin: '-20% 0px -60% 0px', threshold: 0 }
);

sections.forEach(section => observer.observe(section));