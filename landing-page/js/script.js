function copyCode(button) {
  const codeElement = button.parentElement.querySelector('code');
  navigator.clipboard.writeText(codeElement.innerText).then(() => {
    const originalText = button.innerText;
    button.innerText = 'Copiado!';
    setTimeout(() => {
      button.innerText = originalText;
    }, 1800);
  });
}

function openTab(event, tabId) {
  const panels = document.querySelectorAll('.tab-panel');
  const buttons = document.querySelectorAll('.tab-btn');

  panels.forEach((panel) => {
    panel.classList.remove('active');
  });

  buttons.forEach((btn) => {
    btn.classList.remove('active');
  });

  document.getElementById(tabId).classList.add('active');
  event.currentTarget.classList.add('active');
}