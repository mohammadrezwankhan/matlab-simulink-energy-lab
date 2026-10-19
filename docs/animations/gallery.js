'use strict';
// Media are loaded only after an explicit click; stopping removes the player.
for (const button of document.querySelectorAll('[data-play-image]')) {
  const preview = document.getElementById(button.getAttribute('aria-controls'));
  const placeholder = preview.firstElementChild.cloneNode(true);
  button.addEventListener('click', () => {
    if (button.getAttribute('aria-pressed') === 'true') {
      preview.replaceChildren(placeholder.cloneNode(true));
      button.setAttribute('aria-pressed', 'false');
      button.textContent = 'Play animation';
      return;
    }
    const image = document.createElement('img');
    image.alt = button.dataset.alt;
    image.src = button.dataset.playImage;
    preview.replaceChildren(image);
    button.setAttribute('aria-pressed', 'true');
    button.textContent = 'Stop animation';
  });
}
