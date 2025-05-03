document.addEventListener("DOMContentLoaded", () => {
  const root = document.documentElement;
  const buttons = document.querySelectorAll("[data-theme]");
  const toggleBtn = document.getElementById("toggleTheme");

  const savedTheme = localStorage.getItem("theme");
  if (savedTheme) {
    applyTheme(savedTheme);
  }

  buttons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const theme = btn.dataset.theme;
      applyTheme(theme);
      localStorage.setItem("theme", theme);
    });
  });

  toggleBtn.addEventListener("click", () => {
    const current = root.getAttribute("data-theme");
    const next = current === "dark" ? "light" : "dark";
    applyTheme(next);
    localStorage.setItem("theme", next);
  });

  function applyTheme(theme) {
    root.setAttribute("data-theme", theme);
    document.body.className = `theme-${theme}`;
  }
});

document.querySelectorAll('#themeControls button').forEach(btn => {
  btn.addEventListener('click', () => {
    const newTheme = btn.dataset.theme;
    document.body.className = ''; 
    document.body.classList.add(`theme-${newTheme}`);
  });
});

