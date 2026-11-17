
const menuToggle = document.getElementById('menu-toggle');
const menuClose = document.getElementById('menu-close');
const sidebar = document.getElementById('sidebar');
const backdrop = document.getElementById('sidebar-backdrop');
const navLinks = document.querySelectorAll('.sidebar-nav a');


function toggleMenu() {
  sidebar.classList.toggle('open');
  backdrop.classList.toggle('active');
}


menuToggle.addEventListener('click', toggleMenu);


menuClose.addEventListener('click', toggleMenu);
backdrop.addEventListener('click', toggleMenu);


navLinks.forEach((link) => {
  link.addEventListener('click', () => {
    sidebar.classList.remove('open');
    backdrop.classList.remove('active');
  });
});