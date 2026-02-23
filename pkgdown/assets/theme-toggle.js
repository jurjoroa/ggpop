(function () {
  var STORAGE_KEY = 'ggpop-theme';
  var theme = localStorage.getItem(STORAGE_KEY) || 'light';
  document.documentElement.setAttribute('data-bs-theme', theme);

  function updateBtn(t) {
    var icon = document.querySelector('#ggpop-theme-btn .theme-icon');
    if (!icon) return;
    /* t='light' = dark mode active → show sun (click to go light)
       t='dark'  = light mode active → show moon (click to go dark) */
    icon.className = 'fa theme-icon ' + (t === 'light' ? 'fa-sun' : 'fa-moon');
  }

  function inject() {
    var navRight = document.querySelector('.navbar-nav.ms-auto')
                || document.querySelector('.navbar-right')
                || document.querySelector('.navbar-nav:last-of-type');
    if (!navRight) return;
    var li = document.createElement('li');
    li.className = 'nav-item d-flex align-items-center ms-2';
    li.innerHTML = '<button id="ggpop-theme-btn" class="theme-switch" aria-label="Toggle theme">'
      + '<span class="theme-switch-track">'
      + '<span class="theme-switch-thumb"><i class="fa theme-icon fa-sun"></i></span>'
      + '</span></button>';
    navRight.appendChild(li);
    updateBtn(theme);
    document.getElementById('ggpop-theme-btn').addEventListener('click', function () {
      var cur = document.documentElement.getAttribute('data-bs-theme');
      var next = cur === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-bs-theme', next);
      localStorage.setItem(STORAGE_KEY, next);
      updateBtn(next);
    });
  }

  document.readyState === 'loading'
    ? document.addEventListener('DOMContentLoaded', inject)
    : inject();
})();
